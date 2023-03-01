//
//  DrawLine.h
//  Intelligent_fire_protection
//
//  Created by 王声䘵 on 2021/4/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DrawLine : UIView

- (instancetype)initWithFrame:(CGRect)frame startPoint:(CGPoint)startPoint stopPoint:(CGPoint)stopPoint LineColor:(UIColor *)color;
//-(void)setDrawLinePoint:(CGPoint)startPoint StopPoint:(CGPoint)stopPoint;
@end

NS_ASSUME_NONNULL_END
