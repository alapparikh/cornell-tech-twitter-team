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
@property (weak, nonatomic) IBOutlet UIView *tableView;
@end

@implementation ViewController {
    
    
    GMSPlacePicker *_placePicker;
    GMSMapView *mapView_;

    CLLocationManager *locationManager;
    CLLocationCoordinate2D center;
    CLLocationCoordinate2D northEast;
    CLLocationCoordinate2D southWest;
    CLLocationCoordinate2D destination;
    NSString *ServerIP;
    AFHTTPRequestOperationManager *AFmanager;
    NSString *placeName;
    NSMutableArray *latestTweetSet;
    NSURL *tweetURL;
    BOOL loadingData;
    BOOL noMoreData;
    int pace;
    BOOL isEmpty;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Navigation bar styling
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:(172/255.0) blue:(237/255.0) alpha:0.4];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    ServerIP = @"http://162.243.149.41:54321/";
    loadingData = false;
    noMoreData = false;
    isEmpty = true;
    pace = 20;
    AFmanager = [AFHTTPRequestOperationManager manager];
    
    // GPS Settings
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
    placeName = @"";
}

// Before view appears, load data if needed
- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"viewillappear called");
    if (isEmpty) {
        [latestTweetSet removeAllObjects];
        isEmpty = false;
    }
    else {
        NSLog(@"loadmoredata called");
        [self loadMoreData];
    }
}


# pragma mark - Location Manager
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
}

// GPS error message
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

# pragma mark - Tweet Controllers

// Get Tweets from server if needed
- (void) loadMoreData {
    if (loadingData || noMoreData) {
        return;
    }
    loadingData = true;
    NSMutableString *GETAddress = [NSMutableString string];
    [GETAddress appendString:[ServerIP stringByAppendingString: @"search/"]];
    [GETAddress appendString:placeName];
    [AFmanager GET:GETAddress
        parameters:@{ @"begin" : [NSString stringWithFormat:@"%lu",(unsigned long)[latestTweetSet count]],
                      @"end"   : [NSString stringWithFormat:@"%lu",(unsigned long)[latestTweetSet count] + pace]}
                success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSDictionary *responseDict = responseObject;
        NSArray *responseArray = [responseDict valueForKey:@"tweets"];
        responseArray = [[self deserializeAppInfosFromJSON:responseArray] mutableCopy];
        NSLog (@"%@", responseArray);
        if ([responseArray count] == 0) {
            noMoreData = true;
            if ([latestTweetSet count] == 0) {
                [self.view makeToast:@"Sorry! No results found."];
            }
        }
        else {
            NSMutableArray *newArray = [NSMutableArray arrayWithArray:latestTweetSet];
            [newArray addObjectsFromArray:responseArray];
            latestTweetSet = newArray;
            [self.tweetsTableView reloadData];
            loadingData = false;
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        loadingData = false;
        NSLog(@"Error: %@", error);
    }];
}

// Import JSON into Tweet class (handled by Mantle)
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

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y + self.tweetsTableView.frame.size.height > scrollView.contentSize.height && !noMoreData) {
        [self loadMoreData];
    }
}

# pragma mark - Interaction

// Go to map view when explore button is pressed
- (IBAction)onExploreButtonPressed:(id)sender {
    
    [self performSegueWithIdentifier:@"MapViewSegue" sender:self];
}

// Launch Google Maps app (if installed on phone) with directions from current location to current place
- (IBAction)onGetDirectionsButtonPressed:(id)sender {
    
    
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) {
        
        NSMutableString *GETAddress = [NSMutableString string];
        [GETAddress appendString:@"comgooglemaps://?saddr="];
        [GETAddress appendString:[[NSString alloc] initWithFormat:@"%f", center.latitude]];
        [GETAddress appendString:@","];
        [GETAddress appendString:[[NSString alloc] initWithFormat:@"%f", center.longitude]];
        [GETAddress appendString:@"&daddr="];
        [GETAddress appendString:[[NSString alloc] initWithFormat:@"%f", destination.latitude]];
        [GETAddress appendString:@","];
        [GETAddress appendString:[[NSString alloc] initWithFormat:@"%f", destination.longitude]];
        [GETAddress appendString:@"&directionsmode=walking"];
        
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:GETAddress]];
    } else {
        NSLog(@"Can't use comgooglemaps://");
        
    }
}


