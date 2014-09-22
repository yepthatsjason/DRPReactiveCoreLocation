// Copyright Jason Ederle. All Rights Reserved.

#import "DRPMemModelCache.h"
#import "DRPLogging.h"

typedef void (^mem_model_save_handler_t)(BOOL successful, id<DRPMemModelCacheObjectProtocol> newCacheObject);

#define kDRPDefaultMemModelCacheUpdateStyle kDRPMemModelCacheUpdateStyleDefault
@interface DRPMemModelCache () {
  NSMutableDictionary *_registeredObservers;
  dispatch_queue_t _workQueue;
}
@end

@implementation DRPMemModelCache

+ (id)sharedMemModelCache
{
  static dispatch_once_t onceToken;
  static DRPMemModelCache *cache = nil;
  dispatch_once(&onceToken, ^{
    cache = [[DRPMemModelCache alloc] init];
  });
  return cache;
}

- (id)init
{
  self = [super init];
  if (self) {
    _registeredObservers = [NSMutableDictionary dictionary];
    _workQueue = dispatch_queue_create("com.facebook.memModelCache", NULL);
  }
  return self;
}

// update cache with array of id<DRPMemModelCacheObjectProtocol> objects
- (void)updateCacheObjects:(NSArray*)memObjectArray cacheUpdateStyle:(DRPMemModelCacheUpdateStyle)style
{
  DRPAssertIsMainThread();

  for (id<DRPMemModelCacheObjectProtocol> aObject in memObjectArray) {
    [self updateCacheObject:aObject
             previousObject:nil
           cacheUpdateStyle:style
                    success:nil
                    failure:nil];
  }
}

// store a new cached object
- (void)updateCacheObject:(id<DRPMemModelCacheObjectProtocol>)memObject
{
  DRPAssertIsMainThread();
  
  [self updateCacheObject:memObject
           previousObject:nil
         cacheUpdateStyle:kDRPDefaultMemModelCacheUpdateStyle
                  success:nil
                  failure:nil];
}

// update an object where the style determines the type of sync that happens.
// adjusting the style flag can give optimistic behavior or robust save operations
// where demands are different for certain operations.
- (void)updateCacheObject:(id<DRPMemModelCacheObjectProtocol>)memObject
           previousObject:(id<DRPMemModelCacheObjectProtocol>)previousMemObject
         cacheUpdateStyle:(DRPMemModelCacheUpdateStyle)style
                  success:(mem_model_object_handler_t)successHandler
                  failure:(mem_model_object_handler_t)failHandler
{
  DRPAssertIsMainThread();

  dispatch_async(_workQueue, ^{
    // update the cache and notify client differently based on style flag
    if (style == kDRPMemModelCacheUpdateStyleDefault) {
      [self updateCacheObjectSync:memObject
                   previousObject:previousMemObject
                          success:successHandler
                          failure:failHandler];
    } else if (style == kDRPMemModelCacheUpdateStyleOptimistic) {
      [self updateCacheObjectOptimistically:memObject
                             previousObject:previousMemObject
                                    success:successHandler
                                    failure:failHandler];
    }
  });
}

// notify clients of the optimistic value change
- (void)updateCacheObjectOptimistically:(id<DRPMemModelCacheObjectProtocol>)memObject
                         previousObject:(id<DRPMemModelCacheObjectProtocol>)previousMemObject
                                success:(mem_model_object_handler_t)successHandler
                                failure:(mem_model_object_handler_t)failHandler
{
  [self notifyObserversObjectChanged:memObject optimistic:YES];
}

// notify clients of the new changed object value
- (void)updateCacheObjectNoNetwork:(id<DRPMemModelCacheObjectProtocol>)memObject
                    previousObject:(id<DRPMemModelCacheObjectProtocol>)previousMemObject
                           success:(mem_model_object_handler_t)successHandler
                           failure:(mem_model_object_handler_t)failHandler
{
  [self notifyObserversObjectChanged:memObject optimistic:NO];
}

// save object to server then notify clients if successful
- (void)updateCacheObjectSync:(id<DRPMemModelCacheObjectProtocol>)memObject
               previousObject:(id<DRPMemModelCacheObjectProtocol>)previousMemObject
                      success:(mem_model_object_handler_t)successHandler
                      failure:(mem_model_object_handler_t)failHandler
{
  id<DRPMemModelCacheObjectProtocol> latestMemObject = memObject;
  
  [self notifyObserversObjectChanged:latestMemObject optimistic:NO];
  
  if (successHandler) {
    dispatch_async(dispatch_get_main_queue(), ^{
      successHandler(latestMemObject);
    });
  }
}

