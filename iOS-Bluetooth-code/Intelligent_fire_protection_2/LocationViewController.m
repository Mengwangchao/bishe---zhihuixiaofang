//
//  LocationIbeacon.m
//  Intelligent_fire_protection
//
//  Created by 王声䘵 on 2021/3/9.
//
#import "LocationViewController.h"
//#import "MQTT.h"
#import <OHMySQL.h>
#define MY_UUID @"fda50693-a4e2-4fb1-afcf-c6eb07647825"
#define MY_REGION_IDENTIFIER @"my region"
#define RssiProofreading 0
//static NSString *const server_ip = @"ws://192.168.1.101:15675/ws";
static NSString *const server_ip = @"ws://101.34.92.39:8888/ws";

//static NSString *const server_ip = @"ws://172.19.194.91:9999/ws";
@interface LocationViewController ()<SRWebSocketDelegate>{
    bool startBool;
    double heightRuler;
    OHMySQLStoreCoordinator *coordinator;
    double widthRuler;
     NSArray *myTopics;
    int rssiFlag;
    
    long rssi_Rssi[100];
    
    long rssi_Major[100];
    
    long rssi_Major_flag[100];
    int rssi_Major_count;
//    long rssi_1;
//
//    long rssi_2;
//
//    long rssi_3;
//
//    long rssi_4;
    UIImageView *backImag;
    bool connectFlag;
    
    bool pushButtonFlag;
    double realWidth;
    double realHeight;
    
    int locationFlag;
   
}

@property(nonatomic ,strong)MQTT *myMqtt;

@property(nonatomic,strong)NSMutableArray *dbDataArray;
@property(nonatomic,strong)NSTimer *time;
@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong)UIImageView *LabelPointA;
@property(nonatomic,strong)UIImageView *LabelPointB;
@property(nonatomic,strong)UIImageView *LabelPointC;
@property(nonatomic,strong)UIImageView *LabelPointD;
@property(nonatomic,strong)UILabel *LabelPointMy;
@property(nonatomic,strong)UILabel *MyPoint;
@property(nonatomic,strong)CLBeacon *maxIbeacon;
@property(nonatomic,strong)CLBeacon *midIbeacon;
@property(nonatomic,strong)CLBeacon *minIbeacon;
@property(nonatomic,strong)UIView *majorView;
@property(nonatomic,strong)UILabel *missingBaseStationLabel;

@property(nonatomic,strong)UIView *boxView;
@property(nonatomic,strong)UIButton *stopButton;
@property(nonatomic,strong)UIButton *startButton;


@property(nonatomic,strong)UIView *max1View;
@property(nonatomic,strong)UIView *max2View;
@property(nonatomic,strong)UIView *max3View;
@property(nonatomic,strong)UIView *max4View;


@property(nonatomic,strong)UIButton *pushButtonStart;
@property(nonatomic,strong)UIButton *pushButtonStop;
@property(nonatomic,strong)UILabel *pushSuccessLabel;



@property(nonatomic,strong)DrawLine *blueLine;
@property(nonatomic,strong)DrawLine *greenLine;
@property(nonatomic,strong)DrawLine *blackLine;
@property(nonatomic,strong)DrawLine *grayLine;

@property(nonatomic,strong)NSString* myroom;
@property(nonatomic,strong)UIButton *locationButton;
@end

@implementation LocationViewController

 
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    startBool=true;
    if ( self.navigationController.navigationBar.isHidden==NO) {
        self.navigationController.navigationBar.hidden=YES;
    }

    locationFlag=1;
    
    
    widthRuler=0;
    heightRuler=0;
    
    
    UIImageView *backgroundPicView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 70, MAINWINDOWSWIDTH, MAINWINDOWSHEIGHT-100)];
//    backgroundPicView.image=[UIImage imageNamed:@"testPic"];
    backgroundPicView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:backgroundPicView];
    
    UIView *titleView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, MAINWINDOWSWIDTH, 120)];
    titleView.backgroundColor=[UIColor colorWithRed:64.0/256.0 green:81.0/256.0  blue:184.0/256.0  alpha:1.0];
    [self.view addSubview:titleView];
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, titleView.frame.origin.y+55, titleView.frame.size.width, 50)];
    titleLabel.text=@"智慧消防";
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.font=[UIFont systemFontOfSize:23.0];
    [self.view addSubview:titleLabel];
    
    
    
    _boxView=[[UIView alloc]initWithFrame:CGRectMake(30, titleView.frame.origin.y+titleView.frame.size.height+40, MAINWINDOWSWIDTH-60, MAINWINDOWSHEIGHT/1.8)];
    backImag=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background3"]];
    backImag.backgroundColor=[UIColor clearColor];
    backImag.frame=CGRectMake(0, 0, _boxView.frame.size.width-7, _boxView.frame.size.height-7);
    [_boxView addSubview:backImag];
    _boxView.backgroundColor=[UIColor whiteColor];
    _boxView.layer.borderWidth=1;
    _boxView.layer.borderColor=[UIColor grayColor].CGColor;
    [self.view addSubview:_boxView];

