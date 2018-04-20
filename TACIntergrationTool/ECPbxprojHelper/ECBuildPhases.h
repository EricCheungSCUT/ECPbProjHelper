//
//  ECBuildPhases.h
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 20/04/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECBuildPhases : NSObject
@property (nonatomic, copy) NSString* buildActionMask;
@property (nonatomic, strong) NSArray* files;
@property (nonatomic, strong) NSArray* inputPaths;
@property (nonatomic, copy)  NSString* isa;
@property (nonatomic, copy) NSString*  name;
@property (nonatomic, strong) NSArray* outputPaths;
@property (nonatomic, copy) NSString* runOnlyForDeploymentPostprocessing;
@property (nonatomic, copy) NSString* shellPath;
@property (nonatomic, copy) NSString* shellScript;

- (NSDictionary*) toDictionary;

@end
