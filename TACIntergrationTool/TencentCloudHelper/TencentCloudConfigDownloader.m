//
//  TencentCloudConfigDownloader.m
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 16/05/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import "TencentCloudConfigDownloader.h"
@import WebKit;
@implementation TencentCloudConfigDownloader
+ (void)downloadConfigurationWithURL:(NSURL* )url completionHandler:(void(^)(NSString* configurationZIPFilePath))completionHandler {
    
    __block NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    
    
        [[WKWebsiteDataStore defaultDataStore].httpCookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull cookies) {
            NSMutableString *cookieStr = [NSMutableString string];
            for (NSHTTPCookie *cookie in cookies) {
                if (cookieStr.length) {
                    [cookieStr appendString:@"; "];
                }
                [cookieStr appendFormat:@"%@=%@", cookie.name, cookie.value];
            }
            [urlRequest setValue:cookieStr forHTTPHeaderField:@"Cookie"];
            
            
            
            [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if ([(NSHTTPURLResponse*)response statusCode] != 200) {
                    NSLog(@"fail to download configuration file!");
                    return ;
                }
                NSString* tempPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID UUID].UUIDString] stringByAppendingString:@".zip"];
                if ([data writeToFile:tempPath atomically:YES]) {
                    NSLog(@"下载配置文件完成 %@",tempPath);
                    [[NSNotificationCenter defaultCenter ] postNotificationName:kConfigurationDidDownloadKey object: tempPath];
                } else {
                    NSLog(@"Cannot write to path %@",tempPath);
                }
                
            }] resume];
            
        }];
    
    

}
@end