//    heightRuler=(_boxView.frame.size.height-7)/7.7;//_boxView.frame.size.height/高度实际距离
//    widthRuler=(_boxView.frame.size.width-7)/7.7;//_boxView.frame.size.width/宽度实际距离
    
    
    _LabelPointA=[[UIImageView alloc]init];
    [_LabelPointA setImage:[UIImage imageNamed:@"basePic"]];
    [self.boxView addSubview:_LabelPointA];
    
    _LabelPointB=[[UIImageView alloc]init];
    [_LabelPointB setImage:[UIImage imageNamed:@"basePic"]];
    [self.boxView addSubview:_LabelPointB];
    
    _LabelPointC=[[UIImageView alloc]init];
    [_LabelPointC setImage:[UIImage imageNamed:@"basePic"]];
    [self.boxView addSubview:_LabelPointC];
    
    _LabelPointD=[[UIImageView alloc]init];
    [_LabelPointD setImage:[UIImage imageNamed:@"basePic"]];
    [self.boxView addSubview:_LabelPointD];
    
    _LabelPointMy=[[UILabel alloc]init];
    _LabelPointMy.backgroundColor=[UIColor redColor];
    _LabelPointMy.layer.cornerRadius=5;
    [self.boxView addSubview:_LabelPointMy];
    
    _MyPoint = [[UILabel alloc]init];
    _MyPoint.backgroundColor=[UIColor clearColor];
    _MyPoint.textColor=[UIColor blackColor];
    _MyPoint.hidden=YES;
    _MyPoint.font=[UIFont systemFontOfSize:8.0];
    [self.boxView addSubview:_MyPoint];
    
    _startButton=[[UIButton alloc]initWithFrame:CGRectMake(30, MAINWINDOWSHEIGHT-150, 70, 30)];
    _startButton.backgroundColor=[UIColor clearColor];
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
    [_startButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_startButton addTarget:self action:@selector(startButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startButton];
    
    _stopButton=[[UIButton alloc]initWithFrame:CGRectMake(100, MAINWINDOWSHEIGHT-150, 70, 30)];
    _stopButton.backgroundColor=[UIColor clearColor];
    [_stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    [_stopButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_stopButton addTarget:self action:@selector(stopButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_stopButton];
    
    _pushButtonStart =[[UIButton alloc]initWithFrame:CGRectMake(170, MAINWINDOWSHEIGHT-150, 140, 30)];
    _pushButtonStart.backgroundColor=[UIColor clearColor];
    [_pushButtonStart setTitle:@"开始采指纹" forState:UIControlStateNormal];
    [_pushButtonStart setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_pushButtonStart addTarget:self action:@selector(pushButtonStartClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_pushButtonStart];
    
    _pushButtonStop =[[UIButton alloc]initWithFrame:CGRectMake(270, MAINWINDOWSHEIGHT-150, 140, 30)];
    _pushButtonStop.backgroundColor=[UIColor clearColor];
    [_pushButtonStop setTitle:@"结束采指纹" forState:UIControlStateNormal];
    [_pushButtonStop setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_pushButtonStop addTarget:self action:@selector(pushButtonStopClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_pushButtonStop];
   
    
    _pushSuccessLabel=[[UILabel alloc]initWithFrame:CGRectMake(MAINWINDOWSWIDTH/2-70, MAINWINDOWSHEIGHT/2-15, 140, 30)];
    _pushSuccessLabel.backgroundColor=[UIColor clearColor];
    _pushSuccessLabel.text=@"上传指纹成功";
    _pushSuccessLabel.hidden=YES;
    [self.view addSubview:_pushSuccessLabel];
    _locationButton=[[UIButton alloc]initWithFrame:CGRectMake(MAINWINDOWSWIDTH/2-120, MAINWINDOWSHEIGHT-200, 240, 30)];
    _locationButton.backgroundColor=[UIColor clearColor];
    [_locationButton setTitle:@"更改定位方式:当前指纹定位" forState:UIControlStateNormal];
    [_locationButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_locationButton addTarget:self action:@selector(locationButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_locationButton];


    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    rssiFlag=1;
    realWidth=-100;
    realHeight=-100;
    _myroom=@"";
    pushButtonFlag=false;
    connectFlag=false;
    for (int k=0; k<100; k++) {
        rssi_Rssi[k]=0;
        rssi_Major[k]=0;
        rssi_Major_flag[k]=0;
    }
    myTopics = @[@"dwm/node/1222/uplink/status",@"dwm/node/1222/uplink/config",@"dwm/node/1222/uplink/location"];
    [self connectMQTT:server_ip userName:@"" passWord:@"" topic:myTopics];
    [self connectDB];
    [self turnOnBeacon];
    startBool=true;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    NSMutableDictionary *dic1=[[NSMutableDictionary alloc]init];
    [dic1 setObject:@"false" forKey:@"present"];
    NSData *data1=[self returnDataWithDictionary:dic1];
    [self sendMassage:data1 topic:myTopics[0]];
//    
    [self disconnectMQTT];
    [self disconnectDB];
    startBool=false;
    [self stopBeaconRanging];
    
}
-(void)locationButtonClick{
    if (locationFlag==1) {
        locationFlag=2;
        [_locationButton setTitle:@"更改定位方式:当前测距定位" forState:UIControlStateNormal];
    }else if(locationFlag==2){
        locationFlag=1;
        [_locationButton setTitle:@"更改定位方式:当前指纹定位" forState:UIControlStateNormal];
    }
}
-(void)pushButtonStartClick{
    if (pushButtonFlag) {
        
    }else{
        [_pushButtonStart setTitle:@"正在采指纹" forState:UIControlStateNormal];
        
        UIAlertController *widthAlert=[UIAlertController alertControllerWithTitle:@"输入宽度" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *conform=[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            self->realWidth=[widthAlert.textFields.firstObject.text doubleValue];
            self->realHeight=[widthAlert.textFields.lastObject.text doubleValue];
            
            self->pushButtonFlag=true;
        }];
        UIAlertAction *cancel=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [widthAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder=@"输入整数类型宽度";
        }];
        [widthAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder=@"输入整数类型长度";
        }];
        [widthAlert addAction:conform];
        [widthAlert addAction:cancel];
        [self presentViewController:widthAlert animated:NO completion:nil];
    }
}
-(void)pushButtonStopClick{
    if (pushButtonFlag) {
        [_pushButtonStart setTitle:@"开始采指纹" forState:UIControlStateNormal];
        pushButtonFlag=false;
        rssiFlag=1;
    }
}
-(void)connectMQTT:(NSString *)urlString userName:(NSString *)userName passWord:(NSString *)passWord topic:(NSArray *)topics{
    if (_myMqtt) {
        
    }else{
        
        _myMqtt=[[MQTT alloc]init];
        [_myMqtt connectServer:urlString userName:userName passWord:passWord topic:topics];
       
        
    }
}
-(void)disconnectMQTT{
    if (_myMqtt) {
        [_myMqtt disConnectServer];
        _myMqtt=nil;
    }
}
-(void)sendMassage:(NSData *)msg topic:(NSString *)topic{
    if (_myMqtt) {
        
        [_myMqtt sendMassage:msg topic:topic];
        
    }else{
        NSLog(@"_myMqtt未初始化");
        
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 
#pragma mark - Beacons Methods
- (void) turnOnBeacon{
    [self initLocationManager];
    [self initBeaconRegion];
    [self initDetectedBeaconsList];
        
        [self startBeaconRanging];
    
}
#pragma mark Init Beacons
- (void) initLocationManager{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        [self checkLocationAccessForRanging];
    }
}
 
- (void) initDetectedBeaconsList{
    if (!_detectedBeacons) {
        _detectedBeacons = [[NSMutableArray array] init];
    }
}
 
- (void) initBeaconRegion{
    if (_region)
        return;
    
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:MY_UUID];
    _region = [[CLBeaconRegion alloc] initWithUUID:proximityUUID identifier:MY_REGION_IDENTIFIER];
    _region.notifyEntryStateOnDisplay = YES;
}
 
#pragma mark Beacons Ranging
 
- (void) startBeaconRanging{
    if (!_locationManager || !_region) {
        return;
    }
    if (_locationManager.rangedRegions.count > 0) {
        NSLog(@"Didn't turn on ranging: Ranging already on.");
        return;
    }
    
    [_locationManager startRangingBeaconsInRegion:_region];
    
}
 
- (void) stopBeaconRanging{
    if (!_locationManager || !_region) {
        return;
    }
    [_locationManager stopRangingBeaconsInRegion:_region];
}
 
//Location manager delegate method
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region{



    if(_majorView){
        [_majorView removeFromSuperview];
        _majorView=nil;
    }
    _majorView=[[UIView alloc]initWithFrame:CGRectMake(0, 100, MAINWINDOWSWIDTH/2, 280)];
    _majorView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_majorView];
    
    if (_missingBaseStationLabel) {
        [_missingBaseStationLabel removeFromSuperview];
        _missingBaseStationLabel=nil;
    }
    if (beacons.count == 0) {

        NSLog(@"No beacons found nearby.");
    } else {
        _detectedBeacons = beacons;
        _dataArray=[[NSMutableArray alloc]init];
        NSLog(@"beacons count:%lu", beacons.count);
        int i=0;
        
        
        for (CLBeacon *beacon in beacons) {
            [_dataArray addObject:beacon];
            i++;
//            NSLog(@"%@", [self detailsStringForBeacon:beacon]);
        }

      

        bool rssiZeroFlag=false;
        int p=0;
        for (CLBeacon *ble in _dataArray) {

           
            if (ble.rssi==0) {
                rssiZeroFlag=true;
                
            }else {
                p++;
            }
        }
        if (rssiZeroFlag&&p>=4) {
            rssiZeroFlag=false;
        }
        if (_blueLine) {
            [_blueLine removeFromSuperview];
            _blueLine=nil;
        }
        if (_greenLine) {
            [_greenLine removeFromSuperview];
            _greenLine=nil;
        }
        if (_blackLine) {
            [_blackLine removeFromSuperview];
            _blackLine=nil;
        }
        if (_grayLine) {
            [_grayLine removeFromSuperview];
            _grayLine=nil;
        }
        if(_dataArray.count<4){//       次数应该小于等于2
            NSLog(@"基站数不足");
            _missingBaseStationLabel=[[UILabel alloc]initWithFrame:CGRectMake(MAINWINDOWSWIDTH/2-50, MAINWINDOWSHEIGHT/2, 100, 50)];
            _missingBaseStationLabel.text=@"基站数不足";
            _missingBaseStationLabel.backgroundColor=[UIColor clearColor];
            [self.view addSubview:_missingBaseStationLabel];
        }
        else if(locationFlag==1){

            
            if (_MyPoint.hidden==NO) {
                _MyPoint.hidden=YES;
            }
            if (pushButtonFlag&&realWidth!=-100&&realHeight!=-100) {
                            double x=widthRuler*realWidth;
                            double y=heightRuler*realHeight;
                
                            _LabelPointMy.frame=CGRectMake(x,y, 7, 7);
                if (rssiFlag==1) {
                    OHMySQLQueryContext *queryContext = [OHMySQLQueryContext new];
                    
                    //设置连接器
                    queryContext.storeCoordinator = coordinator;
                    
                    //获取test表中的数据
                    OHMySQLQueryRequest *query = [OHMySQLQueryRequestFactory SELECT:@"ibeacon_room" condition:nil orderBy:@[@"major",@"room"] ascending:NO];
                    NSError *error = nil;
                    
                    //task用于存放数据库返回的数据
                    
                    NSArray *tasks = [queryContext executeQueryRequestAndFetchResult:query error:&error];
                    NSMutableArray *arrayModels = [NSMutableArray array];
                    if (tasks != nil) {
                        for (NSDictionary *dict in tasks) {
                            
                            DBRoom *model = [DBRoom testWithDict:dict];
                            [arrayModels addObject:model];
                        }
                    }
                    else
                        NSLog(@"%@",error.description);
                    long MaxRssi=-100;
                    NSString *MaxMajor;
                    for (CLBeacon *beacon in _dataArray) {
                        if (beacon.rssi>MaxRssi&&beacon.rssi!=0) {
                            MaxRssi=beacon.rssi;
                            MaxMajor=[NSString stringWithFormat:@"%@",beacon.major];
                        }
                    }
                    for (DBRoom *data in arrayModels) {
                        if ([[NSString stringWithFormat:@"%@",data.major] isEqual:MaxMajor]) {
                            _myroom=data.room;
                            
                        }
                    }
                    int i=0;
                    for (CLBeacon *beacon in _dataArray) {
                        
                        rssi_Major[i]= beacon.major.longValue;
                        i++;
                        
                    }
                    rssi_Major_count=i;
                }
                            if (rssiFlag==40) {
                                rssiFlag=1;
                
                                NSString *xStr=[NSString stringWithFormat:@"%.2lf",x];//widthRuler*所在现实位置，单位:米
                                NSString *yStr=[NSString stringWithFormat:@"%.2lf",y];//heightRuler*所在现实位置，单位:米
                
                
                                NSString *pushString=@"";
                                for (int i=0; i<rssi_Major_count; i++) {
                                    if (rssi_Rssi[i]<=0&&rssi_Rssi[i]>-10) {
                                        
                                    }else{
                                        pushString=[NSString stringWithFormat:@"%@%ld:%ld,",pushString,rssi_Major[i],rssi_Rssi[i]/rssi_Major_flag[i]];
                                    }
                                   
                                }
                                [self pushPoint:pushString x:xStr y:yStr room:_myroom];
//                                [self pushPoint:[NSString stringWithFormat:@"10160:%ld,10170:%ld,10180:%ld,10190:%ld,",rssi_1/40,rssi_2/40,rssi_3/40,rssi_4/40] x:xStr y:yStr room:_myroom];
//                                rssi_1=0;
//                                rssi_2=0;
//                                rssi_3=0;
//                                rssi_4=0;
                                for (int k=0; k<100; k++) {
                                    rssi_Rssi[k]=0;
                                    rssi_Major[k]=0;
                                    rssi_Major_flag[k]=0;
                                }
                                pushButtonFlag=false;
                                [_pushButtonStart setTitle:@"开始采指纹" forState:UIControlStateNormal];
                                _pushSuccessLabel.hidden=NO;

                                [NSTimer scheduledTimerWithTimeInterval:1.5 repeats:NO block:^(NSTimer * _Nonnull timer) {
                                    self.pushSuccessLabel.hidden=YES;
                                }];
                            }else if (rssiZeroFlag){
                                NSLog(@"存在rssi=0！！！！");
                            }
                            else{
                                rssiFlag++;
                                for (CLBeacon *ble in _dataArray) {
                                    long ble_major=ble.major.longValue;
//                                    if (ble_major==10160) {
//                                        rssi_1=rssi_1+ble.rssi+RssiProofreading;
//                                    }else if (ble_major==10170){
//                                        rssi_2=rssi_2+ble.rssi+RssiProofreading;
//                                    }else if (ble_major==10180){
//                                        rssi_3=rssi_3+ble.rssi+RssiProofreading;
//                                    }else if (ble_major==10190){
//                                        rssi_4=rssi_4+ble.rssi+RssiProofreading;
//                                    }
                                    for (int i=0; i<_dataArray.count; i++) {
                                        if (ble_major==rssi_Major[i]&&ble.rssi!=0) {
                                            rssi_Rssi[i]=rssi_Rssi[i]+ble.rssi+RssiProofreading;
                                            rssi_Major_flag[i]++;
                                            break;
                                        }
                                    }
                             }
                            }
            }else{
                
                CGPoint myPoint=[self getPoint:_dataArray room:_myroom];
                
//                CGPoint myPoint=[self getPoint2:_dataArray room:@"tian"];
                _LabelPointMy.frame=CGRectMake(myPoint.x,myPoint.y, 7, 7);
                
                            NSMutableDictionary *dic1=[[NSMutableDictionary alloc]init];
                            [dic1 setObject:@"true" forKey:@"present"];
                            NSData *data1=[self returnDataWithDictionary:dic1];
                            [self sendMassage:data1 topic:myTopics[0]];
                
                
                            NSMutableDictionary *dic2=[[NSMutableDictionary alloc]init];
                            NSMutableDictionary *dic21=[[NSMutableDictionary alloc]init];
                            [dic21 setObject:@"BleTag" forKey:@"label"];
                            [dic21 setObject:@"BLE" forKey:@"locationType"];
                            [dic21 setObject:@"TAG" forKey:@"nodeType"];//节点类型（基站/标签）
                            [dic21 setObject:@"false" forKey:@"ble"];
                            [dic21 setObject:@"true" forKey:@"leds"];
                            [dic21 setObject:@"false" forKey:@"uwbFirmwareUpdate"];
                            NSMutableDictionary *dic211=[[NSMutableDictionary alloc]init];
                            [dic211 setObject:@"true" forKey:@"stationaryDetection"];
                            [dic211 setObject:@"true" forKey:@"responsive"];
                            [dic211 setObject:@"true" forKey:@"locationEngine"];
                            [dic211 setObject:@"100" forKey:@"nomUpdateRate"];
                            [dic211 setObject:@"500" forKey:@"statUpdateRate"];
                            [dic21 setObject:dic211 forKey:@"tag"];
                            [dic2 setObject:dic21 forKey:@"configuration"];
                            NSData *data2=[self returnDataWithDictionary:dic2];
                            [self sendMassage:data2 topic:myTopics[1]];
                OHMySQLQueryContext *queryContext = [OHMySQLQueryContext new];
                
                //设置连接器
                queryContext.storeCoordinator = coordinator;
                //获取test表中的数据
                OHMySQLQueryRequest *query1 = [OHMySQLQueryRequestFactory SELECT:@"ibeacon_room_heightandwidth" condition:nil orderBy:@[@"width",@"room",@"height",@"roomid"] ascending:NO];
                NSError *error1 = nil;
                
                //task用于存放数据库返回的数据
                
                NSArray *tasks1 = [queryContext executeQueryRequestAndFetchResult:query1 error:&error1];
                NSMutableArray *arrayModels1 = [NSMutableArray array];
                if (tasks1 != nil) {
                    for (NSDictionary *dict in tasks1) {
                        
                        DBRoomRuler *model = [DBRoomRuler testWithDict:dict];
                        [arrayModels1 addObject:model];
                    }
                }
                else
                    NSLog(@"%@",error1.description);
                long MaxRssi=-100;
                NSString *MaxMajor;
                for (CLBeacon *beacon in _dataArray) {
                    if (beacon.rssi>MaxRssi&&beacon.rssi!=0) {
                        MaxRssi=beacon.rssi;
                        MaxMajor=[NSString stringWithFormat:@"%@",beacon.major];
                    }
                }
                int roomid=1;
                double roomWidth=0;
                for (DBRoomRuler *data in arrayModels1) {
                    if ([data.room isEqual:_myroom]) {
                        NSString *roomIdStr=data.roomid;
                        NSString *roomwidthstr=data.width;
                        roomWidth=[roomwidthstr doubleValue];
                        roomid=[roomIdStr intValue];
                    }
                }
                            NSMutableDictionary *dic3=[[NSMutableDictionary alloc]init];
                            NSMutableDictionary *dic31=[[NSMutableDictionary alloc]init];
                if (roomid==1) {
                    [dic31 setObject:[NSString stringWithFormat:@"%f",(_LabelPointMy.frame.origin.x)/widthRuler] forKey:@"x"];
                }else if(roomid==2){
                    [dic31 setObject:[NSString stringWithFormat:@"%f",8+(_LabelPointMy.frame.origin.x)/widthRuler] forKey:@"x"];
                }
                            
//
////                            [dic31 setObject:[NSString stringWithFormat:@"%f",(-My+_boxView.frame.origin.y+_boxView.frame.size.height-15)/ruler] forKey:@"y"];

                
                            [dic31 setObject:[NSString stringWithFormat:@"%f",roomWidth-(_LabelPointMy.frame.origin.y)/heightRuler] forKey:@"y"];
//                [dic31 setObject:@"11" forKey:@"x"];
//                [dic31 setObject:@"11" forKey:@"y"];
                            NSLog(@"-----------%.2f",(_LabelPointMy.frame.size.height)/heightRuler);
                            [dic31 setObject:[NSString stringWithFormat:@"0.00"] forKey:@"z"];
                
                            [dic31 setObject:@"40" forKey:@"quality"];
                            [dic3 setObject:dic31 forKey:@"position"];
                            [dic3 setObject:@"999" forKey:@"superFrameNumber"];
                            NSData *data3=[self returnDataWithDictionary:dic3];
                            [self sendMassage:data3 topic:myTopics[2]];
//                            NSLog(@"-----------上传的x:%@,y:%@---------------",[dic31 valueForKey:@"x"],[dic31 valueForKey:@"y"]);

            }
            [_LabelPointMy reloadInputViews];
              
                
            _LabelPointA.frame=CGRectMake(0, 0, 15, 15);
            _LabelPointB.frame=CGRectMake(_boxView.frame.size.width-8, 0, 15, 15);
            _LabelPointC.frame=CGRectMake(0, _boxView.frame.size.height-8, 15, 15);
            _LabelPointD.frame=CGRectMake(_boxView.frame.size.width-8, _boxView.frame.size.height-8, 15, 15);
                
            [_LabelPointA reloadInputViews];
            [_LabelPointB reloadInputViews];
            [_LabelPointC reloadInputViews];
            [_LabelPointD reloadInputViews];
            
    
            
//
        }
        else if (locationFlag==2){
            if (_MyPoint.hidden==YES) {
                _MyPoint.hidden=NO;
            }
            //圆A坐标和半径，半径为accuracy
            //比例尺   10m
            CLBeacon *bea1=_dataArray[0];
            CLBeacon *bea2=_dataArray[1];
            CLBeacon *bea3=_dataArray[2];
            CLBeacon *bea4=_dataArray[3];
            
            
            double ruler=widthRuler;                  //黄绿两点像素差/实际米数
            CGPoint Point1=[self GetPoint:bea1.major ruler:ruler];
            double r1=[self calcDistByRSSI:(int)bea1.rssi+RssiProofreading]*ruler;
            CGPoint Point2=[self GetPoint:bea2.major ruler:ruler];
            double r2=[self calcDistByRSSI:(int)bea2.rssi+RssiProofreading]*ruler;
            //圆C坐标和半径，半径为accuracy
            CGPoint Point3=[self GetPoint:bea3.major ruler:ruler];
            double r3=[self calcDistByRSSI:(int)bea3.rssi+RssiProofreading]*ruler;
            
            CGPoint Point4=[self GetPoint:bea4.major ruler:ruler];
            double r4=[self calcDistByRSSI:(int)bea4.rssi+RssiProofreading]*ruler;
            
          
        //
            CGPoint pointA = [self sidePointCalculationWith:Point1.x :Point1.y :r1
                                                           :Point2.x:Point2.y :r2
                                                           :Point3.x :Point3.y ];
            CGPoint pointB = [self sidePointCalculationWith:Point2.x :Point2.y :r2
                                                           :Point3.x :Point3.y :r3
                                                           :Point1.x :Point1.y ];
            CGPoint pointC = [self sidePointCalculationWith:Point1.x :Point1.y :r1
                                                           :Point3.x :Point3.y :r3
                                                           :Point2.x :Point2.y ];
            
            CGPoint pointA2 = [self sidePointCalculationWith:Point4.x :Point4.y :r4
                                                           :Point2.x:Point2.y :r2
                                                           :Point3.x :Point3.y ];
            CGPoint pointB2 = [self sidePointCalculationWith:Point2.x :Point2.y :r2
                                                           :Point3.x :Point3.y :r3
                                                           :Point4.x :Point4.y ];
            CGPoint pointC2 = [self sidePointCalculationWith:Point4.x :Point4.y :r4
                                                           :Point3.x :Point3.y :r3
                                                           :Point2.x :Point2.y ];
            
            CGPoint pointA3 = [self sidePointCalculationWith:Point4.x :Point4.y :r4
                                                           :Point1.x:Point1.y :r1
                                                           :Point3.x :Point3.y ];
            CGPoint pointB3 = [self sidePointCalculationWith:Point1.x :Point1.y :r1
                                                           :Point3.x :Point3.y :r3
                                                           :Point4.x :Point4.y ];
            CGPoint pointC3 = [self sidePointCalculationWith:Point4.x :Point4.y :r4
                                                           :Point3.x :Point3.y :r3
                                                           :Point1.x :Point1.y ];
            
            CGPoint pointA4 = [self sidePointCalculationWith:Point4.x :Point4.y :r4
                                                           :Point2.x:Point2.y :r2
                                                           :Point1.x :Point1.y ];
            CGPoint pointB4 = [self sidePointCalculationWith:Point2.x :Point2.y :r2
                                                           :Point1.x :Point1.y :r1
                                                           :Point4.x :Point4.y ];
            CGPoint pointC4 = [self sidePointCalculationWith:Point4.x :Point4.y :r4
                                                           :Point1.x :Point1.y :r1
                                                           :Point2.x :Point2.y ];
            int xflag=12;
            if (pointA.x==0) {
                xflag--;
            }
            if (pointB.x==0) {
                xflag--;
            }
            if (pointC.x==0) {
                xflag--;
            }
            if (pointA2.x==0) {
                xflag--;
            }
            if (pointB2.x==0) {
                xflag--;
            }
            if (pointC2.x==0) {
                xflag--;
            }
            if (pointA3.x==0) {
                xflag--;
            }
            if (pointB3.x==0) {
                xflag--;
            }
            if (pointC3.x==0) {
                xflag--;
            }
            if (pointA4.x==0) {
                xflag--;
            }
            if (pointB4.x==0) {
                xflag--;
            }
            if (pointC4.x==0) {
                xflag--;
            }
            
            int yflag=12;
            if (pointA.y==0) {
                yflag--;
            }
            if (pointB.y==0) {
                yflag--;
            }
            if (pointC.y==0) {
                yflag--;
            }
            if (pointA2.y==0) {
                yflag--;
            }
            if (pointB2.y==0) {
                yflag--;
            }
            if (pointC2.y==0) {
                yflag--;
            }
            if (pointA3.y==0) {
                yflag--;
            }
            if (pointB3.y==0) {
                yflag--;
            }
            if (pointC3.y==0) {
                yflag--;
            }
            if (pointA4.y==0) {
                yflag--;
            }
            if (pointB4.y==0) {
                yflag--;
            }
            if (pointC4.y==0) {
                yflag--;
            }
            double Mx = (pointA.x + pointB.x + pointC.x+pointA2.x + pointB2.x + pointC2.x+pointA3.x + pointB3.x + pointC3.x+pointA4.x + pointB4.x + pointC4.x) / xflag;
            
            double My = (pointA.y + pointB.y + pointC.y+pointA2.y + pointB2.y + pointC2.y+pointA3.y + pointB3.y + pointC3.y+pointA4.y + pointB4.y + pointC4.y) / yflag;
            
            

            
            _LabelPointA.frame=CGRectMake(Point1.x-7.5, Point1.y-7.5, 15, 15);
            _LabelPointB.frame=CGRectMake(Point2.x-7.5, Point2.y-7.5, 15, 15);
            _LabelPointC.frame=CGRectMake(Point3.x-7.5, Point3.y-7.5, 15, 15);
            _LabelPointD.frame=CGRectMake(Point4.x-7.5, Point4.y-7.5, 15, 15);
            _LabelPointMy.frame=CGRectMake(Mx, My, 7, 7);
            
            _MyPoint.frame=CGRectMake(_LabelPointMy.frame.origin.x-35, _LabelPointMy.frame.origin.y-20, 70, 20);
            _MyPoint.text=[NSString stringWithFormat:@"(%.2f,%.2f)",Mx,My];
            NSLog(@"x=%f   y=%f---------Mx=%f     My=%f",_LabelPointMy.frame.origin.x,_LabelPointMy.frame.origin.y,Mx,My);
            
            _blueLine=[[DrawLine alloc]initWithFrame:self.view.frame startPoint:_LabelPointA.center stopPoint:_LabelPointMy.center LineColor:[UIColor colorWithWhite:0.5 alpha:1]];
            
            _greenLine=[[DrawLine alloc]initWithFrame:self.view.frame startPoint:_LabelPointB.center stopPoint:_LabelPointMy.center LineColor:[UIColor colorWithWhite:0.5 alpha:1]];
            _blackLine=[[DrawLine alloc]initWithFrame:self.view.frame startPoint:_LabelPointC.center stopPoint:_LabelPointMy.center LineColor:[UIColor colorWithWhite:0.5 alpha:1]];
            _grayLine=[[DrawLine alloc]initWithFrame:self.view.frame startPoint:_LabelPointD.center stopPoint:_LabelPointMy.center LineColor:[UIColor colorWithWhite:0.5 alpha:1]];
            [self.boxView addSubview:_greenLine];
            [self.boxView addSubview:_blackLine];
            [self.boxView addSubview:_blueLine];
            [self.boxView addSubview:_grayLine];
      
            
            NSMutableDictionary *dic1=[[NSMutableDictionary alloc]init];
            [dic1 setObject:@"true" forKey:@"present"];
            NSData *data1=[self returnDataWithDictionary:dic1];
            [self sendMassage:data1 topic:myTopics[0]];


            NSMutableDictionary *dic2=[[NSMutableDictionary alloc]init];
            NSMutableDictionary *dic21=[[NSMutableDictionary alloc]init];
            [dic21 setObject:@"BleTag" forKey:@"label"];
            [dic21 setObject:@"BLE" forKey:@"locationType"];
            [dic21 setObject:@"TAG" forKey:@"nodeType"];//节点类型（基站/标签）
            [dic21 setObject:@"false" forKey:@"ble"];
            [dic21 setObject:@"true" forKey:@"leds"];
            [dic21 setObject:@"false" forKey:@"uwbFirmwareUpdate"];
            NSMutableDictionary *dic211=[[NSMutableDictionary alloc]init];
            [dic211 setObject:@"true" forKey:@"stationaryDetection"];
            [dic211 setObject:@"true" forKey:@"responsive"];
            [dic211 setObject:@"true" forKey:@"locationEngine"];
            [dic211 setObject:@"100" forKey:@"nomUpdateRate"];
            [dic211 setObject:@"500" forKey:@"statUpdateRate"];
            [dic21 setObject:dic211 forKey:@"tag"];
            [dic2 setObject:dic21 forKey:@"configuration"];
            NSData *data2=[self returnDataWithDictionary:dic2];
            [self sendMassage:data2 topic:myTopics[1]];

            NSMutableDictionary *dic3=[[NSMutableDictionary alloc]init];
            NSMutableDictionary *dic31=[[NSMutableDictionary alloc]init];
                            [dic31 setObject:[NSString stringWithFormat:@"%f",(_LabelPointMy.frame.size.width)/widthRuler] forKey:@"x"];
//
                          [dic31 setObject:[NSString stringWithFormat:@"%f",(_LabelPointMy.frame.size.height)/heightRuler] forKey:@"y"];

            NSLog(@"-----------%.2f",(_LabelPointMy.frame.size.height)/heightRuler);
            [dic31 setObject:[NSString stringWithFormat:@"0.00"] forKey:@"z"];

            [dic31 setObject:@"40" forKey:@"quality"];
            [dic3 setObject:dic31 forKey:@"position"];
            [dic3 setObject:@"999" forKey:@"superFrameNumber"];
            NSData *data3=[self returnDataWithDictionary:dic3];
            [self sendMassage:data3 topic:myTopics[2]];
            NSLog(@"-----------上传的x:%@,y:%@---------------",[dic31 valueForKey:@"x"],[dic31 valueForKey:@"y"]);
            [_LabelPointA reloadInputViews];
            [_LabelPointB reloadInputViews];
            [_LabelPointC reloadInputViews];
            [_LabelPointMy reloadInputViews];
            [_MyPoint reloadInputViews];
        }
    }
}

//指纹定位匹配
-(CGPoint)getPoint:(NSArray *)beaconArray room:(NSString *)room{
    CGPoint myPoint;
    NSMutableArray *rssiArray=[[NSMutableArray alloc]init];
    OHMySQLQueryContext *queryContext = [OHMySQLQueryContext new];
    
    //设置连接器
    queryContext.storeCoordinator = coordinator;
    //获取test表中的数据
    OHMySQLQueryRequest *query1 = [OHMySQLQueryRequestFactory SELECT:@"ibeacon_room" condition:nil orderBy:@[@"major",@"room",@"background"] ascending:NO];
    NSError *error1 = nil;
    
    //task用于存放数据库返回的数据
    
    NSArray *tasks1 = [queryContext executeQueryRequestAndFetchResult:query1 error:&error1];
    NSMutableArray *arrayModels1 = [NSMutableArray array];
    if (tasks1 != nil) {
        for (NSDictionary *dict in tasks1) {
            
            DBRoom *model = [DBRoom testWithDict:dict];
            [arrayModels1 addObject:model];
        }
    }
    else
        NSLog(@"%@",error1.description);
    long MaxRssi=-100;
    NSString *MaxMajor;
    for (CLBeacon *beacon in _dataArray) {
        if (beacon.rssi>MaxRssi&&beacon.rssi!=0) {
            MaxRssi=beacon.rssi;
            MaxMajor=[NSString stringWithFormat:@"%@",beacon.major];
        }
    }
    for (DBRoom *data in arrayModels1) {
        if ([[NSString stringWithFormat:@"%@",data.major] isEqual:MaxMajor]) {
            _myroom=data.room;
            backImag.image=[UIImage imageNamed:data.background];
        }
    }
    //获取test表中的数据
    OHMySQLQueryRequest *query = [OHMySQLQueryRequestFactory SELECT:@"ibeacon_room_heightandwidth" condition:nil orderBy:@[@"room"] ascending:NO];
    NSError *error = nil;
    
    //task用于存放数据库返回的数据
    
    NSArray *tasks = [queryContext executeQueryRequestAndFetchResult:query error:&error];
    NSMutableArray *arrayModels = [NSMutableArray array];
    if (tasks != nil) {
        for (NSDictionary *dict in tasks) {
            
            DBRoomRuler *model = [DBRoomRuler testWithDict:dict];
            [arrayModels addObject:model];
        }
    }
    else
        NSLog(@"%@",error.description);
    bool dbFlag=false;
    for (DBRoomRuler *r in arrayModels) {
        if ([r.room isEqual:_myroom]) {
            dbFlag=true;
            NSString *width=r.width;
            NSString *height=r.height;
            double totalWidth=[width doubleValue];
            double totalHeight=[height doubleValue];
            self->widthRuler=(_boxView.frame.size.width-7)/totalWidth;
           self->heightRuler=(_boxView.frame.size.height-7)/totalHeight;
        }
    }
    if (!dbFlag) {
        [self stopBeaconRanging];
    UIAlertController *changkuan=[UIAlertController alertControllerWithTitle:@"输入房间的长和宽" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confrom=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        double totalWdith;
        double totalHeight;
        totalWdith=[changkuan.textFields.firstObject.text doubleValue];
        totalHeight=[changkuan.textFields[1].text doubleValue];
//            UITextField *mytext=changkuan.textFields[2];
////            UITextField *mytext2=changkuan.textFields[1];
//           _myroom= mytext.text;
        if (totalHeight==0||totalWdith==0) {
            self->widthRuler=0;
            self->heightRuler=0;
        }else{

            self->widthRuler=(_boxView.frame.size.width-7)/totalWdith;
           self->heightRuler=(_boxView.frame.size.height-7)/totalHeight;
            OHMySQLQueryContext *queryContext = [OHMySQLQueryContext new];
            
            //设置连接器
            queryContext.storeCoordinator = coordinator;
            NSMutableDictionary *quedic=[[NSMutableDictionary alloc]init];
            [quedic setValue:_myroom forKey:@"room"];
            [quedic setValue:[NSString stringWithFormat:@"%lf",totalHeight] forKey:@"height"];
            [quedic setValue:[NSString stringWithFormat:@"%lf",totalWdith]  forKey:@"width"];
            //获取test表中的数据
            OHMySQLQueryRequest *query = [OHMySQLQueryRequestFactory INSERT:@"ibeacon_room_heightandwidth" set:quedic];
            NSError *error = nil;
            
            //task用于存放数据库返回的数据
            
             [queryContext executeQueryRequestAndFetchResult:query error:&error];

        }
        [self turnOnBeacon];
    }];
    [changkuan addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder=@"请输入房间宽度";
    }];
    [changkuan addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder=@"请输入房间长度";
    }];
//        [changkuan addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//                    textField.placeholder=@"请输入房间号";
//        }];
    [changkuan addAction:confrom];
    [self presentViewController:changkuan animated:NO completion:nil];

    }
   
    

    
    //获取test表中的数据
    OHMySQLQueryRequest *query2 = [OHMySQLQueryRequestFactory SELECT:@"ibeacon" condition:nil orderBy:@[@"location"] ascending:NO];
    NSError *error2 = nil;
    
    //task用于存放数据库返回的数据
    
    NSArray *tasks2 = [queryContext executeQueryRequestAndFetchResult:query2 error:&error2];
    NSMutableArray *arrayModels2 = [NSMutableArray array];
    if (tasks2 != nil) {
        for (NSDictionary *dict in tasks2) {
            
            DBdata *model = [DBdata testWithDict:dict];
            [arrayModels2 addObject:model];
        }
               _dbDataArray = arrayModels2;
    }
    else
        NSLog(@"%@",error.description);
    
    for (DBdata *data in _dbDataArray) {
        if ([data.room isEqual:_myroom]) {
            
            NSMutableDictionary *rssiDic=[[NSMutableDictionary alloc]init];
            [rssiDic setObject:[NSString stringWithFormat:@"%@",data.location] forKey:@"location"];
            [rssiDic setObject:[NSString stringWithFormat:@"%@",data.rssi] forKey:@"rssi"];
            [rssiArray addObject:rssiDic];
        }
    }
    double max1=100;
    double max2=100;
    double max3=100;
    double max4=100;
    double max5=100;
    double max6=100;
    long maxArr[24];
    for (int i=0; i<24; i++) {
        maxArr[i]=1000;
    }
    NSString *max1location=@"";
    NSString *max2location=@"";
    NSString *max3location=@"";
    NSString *max4location=@"";
    NSString *max5location=@"";
    NSString *max6location=@"";
    for (NSDictionary *rssiDic in rssiArray) {
        NSString *rssiString=[rssiDic valueForKey:@"rssi"];
        double rssiAbs=0;
        long flagLong[4]={0,0,0,0};
        while (![rssiString isEqual:@""]) {
            NSString *major=[rssiString substringToIndex:5];
            rssiString=[rssiString substringFromIndex:6];
            NSString *rssiStr=[rssiString substringToIndex:3];
            long rssiInt=[rssiStr longLongValue];
            rssiString=[rssiString substringFromIndex:4];
            
            for (int i=0; i<beaconArray.count; i++) {
                CLBeacon *ble=beaconArray[i];
                if ([major isEqual:[NSString stringWithFormat:@"%@",ble.major]]) {
                    rssiAbs=rssiAbs+labs(rssiInt-ble.rssi-RssiProofreading);
                    
                    flagLong[i]=labs(rssiInt-ble.rssi-RssiProofreading);
                    
                }
            }
        

           
        }
        double rssiResult=rssiAbs/rssiArray.count;
        
        if (max1>rssiResult&&max6!=100&&max5!=100&&max4!=100&&max3!=100&&max2!=100) {
            max1=rssiResult;
            max1location=[rssiDic valueForKey:@"location"];
            for (int i=0; i<4; i++) {
                maxArr[i+20]=flagLong[i];
            }
        }else if (max2>rssiResult&&max6!=100&&max5!=100&&max4!=100&&max3!=100){
            
                max2=rssiResult;
                max2location=[rssiDic valueForKey:@"location"];
            for (int i=0; i<4; i++) {
                maxArr[i+16]=flagLong[i];
            }
        }else if (max3>rssiResult&&max6!=100&&max5!=100&&max4!=100){
            max3=rssiResult;
            max3location=[rssiDic valueForKey:@"location"];
            for (int i=0; i<4; i++) {
                maxArr[i+12]=flagLong[i];
            }
            
        }else if (max4>rssiResult&&max6!=100&&max5!=100){
            max4=rssiResult;
            max4location=[rssiDic valueForKey:@"location"];
            for (int i=0; i<4; i++) {
                maxArr[i+8]=flagLong[i];
            }
            
        }else if (max5>rssiResult&&max6!=100){
            max5=rssiResult;
            max5location=[rssiDic valueForKey:@"location"];
            for (int i=0; i<4; i++) {
                maxArr[i+4]=flagLong[i];
            }
            
        }else if (max6>rssiResult){
            max6=rssiResult;
            max6location=[rssiDic valueForKey:@"location"];
            for (int i=0; i<4; i++) {
                maxArr[i]=flagLong[i];
            }
        }
        
    }
    if ((max1!=100||max2!=100)&&max3!=100&&max4!=100&&max6!=100&&max5!=100) {
        NSMutableArray *rssiLocation=[[NSMutableArray alloc]init];
        [rssiLocation addObject:max6location];
        [rssiLocation addObject:max5location];
        [rssiLocation addObject:max4location];
        [rssiLocation addObject:max3location];
        [rssiLocation addObject:max2location];
        [rssiLocation addObject:max1location];
        max1location=rssiLocation[0];
        max2location=rssiLocation[1];
        max3location=rssiLocation[2];
        max4location=rssiLocation[3];
        int loca[6]={0,0,0,0,0,0};
        for (int k=0; k<24; k=k+4) {
            for (int i=0; i<4; i++) {
                long min=maxArr[k+i];
                int minFlag=0;
                for (int j=i; j<24; j=j+4) {
                    if (k+i==j) {
                        
                    }else{
                        if (min<=maxArr[j]) {
//                            min=maxArr[j];
                            minFlag++;
                        }
                    }
                }
                if (minFlag>=2) {
                    loca[k/4]++;
                }
                
            }
            
        }
        
        for (int i=0; i<6; i++) {
            int t;
            NSString *t2;
            for (int k=i; k<6; k++) {
                if (loca[i]<loca[k]) {
                    t=loca[i];
                    loca[i]=loca[k];
                    loca[k]=t;
                    t2=rssiLocation[i];
                    rssiLocation[i]=rssiLocation[k];
                    rssiLocation[k]=t2;
                }
            }
        }
        max1location=rssiLocation[0];
        max2location=rssiLocation[1];
        max3location=rssiLocation[2];
        max4location=rssiLocation[3];
    }
    if (max1!=100&&max2!=100&&max3!=100&&max4!=100) {
        NSArray *max1Array=[max1location componentsSeparatedByString:@","];
        NSString* max1XStr=max1Array[0];
        NSString* max1YStr=max1Array[1];
        double max1X=[max1XStr doubleValue];
        double max1Y=[max1YStr doubleValue];
        
        NSArray *max2Array=[max2location componentsSeparatedByString:@","];
        NSString* max2XStr=max2Array[0];
        NSString* max2YStr=max2Array[1];
        double max2X=[max2XStr doubleValue];
        double max2Y=[max2YStr doubleValue];
        
        NSArray *max3Array=[max3location componentsSeparatedByString:@","];
        NSString* max3XStr=max3Array[0];
        NSString* max3YStr=max3Array[1];
        double max3X=[max3XStr doubleValue];
        double max3Y=[max3YStr doubleValue];
        
        NSArray *max4Array=[max4location componentsSeparatedByString:@","];
        NSString* max4XStr=max4Array[0];
        NSString* max4YStr=max4Array[1];
        double max4X=[max4XStr doubleValue];
        double max4Y=[max4YStr doubleValue];
        
        double x=(max1X+max2X+max3X)/3;
        
        double y=(max1Y+max2Y+max3Y)/3;
        
        

        _max1View.frame=CGRectMake(max1X, max1Y, 7, 7);
        [_max1View reloadInputViews];
        
        _max2View.frame=CGRectMake(max2X, max2Y, 7, 7);
        [_max2View reloadInputViews];
        
        _max3View.frame=CGRectMake(max3X, max3Y, 7, 7);
        [_max3View reloadInputViews];
        
//        _max4View.frame=CGRectMake(max4X, max4Y, 7, 7);
//        [_max4View reloadInputViews];
        NSLog(@"max1:(%.2lf,%.2lf)-----max2:(%.2lf,%.2lf)--------max3:(%.2lf,%.2lf)--------max4:(%.2lf,%.2lf),-------",max1X,max1Y,max2X,max2Y,max3X,max3Y,max4X,max4Y);
        myPoint.x=x;
        myPoint.y=y;
    }else{
        NSLog(@"指纹数不足");
        myPoint.x=-1;
        myPoint.y=-1;
    }
    return  myPoint;
}

