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
#import "WebViewController.h"
#import "ArchiveHelper.h"
@import WebKit;

@interface ViewController()<NSPathControlDelegate,NSViewControllerPresentationAnimator>
@property (weak) IBOutlet NSPathControl *configurationFilePathControl;
@property (weak) IBOutlet NSPathControl *pathControl;
@property (nonatomic,strong ) NSString* lastPathSelected;
@property (nonatomic,strong)  NSString* configurationPlistSelected;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.pathControl.delegate = self;
    self.configurationFilePathControl.delegate = self;
}

- (IBAction)onHandleFIlePathChange:(id)sender {
    NSLog(@"sender is ");
    NSString* samplePath = [[sender URL] path];
    self.lastPathSelected = samplePath;
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
}

- (IBAction)onHandleConfigurationFilePathControlChange:(id)sender {
    NSLog(@"sender is ");
    NSString* samplePath = [[sender URL] path];
    self.configurationPlistSelected = samplePath;
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
    
    
    NSString* configurationPath = self.configurationPlistSelected;
    if (!configurationPath) {
        return NO;
    }
    
    NSArray* configurationFileList;
    if ([configurationPath.lastPathComponent isEqualToString:@"zip"]) {
        // 压缩包
        configurationFileList = [ArchiveHelper unArchiveWithZip:configurationPath];
    } else {
        //safari 自动解压
        configurationFileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:configurationPath error:nil];
    }
    
    
    
    NSArray* fileList = [CocoaUtil findFilesWithExtension:@"plist" inFolder:workspcaePath];//[[NSFileManager defaultManager] contentsOfDirectoryAtPath:workspcaePath error:&error];
    
    NSArray* test = [CocoaUtil findFilesWithFileName:@"AppDelegate.h" inDirectory:workspcaePath];
    NSArray* directoryTest = [CocoaUtil findDirectoryWithName:@"TACCrash.framework" inDirectory:workspcaePath];
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

    
    NSString* buildAfterShell;
    if (directoryTest.count == 0) {
        //means intergrate via cocoapods
        buildAfterShell=@"${PODS_ROOT}/TACCore/Scripts/tac.run.all.after.sh";
    } else {
        NSString* crashFrameworkPath = [[directoryTest firstObject] stringByAppendingString:@"/Scripts/run"];
        NSInteger SRCRootLength = workspcaePath.length;
        NSString* directoryUnderSRCROOT = [crashFrameworkPath substringFromIndex:SRCRootLength];
        buildAfterShell = [NSString stringWithFormat:@"bash \"${SRCROOT}%@\"",directoryUnderSRCROOT];
    }
    
    ECBuildPhases* buildPhasesAfter = [[ECBuildPhases alloc] init];
    buildPhasesAfter.name = @"[Test] run after build shell script phases";
    buildPhasesAfter.shellScript = buildAfterShell;
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

- (void)showWebview {
    WebViewController* webviewController = [[WebViewController alloc] init];
    [self presentViewControllerAsModalWindow:webviewController];
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
