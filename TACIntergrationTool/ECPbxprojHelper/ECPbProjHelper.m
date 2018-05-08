//
//  ECPbProjHelper.m
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 20/04/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import "ECPbProjHelper.h"
#import "ECProjectBuildConfiguration.h"
@import YYModel;
#import "ECProjectGroup.h"

#define kRootObjectKey  @"rootObject"
#define kTargetsKey     @"targets"
#define kObjectsKey     @"objects"
#define kBuildPhasesKey @"buildPhases"



@interface ECPbProjHelper()
@property (nonatomic, strong) NSMutableArray* histroyUUIDs;
@end

@implementation ECPbProjHelper
+(instancetype)sharedInstance {
    static ECPbProjHelper* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ECPbProjHelper alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    _histroyUUIDs = [NSMutableArray array];
    return self;
}

- (BOOL)checkDictionaryValid:(id)dictionary {
    // paramter validation
    if (nil ==  dictionary || ![dictionary valueForKey:kRootObjectKey]) {
        NSLog(@"Dictionary is nil, or does not contain root object key");
        return NO;
    }
    if (![dictionary isKindOfClass:[NSMutableDictionary class]]) {
        NSLog(@"Dictionary is not mutable, or even not class of dictionary!");
        return NO;
    }
    return YES;
}


#pragma mark - High level interface

- (BOOL)insertBuildPhase:(ECBuildPhases*)buildPhases
            inDictionary:(NSMutableDictionary*) dictionary
               withIndex:(NSInteger)index {
    if (![self checkDictionaryValid:dictionary]) {
        return NO;
    }
    // insert in declar!tion
    
    NSArray* targets = [self getTargets:dictionary];
    if (targets.count == 0 ) {
        NSLog(@"No targets found in project");
        return NO;
    }
    for (NSString* string in targets) {
        ECProjectBuildConfiguration* buildConfiguration = [self getConfigurationInTarget:string dictionary:dictionary];
        NSLog(@"target configuration:%@",buildConfiguration);
        
        NSString* firstBuildPhasesUUID = buildConfiguration.buildPhases.firstObject;
        ECBuildPhases* tempBuildPhases = [self getBuildPhasesWithUUID:firstBuildPhasesUUID inDictionary:dictionary];
        buildPhases.buildActionMask =  tempBuildPhases.buildActionMask;
        NSString* buildPhasesUUID = [self generateUUIDInPlist:dictionary];
        NSMutableArray* mutableBuildPhases = [buildConfiguration.buildPhases mutableCopy];
        if (mutableBuildPhases.count == 0) {
            return NO;
        }
        NSInteger actualIndex = NSIntegerMax;
        if (index >= 0) {
            if (index < mutableBuildPhases.count) {
                actualIndex = index;
            }
        } else/* index < 0 */  {
            if ( mutableBuildPhases.count + index > 0) {
                actualIndex = mutableBuildPhases.count + index;
            }
        }
        NSAssert(actualIndex != NSIntegerMax, @"Index invalid !");
        [mutableBuildPhases insertObject:buildPhasesUUID atIndex:actualIndex];
        NSString* buildPhasesKeyPath = [NSString stringWithFormat:@"%@.%@.%@",kObjectsKey,string,kBuildPhasesKey];
        [dictionary setValue:mutableBuildPhases forKeyPath:buildPhasesKeyPath];
        // insert in objects(details)
        NSString* objectsKeyPath = [NSString stringWithFormat:@"%@.%@",kObjectsKey,buildPhasesUUID];
        NSDictionary* insertedDictionary = [buildPhases yy_modelToJSONObject];
        [dictionary setValue:insertedDictionary forKeyPath:objectsKeyPath];
    }
    return YES;
}


