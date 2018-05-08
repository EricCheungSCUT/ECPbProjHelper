//
//  ECProjectBuildPhases.h
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 08/05/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECProjectBuildPhases : NSObject
@property (nonatomic, copy) NSString*   buildActionMask;
@property (nonatomic, copy) NSString*   isa;
@property (nonatomic, assign) NSInteger runOnlyForDeploymentPostprocessing;
@property (nonatomic, strong) NSArray* files;
@end
