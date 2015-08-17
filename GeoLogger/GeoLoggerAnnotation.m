//
//  GeoLoggerAnnotation.m
//  GeoLogger
//
//  Created by Coji Mizoguchi on 2015/08/15.
//  Copyright (c) 2015年 Coji Mizoguchi. All rights reserved.
//

#import "GeoLoggerAnnotation.h"

@implementation GeoLoggerAnnotation
@synthesize coordinate, title, timestamp, accuracy, is_visit, arrival_date, departure_date;

- (void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeDouble:coordinate.latitude forKey:@"latitude"];
    [coder encodeDouble:coordinate.longitude forKey:@"longitude"];
    [coder encodeObject:title forKey:@"title"];
    [coder encodeObject:timestamp forKey:@"timestamp"];
    [coder encodeDouble:accuracy forKey:@"accuracy"];
    [coder encodeBool:is_visit forKey:@"is_visit"];
    [coder encodeObject:arrival_date forKey:@"arrival_date"];
    [coder encodeObject:departure_date forKey:@"departure_date"];
    
}

- (id) initWithCoder:(NSCoder *)coder
{
    CLLocationCoordinate2D cd;
    cd.latitude = [coder decodeDoubleForKey:@"latitude"];
    cd.longitude = [coder decodeDoubleForKey:@"longitude"];
    [self setCoordinate:cd];
    self.title = [coder decodeObjectForKey:@"title"];
    self.timestamp = [coder decodeObjectForKey:@"timestamp"];
    self.is_visit = [coder decodeBoolForKey:@"is_visit"];
    self.arrival_date = [coder decodeObjectForKey:@"arrival_date"];
    self.departure_date = [coder decodeObjectForKey:@"departure_date"];
    
    return self;
}

@end
