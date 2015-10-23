//
//  TweetViewCell.h
//  twitterPrototype
//
//  Created by Alap Parikh on 10/23/15.
//  Copyright © 2015 Alap Parikh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, weak) IBOutlet UILabel *twitterHandle;
@property (nonatomic, weak) IBOutlet UIImageView *profileImage;
@property (nonatomic, weak) IBOutlet UILabel *time;
@property (nonatomic, weak) IBOutlet UILabel *content;
@property (nonatomic, weak) IBOutlet UILabel *favoriteCount;
@property (nonatomic, weak) IBOutlet UILabel *retweetCount;

@end
