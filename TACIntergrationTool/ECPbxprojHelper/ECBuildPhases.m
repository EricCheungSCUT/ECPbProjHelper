//
//  ECBuildPhases.m
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 20/04/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import "ECBuildPhases.h"

@implementation ECBuildPhases
- (NSDictionary *)toDictionary {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    if (self.buildActionMask) {
        [dict setValue:self.buildActionMask forKey:@"buildActionMask"];
    }
    if (self.files) {
        [dict setValue:self.files  forKey:@"files"];
    }
    if (self.inputPaths) {
        [dict setValue:self.inputPaths forKey:@"files"];
    }
    if (self.isa) {
        [dict setValue:self.isa forKey:@"isa"];
    }
    if (self.name) {
        [dict setValue:self.name forKey:@"name"];
    }
    if (self.outputPaths) {
        [dict setValue:self.outputPaths forKey:@"outputPaths"];
    }
    if (self.runOnlyForDeploymentPostprocessing) {
        [dict setValue:self.runOnlyForDeploymentPostprocessing forKey:@"runOnlyForDeploymentPostprocessing"];
    }
    if (self.shellPath) {
        [dict setValue:self.shellPath forKey:@"shellPath"];
    }
    if (self.shellScript) {
        [dict setValue:self.shellScript forKey:@"shellScript"];
    }
    return [dict copy];
}



@end
