//
//  CocoaUtil.h
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 24/04/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CocoaUtil : NSObject

+ (NSArray *)findFilesWithExtension:(NSString *)extension
                           inFolder:(NSString *)folder;

@end
