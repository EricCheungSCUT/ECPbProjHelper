//
//  FileUtilies.h
//  TACIntergrationTool
//
//  Created by Eric Cheung on 21/04/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtilies : NSObject
+ (NSDictionary*) dictionaryFromPlistFile:(NSString*)path;

+ (BOOL) writePlistDataToPath:(NSString*)path withDictionary:(NSDictionary*) dictionary;
+ (NSArray*) generateConfigurationFileListFromZipOrPath:(NSString*)path;
@end
