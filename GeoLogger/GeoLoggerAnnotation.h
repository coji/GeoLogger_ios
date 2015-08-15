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
@property (readwrite, nonatomic, strong) NSString* sample;

@end
