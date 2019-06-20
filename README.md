# Baidu_TTS_And_Amazon_TTS
百度及亚马逊文本转语音

```objc
//百度语音TTS
//设置授权参数
[[Baidu_TTS shared] setAuthKey:@""];
[[Baidu_TTS shared] setAuthSecret:@""];

//授权操作
[[Baidu_TTS shared] baidu_auth:^(BOOL state) {

}];

//转换操作
[[Baidu_TTS shared] tts:@"转成语音的文本内容" completionHandler:^(NSInteger code, NSData * _Nullable data) {
    //code=200 成功 data=mp3格式二进制数据
}];


//亚马逊TTS 需要使用到#import <AWSPolly/AWSPolly.h>框架 可用使用cocoapods引用 pod 'AWSPolly', '~> 2.8.0'

//设置授权ID
[[AmazonPolly shared] setCognitoIdentityPoolIdWithId:@""];

[[AmazonPolly shared] ttsWithText:@"转成语音的文本内容" completetion:^(NSInteger code, NSData * _Nullable data) {
    //code=200 成功 data=mp3格式二进制数据
}];

```
