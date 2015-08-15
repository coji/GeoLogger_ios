//
//  ViewController.h
//  GeoLogger
//
//  Created by Coji Mizoguchi on 2015/08/13.
//  Copyright (c) 2015年 Coji Mizoguchi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GeoLoggerAnnotation.h"

@interface ViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UITableView *tblList;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *btnReset;

- (void)addTableItem:(GeoLoggerAnnotation *)tt;
- (void)addLocation:(CLLocation*)location;
- (void)addVisit:(CLVisit *)visit;

@end

