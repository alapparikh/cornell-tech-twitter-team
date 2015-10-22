//
//  ViewController.m
//  twitterPrototype
//
//  Created by Alap Parikh on 10/21/15.
//  Copyright © 2015 Alap Parikh. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
@import GoogleMaps;


@interface ViewController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@end

@implementation ViewController {
    GMSPlacePicker *_placePicker;
    CLLocationManager *locationManager;
    CLLocationCoordinate2D center;
    CLLocationCoordinate2D northEast;
    CLLocationCoordinate2D southWest;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // User location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager requestAlwaysAuthorization];
    //locationManager.distanceFilter = 100; // updates triggered every 100 m
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations
{
    NSLog(@"didUpdateLocations: %@", [locations lastObject]);
    CLLocation *currentLocation = [locations lastObject];
    
    NSDate* eventDate = currentLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 15.0) {
        self.nameLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        self.addressLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              currentLocation.coordinate.latitude,
              currentLocation.coordinate.longitude);
        center = currentLocation.coordinate;
        northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001);
        southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001);
        
        // Google Place picker
        [self pickPlace];
    }
    
    [locationManager stopUpdatingLocation];
    NSLog(@"Stopped updating location");
    locationManager = nil;
}

// The code snippet below creates a GMSPlacePicker
- (void)pickPlace {
    //center = CLLocationCoordinate2DMake(51.5108396, -0.0922251);
    //northEast = CLLocationCoordinate2DMake(center.latitude + 0.001, center.longitude + 0.001);
    //southWest = CLLocationCoordinate2DMake(center.latitude - 0.001, center.longitude - 0.001);
    
    NSLog(@"pickPlace called");
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
        } else {
            NSLog(@"No place selected");
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
