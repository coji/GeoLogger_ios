//
//  GeoLocationService.h
//  GeoLogger
//
//  Created by Coji Mizoguchi on 2015/08/16.
//  Copyright (c) 2015年 Coji Mizoguchi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GeoLoggerAnnotation.h"

@protocol GeoLocationServiceDelegate <NSObject>
- (void)didAddedAnnotaition:(GeoLoggerAnnotation *) item;
@end

@interface GeoLocationService : NSObject <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *geo_locations;
@property (nonatomic, assign) id<GeoLocationServiceDelegate> delegate;

+ (GeoLocationService*)sharedInstance;

- (void)startService;
- (void)stopService;

- (void)addLocation:(CLLocation *)location;
- (void)addVisit:(CLVisit *)visit;

- (void)save;
- (void)load;
- (void)clear;

@end
