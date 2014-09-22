//
//  DRPFriendInfo.m
//  Comment Box
//
//  Created by Jason Ederle on 6/29/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPFriendInfo.h"

@implementation DRPFriendInfo

- (id)initWithFriendId:(NSString *)friendId type:(NSString *)friendIdType
{
  self = [super init];
  if (self) {
    _friendId = friendId;
    _friendIdType = friendIdType;
  }
  return self;
}

@end
