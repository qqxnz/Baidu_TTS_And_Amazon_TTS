//
//  Baidu_TTS.h
//  OFit
//
//  Created by lv on 2018/10/17.
//  Copyright © 2018 JdHealth. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^baidu_authCallCack) (BOOL state);
typedef void (^baidu_ttsCallCack) (NSInteger code,NSData * _Nullable data);


@interface Baidu_TTS : NSObject

@property (nonatomic,strong) NSString * token;
@property (nonatomic,strong) NSString * authKey;
@property (nonatomic,strong) NSString * authSecret;
@property (nonatomic,assign) NSTimeInterval  authTime;

+ (instancetype)shared;
-(void)baidu_auth:(void (^)(BOOL))result;
-(void)baidu_tts:(NSString*)text completionHandler:(baidu_ttsCallCack)completionHandler;
-(void)tts:(NSString*)text completionHandler:(baidu_ttsCallCack)completionHandler;

@end

NS_ASSUME_NONNULL_END
