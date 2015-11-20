//
//  Place.m
//  twitterPrototype
//
//  Created by Alap Parikh on 11/19/15.
//  Copyright © 2015 Alap Parikh. All rights reserved.
//

#import "Place.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"

@implementation Place

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
             @"placeId": @"place_id",
             @"latitude": @"geometry",
             @"longitude": @"geometry",
             @"name": @"name",
             };
}

+ (NSValueTransformer *) latitudeJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSDictionary *dict) {
        //NSDictionary *userInfo = [values firstObject];
        return dict[@"location"][@"lat"];
    } reverseBlock:^(NSString *str) {
        return @{@"location" : str};
    }];
}


@end
