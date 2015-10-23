//
//  Tweet.h
//  twitterPrototype
//
//  Created by Alap Parikh on 10/23/15.
//  Copyright © 2015 Alap Parikh. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "TweetUser.h"
#import "TweetPlace.h"

@interface Tweet : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *tweetId;
@property (nonatomic, copy) NSNumber *favoriteCount;
@property (nonatomic, copy) NSNumber *retweetCount;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *createdAt;
//@property (nonatomic, copy) TweetPlace *placeDict;
//@property (nonatomic, copy) TweetUser *userDict;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *twitterHandle;
@property (nonatomic, copy) NSString *profileImage;

@end

