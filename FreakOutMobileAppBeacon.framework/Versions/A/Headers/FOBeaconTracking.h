//
//  FOBeaconTracking.h
//  FOBeaconTracking
//
//  Created by FreakOut inc, on 8/18/14.
//  Copyright (c) 2014 FreakOut inc,. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FreakOutMobileAppDMP/FOTracking.h>
#import <CoreLocation/CoreLocation.h>

@protocol FOBeaconTrackingDelegate <NSObject>

@optional
- (void)didEnterRegion:(CLRegion *)region;
- (void)didExitRegion:(CLRegion *)region;

@end

@interface FOBeaconTracking : NSObject

@property (nonatomic, weak) id<FOBeaconTrackingDelegate> delegate;

/**
 singltonインスタンスの取得
 @return FOTracking singlton インスタンス
 */
+ (FOBeaconTracking*)sharedInstance;

/**
 iBeacon監視開始
 */
- (void)start;

/**
 初期値 NO
 @brief デバッグログ表示切り替え
 @param debug
 */
- (void)setDebug:(BOOL)debug;

@end
