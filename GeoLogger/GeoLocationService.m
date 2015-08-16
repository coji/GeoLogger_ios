//
//  GeoLocationService.m
//  GeoLogger
//
//  Created by Coji Mizoguchi on 2015/08/16.
//  Copyright (c) 2015年 Coji Mizoguchi. All rights reserved.
//

#import "GeoLocationService.h"

@implementation GeoLocationService
@synthesize delegate;


+ (GeoLocationService*)sharedInstance
{
    static GeoLocationService* sharedInstance;
    static dispatch_once_t once;
    dispatch_once( &once, ^{
        sharedInstance = [[self alloc] init];
        [sharedInstance load];
    });
        
    return sharedInstance;
}

- (id)init
{
    if(self = [super init])
    {
        
    }
    return self;
}

- (void)startService
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        NSLog(@"Location services is unauthorized.");
    } else {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
        {
            [self.locationManager requestAlwaysAuthorization];
        }
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;

        // [self.locationManager startUpdatingLocation];
        [self.locationManager startMonitoringSignificantLocationChanges];
        [self.locationManager startMonitoringVisits];
    }
}

- (void)stopService
{
    // [self.locationManager stopUpdatingLocation];
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager stopMonitoringVisits];
}

- (void)addLocation:(CLLocation *)location
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *timestamp = [outputFormatter stringFromDate:location.timestamp];
    NSString *accuracy = [NSString stringWithFormat:@"%0.0f", location.horizontalAccuracy];
    NSString *message = [[NSString alloc] initWithFormat:@"%lu: %@ (精度:%@m)", (unsigned long)self.geo_locations.count+1, timestamp, accuracy];
    
    GeoLoggerAnnotation* item = [[GeoLoggerAnnotation alloc] init];
    item.coordinate = location.coordinate;
    item.title = message;
    item.is_visit = FALSE;
    item.timestamp = location.timestamp;
    item.accuracy = location.horizontalAccuracy;
    item.arrival_date = nil;
    item.departure_date = nil;

    [self.geo_locations insertObject:item atIndex:0];
    [self save];

    if ([self.delegate respondsToSelector:@selector(didAddedAnnotaition:)]) {
        [self.delegate didAddedAnnotaition:item];
    }
}

- (void)addVisit:(CLVisit *)visit
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *timestamp = [outputFormatter stringFromDate:[NSDate date]];
    NSString *accuracy = [NSString stringWithFormat:@"%0.0f", visit.horizontalAccuracy];
    NSString *message = [[NSString alloc] initWithFormat:@"%lu: %@ (精度:%@m) visit", (unsigned long)self.geo_locations.count+1, timestamp, accuracy];
    
    GeoLoggerAnnotation* item = [[GeoLoggerAnnotation alloc] init];
    item.coordinate = visit.coordinate;
    item.title = message;
    item.is_visit = FALSE;
    item.timestamp = [NSDate date];
    item.arrival_date = visit.arrivalDate;
    item.departure_date = visit.departureDate;

    [self.geo_locations insertObject:item atIndex:0];
    [self save];

    if ([self.delegate respondsToSelector:@selector(didAddedAnnotaition:)]) {
        [self.delegate didAddedAnnotaition:item];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for(CLLocation *loc in locations) {
        [self addLocation: loc];
    }
}

- (void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit
{
    [self addVisit:visit];
}

- (void)save
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"geo_locations.dat"];
    
    [NSKeyedArchiver archiveRootObject:self.geo_locations toFile:path];
}

- (void)load
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"geo_locations.dat"];
    
    self.geo_locations = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if(self.geo_locations == nil) {
        self.geo_locations = [[NSMutableArray alloc] init];
    }
}

- (void)clear
{
    [self.geo_locations removeAllObjects];
    [self save];
}

@end

