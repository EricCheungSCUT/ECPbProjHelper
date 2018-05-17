//
//  WebViewController.m
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 02/05/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import "WebViewController.h"
#import "TencentCloudConfigDownloader.h"
@import WebKit;


@interface WKNavigationResponse(TencentCloud)
- (BOOL)isDownloadConfigurationResponse ;
@end

@implementation WKNavigationResponse(TencentCloud)

- (BOOL)isDownloadConfigurationResponse {
    if ([self.response.URL.lastPathComponent isEqualToString:@"download_config"]) {
        return YES;
    }
    return NO;
}

@end


@interface WKNavigationAction(TencentCloud)
- (BOOL)isDownloadConfigurationAction ;
@end

@implementation WKNavigationAction(TencentCloud)

- (BOOL)isDownloadConfigurationAction {
    if ([self.request.URL.lastPathComponent isEqualToString:@"download_config"]) {
        return YES;
    }
    return NO;
}

@end

@interface WebViewController ()<WKNavigationDelegate,WKScriptMessageHandler>
@property(nonatomic,strong) WKWebView* webview;
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setFrame:NSMakeRect(0, 0, 2000, 1000)];
    [self.view addSubview:self.webview];
    
}

- (void)viewDidDisappear {
    [super viewDidDisappear  ];
    
}

- (void) addUserScriptToUserContentController:(WKUserContentController *) userContentController{
    NSString *jsHandler = [NSString stringWithContentsOfURL:[[NSBundle mainBundle]URLForResource:@"ajaxHandler" withExtension:@"js"] encoding:NSUTF8StringEncoding error:NULL];
    WKUserScript *ajaxHandler = [[WKUserScript alloc]initWithSource:jsHandler injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    [userContentController addScriptMessageHandler:self name:@"callbackHandler"];
    [userContentController addUserScript:ajaxHandler];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"blabla");
}


- (void)viewDidAppear {
    [super viewDidAppear];
    NSURLRequest* reuquest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://console.cloud.tencent.com/tac"]];
    [self.webview loadRequest:reuquest];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"NavigationResponse:%@\n",navigationResponse);

    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"NavigationAction is %@",navigationAction);
    if ([navigationAction isDownloadConfigurationAction ] ) {
        __block NSProgressIndicator* indicator = [[NSProgressIndicator alloc] initWithFrame:self.view.bounds] ;
        [indicator setStyle:NSProgressIndicatorSpinningStyle];
        [self.view addSubview:indicator];
        [indicator startAnimation:indicator];
        [self.webview setAlphaValue:0.2f];
        [TencentCloudConfigDownloader  downloadConfigurationWithURL:navigationAction.request.URL completionHandler:^(NSString *configurationZIPFilePath) {
            // do nothing here
            dispatch_async(dispatch_get_main_queue(), ^{
                [indicator removeFromSuperview];
            });
        }];
    }
        decisionHandler(WKNavigationActionPolicyAllow);
}


- (WKWebView *)webview {
    if (!_webview) {
        WKWebViewConfiguration* configuration = [[WKWebViewConfiguration alloc] init];
        _webview = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
        _webview.navigationDelegate = self;
        _webview.UIDelegate = self;
        [self addUserScriptToUserContentController:configuration.userContentController];
    }
    return _webview;
}

@end
