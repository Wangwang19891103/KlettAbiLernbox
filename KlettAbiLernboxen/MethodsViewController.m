//
//  MethodsViewController.m
//  KlettAbiLernboxen
//
//  Created by Wang on 07.12.12.
//
//

#import "MethodsViewController.h"

@implementation MethodsViewController

- (id) init {
    
    if (self = [super init]) {
        
        [self.navigationItem setTitle:@"Die zwei Lernmethoden"];

    }
    
    return self;
}

- (void) viewDidLoad {
    
    [super viewDidLoad];

    
    // navigation bar image
    UIImage* bgImage = [[ResourceManager instance] resourceForKeyPath:@"Images.NavigationBar.Background"];
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
    
    NSString* fileName = resource(@"Dictionaries.TwoMethods.File");
    NSString* filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSString* string = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    string = [string stringByReplacingOccurrencesOfString:@"FONT_NAME" withString:descFont.fontName];
    string = [string stringByReplacingOccurrencesOfString:@"FONT_SIZE" withString:[NSString stringWithFormat:@"%f", descFont.pointSize]];
    string = [self parseHTMLString:string];
    
    NSString* basePath = [[NSBundle mainBundle] bundlePath];
    NSURL* baseURL = [NSURL fileURLWithPath:basePath];
    
    [_webView loadHTMLString:string baseURL:baseURL];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.tabBarController.tabBar setHidden:YES];
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


- (NSString*) parseHTMLString:(NSString*) htmlString {
    
    char currentChar, previousChar;
    uint startingIndex;
    NSString* returnString = [htmlString copy];
    
    for (uint i = 0; i < returnString.length; ++i) {
        
        currentChar = [returnString characterAtIndex:i];
        
        //        NSLog(@"currentChar: %c (pos: %d)", currentChar, i);
        
        if (currentChar == '<' && previousChar == '<') {
            
            startingIndex = i + 1;
        }
        else if (currentChar == '>' && previousChar == '>') {
            
            uint closingIndex = i - 2;
            
            NSRange tokenRange = NSMakeRange(startingIndex, closingIndex - startingIndex + 1);
            NSRange outerRange = NSMakeRange(startingIndex - 2, closingIndex - startingIndex + 5);
            NSString* token = [returnString substringWithRange:tokenRange];
            
            //            NSLog(@"token: %@", token);
            
            NSArray* tokenComps = [token componentsSeparatedByString:@":"];
            NSString* type = [tokenComps objectAtIndex:0];
            NSString* arg = [tokenComps objectAtIndex:1];
            NSString* replacementString = nil;
            
            if ([type isEqualToString:@"int"]) {
                
                int value = [arg intValue];
                int newValue = [self handleInt:value];
                replacementString = [NSString stringWithFormat:@"%d", newValue];
            }
            else if ([type isEqualToString:@"image"]) {
                
                replacementString = [self handleImage:arg];
            }
            
            returnString = [returnString stringByReplacingCharactersInRange:outerRange withString:replacementString];
            
            uint diffLen = outerRange.length + 4 - replacementString.length;
            
            i -= diffLen;
            
            //            NSLog(@"i=%d, len=%d", i, returnString.length);
        }
        
        
        
        previousChar = currentChar;
    }
    
    return returnString;
}


- (int) handleInt:(int) value {
    
    return (is_ipad) ? value * 1.5 : value;
}


- (NSString*) handleImage:(NSString*) imageName {
    
    NSArray* comps = [imageName componentsSeparatedByString:@"."];
    BOOL isRetina = [UIScreen mainScreen].scale == 2.0;
    
    return [NSString stringWithFormat:@"%@%@.%@", [comps objectAtIndex:0], (isRetina) ? @"@2x" : @"", [comps objectAtIndex:1]];
}


@end
