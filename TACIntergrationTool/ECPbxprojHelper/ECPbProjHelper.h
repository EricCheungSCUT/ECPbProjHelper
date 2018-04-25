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


/**
 Insert build phases into project settings

 @param buildPhases buildPhases entity class
 @param dictionary plistDictionary, which must be mutable
 @param index index that you would like to insert.There might be several build phases, and you have to specify an index which the build phases insertd located. Something might take attention here is that the index can be negative. Setting this value into -1 turns out putting build phase in last, -2 means putting build phase into the fronter one, etc. Index start from zero.
 @return whether the insertion is success or not. If insertion fails, there might be several reasons, such as buildPhases is not in correct format, dictionary is not mutable nor properly pbxproj data, etc. Log will provide you with more information.
 */
- (BOOL)insertBuildPhase:(ECBuildPhases*)buildPhases
            inDictionary:(NSMutableDictionary*) dictionary
               withIndex:(NSInteger)index;


/**
 get UUID of root Object

 @param dict plistDictionary
 @return root object value
 */
- (NSString*) getRootObject:(NSDictionary*)dict;

/**
 Get UUID of all targets in project.

 @return rootObject
 */
- (NSArray<NSString*>*) getTargets:(NSDictionary*)dict;
@end
