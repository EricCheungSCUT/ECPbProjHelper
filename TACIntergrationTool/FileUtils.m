//
//  FileUtils.m
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 13/04/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import "FileUtils.h"

@implementation FileUtils
+ (instancetype)sharedInstance {
    static FileUtils* utils ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        utils = [[FileUtils alloc] init];
    });
    return utils;
}

- (NSArray<NSString*>*) filesInPath:(NSString*)path {
    if (!path) {
        return nil;
    }
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
}

- (NSArray<NSString*>*) findPlistFile:(NSArray*)files {
    NSMutableArray* result = [NSMutableArray array];
    for (NSString* file in files) {
        if ([self isPlistFile:file]) {
            [result addObject:file];
        }
    }
    return [result copy];
}

- (BOOL)isPlistFile:(NSString*)string {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"plist$" options:NSRegularExpressionCaseInsensitive error:&error];
                                  NSTextCheckingResult *match = [regex firstMatchInString:string options:NSMatchingReportCompletion range:NSMakeRange(0, [string length])];
                                  if (match){
                                      return YES;
                                  }else{
                                      return NO;
                                  }
}

- (BOOL)isInfoPlist:(NSString*)fileName {
    return  [fileName isEqualToString:@"Info.plist"];
}


- (NSDictionary*)insertQQSchemeIntoPlist:(NSDictionary*)infoPlist :(NSDictionary*)QQPlist {
    
    NSString* URLTypesKey = @"CFBundleURLTypes";
    NSMutableDictionary* result = [infoPlist mutableCopy];
    NSMutableArray* URLTypes = [result[@"CFBundleURLTypes"] mutableCopy];
    if (URLTypes == nil) {
        URLTypes = [NSMutableArray array];
    }
    
    
    NSString* APPID = QQPlist[@"services"][@"social"][@"qq"][@"appId"] ;
    NSString* QQWalletScheme = [NSString stringWithFormat:@"qqwallet--test--%@",APPID];
    
    NSDictionary* QQWalletSchemeDictionary = @{@"CFBundleTypeRole":@"Editor",@"CFBundleURLName":QQWalletScheme,@"CFBundleURLSchemes":@[QQWalletScheme]};
    [URLTypes addObject:QQWalletSchemeDictionary];
    [result setValue:URLTypes forKey:URLTypesKey];
    
    return [result copy];
    
}

- (BOOL) writePlist:(NSDictionary*)plistDict intoPath:(NSString*)path {
    NSError* error;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict
                         
                                                                   format:NSPropertyListXMLFormat_v1_0
                         
                                                         errorDescription:&error];
    BOOL canWrite = [[NSFileManager defaultManager] isWritableFileAtPath:path];
    
    [plistData writeToFile:path atomically:YES];
    return YES;
}
@end
