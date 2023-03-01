//
//  DBdata.m
//  Intelligent_fire_protection_2
//
//  Created by 王声䘵 on 2021/6/4.
//

#import "DBdata.h"

@implementation DBdata
-(instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return  self;
}
+(instancetype)testWithDict:(NSDictionary *)dict
{
    return [[self alloc]initWithDict:dict];
}

@end
