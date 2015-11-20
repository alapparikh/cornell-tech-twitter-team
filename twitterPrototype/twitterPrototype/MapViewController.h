//
//  MapViewController.h
//  twitterPrototype
//
//  Created by Alap Parikh on 11/16/15.
//  Copyright © 2015 Alap Parikh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@import GoogleMaps;

@protocol MapViewControllerDelegate;

@interface MapViewController : UIViewController

@property CLLocationCoordinate2D center;
@property (nonatomic, weak) id<MapViewControllerDelegate> delegate;

- (BOOL) mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker;

@end

@protocol MapViewControllerDelegate <NSObject>

- (void)MapViewController:(MapViewController*)viewController
             didSelectPlaceName:(NSString *)name;

@end
