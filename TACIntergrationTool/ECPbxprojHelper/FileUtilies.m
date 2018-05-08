//
//  FileUtilies.m
//  TACIntergrationTool
//
//  Created by Eric Cheung on 21/04/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import "FileUtilies.h"
#import "ArchiveHelper.h"
@implementation FileUtilies
+ (NSDictionary*) dictionaryFromPlistFile:(NSString*)path {
    if ([[NSFileManager defaultManager] isReadableFileAtPath:path]) {
        return [[NSDictionary alloc] initWithContentsOfFile:path];
    } else {
        NSLog(@"Cannot access file in %@",path);
        return nil;
    }
}

+ (BOOL) writePlistDataToPath:(NSString*)path withDictionary:(NSDictionary*) dictionary {
    
    NSData* plistData = [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
    if (nil == plistData) {
        return  NO;
    }
    return [plistData writeToFile:path atomically:YES];
}

+ (NSArray*) generateConfigurationFileListFromZipOrPath:(NSString*)configurationFilePath {
    NSArray<NSString*>* configurationFileList;
    if ([configurationFilePath.lastPathComponent isEqualToString:@"zip"]) {
        // 压缩包
        configurationFileList = [ArchiveHelper unArchiveWithZip:configurationFilePath];
    } else {
        //safari 自动解压
        NSMutableArray* configurationFileNameList = [NSMutableArray array];
        for( NSString* fileName in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:configurationFilePath error:nil]) {
            if (![fileName hasSuffix:@"plist"]) {
                continue;
            }
            [configurationFileNameList addObject:[configurationFilePath stringByAppendingPathComponent:fileName]];
        }
        configurationFileList = [configurationFileNameList copy];
    }
    return configurationFileList;
}

@end
