//
//  ViewController.m
//  GeoLogger
//
//  Created by Coji Mizoguchi on 2015/08/13.
//  Copyright (c) 2015年 Coji Mizoguchi. All rights reserved.
//

@import GoogleMobileAds;
#import "AppDelegate.h"
#import "ViewController.h"
#import <AppDavis/ADVSInstreamAdLoader.h>

@interface ViewController ()<ADVSInstreamAdLoaderDelegate>
@property(nonatomic) ADVSInstreamAdLoader *instreamAdLoader;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // AdMob banner
    self.bannerView.adUnitID = @"ca-app-pub-2610590216983914/9954980181";
    self.bannerView.rootViewController = self;
    GADRequest* request = [GADRequest request];
     [self.bannerView loadRequest:request];

    self.mapView.showsUserLocation = YES; //ユーザの位置を表示するかどうか
    GeoLocationService.sharedInstance.delegate = self;
    for(GeoLoggerAnnotation* item in GeoLocationService.sharedInstance.geo_locations) {
        [self didAddedAnnotaition:item];
    }

    // 位置情報リスト
    self.tblList.delegate = self;
    self.tblList.dataSource = self;
    self.tblList.rowHeight = UITableViewAutomaticDimension;

    //(3) Hike をインスタンス化。delegate を設定
    self.instreamAdLoader = [ADVSInstreamAdLoader new];
    self.instreamAdLoader.delegate = self;
    //(4) In-Feed広告を挿入したいtableViewと広告枠IDを設定
    [self.instreamAdLoader bindToTableView:self.tblList adSpotId:@"NTA1OjQwMzM"];
    //(5) In-Feed広告ロードを呼び出し
    [self.instreamAdLoader loadAd:3 positions:@[@5,@15,@25]];
    [self.tblList reloadData];
}

- (void)didAddedAnnotaition:(GeoLoggerAnnotation *) item;
{
    CLLocationCoordinate2D centerCoordinate = item.coordinate;
    CLLocationCoordinate2D fromEyeCoordinate = CLLocationCoordinate2DMake(item.coordinate.latitude-0.001,
                                                                          item.coordinate.longitude);
    CLLocationDistance eyeAltitude = 400.0; // meter
    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:centerCoordinate
                                                     fromEyeCoordinate:fromEyeCoordinate
                                                           eyeAltitude:eyeAltitude];
    [self.mapView setCamera:camera animated:NO];

    // pin の追加
    [self.mapView addAnnotation:item];
    

    // 広告の表示
    GADRequest* request = [GADRequest request];
    [request setLocationWithLatitude:item.coordinate.latitude
                           longitude:item.coordinate.longitude
                            accuracy:item.accuracy];
    [self.bannerView loadRequest:request];

    // table view の更新
    [self.tblList reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return UITableViewAutomaticDimension;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    
//    if (!cell) {
        // 再利用できない場合は新規で作成
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:str];
        
        GeoLoggerAnnotation* tt = geo_locations[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%lu: %@", geo_locations.count - (long)indexPath.row, tt.title];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", tt.place];
//    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *geo_locations = [[GeoLocationService sharedInstance] geo_locations];
    
    GeoLoggerAnnotation* item = geo_locations[indexPath.row];
    CLLocationCoordinate2D centerCoordinate = item.coordinate;
    CLLocationCoordinate2D fromEyeCoordinate = CLLocationCoordinate2DMake(item.coordinate.latitude-0.001,
                                                                          item.coordinate.longitude);
    CLLocationDistance eyeAltitude = 400.0; // meter
    MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:centerCoordinate
                                                     fromEyeCoordinate:fromEyeCoordinate
                                                           eyeAltitude:eyeAltitude];
    [self.mapView setCamera:camera animated:YES];
}

- (IBAction)btnResetTapped:(id)sender {
    [self.mapView removeAnnotations:[[GeoLocationService sharedInstance] geo_locations]];
    [[GeoLocationService sharedInstance] clear];
    [self.tblList reloadData];
}


@end
