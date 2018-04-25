//
//  ECProjectBuildConfiguration.h
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 24/04/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import <Foundation/Foundation.h>
@import YYModel;
@interface ECProjectBuildConfiguration : NSObject
@property (nonatomic, copy)   NSString* buildConfigurationList;
@property (nonatomic, strong) NSArray<NSString*>* buildPhases;
@property (nonatomic, strong) NSArray* buildRules;
@property (nonatomic, strong) NSArray* dependencies;
@property (nonatomic, copy) NSString* isa;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* productName;
@property (nonatomic, copy) NSString* productReference;
@property (nonatomic, copy) NSString* productType;
@end
