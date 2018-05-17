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
#import "FileUtilies.h"
#import "TencentCloudConfigDownloader.h"
@import WebKit;

@interface ViewController()<NSPathControlDelegate,NSViewControllerPresentationAnimator>
@property (weak) IBOutlet NSPathControl *configurationFilePathControl;
@property (weak) IBOutlet NSPathControl *pathControl;
@property (nonatomic,strong ) NSString* lastPathSelected;
@property (nonatomic,strong)  NSString* configurationPlistSelected;
@property (nonatomic, copy) NSString* lastDownloaedConfigurationFilePath;
@property (nonatomic, strong) WebViewController* webviewController;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.pathControl.delegate = self;
    self.configurationFilePathControl.delegate = self;
}
- (IBAction)onHandleLoginButtonClicked:(id)sender {
    [self showWebview];
}

- (IBAction)onHandleFIlePathChange:(id)sender {
    NSLog(@"sender is ");
    NSString* samplePath = [[sender URL] path];
    self.lastPathSelected = samplePath;
}

- (void)viewDidAppear {
    [super viewDidAppear];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHandleConfigurationFileDownloaded:) name:kConfigurationDidDownloadKey object:nil];
}


- (void)viewDidDisappear {
    [super viewDidDisappear];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onHandleConfigurationFileDownloaded:(NSNotification*)notification {
    NSString* configurationZipFilePath = notification.object;
    self.lastDownloaedConfigurationFilePath = configurationZipFilePath;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissController:self.webviewController];
        [self.webviewController dismissController:self.webviewController];
    [self.configurationFilePathControl setURL:[NSURL URLWithString:configurationZipFilePath]];
    });
    
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

- (BOOL) insertPlistConfigurationFileIn:(NSString*)pbxprojFilePath configurationFilePath:(NSString*)configurationFilePath {
    if (!configurationFilePath) {
        return NO;
    }
    NSMutableDictionary* mutableDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:pbxprojFilePath];
    NSArray* configurationFileList = [FileUtilies generateConfigurationFileListFromZipOrPath:configurationFilePath];
    for (NSString* filePath in configurationFileList) {
        ECProjectFileReference* testFileReference = [[ECProjectFileReference alloc] init];
        testFileReference.isa = @"PBXFileReference";
        testFileReference.fileEncoding = 4;
        testFileReference.lastKnownFileType = @"text.plist.xml";
        testFileReference.path = filePath.lastPathComponent;
        testFileReference.sourceTree = @"SOURCE_ROOT";
        BOOL copyIntoBundleResources = YES;
        if ([filePath.lastPathComponent isEqualToString:@"tac_services_configurations_unpackage.plist"]) {
            copyIntoBundleResources = NO;
        }
        [[ECPbProjHelper sharedInstance] insertFileReference:testFileReference inDictionary:mutableDictionary copyIntoBundleResources:copyIntoBundleResources];
        [[FileUtils sharedInstance] writePlist:mutableDictionary intoPath:pbxprojFilePath];
    }
    return YES;
}

- (BOOL) moveConfigurationPlistFileIntoSourceRootWithCongfigurationFilePath:(NSString*)configurationFilePath workspacePath:(NSString* )workspacePath {
    NSArray* configurationFileList = [FileUtilies generateConfigurationFileListFromZipOrPath:configurationFilePath];
    for (NSString* filePath in configurationFileList) {
        NSString* destinationPath = [workspacePath stringByAppendingPathComponent:filePath.lastPathComponent];
        NSError* error;
        [[NSFileManager defaultManager] copyItemAtPath:filePath toPath:destinationPath error:&error];
        if (error) {
            NSLog(@"Move file error!%@",error);
        }
    }
    return YES;
}

- (BOOL)insertPlistFileInPath:(NSString*)workspcaePath {
    NSError* error;
    NSString* projectName = [[FileUtils sharedInstance] projectNameFromPath:workspcaePath];
    if (!projectName) {
        NSLog(@"Cannot found project in path %@",workspcaePath);
        return NO;
    }
    NSString* configurationFilePath = self.configurationPlistSelected?self.configurationPlistSelected:self.lastDownloaedConfigurationFilePath;
    
    NSString* pbxcprojPath = [workspcaePath stringByAppendingFormat:@"/%@.xcodeproj/project.pbxproj",projectName];
    [self moveConfigurationPlistFileIntoSourceRootWithCongfigurationFilePath:configurationFilePath workspacePath:workspcaePath];
    [self insertPlistConfigurationFileIn:pbxcprojPath configurationFilePath:configurationFilePath];
//    [self showAlertWithTitle:@"配置成功" content:@"请打开项目配置文件"];

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
//    if (plistFiles.count == 0) {
        currentPath = [currentPath stringByAppendingPathComponent:projectName];
        contents =  [[NSFileManager defaultManager] contentsOfDirectoryAtPath:currentPath error:nil];
        plistFiles =[[FileUtils sharedInstance] findPlistFile:contents];
//    }
    
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
        [self showAlertWithTitle:@"配置失败" content:[NSString stringWithFormat:@"%@下面没找到Info.plist文件",currentPath]];
        NSLog(@"Info.plist not found in %@",workspcaePath);
    }
    if (!qqPlist) {
        NSLog(@"Cannot found plist file that contains AppID of QQ in %@",workspcaePath);
    }
    if (!wechatPlist) {
        NSLog(@"Cannot found plist file that contains AppID of Wechat in %@",workspcaePath);
    }
    
//    if (!(infoPlist&&qqPlist&&wechatPlist)) {
//        return NO;
//    }
    
    NSString* QQAppID = [qqPlist valueForKeyPath:@"services.social.qq.appId"];
    NSString* wechatAPPID = [wechatPlist valueForKeyPath:@"services.social.wechat.appId"];
//    NSDictionary* resultInfoPlist = [[FileUtils sharedInstance] insertQQSchemeIntoPlist:infoPlist :qqPlist];
    NSDictionary* resultInfoPlist = [[FileUtils sharedInstance] insertURLSChemeWithValue:[@"qqwallet" stringByAppendingString:QQAppID] intoInfoPlist:infoPlist];
    resultInfoPlist = [[FileUtils sharedInstance] insertURLSChemeWithValue:wechatAPPID intoInfoPlist:resultInfoPlist];
    resultInfoPlist = [[FileUtils sharedInstance] insertURLSChemeWithValue:[@"tencent" stringByAppendingString:QQAppID] intoInfoPlist:resultInfoPlist];
    
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
    [[FileUtils sharedInstance] writePlist:mutableDictionary intoPath:pbxcprojPath];

    
    NSString* buildAfterShell;
    if (directoryTest.count == 0) {
        //means intergrate via cocoapods
        buildAfterShell=@"if [ -f \"${PODS_ROOT}/TACCore/Scripts/tac.run.all.after.sh\"]; then \n${PODS_ROOT}/TACCore/Scripts/tac.run.all.after.sh\nfi";
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
    self.webviewController = [[WebViewController alloc] init];
    [self presentViewControllerAsModalWindow:self.webviewController];
    
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
