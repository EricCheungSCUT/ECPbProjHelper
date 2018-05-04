//
//  WebViewController.m
//  TACIntergrationTool
//
//  Created by erichmzhang(张恒铭) on 02/05/2018.
//  Copyright © 2018 erichmzhang(张恒铭). All rights reserved.
//

#import "WebViewController.h"
@import WebKit;
@interface WebViewController ()<WKNavigationDelegate,WKScriptMessageHandler>
@property(nonatomic,strong) WKWebView* webview;
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setFrame:NSMakeRect(0, 0, 1000, 1000)];
    [self.view addSubview:self.webview];

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
    NSURLRequest* reuquest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://console.cloud.tencent.com"]];
    [self.webview loadRequest:reuquest];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"NavigationResponse:%@\n",navigationResponse);
    NSHTTPURLResponse* response = navigationResponse.response;
    NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:[NSURL URLWithString:@""]];
    for (NSHTTPCookie *cookie in cookies) {
        NSLog(@"Cookie is %@",cookie);
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
   [[WKWebsiteDataStore defaultDataStore].httpCookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull result) {
       for (NSHTTPCookie* cookie in result) {
       NSLog(@"总的 Cookie:%@",cookie);
       }
       
   }];
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
