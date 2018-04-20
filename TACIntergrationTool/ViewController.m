//
//  ViewController.m
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 13/04/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import "ViewController.h"
#import "FileUtils.h"
@interface ViewController()<NSPathControlDelegate>
@property (weak) IBOutlet NSPathControl *pathControl;
@property (nonatomic,strong ) NSString* lastPathSelected;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.pathControl.delegate = self;
    
    
    NSString* path = @"/Users/erichmzhang/Code/NewQCloudiOSCodes/QCloudiOSCodes/Products/TACSamples/TACSamples.xcodeproj/project.pbxproj";
    path = [[NSBundle mainBundle] pathForResource:@"project.pbxproj" ofType:nil];
    NSData* data = [[NSData alloc] initWithContentsOfFile:path];
    NSMutableDictionary* dict = [[[NSMutableDictionary alloc] initWithContentsOfFile:path] mutableCopy];
    
    NSMutableDictionary* mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    
    NSDictionary* buildBefore =  dict[@"objects"][@"1A38B0701FDAB4BB0054E40B"];
    NSMutableDictionary* newScriptPhase = [buildBefore mutableCopy];
    newScriptPhase[@"name"] = @"new Test name";
    newScriptPhase[@"shellScript"]=@"pwd";
    [mutableDict[@"objects"] setValue:newScriptPhase forKey:@"1A38B0723FDA23BB0054390B"];
    
    NSString* outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"project.pbxproj"];
    
    //add declaration
    NSMutableArray* mutableArray = [NSMutableArray arrayWithArray:dict[@"objects"][@"1AB143EB1E601E0500830F93"][@"buildPhases"]];
    [mutableArray  addObject:@"1A38B0723FDA23BB0054390B"];
    [mutableDict[@"objects"][@"1AB143EB1E601E0500830F93"] setValue:mutableArray forKey:@"buildPhases"];
    NSData* outputData = [NSPropertyListSerialization dataWithPropertyList:mutableDict format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
    [outputData writeToFile:outputPath atomically:YES];
    NSLog(@"what ever");
}

- (IBAction)onHandleFIlePathChange:(id)sender {
    
    NSLog(@"sender is ");
    NSString* samplePath = [[sender URL] path];
    self.lastPathSelected = samplePath;
}




- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
- (IBAction)onHandleIntergrationClicked:(id)sender {
    if (!self.lastPathSelected) {
        return ;
    }
    [self insertPlistFileInPath:self.lastPathSelected];
}

- (BOOL)pathControl:(NSPathControl *)pathControl shouldDragItem:(NSPathControlItem *)pathItem withPasteboard:(NSPasteboard *)pasteboard {
    return YES;
}
- (BOOL)pathControl:(NSPathControl *)pathControl shouldDragPathComponentCell:(NSPathComponentCell *)pathComponentCell withPasteboard:(NSPasteboard *)pasteboard {
    return  YES;
}

- (BOOL)insertPlistFileInPath:(NSString*)workspcaePath {
    NSError* error;
    NSArray* fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:workspcaePath error:&error];
    if (nil != error) {
        return  NO;
    }
    NSArray* plistFiles = [[FileUtils sharedInstance] findPlistFile:fileList];
    NSString* currentPath = workspcaePath;
    NSDictionary* infoPlist;
    NSDictionary* qqPlist;
    NSDictionary* wechatPlist;
    currentPath = [currentPath stringByAppendingString:@"/"];
    for (NSString* fileName in plistFiles) {
        
        NSString* filePath = [currentPath stringByAppendingString:fileName];
        NSDictionary* dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        NSLog(@"file path is %@",filePath);
        NSLog(@"dict is %@",dict);
        
        if ([[FileUtils sharedInstance] isInfoPlist:fileName]) {
            infoPlist = dict;
        }
        
        if ([filePath containsString:@"qq"]) {
            qqPlist = dict;
        }
        
        if ([filePath containsString:@"wechat"]) {
            wechatPlist = dict;
        }
        
    }
    
    
    if (!infoPlist) {
        NSLog(@"Info.plist not found in %@",workspcaePath);
    }
    if (!qqPlist) {
        NSLog(@"Cannot found plist file that contains AppID of QQ in %@",workspcaePath);
    }
    if (!wechatPlist) {
        NSLog(@"Cannot found plist file that contains AppID of Wechat in %@",workspcaePath);
    }
    
    if (!(infoPlist&&qqPlist&&wechatPlist)) {
        return NO;
    }
    
    NSDictionary* resultInfoPlist = [[FileUtils sharedInstance] insertQQSchemeIntoPlist:infoPlist :qqPlist];
    
    NSString* destPath = [NSString stringWithFormat:@"%@Info.plist",currentPath];
    [[FileUtils sharedInstance] writePlist:resultInfoPlist intoPath:destPath];
    
    NSLog(@"URL is %@",workspcaePath);
    return YES;
}

@end
