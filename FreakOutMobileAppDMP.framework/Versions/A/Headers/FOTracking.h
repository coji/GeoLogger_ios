//
//  FOTracking.h
//  FOTracking
//
//  Created by FreakOut inc, on 2014/07/24.
//  Copyright (c) 2014年 FreakOut inc,. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompleteBlock)(NSError *error, NSDictionary *result);

extern NSString *const FOTrackingFailureNotification;

@protocol FOTrackingDelegate <NSObject>
@required
- (void)trackingFailure:(NSError*)error;
@end

/**
 ログ送信重要度値
 */
typedef enum : short{
    FOTrackingImportanceLow = 3,
    FOTrackingImportanceMedium = 5,
    FOTrackingImportanceHigh = 10,
} FOTrackingImportance;

/**
 ログ送信間隔
 */
typedef enum : short{
    FOTrackingIntervalShort = 10,
    FOTrackingIntervalMedium = 20,
    FOTrackingIntervalLong = 30,
} FOTrackingInterval;

/**
 GET通信時に一回で送信するGET通信回数
 */
typedef enum : short{
    FOTrackingLimitConnectionOnceLow = 10,
    FOTrackingLimitConnectionOnceMedium = 20,
    FOTrackingLimitConnectionOnceHigh = 30,
} FOTrackingLimitConnectionOnce;

@interface FOTracking : NSObject
@property (nonatomic, weak) id<FOTrackingDelegate> delegate;

/**
 singltonインスタンスの取得
 @return FOTracking singlton インスタンス
 */
+ (FOTracking*)sharedInstance;

/**
 IDFAは自動出力されます。
 全てのパラメータはnil or null不可
 @brief 初期化
 @param applicationID アプリ固有ID
 @param advertiserID 広告主ID
 */
- (void)initialize:(NSString *)applicationID advertiserID:(NSString *)advertiserID;

/**
 { key : value } = &key=value
 @brief ログ送信データ登録
 @param params 送信ログのパラメータ
 */
- (void)tracking:(NSDictionary*)params;

/**
 @brief 会員IDとのシンク
 @param uaid 会員ID
 */
- (void)syncUserAudienceID:(NSString *)uaid;

/**
 通信エラー数がこの値以上になった場合、送信ログを破棄する。初期値 FOTrackingImportanceMedium
 @brief 送信情報全体の重要度設定
 @param importance 重要度値
 */
- (void)setImportance:(FOTrackingImportance)importance;
/**
 FOTrackingIntervalの何れかの値を指定可能。初期値 FOTrackingIntervalMedium
 @brief ログ送信間隔
 @param interval 送信間隔値
 */
- (void)setInterval:(FOTrackingInterval)interval;
/**
 FOTrackingLimitConnectionOnceの何れかの値を指定可能。初期値 FOTrackingLimitConnectionOnceMedium
 @brief 一回のGET通信で送信するリクエストの最大値
 @param limit 通信上限値
 */
- (void)setLimitOnce:(FOTrackingLimitConnectionOnce)limit;

/**
 監視するiBeaconのuuidのリストをサーバーから返す
 @brief iBeaconのuuidのリストを返す
 @param completeHandler 通信が終わったときのコールバック
 */
- (void)getIBeacons:(CompleteBlock)completeBlock;

/**
 ユーザーのセグメントリストを返す
 @brief セグメントリストを返す
 @param completeHandler 通信が終わったときのコールバック
 */
- (void)getSegments:(CompleteBlock)completeBlock;

/**
 DMPサーバーにすぐparams情報を送る、timerを利用しない
 @brief DMPサーバーにすぐparams情報を送る
 @params トラッキングしたい情報
 */
- (void)send:(NSDictionary *)params;

/**
 初期値 NO
 @brief デバッグログ表示切り替え
 @param debug
 */
- (void)setDebug:(BOOL)debug;
@end
