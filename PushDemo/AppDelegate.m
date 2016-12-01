//
//  AppDelegate.m
//  PushDemo
//
//  Created by 赵广亮 on 2016/11/16.
//  Copyright © 2016年 zhaoguangliangzhaoguanliang. All rights reserved.
//

#import "AppDelegate.h"
#import "EaseUI.h"

@interface AppDelegate ()<EMChatManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //AppKey:注册的AppKey，详细见下面注释。
    //apnsCertName:推送证书名（不需要加后缀），详细见下面注释。
    EMOptions *options = [EMOptions optionsWithAppkey:@"1192161108178165#testpushdemo"];
    options.apnsCertName = @"Develop";
    [[EMClient sharedClient] initializeSDKWithOptions:options];

    //登录环信
    [[EMClient sharedClient] loginWithUsername:@"13051698888"
                                      password:@"222222"
                                    completion:^(NSString *aUsername, EMError *aError) {
                                        if (!aError) {
                                            NSLog(@"环信登陆成功");
                                            EMPushOptions *emoptions = [[EMClient sharedClient] pushOptions];
                                            emoptions.displayStyle = EMPushDisplayStyleSimpleBanner;
                                            [[EMClient sharedClient] updatePushOptionsToServer];
                                        } else {
                                            NSLog(@"环信登陆失败");
                                        }
                                    }];
    
    
    /**
     注册APNS离线推送  iOS8 注册APNS
     */
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound |
        UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    else{
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge |
        UIRemoteNotificationTypeSound |
        UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
    
    //实时监听推送消息
   [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];    
    return YES;
}

//监听推送消息  监听环信推送的消息
- (void)messagesDidReceive:(NSArray *)aMessages{
    
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"收到环信通知" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    
        for (EMMessage *message in aMessages) {
            EMMessageBody *msgBody = message.body;
            switch (msgBody.type) {
                case EMMessageBodyTypeText:
                {
                    // 收到的文字消息
                    EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
                    NSString *txt = textBody.text;
                    NSLog(@"收到的文字是 txt -- %@",txt);
                }
                    break;
                case EMMessageBodyTypeImage:
                {
                    // 得到一个图片消息body
                    EMImageMessageBody *body = ((EMImageMessageBody *)msgBody);
                    NSLog(@"大图remote路径 -- %@"   ,body.remotePath);
                    NSLog(@"大图local路径 -- %@"    ,body.localPath); // // 需要使用sdk提供的下载方法后才会存在
                    NSLog(@"大图的secret -- %@"    ,body.secretKey);
                    NSLog(@"大图的W -- %f ,大图的H -- %f",body.size.width,body.size.height);
                    NSLog(@"大图的下载状态 -- %u",body.downloadStatus);
    
    
                    // 缩略图sdk会自动下载
                    NSLog(@"小图remote路径 -- %@"   ,body.thumbnailRemotePath);
                    NSLog(@"小图local路径 -- %@"    ,body.thumbnailLocalPath);
                    NSLog(@"小图的secret -- %@"    ,body.thumbnailSecretKey);
                    NSLog(@"小图的W -- %f ,大图的H -- %f",body.thumbnailSize.width,body.thumbnailSize.height);
                    NSLog(@"小图的下载状态 -- %u",body.thumbnailDownloadStatus);
                }
                    break;
                case EMMessageBodyTypeLocation:
                {
                    EMLocationMessageBody *body = (EMLocationMessageBody *)msgBody;
                    NSLog(@"纬度-- %f",body.latitude);
                    NSLog(@"经度-- %f",body.longitude);
                    NSLog(@"地址-- %@",body.address);
                }
                    break;
                case EMMessageBodyTypeVoice:
                {
                    // 音频sdk会自动下载
                    EMVoiceMessageBody *body = (EMVoiceMessageBody *)msgBody;
                    NSLog(@"音频remote路径 -- %@"      ,body.remotePath);
                    NSLog(@"音频local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在（音频会自动调用）
                    NSLog(@"音频的secret -- %@"        ,body.secretKey);
                    NSLog(@"音频文件大小 -- %lld"       ,body.fileLength);
                    NSLog(@"音频文件的下载状态 -- %u"   ,body.downloadStatus);
                    NSLog(@"音频的时间长度 -- %u"      ,body.duration);
                }
                    break;
                case EMMessageBodyTypeVideo:
                {
                    EMVideoMessageBody *body = (EMVideoMessageBody *)msgBody;
    
                    NSLog(@"视频remote路径 -- %@"      ,body.remotePath);
                    NSLog(@"视频local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在
                    NSLog(@"视频的secret -- %@"        ,body.secretKey);
                    NSLog(@"视频文件大小 -- %lld"       ,body.fileLength);
                    NSLog(@"视频文件的下载状态 -- %u"   ,body.downloadStatus);
                    NSLog(@"视频的时间长度 -- %u"      ,body.duration);
                    NSLog(@"视频的W -- %f ,视频的H -- %f", body.thumbnailSize.width, body.thumbnailSize.height);
    
                    // 缩略图sdk会自动下载
                    NSLog(@"缩略图的remote路径 -- %@"     ,body.thumbnailRemotePath);
                    NSLog(@"缩略图的local路径 -- %@"      ,body.thumbnailLocalPath);
                    NSLog(@"缩略图的secret -- %@"        ,body.thumbnailSecretKey);
                    NSLog(@"缩略图的下载状态 -- %u"      ,body.thumbnailDownloadStatus);
                }
                    break;
                case EMMessageBodyTypeFile:
                {
                    EMFileMessageBody *body = (EMFileMessageBody *)msgBody;
                    NSLog(@"文件remote路径 -- %@"      ,body.remotePath);
                    NSLog(@"文件local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在
                    NSLog(@"文件的secret -- %@"        ,body.secretKey);
                    NSLog(@"文件文件大小 -- %lld"       ,body.fileLength);
                    NSLog(@"文件文件的下载状态 -- %u"   ,body.downloadStatus);
                }
                    break;
                    
                default:
                    break;
            }
        }
}

// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [[EMClient sharedClient] bindDeviceToken:deviceToken];
}

// 注册deviceToken失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"error -- %@",error);
}

// APP进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

// APP将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
