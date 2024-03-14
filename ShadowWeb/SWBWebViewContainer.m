//
//  SWBWebViewContainer.m
//  AquaWeb
//
//  Created by clowwindy on 11-6-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SWBWebViewContainer.h"
#import "SWBAppDelegate.h"
//#import "WebView.h"
//#import "UIWebDocumentView.h"

@implementation SWBWebViewContainer

@synthesize delegate;

-(void)loadDefaults {
    cachedWebViews = [[NSMutableArray alloc] init];
    s = [[NSString alloc] initWithFormat:@"_setDraw%@:", [@"InWebThread" copy]];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self loadDefaults];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self loadDefaults];
    }
    return self;
}

- (void)setNetworkIndicatorStatus {
    BOOL loading = NO;
    for (SWBWebView *webView in cachedWebViews) {
        loading |= webView.loading;
    }
    [appNetworkActivityIndicatorManager setSourceActivityStatusIsBusy:self busy:loading];
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:loading];
}

- (void)moveWebViewToCacheQueueEnd:(SWBWebView *)webView {
    // TODO
    if ([cachedWebViews containsObject:webView]) {
        [cachedWebViews removeObject:webView];
    }
    [cachedWebViews addObject:webView];
}

//- (void)progressEstimateChanged:(NSNotification*)theNotification {
//    // You can get the progress as a float with
//    // [[theNotification object] estimatedProgress], and then you
//    // can set that to a UIProgressView if you'd like.
//    // theProgressView is just an example of what you could do.
//    
////    [theProgressView setProgress:[[theNotification object] estimatedProgress]];
//    
//    NSLog(@"%@",[[theNotification object] estimatedProgress]);
//    
//    if ((int)[[theNotification object] estimatedProgress] == 1) {
////        theProgressView.hidden = TRUE;
//        // Hide the progress view. This is optional, but depending on where
//        // you put it, this may be a good idea.
//        // If you wanted to do this, you'd
//        // have to set theProgressView to visible in your
//        // webViewDidStartLoad delegate method,
//        // see Apple's UIWebView documentation.
//    }
//}

- (void)initAWebView:(SWBWebView *)webView {
    webView.backgroundColor = [UIColor whiteColor];
//    cause crash on double-tap
    
    @try {
        SEL ss = NSSelectorFromString(s);
        
        if ([webView respondsToSelector:ss]) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[WKWebView instanceMethodSignatureForSelector:ss]];
            BOOL setting = YES;
            [invocation setSelector:ss];
            [invocation setTarget:webView];
            [invocation setArgument:&setting atIndex:2];
            [invocation invoke];
//            [webView performSelector:ss withObject:YES];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
        
    }
    
    webView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight 
    | UIViewAutoresizingFlexibleWidth;
    webView.multipleTouchEnabled = YES;
    //webView.scalesPageToFit = YES;
    webView.navigationDelegate = self;
    
    //替换scalesPageToFit
    //以下代码适配文本大小，由UIWebView换为WKWebView后，会发现字体小了很多，这应该是WKWebView与html的兼容问题，解决办法是修改原网页，要么我们手动注入JS
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta); var imgs = document.getElementsByTagName('img');for (var i in imgs){imgs[i].style.maxWidth='100%';imgs[i].style.height='auto';}";
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [webView.configuration.userContentController addUserScript:wkUScript];
    
//    UIWebDocumentView *documentView = [webView _documentView];
//    WebView *coreWebView = [documentView webView];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressEstimateChanged:) name:@"WebViewProgressEstimateChangedNotification" object:coreWebView];
//    [coreWebView estimatedProgress
    
}
- (void)removeAWebView:(SWBWebView *)webView {
    webView.navigationDelegate = nil;
//    // fix memory leaks
//    [webView loadHTMLString:@"" baseURL:nil];
    [cachedWebViews removeObject:webView];
    if (webView.superview) {
        [webView removeFromSuperview];
    }
}

