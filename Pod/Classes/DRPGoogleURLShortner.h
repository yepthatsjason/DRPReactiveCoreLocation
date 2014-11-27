//
//  DRPGoogleURLShortner.h
//  Atmosphere
//
//  Created by Jason Ederle on 9/30/14.
//  Copyright (c) 2014 Jason Ederle. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^shortned_url_handler)(NSURL *shortenedURL, NSError *error);

// This class uses the Google URL Shortner API to create small URL's
@interface DRPGoogleURLShortner : NSObject

- (id)initWithGoogleAPIKey:(NSString *)apiKey;

- (void)shortnedURL:(NSURL *)longURL handler:(shortned_url_handler)callback;

@end
