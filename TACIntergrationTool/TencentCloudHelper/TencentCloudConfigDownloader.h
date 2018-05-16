//
//  TencentCloudConfigDownloader.h
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 16/05/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import <Foundation/Foundation.h>
#define kConfigurationDidDownloadKey @"kConfigurationDidDownloadKey"


@interface TencentCloudConfigDownloader : NSObject

+ (void)downloadConfigurationWithURL:(NSURL* )url completionHandler:(void(^)(NSString* configurationZIPFilePath))completionHandler;

@end
