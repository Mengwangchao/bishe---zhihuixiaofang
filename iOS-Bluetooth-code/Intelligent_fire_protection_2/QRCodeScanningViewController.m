//
//  QRCodeScanningViewController.m
//  Intelligent_fire_protection_2
//
//  Created by 王声䘵 on 2021/6/16.
//

#import "QRCodeScanningViewController.h"
#define kScanRect CGRectMake(0,0,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height-70)//设置扫码区域
//#define kScanRect CGRectMake(0,100,500,500)//设置扫码区域
@interface QRCodeScanningViewController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
    int num;
    BOOL upOrdown;
    NSTimer *timer;
    CAShapeLayer *cropLayer;
}
@property (nonatomic, strong)AVCaptureDevice *device;
@property (nonatomic, strong)AVCaptureDeviceInput *input;
@property (nonatomic, strong)AVCaptureMetadataOutput *output;
@property (nonatomic, strong)AVCaptureSession *session;
@property (nonatomic, strong)AVCaptureVideoPreviewLayer *preview;
/**上下扫动的线*/
@property (nonatomic, strong)UIImageView *line;
/**结果字符串*/
@property (nonatomic, strong)NSString *valueString;

@property (nonatomic,strong)UILabel *resultLabel;
@property (nonatomic,strong)UILabel *resultLabel2;
@property (nonatomic,strong)UILabel *resultLabel3;
@property (nonatomic,strong)UILabel *resultLabel4;
@property (nonatomic,strong)UILabel *resultLabel5;
@property (nonatomic,strong)UILabel *resultLabel6;

@property (nonatomic,strong)UIButton *resultButton;
@end

