//
//  Baidu_TTS.m
//  OFit
//
//  Created by lv on 2018/10/17.
//  Copyright © 2018 JdHealth. All rights reserved.
//

#import "Baidu_TTS.h"
#import "JDUtilities.h"

@implementation Baidu_TTS

static Baidu_TTS *shared = nil;

#pragma mark - ARC

+ (instancetype)shared{
    
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        shared = [super allocWithZone:zone];
    });
    
    return shared;
}

- (id)copyWithZone:(struct _NSZone *)zone{
    
    return shared;
}

#pragma mark - MRC

#if __has_feature(objc_arc)

#else

- (instancetype)retain{
    
    return shared;
}

- (NSUInteger)retainCount{
    
    return 1;//此处也可以返回max
}

- (oneway void)release{
    
}

- (instancetype)autorelease{
    
    return shared;
}

#endif

#pragma mark - FUNCTION

-(void)baidu_auth:(baidu_authCallCack)result{

    NSString * urlString = [NSString stringWithFormat:@"https://openapi.baidu.com/oauth/2.0/token?grant_type=client_credentials&client_id=%@&client_secret=%@",self.authKey,self.authSecret];
    
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    [req setTimeoutInterval:5];
    [req setHTTPMethod:@"GET"];
    
    NSURLSession *session  = [NSURLSession sharedSession];
    __weak typeof(self) weakSelf = self;
    NSURLSessionTask *task = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSHTTPURLResponse *res = (NSHTTPURLResponse*)response;
//        NSLog(@"%@",error);
//        NSLog(@"%lu",[data length]);
//        NSLog(@"%@",response);
//        NSLog(@"%ld",[res statusCode]);
//
        if(error || [res statusCode] != 200){
            NSLog(@"baidu_auth_no");
            result(NO);
        }else{
//            JDLog(@"baidu_auth_ok");
            NSDictionary *body  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            strongSelf.token = body[@"access_token"];
            NSDate * now = [NSDate dateWithTimeIntervalSinceNow:0];
            strongSelf.authTime = [now timeIntervalSince1970];
            result(YES);
        }
        
    }];
    
    [task resume];
}

-(void)baidu_tts:(NSString*)text completionHandler:(baidu_ttsCallCack)completionHandler{
    
    NSString * str = [NSString stringWithFormat: @"tex=%@&lan=zh&vol=13&cuid=***&ctp=1&aue=3&tok=%@",text,self.token];
    
    NSMutableURLRequest * req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://tsn.baidu.com/text2audio"]];
    
    [req setHTTPMethod:@"POST"];
    
    [req setTimeoutInterval:5];
    
    
    [req setHTTPBody:[str dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSURLSession *session  = [NSURLSession sharedSession];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSHTTPURLResponse *res = (NSHTTPURLResponse*)response;
        
//                NSLog(@"%@",error);
//                NSLog(@"%lu",[data length]);
//                NSLog(@"%@",response);
//                NSLog(@"%ld",[res statusCode]);
//        NSLog(@"%@",res.allHeaderFields);
        
        NSString *type = res.allHeaderFields[@"Content-Type"];
        if([type isEqualToString:@"audio/mp3"]){
            completionHandler(200,data);
        }else{
            completionHandler(-100,data);
        }

    }];
    
    [task resume];
}





-(void)tts:(NSString*)text completionHandler:(baidu_ttsCallCack)completionHandler{
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    NSDate * nowd = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now = [nowd timeIntervalSince1970];
    if(now - self.authTime > 86400){///超过9分钟授权一次
        [self baidu_auth:^(BOOL state) {
            if(state){
                dispatch_group_leave(group);
            }else{
                completionHandler(-10000,nil);
            }
        }];
    }else{
        dispatch_group_leave(group);
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self baidu_tts:text completionHandler:completionHandler];
    });
}



@end
