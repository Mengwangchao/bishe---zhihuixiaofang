//
//  DBRoomRuler.h
//  Intelligent_fire_protection_2
//
//  Created by 王声䘵 on 2021/7/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DBRoomRuler : NSObject

@property(nonatomic,copy)NSString *width;
@property(nonatomic,copy)NSString *room;
@property(nonatomic,copy)NSString *height;
@property(nonatomic,copy)NSString *roomid;






-(instancetype)initWithDict:(NSDictionary *)dict;
+(instancetype)testWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