- (BOOL)insertFileReference:(ECProjectFileReference*)fileReference
               inDictionary:(NSMutableDictionary*)dictionary {
    if (![self checkDictionaryValid:dictionary]) {
        return NO;
    }
    NSString* fileReferenceUUID = [self generateUUIDInPlist:dictionary];
    //Step 1 . Insert in objects declaration
    NSString*      declarationUUID = [self generateUUIDInPlist:dictionary];
    NSString*      step1KeyPath = [NSString stringWithFormat:@"%@.%@",kObjectsKey,declarationUUID];
    NSDictionary*  step1Value = @{@"isa":fileReference.isa,@"fileRef":fileReferenceUUID};
    [dictionary setValue:step1Value forKeyPath:step1KeyPath];
    
    //step2. Insert file reference object in obejcts declaration
    NSString*     step2KeyPath = [NSString stringWithFormat:@"%@.%@",kObjectsKey,fileReferenceUUID];
    NSDictionary* step2Value   = [fileReference yy_modelToJSONObject];
    [dictionary setValue:step2Value forKeyPath:step2KeyPath];
    
    //step3 Insert in PBXGroup (directory shown in xcode. We insert the file into root group here)
    NSString* rootObjectKey = [self getRootObject:dictionary];
    //key path that can get value of root object
    NSString* rootObjectKeyPath = [NSString stringWithFormat:@"%@.%@",kObjectsKey,rootObjectKey];
    NSDictionary* rootObjectDictionary = [dictionary valueForKeyPath:rootObjectKeyPath];
    
    NSString* mainGroupKey = [rootObjectDictionary valueForKey:@"mainGroup"];
    ECProjectGroup* projectGroup = [self getProjectGroupWithUUID:mainGroupKey inDictionary:dictionary];
    NSString* APPGroupKey = projectGroup.children.firstObject;
#warning Instad of getting first object directory, traversal all group to find the one with subfix "APP"
    ECProjectGroup* APPGroup = [self getProjectGroupWithUUID:APPGroupKey inDictionary:dictionary];
    NSMutableArray* mutableChildrenArray = [APPGroup.children mutableCopy];
    [mutableChildrenArray insertObject:fileReferenceUUID atIndex:0];
    APPGroup.children = [mutableChildrenArray copy];
    
    NSString* appGroupKeyPath = [NSString stringWithFormat:@"%@.%@",kObjectsKey,APPGroupKey];
    [dictionary setValue:[APPGroup yy_modelToJSONObject] forKeyPath:appGroupKeyPath];
    return YES;

    //step4 Insert in target's build phases section file (DeclarationUUID is the one should be inserted here, not fileReferenceUUID)
    NSArray* targets = [self getTargets:dictionary];
    NSString* APPTarget = targets.firstObject;
    ECProjectTarget* target =[ECProjectTarget yy_modelWithJSON:dictionary[kObjectsKey][APPTarget]];
    ECBuildPhases* buildPhases;
    NSString* buildPhasesUUID;
    for (NSString* tempBuildPhasesUUID in target.buildPhases) {
        ECBuildPhases* tempBuildPhases = [ECBuildPhases yy_modelWithJSON:dictionary[kObjectsKey][tempBuildPhasesUUID]];
        if ([tempBuildPhases.isa isEqualToString:@"PBXResourcesBuildPhase"]) {
            buildPhases  = tempBuildPhases;
            buildPhasesUUID = tempBuildPhasesUUID;
            break;
        }
    }
    NSMutableArray* files = buildPhases.files.mutableCopy;
    [files insertObject:declarationUUID atIndex:0];
    buildPhases.files = [files copy];
    NSString* buildPhasesKeyPath = [NSString stringWithFormat:@"%@.%@",kObjectsKey,buildPhasesUUID];
    [dictionary setValue:[buildPhases yy_modelToJSONObject] forKeyPath:buildPhasesKeyPath];
    return YES;
}

#pragma mark - Basic Functions

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
    NSString* keyPath = [NSString stringWithFormat:@"%@.%@.%@",kObjectsKey,rootObject,kTargetsKey];
    NSLog(@"keyPath is %@",keyPath);
    NSArray* result = [dict valueForKeyPath:keyPath];
    return result;
}

- (ECProjectBuildConfiguration*)getConfigurationInTarget:(NSString*)targetUUID
                                              dictionary:(NSDictionary*)dictionary {
    NSString* keyPath = [NSString stringWithFormat:@"%@.%@",kObjectsKey,targetUUID];
    NSDictionary* result = [dictionary valueForKeyPath:keyPath];
    ECProjectBuildConfiguration* configuration = [ECProjectBuildConfiguration yy_modelWithJSON:result];
    return configuration;
}

- (ECBuildPhases*) getBuildPhasesWithUUID:(NSString*)buildPhasesUUID
                             inDictionary:(NSDictionary*)plistDictionary {
    NSString* keyPath = [NSString stringWithFormat:@"%@.%@",kObjectsKey,buildPhasesUUID];
    NSDictionary* dict = [plistDictionary valueForKeyPath:keyPath];
    ECBuildPhases* result = [ECBuildPhases yy_modelWithJSON:dict];
    return result;
}

- (ECProjectGroup*) getProjectGroupWithUUID:(NSString*)groupUUID
                               inDictionary:(NSDictionary*)plistDictionary {
    NSString* keyPath = [NSString stringWithFormat:@"%@.%@",kObjectsKey,groupUUID];
    NSDictionary* dict = [plistDictionary valueForKeyPath:keyPath];
    ECProjectGroup* result = [ECProjectGroup yy_modelWithJSON:dict];
    return result;
}

- (NSString*) generateUUIDInPlist:(NSDictionary*)plistDictionary {
    NSString* tempUUIDString = [NSUUID UUID].UUIDString;
    NSString* UUIDIn32Bit = [NSString stringWithFormat:@"%@%@",[tempUUIDString substringFromIndex:tempUUIDString.length-12],[tempUUIDString substringFromIndex:tempUUIDString.length-12]];
    
    
    while ([self checkWhetherUUIDExisted:UUIDIn32Bit inPlistDictionary:plistDictionary]) {
        NSLog(@"Checking UUID existence");
        tempUUIDString = [NSUUID UUID].UUIDString;
        UUIDIn32Bit = [NSString stringWithFormat:@"%@%@",[tempUUIDString substringFromIndex:tempUUIDString.length-12],[tempUUIDString substringFromIndex:tempUUIDString.length-12]];
    }
    [self.histroyUUIDs addObject:UUIDIn32Bit];
    return UUIDIn32Bit;
}

- (BOOL)checkWhetherUUIDExisted:(NSString*)UUIDString inPlistDictionary:(NSDictionary*)plistDictionary
{
    BOOL isExisted = NO;
    NSArray* existedUUIDs = [plistDictionary[kObjectsKey] allKeys];

    for (NSString* string in existedUUIDs ) {
        if ([string isEqualToString:UUIDString]) {
            isExisted = YES;
            break;
        }
    }
    
    for (NSString* string in self.histroyUUIDs) {
        if ([string isEqualToString:UUIDString]) {
            isExisted = YES;
            break;
        }
    }
    
    return isExisted;
}
@end
