//
//  MQTT.m
//  Intelligent_fire_protection
//
//  Created by 王声䘵 on 2021/5/26.
//

#import "MQTT.h"

@interface MQTT ()<MQTTSessionDelegate,MQTTSessionManagerDelegate>
@property(nonatomic,strong)NSString *server_ip;
@property(nonatomic,strong)NSString *userName;
@property(nonatomic,strong)NSString *passWord;
@property(nonatomic,strong)NSArray *topics;

@end

@implementation MQTT


-(void)connectServer:(NSString *)urlString userName:(NSString *)userName passWord:(NSString *)passWord topic:(NSArray *)topics{
    _server_ip=urlString;
    _userName=userName;
    _passWord=passWord;
    _topics=topics;
    [self websocket];
   
}
-(void)disConnectServer{
    [_mySession closeAndWait:1];
    self.mySession.delegate=nil;//代理
    _mySession=nil;
//    _transport=nil;//连接服务器属性
    _server_ip=nil;//服务器ip地址
//    _port=0;//服务器ip地址
    _userName=nil;//用户名
    _passWord=nil;//密码
//    _topic=nil;//单个主题订阅
    _topics=nil;//多个主题订阅
}
-(void)sendMassage:(NSData *)msg topic:(NSString *)topic{

    [self.mySession publishData:msg onTopic:topic retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
        if (error) {
            NSLog(@"发送失败 - %@",error);

            
        }else{
            NSLog(@"发送成功");
           
            
        }
    }];
}

-(void)websocket{
    WEAKSELF
//    NSString *myId=[NSString stringWithFormat:@"%d",arc4random()%10000];
    NSString *clientID =[NSString stringWithFormat:@"%@|iOS|%@",[[NSBundle mainBundle] bundleIdentifier],[UIDevice currentDevice].identifierForVendor.UUIDString];;
    MQTTWebsocketTransport *transport = [[MQTTWebsocketTransport alloc] init];
//    transport.host = [NSString stringWithFormat:@"%@",server_ip];
//    transport.port =  9999;  // 端口号
    NSURL *url=[NSURL URLWithString:_server_ip];
    transport.url=url;
    transport.tls = YES; //  根据需要配置  YES 开起 SSL 验证 此处为单向验证 双向验证 根据SDK 提供方法直接添加
    MQTTSession *session = [[MQTTSession alloc] init];
    NSString *linkUserName = _userName;
    NSString *linkPassWord = _passWord;
    [session setUserName:linkUserName];
    [session setClientId:clientID];
    [session setPassword:linkPassWord];
    [session setKeepAliveInterval:5];
    session.transport = transport;
    session.delegate = self;
    [session connectAndWaitTimeout:10];
    self.mySession = session;
    [self.mySession addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil]; //添加事件监听

}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    switch (self.mySession.status) {
        case MQTTSessionManagerStateClosed:
        NSLog(@"连接已经关闭");
        break;
        case MQTTSessionManagerStateClosing:
        NSLog(@"连接正在关闭");
        break;
        case MQTTSessionManagerStateConnected:
        NSLog(@"已经连接");
        break;
        case MQTTSessionManagerStateConnecting:
        NSLog(@"正在连接中");
        
        break;
        case MQTTSessionManagerStateError: {
            //            NSString *errorCode = self.mySession.lastErrorCode.localizedDescription;
            NSString *errorCode = self.mySession.description;
            NSLog(@"连接异常 ----- %@",errorCode);
        }
        break;
        case MQTTSessionManagerStateStarting:
        NSLog(@"开始连接");
        break;
        default:
        break;
    }
}
-(void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error{
    if (eventCode == MQTTSessionEventConnected) {
        NSLog(@"2222222 链接MQTT 成功");
        
        // 方法 封装 可外部调用
        for (NSString *topic in _topics) {
            [session subscribeToTopic:topic atLevel:2 subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss){
                if (error) {
                    NSLog(@"Subscription failed %@", error.localizedDescription);
                } else {
                    NSLog(@"Subscription sucessfull! Granted Qos: %@", gQoss);

    //                [self send];
                }
             }];
        }
 // this is part of the block API

    }else if (eventCode == MQTTSessionEventConnectionRefused) {
            NSLog(@"MQTT拒绝链接");
   }else if (eventCode == MQTTSessionEventConnectionClosed){
            NSLog(@"MQTT链接关闭");
  }else if (eventCode == MQTTSessionEventConnectionError){
            NSLog(@"MQTT 链接错误");
  }else if (eventCode == MQTTSessionEventProtocolError){
            NSLog(@"MQTT 不可接受的协议");
  }else{//MQTTSessionEventConnectionClosedByBroker
            NSLog(@"MQTT链接 其他错误");
  }
   if (error) {
        NSLog(@"链接报错  -- %@",error);
   }
}

-(void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid
{
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    // 做相对应的操作
}
- (void)subscibeToTopicAction {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self subscibeToTopic:@"你要订阅的主题"];
            
        });
    });
}

-(void)subscibeToTopic:(NSString *)topicUrl
{
    [self.mySession subscribeToTopic:topicUrl atLevel:MQTTQosLevelAtMostOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
        if (error) {
            NSLog(@"订阅 %@ 失败 原因 %@",topicUrl,error);
        }else
        {
            NSLog(@"订阅 %@ 成功 g1oss %@",topicUrl,gQoss);
            dispatch_async(dispatch_get_main_queue(), ^{
                // 操作
            });

        };
    }];
}
-(void)closeMQTTClient{
    [self.mySession disconnect];
    [self.mySession unsubscribeTopics:@[@"已经订阅的主题"] unsubscribeHandler:^(NSError *error) {
        if (error) {
            NSLog(@"取消订阅失败");
        }else{
            NSLog(@"取消订阅成功");
        }
    }];
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
