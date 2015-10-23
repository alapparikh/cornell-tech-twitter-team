//
//  TweetPlace.h
//  twitterPrototype
//
//  Created by Alap Parikh on 10/23/15.
//  Copyright © 2015 Alap Parikh. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface TweetPlace : MTLModel <MTLJSONSerializing>

@property (nonatomic) NSString *country;

@end
