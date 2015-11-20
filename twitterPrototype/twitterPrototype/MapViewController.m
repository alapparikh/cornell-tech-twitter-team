//
//  MapViewController.m
//  twitterPrototype
//
//  Created by Alap Parikh on 11/16/15.
//  Copyright © 2015 Alap Parikh. All rights reserved.
//

#import "MapViewController.h"
#import "AFNetworking.h"
@import GoogleMaps;

@interface MapViewController () <GMSMapViewDelegate>
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@end

@implementation MapViewController {
    //GMSMapView *mapView_;
    NSString *radius;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Set radius
    radius = @"100";
    // [self setRadius];
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.center.latitude
                                                            longitude:self.center.longitude
                                                                 zoom:15];
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled = YES;
    
    // Map settings
    self.mapView.settings.tiltGestures = NO;
    self.mapView.settings.indoorPicker = NO;
    self.mapView.settings.compassButton = YES;
    self.mapView.settings.myLocationButton = YES;
    
    // Set delegate
    self.mapView.delegate = self;
    
    // Load places
    [self sendPlacesGETRequest];
}

- (void) sendPlacesGETRequest {
    NSMutableString *GETAddress = [NSMutableString string];
    [GETAddress appendString:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?"];
    [GETAddress appendString:@"location="];
    [GETAddress appendString:[[NSString alloc] initWithFormat:@"%f", self.center.latitude]];
    [GETAddress appendString:@","];
    [GETAddress appendString:[[NSString alloc] initWithFormat:@"%f", self.center.longitude]];
    [GETAddress appendString:@"&radius="];
    [GETAddress appendString:radius];
    [GETAddress appendString:@"&key=AIzaSyAM0_AhR6f6ePRNQfzALLXRIrYXVG_AY18"];
    
    NSLog(@"send places get request called");
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:GETAddress parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *responseDict = responseObject;
        NSLog(@"%@", responseDict);
        NSLog(@"Number of results: %lu", (unsigned long)responseDict.count);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

- (void) setRadius {
    
}


#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    
    NSLog(@"You tapped at %f,%f", coordinate.latitude, coordinate.longitude);
}

- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture {
    [mapView clear];
}

- (void)mapView:(GMSMapView *)mapView
idleAtCameraPosition:(GMSCameraPosition *)cameraPosition {
    //    id handler = ^(GMSReverseGeocodeResponse *response, NSError *error) {
    //        if (error == nil) {
    //            GMSReverseGeocodeResult *result = response.firstResult;
    //            GMSMarker *marker = [GMSMarker markerWithPosition:cameraPosition.target];
    //            marker.title = result.lines[0];
    //            marker.snippet = result.lines[1];
    //            marker.map = mapView;
    //        }
    //    };
    //    [geocoder_ reverseGeocodeCoordinate:cameraPosition.target completionHandler:handler];
    self.center = [self.mapView.camera target];
    [self setRadius];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
