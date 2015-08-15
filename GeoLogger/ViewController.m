//
//  ViewController.m
//  GeoLogger
//
//  Created by Coji Mizoguchi on 2015/08/13.
//  Copyright (c) 2015年 Coji Mizoguchi. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "GeoLoggerAnnotation.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mapView.showsUserLocation = YES; //ユーザの位置を表示するかどうか

    // 位置情報リスト
    self.tblList.delegate = self;
    self.tblList.dataSource = self;

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
        //self.locationManager.distanceFilter = 0;                    //100m 移動ごとに通知
        //[self.locationManager startUpdatingLocation];
        [self.locationManager startMonitoringSignificantLocationChanges];
        [self.locationManager startMonitoringVisits];
    }
}

- (void)addTableItem:(CLLocationCoordinate2D)coordinate
        timestamp:(NSDate *)date
        message:(NSString *)message
{
    NSMutableArray *geo_locations = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).geo_locations;

    GeoLoggerAnnotation* tt = [[GeoLoggerAnnotation alloc] init];
    tt.coordinate = coordinate;
    tt.title = message;
    [self.mapView addAnnotation:tt];
    
    // 地図の移動&ズーム
    MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(0.0001, 0.0001);
    MKCoordinateRegion newRegion = MKCoordinateRegionMake(coordinate, coordinateSpan);
    [self.mapView setRegion:newRegion animated:YES];

    // データの追加 / 保存
    [geo_locations insertObject:tt atIndex:0];
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate save_geo_locations];
    
    // table view の更新
    [self.tblList beginUpdates];
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tblList insertRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationTop];
    [self.tblList endUpdates];
    [self.tblList reloadData];
}

- (void)addLocation:(CLLocation *)location
{
    NSMutableArray *geo_locations = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).geo_locations;

    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *timestamp = [outputFormatter stringFromDate:location.timestamp];
    NSString *accuracy = [NSString stringWithFormat:@"%0.0f", location.horizontalAccuracy];
    NSString *message = [[NSString alloc] initWithFormat:@"%lu: %@ (精度:%@m)", (unsigned long)geo_locations.count+1, timestamp, accuracy];
    
    [self addTableItem:location.coordinate timestamp:location.timestamp message:message];
}

- (void)addVisit:(CLVisit *)visit
{
    NSMutableArray *geo_locations = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).geo_locations;

    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *timestamp = [outputFormatter stringFromDate:[NSDate date]];
    NSString *accuracy = [NSString stringWithFormat:@"%0.0f", visit.horizontalAccuracy];
    NSString *message = [[NSString alloc] initWithFormat:@"%lu: %@ (精度:%@m) visit", (unsigned long)geo_locations.count+1, timestamp, accuracy];
    
    [self addTableItem:visit.coordinate timestamp:[NSDate date] message:message];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *geo_locations = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).geo_locations;
    return geo_locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *geo_locations = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).geo_locations;
    NSString *str = [NSString stringWithFormat:@"%ld", indexPath.row];
    // 再利用できるセルがあれば再利用する
    UITableViewCell *cell;// = [tableView dequeueReusableCellWithIdentifier:str];
    
    if (!cell) {
        // 再利用できない場合は新規で作成
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:str];
        GeoLoggerAnnotation* tt = geo_locations[indexPath.row];
        cell.textLabel.text = tt.title;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *geo_locations = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).geo_locations;
    
    GeoLoggerAnnotation* tt = geo_locations[indexPath.row];
    MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(0.00001, 0.00001); //数が小さいほど拡大率アップ

    MKCoordinateRegion newRegion = MKCoordinateRegionMake(tt.coordinate, coordinateSpan);
    [self.mapView setRegion:newRegion animated:YES];
}

- (IBAction)btnResetTapped:(id)sender {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.geo_locations removeAllObjects];
    [delegate save_geo_locations];

    [self.tblList reloadData];
}

@end