//上传指纹点
-(void)pushPoint:(NSString *)beaconRssi x:(NSString *)x y:(NSString *)y room:(NSString *)room{
    NSString *pushString=beaconRssi;

    OHMySQLQueryContext *queryContext=[OHMySQLQueryContext new];
    queryContext.storeCoordinator=coordinator;
    OHMySQLQueryRequest *query=[OHMySQLQueryRequestFactory SELECT:@"ibeacon" condition:nil orderBy:@[@"location"] ascending:NO];
     
//        获取test表中的数据

        NSError *error = nil;
    
        //task用于存放数据库返回的数据
    
        NSArray *tasks = [queryContext executeQueryRequestAndFetchResult:query error:&error];
        NSMutableArray *arrayModels = [NSMutableArray array];
        if (tasks != nil) {
            for (NSDictionary *dict in tasks) {
    
                DBdata *model = [DBdata testWithDict:dict];
                [arrayModels addObject:model];
            }
        }
        else
            NSLog(@"%@",error.description);
    
    bool dataFlag=false;
    for (DBdata *selectData in arrayModels) {
        if ([selectData.location isEqual:[NSString stringWithFormat:@"%@,%@",x,y]]) {
            dataFlag=YES;
            break;
        }
    }
    OHMySQLQueryRequest *que;
    if (dataFlag) {
        NSMutableDictionary *setDic=[[NSMutableDictionary alloc]init];
        [setDic setValue:pushString forKey:@"rssi"];
        
        NSString *condStr=[NSString stringWithFormat:@"location='%@,%@'",x,y];
        que=[OHMySQLQueryRequestFactory UPDATE:@"ibeacon" set:setDic condition:condStr];
        
    }
    else{
        NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
        [dic setObject:[NSString stringWithFormat:@"%@,%@",x,y] forKey:@"location"];
        [dic setObject:room forKey:@"room"];
        [dic setObject:pushString forKey:@"rssi"];
        que=[OHMySQLQueryRequestFactory INSERT:@"ibeacon" set:dic];
    }
    
//    OHMySQLQueryRequest *que=[OHMySQLQueryRequestFactory UPDATE:@"ibeacon" set:[@"location":@"10,10"]//字典 condition:@"location='10,10'"];
    
    //task用于存放数据库返回的数据
    
    NSArray *tasks_2 = [queryContext executeQueryRequestAndFetchResult:que error:&error];
    NSMutableArray *arrayModels_2 = [NSMutableArray array];
    if (tasks_2 != nil) {
        for (NSDictionary *dict in tasks_2) {
            
            DBdata *model = [DBdata testWithDict:dict];
            [arrayModels_2 addObject:model];
        }
    }
    else
        NSLog(@"%@",error.description);
    
}
//连接数据库
-(void)connectDB{
    if (!connectFlag) {
        OHMySQLUser *usr = [[OHMySQLUser alloc]initWithUserName:@"ssdut" password:@"Dut12345678" serverName:@"rm-2zev4384698mt971eoo.mysql.rds.aliyuncs.com" dbName:@"dingwei" port:3306 socket:nil];
        
        //初始化连接器
        /*第一步：连接数据库
        连接数据库的测试参数：
        用户名：ssdut
        密码：Dut12345678
        服务器域名：rm-2zev4384698mt971eoo.mysql.rds.aliyuncs.com
        数据库名字:dingwei
        端口号:3306
        */
        coordinator = [[OHMySQLStoreCoordinator alloc]initWithUser:usr];
        
        //连接到数据库
        [coordinator connect];
        connectFlag=true;
        
    }



}

