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

#define SERVER_URL_LOCATION @"http://techtalk.jp/geo_api.cgi?lat=%f&lng=%f&accuracy=%f"
#define SERVER_URL_VISIT @"http://techtalk.jp/geo_api.cgi?lat=%f&lng=%f&accuracy=%f&arrival_date=%@&departure_date=%@"

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
        self.locationManager = nil;
        self.geo_locations = nil;
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

        [self.locationManager startMonitoringSignificantLocationChanges];
        [self.locationManager startMonitoringVisits];
    }
}

- (void)stopService
{
    [self.locationManager stopMonitoringSignificantLocationChanges];
    [self.locationManager stopMonitoringVisits];
}

- (void)addLocation:(CLLocation *)location
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *timestamp = [outputFormatter stringFromDate:location.timestamp];
    NSString *accuracy = [NSString stringWithFormat:@"%0.0f", location.horizontalAccuracy];
    NSString *message = [[NSString alloc] initWithFormat:@"%@ (精度:%@m)", timestamp, accuracy];
    
    GeoLoggerAnnotation* item = [[GeoLoggerAnnotation alloc] init];
    item.coordinate = location.coordinate;
    item.title = message;
    item.is_visit = FALSE;
    item.timestamp = location.timestamp;
    item.accuracy = location.horizontalAccuracy;
    item.arrival_date = nil;
    item.departure_date = nil;

    if(item.place == nil) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:item.coordinate.latitude
                                                          longitude:item.coordinate.longitude];
        [geocoder reverseGeocodeLocation:location
                       completionHandler:^(NSArray* placemarks, NSError* error) {
                           CLPlacemark* placemark = [placemarks lastObject];
                           item.place = [@[placemark.postalCode ? placemark.postalCode : @"",
                                           placemark.locality ? placemark.locality : @"",
                                           placemark.thoroughfare ? placemark.thoroughfare : @"",
                                           placemark.subThoroughfare ? placemark.subThoroughfare : @""] componentsJoinedByString:@" "];
                           item.subtitle = item.place;
                       }];
    }

    [self.geo_locations insertObject:item atIndex:0];
    [self save];

    if ([self.delegate respondsToSelector:@selector(didAddedAnnotaition:)])
    {
        [self.delegate didAddedAnnotaition:item];
    }

    /*
    UILocalNotification *futureAlert;
    futureAlert = [[UILocalNotification alloc] init];
    [futureAlert setAlertBody:message];
    futureAlert.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    futureAlert.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:futureAlert];
    */
    
    [self sendToServerWithAnnotation:item];
}

- (void)addVisit:(CLVisit *)visit
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *timestamp = [outputFormatter stringFromDate:[NSDate date]];
    NSString *accuracy = [NSString stringWithFormat:@"%0.0f", visit.horizontalAccuracy];
    NSString *message = [[NSString alloc] initWithFormat:@"%@ (精度:%@m) visit", timestamp, accuracy];
    
    GeoLoggerAnnotation* item = [[GeoLoggerAnnotation alloc] init];
    item.coordinate = visit.coordinate;
    item.title = message;
    item.is_visit = TRUE;
    item.timestamp = [NSDate date];
    item.accuracy = visit.horizontalAccuracy;
    item.arrival_date = visit.arrivalDate;
    item.departure_date = visit.departureDate;
    
    if(item.place == nil) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:item.coordinate.latitude
                                                          longitude:item.coordinate.longitude];
        [geocoder reverseGeocodeLocation:location
                       completionHandler:^(NSArray* placemarks, NSError* error) {
                           CLPlacemark* placemark = [placemarks lastObject];
                           item.place = [@[placemark.postalCode ? placemark.postalCode : @"",
                                           placemark.locality ? placemark.locality : @"",
                                           placemark.thoroughfare ? placemark.thoroughfare : @"",
                                           placemark.subThoroughfare ? placemark.subThoroughfare : @""] componentsJoinedByString:@" "];
                           item.subtitle = item.place;
                       }];
    }

    [self.geo_locations insertObject:item atIndex:0];
    [self save];

    if ([self.delegate respondsToSelector:@selector(didAddedAnnotaition:)])
    {
        [self.delegate didAddedAnnotaition:item];
    }
    
    UILocalNotification *futureAlert;
    futureAlert = [[UILocalNotification alloc] init];
    [futureAlert setAlertBody:message];
    futureAlert.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    futureAlert.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:futureAlert];

    [self sendToServerWithAnnotation:item];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self addLocation: locations.lastObject];
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

    for(GeoLoggerAnnotation* item in self.geo_locations) {
        if(item.place == nil) {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            CLLocation *location = [[CLLocation alloc] initWithLatitude:item.coordinate.latitude
                                                              longitude:item.coordinate.longitude];
            [geocoder reverseGeocodeLocation:location
                            completionHandler:^(NSArray* placemarks, NSError* error) {
                                CLPlacemark* placemark = [placemarks lastObject];
                                item.place = [@[placemark.postalCode ? placemark.postalCode : @"",
                                                placemark.locality ? placemark.locality : @"",
                                                placemark.thoroughfare ? placemark.thoroughfare : @"",
                                                placemark.subThoroughfare ? placemark.subThoroughfare : @""] componentsJoinedByString:@" "];
                                item.subtitle = item.place;
            }];
        }

        if ([self.delegate respondsToSelector:@selector(didAddedAnnotaition:)]) {
            [self.delegate didAddedAnnotaition:item];
        }
    }
}

- (void)clear
{
    [self.geo_locations removeAllObjects];
    [self save];
}

- (void)sendToServerWithAnnotation:(GeoLoggerAnnotation*)item
{
    NSString *url;
    if(item.is_visit) {
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

        url = [NSString stringWithFormat:SERVER_URL_VISIT,
               item.coordinate.latitude,
               item.coordinate.longitude,
               item.accuracy,
               [[outputFormatter stringFromDate:item.arrival_date] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
               [[outputFormatter stringFromDate:item.departure_date] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    } else {
        url = [NSString stringWithFormat:SERVER_URL_LOCATION,
               item.coordinate.latitude,
               item.coordinate.longitude,
               item.accuracy];
    }
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];

    [NSURLConnection sendAsynchronousRequest:req
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                           }];
}

@end