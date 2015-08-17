//
//  ViewController.m
//  GeoLogger
//
//  Created by Coji Mizoguchi on 2015/08/13.
//  Copyright (c) 2015年 Coji Mizoguchi. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mapView.showsUserLocation = YES; //ユーザの位置を表示するかどうか
    GeoLocationService.sharedInstance.delegate = self;
    for(GeoLoggerAnnotation* item in GeoLocationService.sharedInstance.geo_locations) {
        [self didAddedAnnotaition:item];
    }

    // 位置情報リスト
    self.tblList.delegate = self;
    self.tblList.dataSource = self;
}

- (void)didAddedAnnotaition:(GeoLoggerAnnotation *) item;
{
    // pin の追加
    [self.mapView addAnnotation:item];
    
    // 地図の移動&ズーム
    MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(0.0001, 0.0001);
    MKCoordinateRegion newRegion = MKCoordinateRegionMake(item.coordinate, coordinateSpan);
    [self.mapView setRegion:newRegion animated:YES];

    // table view の更新
    [self.tblList reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *geo_locations = [[GeoLocationService sharedInstance] geo_locations];
    return geo_locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *geo_locations = [[GeoLocationService sharedInstance] geo_locations];
    NSString *str = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
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
    NSMutableArray *geo_locations = [[GeoLocationService sharedInstance] geo_locations];
    
    GeoLoggerAnnotation* tt = geo_locations[indexPath.row];
    MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(0.00001, 0.00001); //数が小さいほど拡大率アップ

    
    MKCoordinateRegion newRegion = MKCoordinateRegionMake(tt.coordinate, coordinateSpan);
    [self.mapView setRegion:newRegion animated:YES];
}

- (IBAction)btnResetTapped:(id)sender {
    [self.mapView removeAnnotations:[[GeoLocationService sharedInstance] geo_locations]];
    [[GeoLocationService sharedInstance] clear];
    [self.tblList reloadData];
}

@end