//数据库断开
-(void)disconnectDB{
    if (connectFlag) {
        
        [coordinator disconnect];
        coordinator=nil;
        connectFlag=false;
    }
}
//字典转Data
-(NSData *)returnDataWithDictionary:(NSDictionary*)dict
{

    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:false error:nil];
    return data;
    
}
 
#pragma mark Process Beacon Information
//将beacon的信息转换为NSString并返回
- (NSString *)detailsStringForBeacon:(CLBeacon *)beacon
{
//    float distance=[self calcDistByRSSI:beacon.rssi];
    NSArray *ibeaconArray=@[@"major:",@"minor:",@"proximity:",@"distance:",@"rssi:",@"distance:"];
    NSString *format = @"beacon.major:%@ •beacon.minor: %@ •beacon.proximity: %@ •beacon.accuracy: %f •beacon.rssi: %li";
    NSMutableArray *ibeaconDataArray=[[NSMutableArray alloc]init];
    [ibeaconDataArray addObject:beacon.major];
    [ibeaconDataArray addObject:beacon.minor];
    [ibeaconDataArray addObject:[self stringForProximity:beacon.proximity]];
    [ibeaconDataArray addObject:[NSString stringWithFormat:@"%f",beacon.accuracy]];
    [ibeaconDataArray addObject:[NSString stringWithFormat:@"%li",beacon.rssi]];

    
    return [NSString stringWithFormat:format, beacon.major, beacon.minor, [self stringForProximity:beacon.proximity], beacon.accuracy, beacon.rssi];
}
 
