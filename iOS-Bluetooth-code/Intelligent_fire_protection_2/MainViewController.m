//
//  MainViewController.m
//  Intelligent_fire_protection_2
//
//  Created by 王声䘵 on 2021/6/17.
//

#import "MainViewController.h"
#import "LocationViewController.h"
#import "QRCodeScanningViewController.h"
@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    LocationViewController *location=[[LocationViewController alloc]init];
    location.title=@"定位";
    QRCodeScanningViewController *QRcodeScan=[[QRCodeScanningViewController alloc]init];
    QRcodeScan.title=@"扫描";
    
    self.viewControllers=@[location,QRcodeScan];
    
    // Do any additional setup after loading the view.
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
