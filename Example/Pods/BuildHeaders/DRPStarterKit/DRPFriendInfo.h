//
//  DRPFriendInfo.h
//  Comment Box
//
//  Created by Jason Ederle on 6/29/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DRPFriendInfo : NSObject
@property (strong, nonatomic) NSString *friendId;
@property (strong, nonatomic) NSString *friendIdType;

- (id)initWithFriendId:(NSString *)friendId type:(NSString *)friendIdType;

@end