@implementation QRCodeScanningViewController
- (void)viewWillAppear:(BOOL)animated {
    if (_session != nil && timer != nil) {
        [self startScan];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [self stopScan];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self requestCameraAuthorization];
    [self createScanView];
    [self setCropRect:kScanRect];
    [self performSelector:@selector(setupCamera) withObject:nil afterDelay:0.3];
    
    _resultLabel=[[UILabel alloc]initWithFrame:CGRectMake(MAINWINDOWSWIDTH/2-120, MAINWINDOWSHEIGHT/2-155, 240, 30)];
    _resultLabel.backgroundColor=[UIColor whiteColor];
    _resultLabel.textColor=[UIColor blackColor];
    _resultLabel.font=[UIFont systemFontOfSize:17];
    
    _resultLabel2=[[UILabel alloc]initWithFrame:CGRectMake(_resultLabel.frame.origin.x, _resultLabel.frame.origin.y+_resultLabel.frame.size.height, _resultLabel.frame.size.width, 30)];
    _resultLabel2.backgroundColor=[UIColor whiteColor];
    _resultLabel2.textColor=[UIColor blackColor];
    _resultLabel2.font=[UIFont systemFontOfSize:17];
    
    _resultLabel3=[[UILabel alloc]initWithFrame:CGRectMake(_resultLabel2.frame.origin.x, _resultLabel2.frame.origin.y+_resultLabel2.frame.size.height, _resultLabel2.frame.size.width, 30)];
    _resultLabel3.backgroundColor=[UIColor whiteColor];
    _resultLabel3.textColor=[UIColor blackColor];
    _resultLabel3.font=[UIFont systemFontOfSize:17];
    
    _resultLabel4=[[UILabel alloc]initWithFrame:CGRectMake(_resultLabel3.frame.origin.x, _resultLabel3.frame.origin.y+_resultLabel3.frame.size.height, _resultLabel3.frame.size.width, 30)];
    _resultLabel4.backgroundColor=[UIColor whiteColor];
    _resultLabel4.textColor=[UIColor blackColor];
    _resultLabel4.font=[UIFont systemFontOfSize:17];
    
    _resultLabel5=[[UILabel alloc]initWithFrame:CGRectMake(_resultLabel4.frame.origin.x, _resultLabel4.frame.origin.y+_resultLabel4.frame.size.height, _resultLabel4.frame.size.width, 30)];
    _resultLabel5.backgroundColor=[UIColor whiteColor];
    _resultLabel5.textColor=[UIColor blackColor];
    _resultLabel5.font=[UIFont systemFontOfSize:17];
    
    _resultLabel6=[[UILabel alloc]initWithFrame:CGRectMake(_resultLabel5.frame.origin.x, _resultLabel5.frame.origin.y+_resultLabel5.frame.size.height, _resultLabel5.frame.size.width, 30)];
    _resultLabel6.backgroundColor=[UIColor whiteColor];
    _resultLabel6.textColor=[UIColor blackColor];
    _resultLabel6.font=[UIFont systemFontOfSize:17];
    
    _resultButton=[[UIButton alloc]initWithFrame:CGRectMake(_resultLabel6.frame.origin.x, _resultLabel6.frame.origin.y+_resultLabel6.frame.size.height, _resultLabel6.frame.size.width, 30)];
    _resultButton.backgroundColor=[UIColor whiteColor];
    [_resultButton setTitle:@"确定" forState:UIControlStateNormal];
    [_resultButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_resultButton addTarget:self action:@selector(resultButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _resultButton.hidden=YES;
    [self.view addSubview:_resultButton];
    
}
    // Do any additional setup after loading the view.
-(void)resultButtonClick{

    
    [_resultLabel removeFromSuperview];
    [_resultLabel2 removeFromSuperview];
    [_resultLabel3 removeFromSuperview];
    [_resultLabel4 removeFromSuperview];
    [_resultLabel5 removeFromSuperview];
    [_resultLabel6 removeFromSuperview];
    _resultButton.hidden=YES;
    [self startScan];
}
- (void)setCropRect:(CGRect)cropRect {
    cropLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, cropRect);
    CGPathAddRect(path, nil, self.view.bounds);
    
    [cropLayer setFillRule:kCAFillRuleEvenOdd];
    [cropLayer setPath:path];
    [cropLayer setFillColor:[UIColor blackColor].CGColor];
    [cropLayer setOpacity:0.6];
    [cropLayer setNeedsDisplay];
    
    [self.view.layer addSublayer:cropLayer];
}
//设置相机权限
- (void)requestCameraAuthorization {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请在设置中允许打开相机" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
//设置相机
- (void)setupCamera {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device == nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"设备没有摄像头" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //设置扫码区域
    CGFloat top = kScanRect.origin.y/MAINWINDOWSHEIGHT;
    CGFloat left = kScanRect.origin.x/MAINWINDOWSWIDTH;
    CGFloat width = kScanRect.size.width/MAINWINDOWSWIDTH;
    CGFloat height = kScanRect.size.height/MAINWINDOWSHEIGHT;
//    CGFloat top = 0;
//    CGFloat left = 0;
//    CGFloat width = MAINWINDOWSWIDTH;
//    CGFloat height = MAINWINDOWSHEIGHT-100;
    
    [_output setRectOfInterest:CGRectMake(left, top, width, height)];
    
    
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([_session canAddInput:self.input]) {
        [_session addInput:self.input];
    }
    if ([_session canAddOutput:self.output]) {
        [_session addOutput:self.output];
    }
    //条码类型，支持二维码，条形码
    [_output setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, nil]];
    
    _preview = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame = self.view.layer.bounds;
    [self.view.layer insertSublayer:_preview atIndex:0];
    //开始扫码
    [self startScan];
}
//创建扫码区
- (void)createScanView {
    //扫码区
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(MAINWINDOWSWIDTH/2-100, MAINWINDOWSHEIGHT/2-150, 200, 300)];
//    imageView.image = [UIImage imageNamed:@"pick_bg.png"];
    imageView.backgroundColor=[UIColor clearColor];
    imageView.userInteractionEnabled = YES;
    [self.view addSubview:imageView];
    
    //开启前置手电筒
    UIButton *lightBtn = [[UIButton alloc]initWithFrame:CGRectMake(30, 70, 30, 40)];
    [lightBtn setImage:[UIImage imageNamed:@"手电筒"] forState:UIControlStateNormal];
    lightBtn.selected = NO;
    [lightBtn addTarget:self action:@selector(lightAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lightBtn];
    
    //扫描线
    upOrdown = NO;
    num = 0;
    _line = [[UIImageView alloc] initWithFrame:CGRectMake(MAINWINDOWSWIDTH/2-100, MAINWINDOWSHEIGHT/2-150, 200, 2)];
    _line.backgroundColor=[UIColor blueColor];
    [self.view addSubview:_line];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
    //描述
    UILabel *desL = [[UILabel alloc]initWithFrame:CGRectMake(MAINWINDOWSWIDTH/2-100, MAINWINDOWSHEIGHT/2-130, 200, 30)];
    desL.font = [UIFont boldSystemFontOfSize:15];
    desL.backgroundColor=[UIColor clearColor];
    desL.text = @"对准二维码，即可自动扫描";
    desL.textColor = [UIColor whiteColor];
    desL.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:desL];
}
- (void)animation {
    //扫码线动画
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(kScanRect.origin.x, kScanRect.origin.y+10+2*num, kScanRect.size.width, 2);
        if ( num == kScanRect.size.height/2||num == (kScanRect.size.height-1)/2) {
            upOrdown = YES;
        }
    }else {
        num--;
        _line.frame = CGRectMake(kScanRect.origin.x, kScanRect.origin.y+10+2*num, kScanRect.size.width, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
}
//手电筒控制
- (void)lightAction:(UIButton *)sender {
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]) {
            [device lockForConfiguration:nil];
            if (sender.isSelected == NO) {
                //打开闪光灯
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
                sender.selected = YES;
            }else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                sender.selected = NO;
            }
            [device unlockForConfiguration];
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    //有扫描结果
    if ([metadataObjects count] > 0) {
        //停止扫描
        [self stopScan];
        _resultButton.hidden=NO;
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        //扫描的结果
        self.valueString = metadataObject.stringValue;
        if ([self.valueString isEqual:@"MAC地址：d8:a0:1d:60:fe:c6"]||[self.valueString isEqual:@"MAC地址：24:6f:28:f4:91:76"]||[self.valueString isEqual:@"MAC地址：3c:61:05:4c:47:02"]||[self.valueString isEqual:@"MAC地址： 24:6f:28:de:6b:12"]){
            _resultLabel.text=@"  蓝牙实时定位模块";
            _resultLabel2.text=@"  通讯速率：150Mbps";
            _resultLabel3.text=@"  带宽：40MHz";
            _resultLabel4.text=@"  发射功率：20dBm";
            _resultLabel5.text=@"  定位模式：指纹/RSS测距";
            _resultLabel6.text=[NSString stringWithFormat:@"  %@",self.valueString];

            
        }
        else if([self.valueString isEqual:@"MAC地址：7c:df:a1:0f:75:58"]||[self.valueString isEqual:@"MAC地址：7c:df:a1:0f:6f:84"]||[self.valueString isEqual:@"MAC地址：7c:df:a1:0e:de:3c"]){
            _resultLabel.text=@"  WiFi嗅探模块";
            _resultLabel2.text=@"  通讯速率：150Mbps";
            _resultLabel3.text=@"  带宽：40MHz";
            _resultLabel4.text=@"  发射功率：20dBm";
            _resultLabel5.text=@"  ";
            _resultLabel6.text=[NSString stringWithFormat:@"  %@",self.valueString];
        }
        else if([self.valueString isEqual:@"MAC地址： 7c:df:a1:0f:70:40"]){
            _resultLabel.text=@"  人流量估计模块";
            _resultLabel2.text=@"  通讯速率：150Mbps";
            _resultLabel3.text=@"  带宽：40MHz";
            _resultLabel4.text=@"  发射功率：20dBm";
            _resultLabel5.text=@"  ";
            _resultLabel6.text=[NSString stringWithFormat:@"  %@",self.valueString];
        }
        else if([self.valueString isEqual:@"MAC地址：d8:a0:1d:5a:20:74"]){
            _resultLabel.text=@"  CSI发送模块";
            _resultLabel2.text=@"  通讯速率：150Mbps";
            _resultLabel3.text=@"  带宽：40MHz";
            _resultLabel4.text=@"  发射功率：20dBm";
            _resultLabel5.text=@"  ";
            _resultLabel6.text=[NSString stringWithFormat:@"  %@",self.valueString];

        }
        else if([self.valueString isEqual:@"MAC地址：E5:1D:A5:D1:BE:97"]||[self.valueString isEqual:@"MAC地址：C9:D6:3A:F8:B5:37"]||[self.valueString isEqual:@"MAC地址：F7:08:47:0A:34:3F"]||[self.valueString isEqual:@"MAC地址：CE:C9:B3:CE:3B:87"]||[self.valueString isEqual:@"MAC地址：DD:7B:28:7F:C5:5E"]||[self.valueString isEqual:@"MAC地址：F1:B4:4E:A6:E1:1C"]||[self.valueString isEqual:@"MAC地址：D0:59:D4:F9:43:AE"]||[self.valueString isEqual:@"MAC地址：C3:84:85:6A:66:71"]||[self.valueString isEqual:@"MAC地址：F2:C0:A5:1B:31:B1"]||[self.valueString isEqual:@"MAC地址：EB:61:83:FA:CF:4E"]){
            _resultLabel.text=@"  超宽带实时定位模块";
            _resultLabel2.text=@"  通讯速率:110k/6.8Mhz";
            _resultLabel3.text=@"  带宽:500Mhz";
            _resultLabel4.text=@"  发射功率:50dBm/Mhz";
            _resultLabel5.text=@"  定位模式:TOA/TRM";
            _resultLabel6.text=[NSString stringWithFormat:@"  %@",self.valueString];

        }
//        _resultLabel.text=[NSString stringWithFormat:@"  %@",self.valueString];

        [self.view addSubview:_resultLabel];
        [self.view addSubview:_resultLabel2];
        
        [self.view addSubview:_resultLabel3];
        [self.view addSubview:_resultLabel4];
        [self.view addSubview:_resultLabel5];
        [self.view addSubview:_resultLabel6];

        //弹出结果
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        AudioServicesPlaySystemSound(1111);
        NSLog(@"%@",self.valueString);

    }else {
        NSLog(@"无扫码信息");
        return;
    }
}
/**开始扫码*/
- (void)startScan {
    [self.session startRunning];
    [timer setFireDate:[NSDate date]];
}
/**结束扫码*/
- (void)stopScan {
    [self.session stopRunning];
    [timer setFireDate:[NSDate distantFuture]];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
