//
//  GeoLoggerAnnotation.m
//  GeoLogger
//
//  Created by Coji Mizoguchi on 2015/08/15.
//  Copyright (c) 2015年 Coji Mizoguchi. All rights reserved.
//

#import "GeoLoggerAnnotation.h"

@implementation GeoLoggerAnnotation
@synthesize coordinate, title, sample;

- (void) encodeWithCoder:(NSCoder *)coder
{
    [coder encodeDouble:coordinate.latitude forKey:@"latitude"];
    [coder encodeDouble:coordinate.longitude forKey:@"longitude"];
    [coder encodeObject:title forKey:@"title"];
    [coder encodeObject:sample forKey:@"sample"];
}

- (id) initWithCoder:(NSCoder *)coder
{
    CLLocationCoordinate2D cd;
    cd.latitude = [coder decodeDoubleForKey:@"latitude"];
    cd.longitude = [coder decodeDoubleForKey:@"longitude"];
    self.title = [coder decodeObjectForKey:@"title"];
    self.sample = [coder decodeObjectForKey:@"sample"];
    
    return self;
}

@end