- (SWBWebView *)getANewWebView {
    NSInteger count = [cachedWebViews count];
    if (count >= kMaxCachedWebViews) {
        [self removeAWebView:[cachedWebViews objectAtIndex:0]];
    }
    SWBWebView *webView = [[SWBWebView alloc] init];
    [self initAWebView:webView];
    [cachedWebViews addObject:webView];
    
    return webView;
}

- (void)switchToWebViewWithWebView:(SWBWebView *)webView {
    [self moveWebViewToCacheQueueEnd:webView];
//    if (currentWebView) {
//        [currentWebView removeFromSuperview];
//    }
    if (currentWebView && currentWebView != webView) {
        // 让后台的网页不改变大小，以加快旋转和显示小工具的速度
        currentWebView.autoresizingMask = UIViewAutoresizingNone;
//        currentWebView.hidden = YES;
        @try {
            ((UIScrollView *)[[currentWebView subviews] objectAtIndex:0]).scrollsToTop = NO;
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }
    if (webView.superview) {
        [self bringSubviewToFront:webView];
    } else {
//        webView.frame = CGRectZero;
        [self addSubview:webView];        
    }
//    webView.hidden = NO;
    @try {
        ((UIScrollView *)[[webView subviews] objectAtIndex:0]).scrollsToTop = YES;
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    currentWebView = webView;
    // 设置前台
    webView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    webView.autoresizingMask = UIViewAutoresizingFlexibleHeight 
    | UIViewAutoresizingFlexibleWidth;
}

- (void)newWebView:(NSInteger)tag {
    SWBWebView *webView = [self getANewWebView];
    webView.tag = tag;
    [self switchToWebViewWithWebView:webView];
    
    [delegate webViewContainerWebViewDidCreateNew:webView];
}

- (void)switchToWebView:(NSInteger)tag {
    SWBWebView *webView = [self webViewByTag:tag];
    if (currentWebView && currentWebView == webView) {
        // do not compare tags, because currentWebView may be released
        return;
    }
    [self switchToWebViewWithWebView:webView];
    
    [delegate webViewContainerWebViewDidSwitchToWebView:webView];
}

- (void)closeWebView:(NSInteger)tag {
    if (tag == currentWebView.tag) {
        currentWebView = nil;
    }
    [self removeAWebView:[self webViewByTag:tag]];
}

- (SWBWebView *)webViewByTag:(NSInteger)tag {
    for (SWBWebView *webView in cachedWebViews) {
        if (webView.tag == tag) {
            return webView;
        }
    }
    SWBWebView *webView = [self getANewWebView];
    webView.tag = tag;
    
    [delegate webViewContainerWebViewNeedToReload:webView tag:tag];
    
    return webView;
}

- (NSInteger)currentWebView {
    return currentWebView.tag;
}

- (SWBWebView *)currentSWBWebView {
    return currentWebView;
}

- (void)releaseBackgroundWebViews {
    NSInteger count = [cachedWebViews count];
    for (int i = 0; i < count - kMinCachedWebViews; i ++) {
        [(WKWebView *)[cachedWebViews objectAtIndex:0] removeFromSuperview];
        [cachedWebViews removeObjectAtIndex:0];
    }
}

- (void)removeBackgroundWebViewsFromSuperView {
    NSInteger count = [cachedWebViews count];
    for (int i = 0; i < count - kMinCachedWebViews; i ++) {
        [(WKWebView *)[cachedWebViews objectAtIndex:i] removeFromSuperview];
    }
}

// 数据加载发生错误时调用
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [delegate webView:webView didFailNavigation:navigation withError:error];
    [self setNetworkIndicatorStatus];
}

//页面加载失败时调用
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [delegate webView:webView didFailProvisionalNavigation:navigation withError:error];
    [self setNetworkIndicatorStatus];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (delegate) {
        [delegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [delegate webView:webView didFinishNavigation:navigation];
    [self setNetworkIndicatorStatus];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [delegate webView:webView didStartProvisionalNavigation:navigation];
    [self setNetworkIndicatorStatus];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
