//
//  NSArray+Pbxproj.h
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 24/04/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Pbxproj)


/**
 return array that file name is in array

 @param array array of file name that you want to keep
 @return filted result
 */
- (NSArray*) matchedFileNameInArray:(NSArray*)array;

@end
