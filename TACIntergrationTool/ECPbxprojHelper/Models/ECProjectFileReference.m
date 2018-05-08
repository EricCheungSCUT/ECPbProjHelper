//
//  ECProjectFileReference.m
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 07/05/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import "ECProjectFileReference.h"

@implementation ECProjectFileReference

- (NSString*)sourceTree {
    if (!_sourceTree) {
        return @"\"<group>\"";
    }
    return _sourceTree;
}

@end
