//
//  DRPGoogleURLShortner.m
//  Atmosphere
//
//  Created by Jason Ederle on 9/30/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import "DRPGoogleURLShortner.h"
#import <AFNetworking/AFNetworking.h>
#import "DRPLogging.h"
#import "DRPError.h"

static NSString * const kGoogleApiURLFormat = @"https://www.googleapis.com/urlshortener/v1/url?fields=id&key=%@";

@interface DRPGoogleURLShortner ()
{
  NSString *_apiKey;
}
@end

@implementation DRPGoogleURLShortner

- (id)initWithGoogleAPIKey:(NSString *)apiKey
{
  self = [super init];
  if (self) {
    _apiKey = apiKey;
  }
  return self;
}

- (void)shortnedURL:(NSURL *)longURL handler:(shortned_url_handler)callback
{
  if (!longURL) {
    callback(nil, DRPMakeError(kDRPErrorInvalidArgument, @"Can't shorten nil URL"));
    return;
  }
  
  NSString *apiStringURL = [NSString stringWithFormat:kGoogleApiURLFormat, _apiKey];
  NSDictionary *params = @{
                           @"longUrl" : [longURL description]
                           };
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  manager.requestSerializer = [AFJSONRequestSerializer serializer];
  manager.responseSerializer = [AFJSONResponseSerializer serializer];
  
  [manager POST:apiStringURL parameters:params success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
    callback([NSURL URLWithString:responseObject[@"id"]], nil);
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    callback(nil, error);
  }];
}

@end
