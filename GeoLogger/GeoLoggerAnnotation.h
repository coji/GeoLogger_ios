//
//  GeoLoggerAnnotation.h
//  GeoLogger
//
//  Created by Coji Mizoguchi on 2015/08/15.
//  Copyright (c) 2015年 Coji Mizoguchi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GeoLoggerAnnotation : NSObject <MKAnnotation, NSCoding>

@property (readwrite, nonatomic) CLLocationCoordinate2D coordinate;
@property (readwrite, nonatomic, copy) NSString* title;
@property (readwrite, nonatomic, strong) NSDate* timestamp;
@property (readwrite, nonatomic) double accuracy;
@property (readwrite, nonatomic) BOOL is_visit;
@property (readwrite, nonatomic, strong) NSDate* arrival_date;
@property (readwrite, nonatomic, strong) NSDate* departure_date;

@end
