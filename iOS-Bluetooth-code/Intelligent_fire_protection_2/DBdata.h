//
//  DBdata.h
//  Intelligent_fire_protection_2
//
//  Created by 王声䘵 on 2021/6/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBdata : NSObject
//属性名
@property(nonatomic,copy)NSString *location;
@property(nonatomic,copy)NSString *room;
@property(nonatomic,copy)NSString *rssi;






-(instancetype)initWithDict:(NSDictionary *)dict;
+(instancetype)testWithDict:(NSDictionary *)dict;
@end

NS_ASSUME_NONNULL_END
