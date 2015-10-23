//
//  TweetPlace.m
//  twitterPrototype
//
//  Created by Alap Parikh on 10/23/15.
//  Copyright © 2015 Alap Parikh. All rights reserved.
//

#import "TweetPlace.h"

@implementation TweetPlace

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    // model_property_name : json_field_name
    return @{
             @"country" : @"country",
             };
}

@end
