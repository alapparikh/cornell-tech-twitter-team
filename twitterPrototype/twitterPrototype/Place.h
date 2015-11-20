//
//  Place.h
//  twitterPrototype
//
//  Created by Alap Parikh on 11/19/15.
//  Copyright © 2015 Alap Parikh. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Place : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *placeId;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *longitude;
@property (nonatomic, copy) NSString *name;

@end
