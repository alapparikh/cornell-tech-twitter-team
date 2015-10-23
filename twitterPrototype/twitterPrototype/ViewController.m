//
//  ViewController.m
//  twitterPrototype
//
//  Created by Alap Parikh on 10/21/15.
//  Copyright © 2015 Alap Parikh. All rights reserved.
//

#import "ViewController.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AFNetworking.h"
#import <Mantle/Mantle.h>
#import "Tweet.h"
#import "TweetViewCell.h"
#import <Toast/UIView+Toast.h>
@import GoogleMaps;

@interface ViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tweetsTableView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UIButton *exploreButton;
@end

@implementation ViewController {
    GMSPlacePicker *_placePicker;
    CLLocationManager *locationManager;
    CLLocationCoordinate2D center;
    CLLocationCoordinate2D northEast;
    CLLocationCoordinate2D southWest;
    
    NSString *placeName;
    NSMutableArray *latestTweetSet;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:(172/255.0) blue:(237/255.0) alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    // User location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestAlwaysAuthorization];
    locationManager.distanceFilter = 100; // updates triggered every 100 m
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    // Allocate array
    latestTweetSet = [[NSMutableArray alloc] init];
    
    // Table View
    [self.tweetsTableView setDataSource:self];
    [self.tweetsTableView setDelegate:self];
}

- (IBAction)onExploreButtonPressed:(id)sender {
    
    NSLog(@"Launch Google Place Picker");
    GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:northEast
                                                                         coordinate:southWest];
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
    _placePicker = [[GMSPlacePicker alloc] initWithConfig:config];
    
    [_placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Pick Place error %@", [error localizedDescription]);
            return;
        }
        
        if (place != nil) {
            NSLog(@"Place name %@", place.name);
            NSLog(@"Place address %@", place.formattedAddress);
            NSLog(@"Place attributions %@", place.attributions.string);
            placeName = [place.name stringByReplacingOccurrencesOfString:@" " withString:@""];
            [self sendGETRequest];
        } else {
            NSLog(@"No place selected");
        }
    }];

}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

// Updates instance variables containing location coordinates
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations
{
    NSLog(@"didUpdateLocations: %@", [locations lastObject]);
    CLLocation *currentLocation = [locations lastObject];
    
    NSDate* eventDate = currentLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 15.0) {
        
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              currentLocation.coordinate.latitude,
              currentLocation.coordinate.longitude);
        center = currentLocation.coordinate;
        northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001);
        southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001);
    }
    
//    [locationManager stopUpdatingLocation];
//    NSLog(@"Stopped updating location");
//    locationManager = nil;
}

- (NSArray *)deserializeAppInfosFromJSON:(NSArray *)appInfosJSON
{
    NSError *error;
    NSArray *appInfos = [MTLJSONAdapter modelsOfClass:[Tweet class] fromJSONArray:appInfosJSON error:&error];
    if (error) {
        NSLog(@"Couldn't convert JSON to Tweet models: %@", error);
        return nil;
    }
    
    return appInfos;
}

- (void) sendGETRequest {
    NSMutableString *GETAddress = [NSMutableString string];
    [GETAddress appendString:@"http://162.243.149.41:54321/search/"];
    [GETAddress appendString:placeName];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //NSDictionary *params = @{@"name": @"Chelsea Market"};
    [manager GET:GETAddress parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSDictionary *responseDict = responseObject;
        NSArray *responseArray = [responseDict valueForKey:@"tweets"];
        latestTweetSet = [[self deserializeAppInfosFromJSON:responseArray] mutableCopy];
        NSLog(@"tweetset: %@", latestTweetSet);
        
        if ([latestTweetSet count] == 0) {
            [self.view makeToast:@"Sorry! No results found."];
        }
        else {
             [self.tweetsTableView reloadData];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

/*
 DELEGATES
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"CellIdentifier";
    TweetViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
//    if (cell == nil) {
//        cell = [[TweetViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
//    }
    
    // Configure Cell
    Tweet *tweet = latestTweetSet[indexPath.row];
    cell.name.text = tweet.name;
    cell.time.text = [tweet.createdAt substringWithRange:NSMakeRange(4, 6)];
    cell.twitterHandle.text = tweet.twitterHandle;
    cell.content.text = tweet.content;
    cell.retweetCount.text = [tweet.retweetCount stringValue];
    cell.favoriteCount.text = [tweet.favoriteCount stringValue];
    NSLog(@"cellForRowAtIndexPath called");
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([latestTweetSet count] == 0) {
        self.emptyView.hidden = false;
        self.tweetsTableView.hidden = true;
    } else {
        self.tweetsTableView.hidden = false;
        self.emptyView.hidden = true;
    }
    NSLog(@"latestTweetSet count: %lu", (unsigned long)[latestTweetSet count]);
    return [latestTweetSet count];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
