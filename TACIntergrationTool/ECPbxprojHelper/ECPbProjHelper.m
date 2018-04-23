//
//  ECPbProjHelper.m
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 20/04/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import "ECPbProjHelper.h"
#define kRootObjectKey @"rootObject"
#define kTargetsKey @"targets"
#define kObjectsKey @"objects"
#define kBuildPhasesKey @"buildPhases"
@implementation ECPbProjHelper
+(instancetype)sharedInstance {
    static ECPbProjHelper* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ECPbProjHelper alloc] init];
    });
    return instance;
}


- (BOOL)insertBuildPhase:(ECBuildPhases*)buildPhases
            inDictionary:(NSMutableDictionary*) dictionary
               withIndex:(NSInteger)index {
    // paramter validation
    if (nil ==  dictionary || ![dictionary valueForKey:kRootObjectKey]) {
        NSLog(@"Dictionary is nil, or does not contain root object key");
        return NO;
    }
    if ([dictionary isKindOfClass:[NSMutableDictionary class]]) {
        NSLog(@"Dictionary is not mutable!");
        return NO;
    }
    // insert in declaration
    
    // insert in objects(details)
    
    
    return YES;
}

- (NSString*) getRootObject:(NSDictionary*)dict {
    
    if (dict && [dict valueForKey:kRootObjectKey]) {
        return [dict valueForKey:kRootObjectKey];
    }
    return nil;
}


- (NSArray<NSString *> *)getTargets:(NSDictionary *)dict {
    NSString* rootObject = [self getRootObject:dict];
    if (nil == rootObject) {
        return nil;
    }
    NSString* keyPath = [NSString stringWithFormat:@"%@.%@.%@",kObjectsKey,kRootObjectKey,kTargetsKey];
    NSLog(@"keyPath is %@",keyPath);
    NSArray* result = [dict valueForKeyPath:keyPath];
    return result;
}

- (NSDictionary*)getConfigurationInTarget:(NSString*)targetUUID
                               dictionary:(NSDictionary*)dictionary {
    NSString* keyPath = [NSString stringWithFormat:@"%@.%@",kObjectsKey,targetUUID];
    NSDictionary* result = [dictionary valueForKeyPath:keyPath];
    return result;
}

@end
