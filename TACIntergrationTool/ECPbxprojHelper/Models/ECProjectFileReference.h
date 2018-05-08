//
//  ECProjectFileReference.h
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 07/05/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECProjectFileReference : NSObject
@property (nonatomic, copy) NSString* isa;
@property (nonatomic, assign) NSInteger fileEncoding;
@property (nonatomic, copy) NSString*   lastKnownFileType;
@property (nonatomic, copy) NSString* path;
@property (nonatomic, copy) NSString* sourceTree;
@end
