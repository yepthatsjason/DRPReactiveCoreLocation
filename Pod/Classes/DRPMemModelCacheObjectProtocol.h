
#import <Foundation/Foundation.h>

// Copyright Jason Ederle. All Rights Reserved.
@protocol DRPMemModelCacheObjectProtocol;

// basic protocol objects must conform to in order to be tracked by DRPMemModelCache
@protocol DRPMemModelCacheObjectProtocol <NSObject>

// identifer for this object, ex: a database key for a user
- (NSString*)objectId;

@end
