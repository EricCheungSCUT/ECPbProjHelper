//
//  ECProjectGroup.h
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 07/05/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECProjectGroup : NSObject
@property (nonatomic, copy) NSString* isa;
@property (nonatomic, strong) NSArray* children;
@property (nonatomic, copy) NSString* path;
@property (nonatomic, copy) NSString* sourceTree;
@end
