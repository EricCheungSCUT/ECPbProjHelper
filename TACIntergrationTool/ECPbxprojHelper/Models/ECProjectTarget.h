//
//  ECProjectTarget.h
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 08/05/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECProjectTarget : NSObject
@property (nonatomic, copy) NSString* isa;
@property (nonatomic, copy) NSString* buildConfigurationList;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* productName;
@property (nonatomic, copy) NSString* productReference;
@property (nonatomic, copy) NSString* productType;
@property (nonatomic, strong) NSArray* buildRules;
@property (nonatomic, strong) NSArray* buildPhases;
@property (nonatomic, strong) NSArray* dependencies;
@end
