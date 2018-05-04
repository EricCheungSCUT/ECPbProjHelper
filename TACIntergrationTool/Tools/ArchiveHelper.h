//
//  ArchiveHelper.h
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 03/05/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArchiveHelper : NSObject

/**
 return contents that is compressed in zip.File will be compressed into temp directory

 @param zipPath zip file path
 @return path of contents inside zip
 */
+ (NSArray<NSString*>*)unArchiveWithZip:(NSString*)zipPath;
@end
