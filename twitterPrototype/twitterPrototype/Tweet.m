//
//  Tweet.m
//  twitterPrototype
//
//  Created by Alap Parikh on 10/23/15.
//  Copyright © 2015 Alap Parikh. All rights reserved.
//

#import "Tweet.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"

@implementation Tweet

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
               @"tweetId": @"id_str",
               @"favoriteCount": @"favorite_count",
               @"retweetCount": @"retweet_count",
               @"content": @"text",
               @"createdAt": @"created_at",
               @"name": @"user",
               @"twitterHandle": @"user",
               @"profileImage": @"user"
               };
}

+ (NSValueTransformer *)userDictJSONTransformer
{
    // tell Mantle to populate userDict property with an array of TweetUser objects
   // return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[TweetUser class]];
    return [MTLJSONAdapter arrayTransformerWithModelClass:[TweetUser class]];
}

+ (NSValueTransformer *)placeDictJSONTransformer
{
    // tell Mantle to populate placeDict property with an array of TweetPlace objects
    //return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:[TweetPlace class]];
    return [MTLJSONAdapter arrayTransformerWithModelClass:[TweetPlace class]];
}

//+ (NSDateFormatter*)dateFormatter {
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"yyyy-MM-dd";
//    return dateFormatter;
//}
//
//+ (NSValueTransformer *)createdAtJSONTransformer {
//    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
//        return [self.dateFormatter dateFromString:str];
//    } reverseBlock:^(NSDate *date) {
//        return [self.dateFormatter stringFromDate:date];
//    }];
//    
//}

+ (NSValueTransformer *) nameJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSDictionary *dict) {
        //NSDictionary *userInfo = [values firstObject];
        return dict[@"name"];
    } reverseBlock:^(NSString *str) {
        return @{@"name" : str};
    }];
}

+ (NSValueTransformer *) profileImageJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSDictionary *dict) {
        //NSDictionary *userInfo = [values firstObject];
        return dict[@"profile_image_url_https"];
    } reverseBlock:^(NSString *str) {
        return @{@"profile_image_url_https" : str};
    }];
}

+ (NSValueTransformer *) twitterHandleJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSDictionary *dict) {
        //NSDictionary *userInfo = [values firstObject];
        return dict[@"screen_name"];
    } reverseBlock:^(NSString *str) {
        return @{@"screen_name" : str};
    }];
}


@end
