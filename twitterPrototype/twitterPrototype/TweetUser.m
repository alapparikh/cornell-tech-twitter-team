//
//  TweetUser.m
//  twitterPrototype
//
//  Created by Alap Parikh on 10/23/15.
//  Copyright © 2015 Alap Parikh. All rights reserved.
//

#import "TweetUser.h"

@implementation TweetUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    // model_property_name : json_field_name
    return @{
             @"screenName" : @"screen_name",
             @"name" : @"name",
             @"profileImage": @"profile_image_url_https"
             };
}


@end
