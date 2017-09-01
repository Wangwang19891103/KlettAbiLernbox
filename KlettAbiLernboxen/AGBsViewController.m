//
//  AGbsViewController.m
//  KlettAbiLernboxen
//
//  Created by Wang on 17.06.13
//
//

#import "AGBsViewController.h"

@implementation AGBsViewController

- (id) init {
    
    if (self = [super init]) {
        
        [self.navigationItem setTitle:@"AGB"];
        
    }
    
    return self;
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    
#ifdef SCHULWISSEN
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                   [UIColor blackColor],
                                                                   UITextAttributeTextColor,
                                                                   nil];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
#else
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
#endif
    
    
    // navigation bar image
#ifdef SCHULWISSEN
    UIImage* bgImage = [UIImage imageNamed:@"navigation_bar_background_start"];
#else
    UIImage* bgImage = [[ResourceManager instance] resourceForKeyPath:@"Images.NavigationBar.Background"];
#endif    
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 2, 1)];
    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    
//    bgImage = [[ResourceManager instance] resourceForKeyPath:@"Images.NavigationBar.BackgroundLandscape"];
//    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 2, 1)];
//    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsLandscapePhone];
    
    
    self.view.frame = CGRectMake(0, 0, 320, 480);
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    //    _scrollView.bounces = FALSE;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.autoresizesSubviews = TRUE;
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    _contentView.backgroundColor = [UIColor colorWithPatternImage:resource(@"Images.TableViews.BackgroundPattern")];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:resource(@"Images.TableViews.BackgroundPattern")];
    
    [_scrollView addSubview:_contentView];
    [self.view addSubview:_scrollView];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(20, 20, 280, 1)];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _webView.scrollView.bounces = FALSE;
    _webView.delegate = self;
    _webView.opaque = FALSE;
    _webView.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:_webView];
    
    
    UIFont* descFont = resource(@"Fonts.Imprint.Font.Font");
    
    NSString* fileName = resource(@"Dictionaries.Imprint.AGBs");
    NSString* filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSString* string = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    string = [string stringByReplacingOccurrencesOfString:@"FONT_NAME" withString:descFont.fontName];
    string = [string stringByReplacingOccurrencesOfString:@"FONT_SIZE" withString:[NSString stringWithFormat:@"%f", descFont.pointSize]];
    [_webView loadHTMLString:string baseURL:nil];
    
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    return true;
}


- (BOOL) shouldAutorotate {
    
    return true;
}


- (NSUInteger) supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskAll;
}


- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    [self layout];
}


- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
    
    [self layout];
}


- (void) layout {
    
    if (_webView.loading) return;
    
    
    float posY = _webView.frame.origin.y;
    
    // ...
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.querySelector('meta[name=viewport]').setAttribute('content', 'width=%d;', false); ",
                                                      (int)_webView.frame.size.width]];
    
    [_webView setFrameHeight:1];
    CGSize size = [_webView sizeThatFits: CGSizeMake(_webView.frame.size.width, 1000)];
    [_webView setFrameHeight:size.height];
    [_webView setFrameY: posY];
    
    posY += _webView.bounds.size.height + 20;
    
    [_contentView setFrameHeight:MAX(posY, _scrollView.bounds.size.height)];
    [_scrollView setContentSize:_contentView.bounds.size];
}


@end
