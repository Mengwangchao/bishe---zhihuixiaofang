//
//  LocationViewController.h
//  Intelligent_fire_protection_2
//
//  Created by 王声䘵 on 2021/6/2.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MQTT.h"
#import "DBdata.h"
#import "DrawLine.h"
#import "DBRoom.h"
#import "DBRoomRuler.h"
#define MAINWINDOWSWIDTH [[UIScreen mainScreen] bounds].size.width
#define MAINWINDOWSHEIGHT [[UIScreen mainScreen] bounds].size.height
NS_ASSUME_NONNULL_BEGIN

@interface LocationViewController : UIViewController <CLLocationManagerDelegate>{
    CLLocationManager *_locationManager;    //
    CLBeaconRegion *_region;            //
    NSMutableArray *_detectedBeacons;            //存放接收到的beacons
}

@end

NS_ASSUME_NONNULL_END