/* 
 *STUB (favorite, retweet)
*/
-(void)myTapping1 :(id) sender
{
    [self.tweetsTableView makeToast:@"Retweeted"];
    /** failed authentication part, same for myTapping2
     NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
     NSString *intervalString = [NSString stringWithFormat:@"%f", timeStamp];
     NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
     NSMutableString *nounce = [NSMutableString stringWithCapacity:20];
     for (NSUInteger i = 0U; i < 20; i++) {
     u_int32_t r = arc4random() % [alphabet length];
     unichar c = [alphabet characterAtIndex:r];
     [nounce appendFormat:@"%C", c];
     }
     
     AFmanager.requestSerializer = [AFJSONRequestSerializer serializer];
     [AFmanager.requestSerializer setValue:@"oob" forHTTPHeaderField:@"oauth_callback"];
     [AFmanager.requestSerializer setValue:@"PeGra0CiDB7bpwnu8dlMWD6rm" forHTTPHeaderField:@"oauth_consumer_key"];
     [AFmanager.requestSerializer setValue:@"HMAC-SHA1" forHTTPHeaderField:@"oauth_signature_method"];
     [AFmanager.requestSerializer setValue:intervalString forHTTPHeaderField:@"oauth_timestamp"];
     [AFmanager.requestSerializer setValue:nounce forHTTPHeaderField:@"oauth_nounce"];
     [AFmanager.requestSerializer setValue:@"1.0" forHTTPHeaderField:@"oauth_version"];
     
     Authorization head should be
     Authorization:
     OAuth oauth_callback="http%3A%2F%2Flocalhost%2Fsign-in-with-twitter%2F",
     oauth_consumer_key="cChZNFj6T5R0TigYB9yd1w",
     oauth_nonce="ea9ec8429b68d6b77cd5600adbbb0456",
     oauth_signature="F1Li3tvehgcraF8DMJ7OyxO4w9Y%3D", //don't know how to generate that
     oauth_signature_method="HMAC-SHA1",
     oauth_timestamp="1318467427",
     oauth_version="1.0"
     
     NSMutableString *request_token = [NSMutableString stringWithString:@"https://api.twitter.com/oauth/request_token"];
     NSMutableString *oauth_token = [NSMutableString stringWithString:@""];
     [AFmanager POST:request_token
        parameters:@{ @"x_auth_access_type": @"write"}
            success:^(AFHTTPRequestOperation *operation, id responseObject){
     
                NSDictionary *responseDict = responseObject;
                NSString *token = [responseDict valueForKey:@"oauth_token"];
                [oauth_token appendString:token];
                NSLog(@"%@", responseDict);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            }];
     
     NSMutableString *authenticate = [NSMutableString stringWithString:@"https://api.twitter.com/oauth/authenticate?oauth_token="];
     [authenticate appendString:oauth_token];
     [AFmanager GET:authenticate
        parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject){
     
                NSDictionary *responseDict = responseObject;
                NSLog(@"%@", responseDict);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            }];
     
     //need a pop up a window to let user write the oauth_verifier, pass it as a parameters in access_token function
     
     NSMutableString *access_token = [NSMutableString stringWithString:@"https://api.twitter.com/oauth/access_token"];
     [AFmanager POST:access_token
        parameters:@{ @"oauth_verifier": @""}
            success:^(AFHTTPRequestOperation *operation, id responseObject){
     
                NSDictionary *responseDict = responseObject;
                NSLog(@"%@", responseDict);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            }];
     
     **/
    /*
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    Tweet *tweet = latestTweetSet[gesture.view.tag];
    //NSString *tid = tweet.tweetId;
    NSMutableString *URLConstruction = [NSMutableString stringWithString:@"https://api.twitter.com/1.1/statuses/"];
    [URLConstruction appendString:tweet.tweetId];
    [URLConstruction appendString:@".json"];
    
    [AFmanager POST:URLConstruction
         parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSDictionary *responseDict = responseObject;
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
     */
}

-(void)myTapping2 :(id) sender
{
    UIImageView *favorite = (UIImageView*)((UITapGestureRecognizer*)sender).view;
    NSString* imageName1 = [[NSBundle mainBundle] pathForResource:@"favorited_icon" ofType:@"png"];

    NSString* imageName2 = [[NSBundle mainBundle] pathForResource:@"favorite_icon" ofType:@"png"];
    UIImage* image1 = [[UIImage alloc] initWithContentsOfFile:imageName1];
    UIImage* image2 = [[UIImage alloc] initWithContentsOfFile:imageName2];
    if ([UIImagePNGRepresentation(image1) isEqualToData:
            UIImagePNGRepresentation(favorite.image)]) {
        [favorite setImage:image2];
    }
    else {
        [favorite setImage:image1];
    }
    
    /*
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    Tweet *tweet = latestTweetSet[gesture.view.tag];
    //NSString *tid = tweet.tweetId;
    NSMutableString *URLConstruction = [NSMutableString stringWithString:@"https://api.twitter.com/1.1/favorites/create.json?id="];
    [URLConstruction appendString:tweet.tweetId];
    
    [AFmanager POST:URLConstruction
         parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                NSDictionary *responseDict = responseObject;
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
    */
}

# pragma mark - TableView Delegates
/*
 TABLEVIEW DELEGATES
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"CellIdentifier";
    TweetViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    Tweet *tweet = latestTweetSet[indexPath.row];
    cell.name.text = tweet.name;
    cell.time.text = [tweet.createdAt substringWithRange:NSMakeRange(4, 6)];
    cell.twitterHandle.text = tweet.twitterHandle;
    
    // Tweet content
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
        self.tableView.hidden = true;
    } else {
        self.tableView.hidden = false;
        self.emptyView.hidden = true;
    }
    return [latestTweetSet count];
}

# pragma mark - Segue
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
        
        // Pass any objects to the view controller here, like...
        [webViewController setURL:tweetURL];
        
    }
    else if ([[segue identifier] isEqualToString:@"MapViewSegue"]) {
        MapViewController *mapViewController = [segue destinationViewController];
        mapViewController.center = center;
        mapViewController.delegate = self;
    }
}

# pragma mark - Delegate Methods (MapViewController)
/*
 DELEGATE METHODS FOR MAPVIEWCONTROLLER
*/
- (void)MapViewController:(MapViewController *)viewController didSelectPlaceName:(NSString *)name :(CLLocationCoordinate2D)dest {
    NSLog(@"placeName delegate method called");
    // Set place name
    [self.navigationController setTitle:name];
    name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
    placeName = name;
    isEmpty = false;
    noMoreData = false;
    destination = dest;
    [latestTweetSet removeAllObjects];
    NSLog(@"%@", placeName);
    // ...then dismiss the child view controller
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didPressBackButton:(MapViewController *)viewController {
    NSLog(@"isEmpty delegate method called");
    
    // Set isEmpty
    isEmpty = true;
    
    // ...then dismiss the child view controller
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
