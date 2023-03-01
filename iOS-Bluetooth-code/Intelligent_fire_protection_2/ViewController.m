//
//  ViewController.m
//  Intelligent_fire_protection_2
//
//  Created by 王声䘵 on 2021/6/2.
//

#import "ViewController.h"
#import "LocationViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *but=[[UIButton alloc]initWithFrame:CGRectMake(100, 200, 100, 100)];
    but.backgroundColor=[UIColor redColor];
    [but addTarget:self action:@selector(butClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:but];
    // Do any additional setup after loading the view.
}
-(void)butClick{
    LocationViewController *con=[[LocationViewController alloc]init];
    [self.navigationController pushViewController:con animated:NO];
}

@end
