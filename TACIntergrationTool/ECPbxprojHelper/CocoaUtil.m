//
//  CocoaUtil.m
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 24/04/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import "CocoaUtil.h"

// Private Methods
@interface CocoaUtil ()

+ (NSArray *)_findFilesWithExtension:(NSString *)extension
                            inFolder:(NSString *)folder
                        andSubFolder:(NSString *)subFolder;

@end

@implementation CocoaUtil

+ (NSArray *)findFilesWithExtension:(NSString *)extension
                           inFolder:(NSString *)folder
{
    return [CocoaUtil _findFilesWithExtension:extension
                                     inFolder:folder
                                 andSubFolder:nil];
}

+ (NSArray*) findDirectoryWithName:(NSString*)directoryName
                           inDirectory:(NSString*)directory {
    return [CocoaUtil _findDirectoryWithName:directoryName inFolder:directory andSubFolder:nil];
}

+ (NSArray *)_findDirectoryWithName:(NSString*)directoryName
                           inFolder:(NSString*)folder
                       andSubFolder:(NSString*)subFolder {
    NSMutableArray *found = [NSMutableArray array];
    NSString *fullPath = (subFolder != nil) ? [folder stringByAppendingPathComponent:subFolder] : folder;
    
    NSFileManager *fileman = [NSFileManager defaultManager];
    NSError *error;
    NSArray *contents = [fileman contentsOfDirectoryAtPath:fullPath error:&error];
    if (contents == nil)
    {
        NSLog(@"Failed to find files in folder '%@': %@", fullPath, [error localizedDescription]);
        return nil;
    }
    
    for (NSString *file in contents)
    {
        NSString *subSubFolder = subFolder != nil ? [subFolder stringByAppendingPathComponent:file] : file;
        fullPath = [folder stringByAppendingPathComponent:subSubFolder];
        
        NSError *error = nil;
        NSDictionary *attributes = [fileman attributesOfItemAtPath:fullPath error:&error];
        if (attributes == nil)
        {
            NSLog(@"Failed to get attributes of file '%@': %@", fullPath, [error localizedDescription]);
            continue;
        }
        
        NSString *type = [attributes objectForKey:NSFileType];
        
        if (type == NSFileTypeDirectory)
        {
            NSArray *subContents = [CocoaUtil _findDirectoryWithName:directoryName inFolder:folder andSubFolder:subSubFolder];
            if (subContents == nil)
                return nil;
            if ([fullPath.lastPathComponent isEqualToString:directoryName]) {
                [found addObject:fullPath];
            }
            [found addObjectsFromArray:subContents];
        }
//        else if (type == NSFileTypeRegular)
//        {
//            // Note: case sensitive comparison!
//            if ([[fullPath pathExtension] isEqualToString:extension])
//            {
//                [found addObject:fullPath];
//            }
//        }
    }
    
    return found;
}

+ (NSArray *)_findFilesWithExtension:(NSString *)extension
                            inFolder:(NSString *)folder
                        andSubFolder:(NSString *)subFolder
{
    NSMutableArray *found = [NSMutableArray array];
    NSString *fullPath = (subFolder != nil) ? [folder stringByAppendingPathComponent:subFolder] : folder;
    
    NSFileManager *fileman = [NSFileManager defaultManager];
    NSError *error;
    NSArray *contents = [fileman contentsOfDirectoryAtPath:fullPath error:&error];
    if (contents == nil)
    {
        NSLog(@"Failed to find files in folder '%@': %@", fullPath, [error localizedDescription]);
        return nil;
    }
    
    for (NSString *file in contents)
    {
        NSString *subSubFolder = subFolder != nil ? [subFolder stringByAppendingPathComponent:file] : file;
        fullPath = [folder stringByAppendingPathComponent:subSubFolder];
        
        NSError *error = nil;
        NSDictionary *attributes = [fileman attributesOfItemAtPath:fullPath error:&error];
        if (attributes == nil)
        {
            NSLog(@"Failed to get attributes of file '%@': %@", fullPath, [error localizedDescription]);
            continue;
        }
        
        NSString *type = [attributes objectForKey:NSFileType];
        
        if (type == NSFileTypeDirectory)
        {
            NSArray *subContents = [CocoaUtil _findFilesWithExtension:extension inFolder:folder andSubFolder:subSubFolder];
            if (subContents == nil)
                return nil;
            [found addObjectsFromArray:subContents];
        }
        else if (type == NSFileTypeRegular)
        {
            // Note: case sensitive comparison!
            if ([[fullPath pathExtension] isEqualToString:extension])
            {
                [found addObject:fullPath];
            }
        }
    }
    
    return found;
}


+ (NSArray*) findFilesWithFileName:(NSString*)fileName
                       inDirectory:(NSString*)directory {
    return [CocoaUtil _findFilesWithFileName:fileName inFolder:directory andSubFolder:nil];
}

+ (NSArray *)_findFilesWithFileName:(NSString *)fileName
                            inFolder:(NSString *)folder
                        andSubFolder:(NSString *)subFolder
{
    NSMutableArray *found = [NSMutableArray array];
    NSString *fullPath = (subFolder != nil) ? [folder stringByAppendingPathComponent:subFolder] : folder;
    
    NSFileManager *fileman = [NSFileManager defaultManager];
    NSError *error;
    NSArray *contents = [fileman contentsOfDirectoryAtPath:fullPath error:&error];
    if (contents == nil)
    {
        NSLog(@"Failed to find files in folder '%@': %@", fullPath, [error localizedDescription]);
        return nil;
    }
    
    for (NSString *file in contents)
    {
        NSString *subSubFolder = subFolder != nil ? [subFolder stringByAppendingPathComponent:file] : file;
        fullPath = [folder stringByAppendingPathComponent:subSubFolder];
        
        NSError *error = nil;
        NSDictionary *attributes = [fileman attributesOfItemAtPath:fullPath error:&error];
        if (attributes == nil)
        {
            NSLog(@"Failed to get attributes of file '%@': %@", fullPath, [error localizedDescription]);
            continue;
        }
        
        NSString *type = [attributes objectForKey:NSFileType];
        
        if (type == NSFileTypeDirectory)
        {
            NSArray *subContents = [CocoaUtil _findFilesWithFileName:fileName inFolder:folder andSubFolder:subSubFolder];
            if (subContents == nil)
                return nil;
            [found addObjectsFromArray:subContents];
        }
        else if (type == NSFileTypeRegular)
        {
            // Note: case sensitive comparison!
            if ([[fullPath lastPathComponent] isEqualToString:fileName])
            {
                [found addObject:fullPath];
            }
        }
    }
    
    return found;
}

@end
