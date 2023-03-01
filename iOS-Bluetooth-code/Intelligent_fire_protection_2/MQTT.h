//
//  MQTT.h
//  Intelligent_fire_protection
//
//  Created by 王声䘵 on 2021/5/26.
//

#import <UIKit/UIKit.h>

#import <MQTTClient.h>
#import <MQTTWebsocketTransport.h>
#define WEAKSELF   __typeof(&*self) __weak weakSelf = self;

#define MAINWINDOWSWIDTH [[UIScreen mainScreen] bounds].size.width
#define MAINWINDOWSHEIGHT [[UIScreen mainScreen] bounds].size.height
NS_ASSUME_NONNULL_BEGIN

@interface MQTT : NSObject
@property (nonatomic, strong) MQTTSession *mySession;
-(void)connectServer:(NSString *)urlString userName:(NSString *)userName passWord:(NSString *)passWord topic:(NSArray *)topics;
-(void)disConnectServer;
-(void)sendMassage:(NSData *)msg topic:(NSString*)topic;

@end

NS_ASSUME_NONNULL_END
