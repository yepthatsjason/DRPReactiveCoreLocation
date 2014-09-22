// Copyright Jason Ederle. All Rights Reserved.

#import "DRPMemModelCacheObjectProtocol.h"

@protocol DRPMemModelCacheObserverProtocol;

typedef void (^mem_model_set_block_t)();
typedef void (^mem_model_object_handler_t)(id<DRPMemModelCacheObjectProtocol> newObject);
typedef void (^mem_model_save_callback_t)(id<DRPMemModelCacheObjectProtocol> newObject, NSError *error);

typedef enum {
  kDRPMemModelCacheUpdateStyleUnknown = -1,
  kDRPMemModelCacheUpdateStyleDefault,                  // Notify observers object changed
  kDRPMemModelCacheUpdateStyleOptimistic                // Optimistic cache update
} DRPMemModelCacheUpdateStyle;

@interface DRPMemModelCache : NSObject

// this class is a singlton and should only be accessed through this method
+ (id)sharedMemModelCache;

// store object and notify clients only if all operations are successful
- (void)updateCacheObject:(id<DRPMemModelCacheObjectProtocol>)memObject;

// update cache with array of id<DRPMemModelCacheObjectProtocol> objects
- (void)updateCacheObjects:(NSArray*)memObjectArray cacheUpdateStyle:(DRPMemModelCacheUpdateStyle)style;

// update an object where the style determines the type of sync that happens between client and server.
// adjusting the style flag can give optimistic behavior or robust save operations
// where demands are different for certain operations. Cancel pending value is ignored for kFBBMemModelCacheUpdateStyleNoNetworkSave
- (void)updateCacheObject:(id<DRPMemModelCacheObjectProtocol>)memObject
           previousObject:(id<DRPMemModelCacheObjectProtocol>)previousMemObject
         cacheUpdateStyle:(DRPMemModelCacheUpdateStyle)style
                  success:(mem_model_object_handler_t)successHandler
                  failure:(mem_model_object_handler_t)failHandler;

// get notified when a cached object is updated
- (void)watchCacheObjectForChanges:(id<DRPMemModelCacheObjectProtocol>)memObject
                          observer:(id<DRPMemModelCacheObserverProtocol>)observer;

// get notified when any of the memObjects are updated
- (void)watchCacheObjectsForChanges:(NSArray *)memObjects
                          observer:(id<DRPMemModelCacheObserverProtocol>)observer;

// stop getting notifications for a specific object
- (void)unregisterCachedObject:(id<DRPMemModelCacheObjectProtocol>)memObject
                      observer:(id<DRPMemModelCacheObserverProtocol>)observer;

// stop getting notifications for an array of objects
- (void)unregisterCachedObjects:(NSArray *)memObjects
                       observer:(id<DRPMemModelCacheObserverProtocol>)observer;

// unregister an observer from all object changes
- (void)unregisterWatcher:(id<DRPMemModelCacheObserverProtocol>)observer;

@end


@protocol DRPMemModelCacheObserverProtocol <NSObject>

// callback when object has changed values
- (void)cachedObjectDidChange:(id<DRPMemModelCacheObjectProtocol>)memObject;

@optional

// callback when an optimistic cache update happens (meaning not offically saved to a persistent store yet)
- (void)cachedObjectDidOptimisticallyChange:(id<DRPMemModelCacheObjectProtocol>)memObject;

@end
