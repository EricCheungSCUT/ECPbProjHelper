//
//  ECPbProjHelper.h
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 20/04/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECBuildPhases.h"
@interface ECPbProjHelper : NSObject
+ (instancetype)sharedInstance;

- (BOOL)insertBuildPhase:(ECBuildPhases*)buildPhases inDictionary:(NSMutableDictionary*) dictionary;

@end
