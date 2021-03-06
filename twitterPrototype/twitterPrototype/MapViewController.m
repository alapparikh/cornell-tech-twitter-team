//
//  MapViewController.m
//  twitterPrototype
//
//  Created by Alap Parikh on 11/16/15.
//  Copyright © 2015 Alap Parikh. All rights reserved.
//

#import "MapViewController.h"
#import "AFNetworking.h"
#import <Mantle/Mantle.h>
#import "Place.h"
@import GoogleMaps;

@interface MapViewController () <GMSMapViewDelegate>
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;

@end

@implementation MapViewController {
    //GMSMapView *mapView_;
    NSString *radius;
    NSMutableArray *latestPlacesSet;
    NSMutableDictionary *placesDict;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    latestPlacesSet = [[NSMutableArray alloc] init];
    placesDict = [[NSMutableDictionary alloc] initWithCapacity:20];
    [self.navigationItem.backBarButtonItem setAction:@selector(backButtonAction:)];
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.center.latitude
                                                            longitude:self.center.longitude
                                                                 zoom:15];
    
    self.mapView.camera = camera;
    [self setRadius]; // Set radius
    self.mapView.myLocationEnabled = YES;
    
    // Map settings
    self.mapView.settings.tiltGestures = NO;
    self.mapView.settings.indoorPicker = NO;
    self.mapView.settings.compassButton = YES;
    self.mapView.settings.myLocationButton = YES;
    
    // Set delegate
    self.mapView.delegate = self;
}

// GET request to Google API requesting places around current location
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
        latestPlacesSet = [responseDict valueForKey:@"results"];

        NSLog(@"%@", latestPlacesSet);
        
        [self placeMarkers];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}

#pragma mark - Markers
- (void) placeMarkers {
    
    for (int i=0; i<[latestPlacesSet count]; i++) {
        NSDictionary *dict = latestPlacesSet[i];
        [placesDict setObject:dict[@"name"] forKey:dict[@"place_id"]];
        
        CLLocationDegrees lat = [dict[@"geometry"][@"location"][@"lat"] doubleValue];
        CLLocationDegrees lng = [dict[@"geometry"][@"location"][@"lng"] doubleValue];
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(lat, lng);
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.title = dict[@"name"];
        
        marker.icon = [GMSMarker markerImageWithColor:[UIColor colorWithRed:0.0 green:(172/255.0) blue:(237/255.0) alpha:1.0]];
        marker.opacity = 1 - ((float)i/[latestPlacesSet count]);
        [marker setZIndex:0];
        
        //setup label
        UILabel *label = [[UILabel alloc] init];
        label.text = dict[@"types"][0];
        [label setFont:[UIFont systemFontOfSize:12]];
        [label setTextColor:[UIColor whiteColor]];
        [label setBackgroundColor:[UIColor colorWithRed:0.0 green:(172.0/255) blue:(237.0/255) alpha:0.4]];
        [label sizeToFit];
        
        //grab it
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, NO, [[UIScreen mainScreen] scale]);
        [label.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage * icon = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        GMSMarker *labelMarker = [GMSMarker markerWithPosition:position];
        labelMarker.icon = icon;
        labelMarker.title = dict[@"name"];
        [labelMarker setTappable:NO];
        [labelMarker setZIndex:1];
        
        marker.map = self.mapView;
        labelMarker.map = self.mapView;
    }
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
    self.center = [self.mapView.camera target];
    [self setRadius];
    [placesDict removeAllObjects];
    [self sendPlacesGETRequest];
}

- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    
    id<MapViewControllerDelegate> strongDelegate = self.delegate;
    
    // Check that delegate implements method
    if ([strongDelegate respondsToSelector:@selector(MapViewController:didSelectPlaceName::)]) {
        [strongDelegate MapViewController:self didSelectPlaceName:marker.title :marker.position];
    }
    NSLog(@"didTapMarker called");
    return true;
}

-(void) backButtonAction:(id)sender {
    
    //do something here
    id<MapViewControllerDelegate> strongDelegate = self.delegate;
    
    // Check that delegate implements method
    if ([strongDelegate respondsToSelector:@selector(didPressBackButton:)]) {
        [strongDelegate didPressBackButton:self];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - Mantle

- (NSArray *)deserializeAppInfosFromJSON:(NSArray *)appInfosJSON
{
    NSError *error;
    NSArray *appInfos = [MTLJSONAdapter modelsOfClass:[Place class] fromJSONArray:appInfosJSON error:&error];
    if (error) {
        NSLog(@"Couldn't convert JSON to Tweet models: %@", error);
        return nil;
    }
    
    return appInfos;
}

#pragma mark - Helper

// Helper method to decide size of map
- (void) setRadius {
    GMSVisibleRegion region = self.mapView.projection.visibleRegion;
    
    CLLocation *farLeft = [[CLLocation alloc] initWithLatitude:region.farLeft.latitude longitude:region.farLeft.longitude];
    CLLocation *farRight = [[CLLocation alloc] initWithLatitude:region.farRight.latitude longitude:region.farRight.longitude];
    CLLocationDistance meters = [farLeft distanceFromLocation:farRight];
    radius = [NSString stringWithFormat:@"%f",meters/2];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
