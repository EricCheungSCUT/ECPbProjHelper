//
//  ArchiveHelper.m
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 03/05/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import "ArchiveHelper.h"
@import ZipArchive;
@implementation ArchiveHelper
+ (NSArray<NSString*>*)unArchiveWithZip:(NSString*)zipPath {
    NSString* destinationPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSUUID UUID].UUIDString];
    [SSZipArchive unzipFileAtPath:zipPath toDestination:destinationPath];
    NSArray* resultContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:destinationPath error:nil];
    if ( nil == resultContent || resultContent.count == 0) {
        return nil;
    }
    return resultContent;
}
@end
