 //
//  ViewController.m
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 13/04/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import "ViewController.h"
#import "FileUtils.h"
#import "ECPbProjHelper.h"
#import "CocoaUtil.h"
@interface ViewController()<NSPathControlDelegate>
@property (weak) IBOutlet NSPathControl *pathControl;
@property (nonatomic,strong ) NSString* lastPathSelected;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.pathControl.delegate = self;
    
    
//    NSString* path = @"/Users/erichmzhang/Code/NewQCloudiOSCodes/QCloudiOSCodes/Products/TACSamples/TACSamples.xcodeproj/project.pbxproj";
//    path = [[NSBundle mainBundle] pathForResource:@"project.pbxproj" ofType:nil];
//    NSData* data = [[NSData alloc] initWithContentsOfFile:path];
//    NSMutableDictionary* dict = [[[NSMutableDictionary alloc] initWithContentsOfFile:path] mutableCopy];
//
//    NSMutableDictionary* mutableDict = [NSMutableDictionary dictionaryWithDictionary:dict];
//
//    NSDictionary* buildBefore =  dict[@"objects"][@"1A38B0701FDAB4BB0054E40B"];
//    NSMutableDictionary* newScriptPhase = [buildBefore mutableCopy];
//    newScriptPhase[@"name"] = @"new Test name";
//    newScriptPhase[@"shellScript"]=@"pwd";
//    [mutableDict[@"objects"] setValue:newScriptPhase forKey:@"1A38B0723FDA23BB0054390B"];
//
//    NSString* outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"project.pbxproj"];
//
//    //add declaration
//    NSMutableArray* mutableArray = [NSMutableArray arrayWithArray:dict[@"objects"][@"1AB143EB1E601E0500830F93"][@"buildPhases"]];
//    [mutableArray  addObject:@"1A38B0723FDA23BB0054390B"];
//    [mutableDict[@"objects"][@"1AB143EB1E601E0500830F93"] setValue:mutableArray forKey:@"buildPhases"];
//    NSData* outputData = [NSPropertyListSerialization dataWithPropertyList:mutableDict format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
//    [outputData writeToFile:outputPath atomically:YES];
//    NSLog(@"what ever");
//
//
//    ECBuildPhases* buildPhases = [[ECBuildPhases alloc] init];
//    buildPhases.shellScript = @"pwd";
//    [[ECPbProjHelper sharedInstance] insertBuildPhase:buildPhases inDictionary:mutableDict withIndex:0];
//
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
    NSString* projectName = [[FileUtils sharedInstance] projectNameFromPath:workspcaePath];
    if (!projectName) {
        NSLog(@"Cannot found project in path %@",workspcaePath);
        return NO;
    }
    NSArray* fileList = [CocoaUtil findFilesWithExtension:@"plist" inFolder:workspcaePath];//[[NSFileManager defaultManager] contentsOfDirectoryAtPath:workspcaePath error:&error];
    if (nil != error) {
        return  NO;
    }
    NSString* currentPath = workspcaePath;
    NSDictionary* infoPlist;
    NSDictionary* qqPlist;
    NSDictionary* wechatPlist;
    
    
    NSArray * contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:currentPath error:nil];
    NSArray* plistFiles = [[FileUtils sharedInstance] findPlistFile:contents];
//if cannot found the plist file,down deeper into project directory
    if (plistFiles.count == 0) {
        currentPath = [currentPath stringByAppendingPathComponent:projectName];
        contents =  [[NSFileManager defaultManager] contentsOfDirectoryAtPath:currentPath error:nil];
        plistFiles =[[FileUtils sharedInstance] findPlistFile:contents];
    }
    
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

    ECBuildPhases* buildPhases = [[ECBuildPhases alloc] init];
    buildPhases.name = @"[Test] first shell script phases";
    buildPhases.shellScript = @"pwd";
    buildPhases.shellPath = @"/bin/sh";
    buildPhases.isa = @"PBXShellScriptBuildPhase";
    buildPhases.runOnlyForDeploymentPostprocessing = @"0";
    buildPhases.outputPaths = [NSArray array];
    buildPhases.files = [NSArray array];
    buildPhases.inputPaths = [NSArray array];
    NSMutableDictionary* mutableDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:[workspcaePath stringByAppendingFormat:@"/%@.xcodeproj/project.pbxproj",projectName]];
    
    [[ECPbProjHelper sharedInstance] insertBuildPhase:buildPhases inDictionary:mutableDictionary withIndex:0];
    
    
    NSString* pbxcprojPath = [workspcaePath stringByAppendingFormat:@"/%@.xcodeproj/project.pbxproj",projectName];
    
    [[FileUtils sharedInstance] writePlist:mutableDictionary intoPath:pbxcprojPath];

    
    
    ECBuildPhases* buildPhasesAfter = [[ECBuildPhases alloc] init];
    buildPhasesAfter.name = @"[Test] first shell script phases";
    buildPhasesAfter.shellScript = @"pwd";
    buildPhasesAfter.shellPath = @"/bin/sh";
    buildPhasesAfter.isa = @"PBXShellScriptBuildPhase";
    buildPhasesAfter.runOnlyForDeploymentPostprocessing = @"0";
    buildPhasesAfter.outputPaths = [NSArray array];
    buildPhasesAfter.files = [NSArray array];
    buildPhasesAfter.inputPaths = [NSArray array];
    [[ECPbProjHelper sharedInstance] insertBuildPhase:buildPhasesAfter inDictionary:mutableDictionary withIndex:-2];
    [[FileUtils sharedInstance] writePlist:mutableDictionary intoPath:pbxcprojPath];

    [self showAlertWithTitle:@"配置成功" content:@"请打开项目查看 URL Scheme, 编译前后运行脚本"];
    return YES;
}

- (void)showAlertWithTitle:(NSString*)title content:(NSString*)content {
    NSAlert* alert = [NSAlert new];
    [alert setMessageText:title];
    [alert setInformativeText:content];
    [alert addButtonWithTitle:@"确定"];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        
    }];
}

@end
