//
//  BLCViewController.m
//  BlocBrowser
//
//  Created by Paul Lozada on 2015-03-16.
//  Copyright (c) 2015 Bloc. All rights reserved.
//

#import "BLCViewController.h"
#import "BLCAwesomeFloatingToolbar.h"

#define kBLCWebBrowserBackString NSLocalizedString(@"Back", @"Back command")
#define kBLCWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward command")
#define kBLCWebBrowserStopString NSLocalizedString(@"Stop", @"Stop command")
#define kBLCWebBrowserRefreshString NSLocalizedString(@"Refresh",@"Reload command")

@interface BLCViewController () <UIWebViewDelegate,UITextFieldDelegate,BLCAwesomeFloatingToobarDelegate>




@property (nonatomic,strong) UIWebView                  *webview;
@property (nonatomic,strong) UITextField                *textField;
@property (nonatomic,strong) UIActivityIndicatorView    *activityIndicator;
@property (nonatomic,strong) BLCAwesomeFloatingToolbar  *awesomeToolBar;

@property (nonatomic,assign) NSUInteger frameCount;

@end

@implementation BLCViewController

-(void)resetWebView{
    
    [self.webview removeFromSuperview];
    
    UIWebView *newWebView = [[UIWebView alloc]init];
    newWebView.delegate = self;
    [self.view addSubview:newWebView];
    
    self.webview = newWebView;
    
    
    self.textField.text = nil;
    [self updateButtonAndTitle];
    
}


#pragma mark - UIViewController

-(void)loadView{
    
    UIView *mainView                            = [[UIView alloc]init];
    self.view                                   = mainView;
    
    self.webview                                = [[UIWebView alloc]init];
    self.webview.delegate                       = self;
    
    self.textField                              = [[UITextField alloc]init];
    self.textField.keyboardType                 = UIKeyboardTypeURL;
    self.textField.returnKeyType                = UIReturnKeyDone;
    self.textField.autocapitalizationType       = UITextAutocapitalizationTypeNone;
    self.textField.autocorrectionType           = UITextAutocorrectionTypeNo;
    self.textField.placeholder                  = NSLocalizedString(@"Enter Search or Website URL", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor              = [UIColor colorWithWhite: 220/255.0f alpha:1];
    self.textField.delegate = self;
    
    
    
    self.awesomeToolBar = [[BLCAwesomeFloatingToolbar alloc]initWithFourTitles:@[kBLCWebBrowserBackString,kBLCWebBrowserForwardString,kBLCWebBrowserStopString,kBLCWebBrowserRefreshString]];
    self.awesomeToolBar.delegate = self;
   
    
    
//    [mainView addSubview:self.textField];
//    [mainView addSubview:self.webview];
//    [mainView addSubview:self.backButton];
//    [mainView addSubview:self.forwardButton];
//    [mainView addSubview:self.stopButton];
//    [mainView addSubview:self.reloadButton];
//    
    for (UIView *viewToAdd in @[self.webview,self.textField,self.awesomeToolBar]) {
        [mainView addSubview:viewToAdd];
    }
   
    
    
}

-(void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    
    
    // First calculate the dimensions
    
    static const CGFloat itemHeight     = 50;
    CGFloat width                       = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight               = CGRectGetHeight(self.view.bounds) - itemHeight;
    
    
    //Now, assign the frames
    
    self.textField.frame        = CGRectMake(0, 0, width, itemHeight);
    self.webview.frame          = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    self.awesomeToolBar.frame = CGRectMake(20, 100, 280, 60);
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    NSString *URLString     = textField.text;
    
    NSURL *URL              = [NSURL URLWithString:URLString];
    
    if (!URL.scheme) {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@",URLString]];
    }
    
    if (URL) {
        NSURLRequest * request      = [NSURLRequest requestWithURL:URL];
        [self.webview loadRequest:request];
        
    } else {
        
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/search?q=%@",[URLString stringByReplacingOccurrencesOfString:@" " withString:@"+"]]];
        NSLog(@"%@",URL);
    
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webview loadRequest:request];
    }
    return NO;
}







#pragma mark - UIWebViewDelegate

-(void)webViewDidStartLoad:(UIWebView *)webView{
    self.frameCount++;;
    [self updateButtonAndTitle];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    self.frameCount--;
    [self updateButtonAndTitle];
}


-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{

    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Error", @"Error") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
    [alert show];
    [self updateButtonAndTitle];
    self.frameCount--;
    
}

#pragma mark - Miscellaneous

-(void)updateButtonAndTitle{
    
    NSString *webpageTitle = [self.webview stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    if (webpageTitle) {
        self.title = webpageTitle;
    } else {
        self.title = self.webview.request.URL.absoluteString;
    }
    
    [self.awesomeToolBar setEnabled:[self.webview canGoBack] forButtonWithTitle:kBLCWebBrowserBackString];
    [self.awesomeToolBar setEnabled:[self.webview canGoForward] forButtonWithTitle:kBLCWebBrowserForwardString];
    [self.awesomeToolBar setEnabled:self.frameCount > 0 forButtonWithTitle:kBLCWebBrowserStopString];
    [self.awesomeToolBar setEnabled:self.webview.request.URL && self.frameCount == 0 forButtonWithTitle:kBLCWebBrowserRefreshString];
    
    
    if (self.frameCount > 0) {
        [self.activityIndicator startAnimating];
    } else{
        [self.activityIndicator stopAnimating];
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.activityIndicator];
    // Do any additional setup after loading the view.
}

#pragma mark - BLCAwesomeFloatingToolbarDelegate

-(void)floatingToolbar:(BLCAwesomeFloatingToolbar *)toolbar didSelectButtonWithTitle:(NSString *)title{
    
    if ([title isEqual:kBLCWebBrowserBackString]) {
        [self.webview goBack];
    } else if ([title isEqualToString:kBLCWebBrowserForwardString]){
        [self.webview goForward];
    } else if ([title isEqual:kBLCWebBrowserStopString]){
        [self.webview stopLoading];
    } else if ([title isEqual:kBLCWebBrowserRefreshString]){
        [self.webview reload];
    }
}
@end