- (NSString *)stringForProximity:(CLProximity)proximity{
    NSString *proximityValue;
    switch (proximity) {
        case CLProximityNear:
            proximityValue = @"Near";
            break;
        case CLProximityImmediate:
            proximityValue = @"Immediate";
            break;
        case CLProximityFar:
            proximityValue = @"Far";
            break;
        case CLProximityUnknown:
        default:
            proximityValue = @"Unknown";
            break;
    }
    return proximityValue;
}
 
- (void)checkLocationAccessForRanging {
    if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

//测距的三角定位算法

-(CGPoint)sidePointCalculationWith:(double)x1 :(double)y1 :(double)r1
                                  :(double)x2 :(double)y2 :(double)r2
                                  :(double)x3 :(double)y3{
    //勾股定理  sqrt(X)是X开根号  pow（X,n）是X的n次方
    //取beacon1圆心A 与 beacon2圆心B的距离
    double AB = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
    double rAB = (r1 + r2);
    if (rAB > AB && (r1 < AB && r2 < AB)) {
        //两圆有相交点,两圆相交点为C、D。两圆与AB的相交点为E、F。o是EF的中点。
        double EF = rAB - AB;
        double Eo = EF * 0.5;
        double AE = r1 - EF;
        double Ao = AE + Eo;
        double AQ1 = acos((x2 - x1) / AB);
        double AQ2 = acos(Ao / r1);
        
        double BF = r2 - EF;
        double Bo = BF + Eo;
//        double BQ1 = acos(fabs(x1 - x2) / AB);
        double BQ2 = acos(Bo / r2);
        
        //原点{0,0}在左上角的情况下
        double Cx = x1 + (r1 * cos(AQ1 + AQ2));
        double Cy = 0.0;
        double Dx = x2 - (r2 * cos(AQ1 + BQ2));
        double Dy = 0.0;
        if (x1 < x2) {
            Dx = x2 - (r2 * cos(AQ1 + BQ2));
            if (y1 < y2) {
                Cy = y1 + (r1 * sin(AQ1 + AQ2));
                Dy = y2 - (r2 * sin(AQ1 + BQ2));
            }else{
                Cy = y1 - (r1 * sin(AQ1 + AQ2));
                Dy = y2 + (r2 * sin(AQ1 + BQ2));
            }
        }else{
            Cy = y1 + (r1 * sin(AQ1 + AQ2));
            if (y1 < y2) {
                Dy = y2 - (r2 * sin(AQ1 + BQ2));
            }else{
                Dy = y2 + (r2 * sin(AQ1 + BQ2));
            }
        }
        
        double Cc = sqrt(pow(Cx - x3, 2) + pow(Cy - y3, 2));
        double Dc = sqrt(pow(Dx - x3, 2) + pow(Dy - y3, 2));

        return Cc < Dc ? CGPointMake(Cx, Cy) : CGPointMake(Dx, Dy);
    }else{
        //两圆无相交点
        return [self midpointCalculationWith:x1 :y1 :r1
                                            :x2 :y2 :r2];
    }
}
- (CGPoint)midpointCalculationWith:(double)x1 :(double)y1 :(double)r1
                                 :(double)x2 :(double)y2 :(double)r2{
    double a = y1 - y2;//竖边
    double b = x1 - x2;//横边
    double rr = r1 + r2;
    double s = r1 / rr;
    
    double x = fabs(x1 - (b * s)) ;
    double y = fabs(y1 - (a * s)) ;
    
//    return CGPointMake(x, y);
    return CGPointMake(x, y);
}
//基站坐标
-(CGPoint)GetPoint:(NSNumber*)major ruler:(double)ruler{
    CGPoint retPoint;
//    NSLog(@"major:%@",major);
//    double ruler=(400)/4.7;
    if ([major isEqual:[NSNumber numberWithInt:10170]]) {//10120
        retPoint.x=0;
//        retPoint.y=_boxView.frame.size.height+ _boxView.frame.origin.y-15;
        retPoint.y=0;
    }else if ([major isEqual:[NSNumber numberWithInt:10180]]){//10130
        
            retPoint.x=_boxView.frame.size.width-7;
//            retPoint.y=_boxView.frame.size.height+_boxView.frame.origin.y-15;
        retPoint.y= 0;
    }else if ([major isEqual:[NSNumber numberWithInt:10160]]){//10169
        
//        retPoint.x=MAINWINDOWSWIDTH/2;
        retPoint.x=0;
        retPoint.y=ruler*((_boxView.frame.size.height-7)/heightRuler);
        
//        retPoint.y=_boxView.frame.size.height-5.5*ruler+_boxView.frame.origin.y-15;
        //y3=sqrt(实际蓝色或者绿色到黑色的距离的平方-实际蓝色绿色距离的一半的平方）*比例尺+坐标下移   6 4.7
}
    else if([major isEqual:[NSNumber numberWithInt:10190]]){
        retPoint.x=_boxView.frame.size.width-7;
        retPoint.y=ruler*((_boxView.frame.size.height-7)/heightRuler);
        
    }
    else{
        retPoint.x=-1;
        retPoint.y=-1;
        
        NSLog(@"GetPoint函数中坐标获取出错，返回(-1,-1)");
    }
    return retPoint;
}

- (float)calcDistByRSSI:(int)rssi
{
    int iRssi = abs(rssi);
    float power = (iRssi-54)/(10*2.0);
    return pow(10, power);
}
-(void)stopButtonClick{
    if (startBool) {
        [self stopBeaconRanging];
        [_startButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_stopButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        startBool=false;
        NSMutableDictionary *dic1=[[NSMutableDictionary alloc]init];
        [dic1 setObject:@"false" forKey:@"present"];
        NSData *data1=[self returnDataWithDictionary:dic1];
        [self sendMassage:data1 topic:myTopics[0]];
        NSMutableDictionary *dic2=[[NSMutableDictionary alloc]init];
        NSMutableDictionary *dic21=[[NSMutableDictionary alloc]init];
        [dic21 setObject:@"BleTag" forKey:@"label"];
        [dic21 setObject:@"BLE" forKey:@"locationType"];
        [dic21 setObject:@"TAG" forKey:@"nodeType"];//节点类型（基站/标签）
        [dic21 setObject:@"false" forKey:@"ble"];
        [dic21 setObject:@"true" forKey:@"leds"];
        [dic21 setObject:@"false" forKey:@"uwbFirmwareUpdate"];
        NSMutableDictionary *dic211=[[NSMutableDictionary alloc]init];
        [dic211 setObject:@"true" forKey:@"stationaryDetection"];
        [dic211 setObject:@"true" forKey:@"responsive"];
        [dic211 setObject:@"true" forKey:@"locationEngine"];
        [dic211 setObject:@"100" forKey:@"nomUpdateRate"];
        [dic211 setObject:@"500" forKey:@"statUpdateRate"];
        [dic21 setObject:dic211 forKey:@"tag"];
        [dic2 setObject:dic21 forKey:@"configuration"];
        NSData *data2=[self returnDataWithDictionary:dic2];
        [self sendMassage:data2 topic:myTopics[1]];
        [self disconnectDB];
    }else{
    
        return;
    }
}
-(void)startButtonClick{
    if (!startBool) {
//        rssi_1=0;
//        rssi_2=0;
//        rssi_3=0;
//        rssi_4=0;;
        for (int k=0; k<100; k++) {
            rssi_Rssi[k]=0;
            rssi_Major[k]=0;
            rssi_Major_flag[k]=0;
        }
        rssiFlag=1;
        [self turnOnBeacon];
        [_stopButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_startButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        startBool=true;
        [self connectDB];
    }else{
    
        return;
    }
}







@end
