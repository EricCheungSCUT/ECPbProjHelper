//
//  FileUtils.h
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 13/04/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtils : NSObject
+ (instancetype)sharedInstance;

- (NSArray<NSString*>*) filesInPath:(NSString*)path;

- (NSArray<NSString*>*) findPlistFile:(NSArray*)files;

- (BOOL)isInfoPlist:(NSString*)fileName ;

- (NSDictionary*)insertQQSchemeIntoPlist:(NSDictionary*)infoPlist :(NSDictionary*)QQPlist;

- (BOOL) writePlist:(NSDictionary*)plistDict intoPath:(NSString*)path;

@end
