//
//  ViewController.m
//  twitterPrototype
//
//  Created by Alap Parikh on 10/21/15.
//  Copyright © 2015 Alap Parikh. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AFNetworking.h"
#import <Mantle/Mantle.h>
#import "Tweet.h"
#import "TweetViewCell.h"
#import <Toast/UIView+Toast.h>
#import "WebViewController.h"
#import "MapViewController.h"
@import GoogleMaps;
@interface ViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tweetsTableView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UIButton *exploreButton;
@end

@implementation ViewController {
    GMSPlacePicker *_placePicker;
    GMSMapView *mapView_;

    CLLocationManager *locationManager;
    CLLocationCoordinate2D center;
    CLLocationCoordinate2D northEast;
    CLLocationCoordinate2D southWest;
    
    
    NSString *placeName;
    NSMutableArray *latestTweetSet;
    NSURL *tweetURL;
    
    // Decide whether to use gmsplacepicker or gmsmapview
    bool placePicker;
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
    
    placePicker = true;
}

- (IBAction)onExploreButtonPressed:(id)sender {
    
    if (placePicker) {
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
    else {
        //[self sendPlacesGETRequest];
        [self performSegueWithIdentifier:@"MapViewSegue" sender:self];
    }
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

#pragma GET Requests
/*
 * GET Requests
*/

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
        
        [self.tweetsTableView reloadData];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)myTapping1 :(id) sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    NSLog(@"Tag = %d", gesture.view.tag);
    NSLog(@"retweet");
}

-(void)myTapping2 :(id) sender
{
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    NSLog(@"Tag = %d", gesture.view.tag);
    NSLog(@"favorite");
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
    
    /* 
     *Configure Cell
     */
    Tweet *tweet = latestTweetSet[indexPath.row];
    cell.name.text = tweet.name;
    cell.time.text = [tweet.createdAt substringWithRange:NSMakeRange(4, 6)];
    cell.twitterHandle.text = tweet.twitterHandle;
    
    // Tweet content
//    UIFont *contentFont = [UIFont fontWithName:@"System" size:13.0];
//    NSArray *keys = [NSArray arrayWithObjects:NSFontAttributeName, nil];
//    NSArray *objects = [NSArray arrayWithObjects:contentFont, nil];
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
//    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:tweet.content attributes:attributes];
//    cell.content.attributedText= attrString;
    cell.content.text = tweet.content;
    cell.retweetCount.text = [tweet.retweetCount stringValue];
    cell.favoriteCount.text = [tweet.favoriteCount stringValue];
    
    cell.retweet.userInteractionEnabled = YES;
    cell.retweet.tag = indexPath.row;
    UITapGestureRecognizer *tapped1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myTapping1:)];
    tapped1.numberOfTapsRequired = 1;
    [cell.retweet addGestureRecognizer:tapped1];
    
    cell.favorite.userInteractionEnabled = YES;
    cell.favorite.tag = indexPath.row;
    UITapGestureRecognizer *tapped2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myTapping2:)];
    tapped2.numberOfTapsRequired = 1;
    [cell.favorite addGestureRecognizer:tapped2];
    
    // Load profile image
    NSURL *url = [NSURL URLWithString:tweet.profileImage];
    NSData *data = [NSData dataWithContentsOfURL:url];
    //cell.profileImage.image = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
    cell.profileImage.image = [UIImage imageWithData:data];
    NSLog(@"cellForRowAtIndexPath called");
    
    return cell;
}

// Launches web view with relevant Tweet
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *tweet = latestTweetSet[indexPath.row];
    
    NSMutableString *URLConstruction = [NSMutableString stringWithString:@"https://twitter.com/"];
    [URLConstruction appendString:tweet.twitterHandle];
    [URLConstruction appendString:@"/status/"];
    [URLConstruction appendString:tweet.tweetId];
    tweetURL = [NSURL URLWithString:URLConstruction];
    
    [self performSegueWithIdentifier:@"WebViewSegue" sender:self];
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

/*
 SEGUE
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"WebViewSegue"])
    {
        // Get reference to the destination view controller
        WebViewController *webViewController = [segue destinationViewController];
        //UINavigationController *navController = [segue destinationViewController];
        //WebViewController *webViewController = (WebViewController *)([navController viewControllers][0]);
        
        // Pass any objects to the view controller here, like...
        [webViewController setURL:tweetURL];
        
    }
    else if ([[segue identifier] isEqualToString:@"MapViewSegue"]) {
        MapViewController *mapViewController = [segue destinationViewController];
        mapViewController.center = center;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
