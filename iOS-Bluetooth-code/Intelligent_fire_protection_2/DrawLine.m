//
//  DrawLine.m
//  Intelligent_fire_protection
//
//  Created by 王声䘵 on 2021/4/2.
//

#import "DrawLine.h"

#define MAINWINDOWSWIDTH [[UIScreen mainScreen] bounds].size.width
#define MAINWINDOWSHEIGHT [[UIScreen mainScreen] bounds].size.height
@interface DrawLine(){
    CGPoint myStartPoint;
    CGPoint myStopPoint;
    UIColor *linecolor;
}
@end
@implementation DrawLine

- (instancetype)initWithFrame:(CGRect)frame startPoint:(CGPoint)startPoint stopPoint:(CGPoint)stopPoint LineColor:(UIColor *)color
{
    self = [super initWithFrame:frame];
    if (self) {
        //设置 背景为clear
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        linecolor=color;
        myStartPoint=startPoint;
        myStopPoint=stopPoint;
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    UIBezierPath *path=[UIBezierPath bezierPath];
    [path moveToPoint:myStartPoint];
    [path addLineToPoint:myStopPoint];
//    [path moveToPoint:CGPointMake(10, 250)];
//    [path addLineToPoint:CGPointMake(100, 250)];
    [path closePath];
    [path setLineWidth:0.5];
    [linecolor setStroke];
    [path stroke];
//    [[UIColor colorWithWhite:0.5 alpha:0.5]setFill];
//    [path fill];
}
//-(void)setDrawLinePoint:(CGPoint)startPoint StopPoint:(CGPoint)stopPoint{
//    startPoint=startPoint;
//    stopPoint=stopPoint;
//
//}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
