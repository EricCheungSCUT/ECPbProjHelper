//
//  ECPbProjHelper.m
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 20/04/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import "ECPbProjHelper.h"

@implementation ECPbProjHelper
+(instancetype)sharedInstance {
    static ECPbProjHelper* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ECPbProjHelper alloc] init];
    });
    return instance;
}


//- (BOOL)insertBuildPhase:(ECBuildPhases*)buildPhases inDictionary:(NSMutableDictionary*) dictionary {
//    NSDictionary* dict = [buildPhases toDictionary];
//    
//    
//    
//}
@end
