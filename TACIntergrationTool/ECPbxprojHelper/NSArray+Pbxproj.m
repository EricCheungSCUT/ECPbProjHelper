//
//  NSArray+Pbxproj.m
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 24/04/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import "NSArray+Pbxproj.h"

@implementation NSArray (Pbxproj)
- (NSArray*) matchedFileNameInArray:(NSArray*)array {
    NSMutableArray* result = [NSMutableArray array];
    if (self.count == 0 || !array || array.count == 0) {
        return nil;
    }
    for (NSString* path in self) {
        if ([path isKindOfClass:[NSString class]]) {
            return nil;
        }
        NSString* fileName = path.lastPathComponent;
        BOOL isMatched = NO;
        for (NSString* key in array) {
            if ([fileName rangeOfString:key].location != NSNotFound ) {
                isMatched = YES;
                break;
            }
        }
    }
    return [result copy];
}
@end