- (void)notifyObserversObjectChanged:(id<DRPMemModelCacheObjectProtocol>)newObject optimistic:(BOOL)isOptimistic
{
  if (!newObject || ![newObject objectId]) {
    return;
  }
  
  // notify clients that object changed
  NSHashTable *observers = [_registeredObservers objectForKey:[newObject objectId]];
  
  if (observers && observers.count) {
    // deliver new object to all registered clients from main thread
    for (id<DRPMemModelCacheObserverProtocol> aObserver in observers) {
      dispatch_async(dispatch_get_main_queue(), ^{
        if (isOptimistic) {
          if ([aObserver respondsToSelector:@selector(cachedObjectDidOptimisticallyChange:)]) {
            [aObserver cachedObjectDidOptimisticallyChange:newObject];
          }
        } else {
          [aObserver cachedObjectDidChange:newObject];
        }
      });
    }
  }
}

// get notified when a cached object changes
- (void)watchCacheObjectForChanges:(id<DRPMemModelCacheObjectProtocol>)memObject
                          observer:(id<DRPMemModelCacheObserverProtocol>)observer
{
  DRPAssertIsMainThread();
  DRPRequireAndReturn(memObject, kDRPLogError, @"Can't watch nil cache object");
  DRPRequireAndReturn([memObject objectId], kDRPLogError, @"Can't watch item without objectId");
  DRPRequireAndReturn(observer, kDRPLogError, @"Can't watch object with nil observer");

  dispatch_async(_workQueue, ^{
    NSHashTable *observers = nil;
    
    observers = [_registeredObservers objectForKey:[memObject objectId]];
    
    if (!observers) {
      observers = [NSHashTable weakObjectsHashTable];
      [_registeredObservers setObject:observers forKey:[memObject objectId]];
    }
    
    [observers addObject:observer];
  });
}

// get notified when any of the memObjects are updated
- (void)watchCacheObjectsForChanges:(NSArray *)memObjects
                           observer:(id<DRPMemModelCacheObserverProtocol>)observer
{
  DRPAssertIsMainThread();
  DRPRequireAndReturn(memObjects, kDRPLogError, @"Can't watch nil cache objects");
  DRPRequireAndReturn(observer, kDRPLogError, @"Can't watch objects with nil overserver");
  
  // push everything onto the background queue, this doesn't need to be immediate
  for (id<DRPMemModelCacheObjectProtocol> memObject in memObjects) {
    [self watchCacheObjectForChanges:memObject observer:observer];
  }
}

// stop getting notifications for a specific object
- (void)unregisterCachedObject:(id<DRPMemModelCacheObjectProtocol>)memObject
                      observer:(id<DRPMemModelCacheObserverProtocol>)observer
{
  DRPAssertIsMainThread();
  DRPRequireAndReturn(memObject, kDRPLogError, @"Can't unregister from nil object");
  DRPRequireAndReturn(observer, kDRPLogError, @"Can't unregister nil observer");
  
  dispatch_sync(_workQueue, ^{
    NSHashTable *observers = [_registeredObservers objectForKey:[memObject objectId]];
    if (observers) {
      [observers removeObject:observer];
    }
  });
}

// stop getting notifications for an array of objects
- (void)unregisterCachedObjects:(NSArray *)memObjects
                      observer:(id<DRPMemModelCacheObserverProtocol>)observer
{
  DRPAssertIsMainThread();
  DRPRequireAndReturn(memObjects, kDRPLogError, @"Can't unregister from nil objects");
  DRPRequireAndReturn(observer, kDRPLogError, @"Can't unregister nil observer");
  
  dispatch_sync(_workQueue, ^{
    for (id<DRPMemModelCacheObjectProtocol> memObject in memObjects) {
      NSHashTable *observers = [_registeredObservers objectForKey:[memObject objectId]];
      if (observers) {
        [observers removeObject:observer];
      }
    }
  });
}

// unregister an observer from all object changes
- (void)unregisterWatcher:(id<DRPMemModelCacheObserverProtocol>)observer
{
  DRPAssertIsMainThread();
  DRPRequireAndReturn(observer, kDRPLogError, @"Can't unregister nil cache observer");
  
  dispatch_sync(_workQueue, ^{
    for (NSHashTable *objectObservers in [_registeredObservers allValues]) {
      [objectObservers removeObject:observer];
    }
  });
}

@end
