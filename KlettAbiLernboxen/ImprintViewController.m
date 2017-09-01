//
//  ImprintViewController.m
//  KlettAbiLernboxen
//
//  Created by Wang on 06.12.12.
//
//

#import "ImprintViewController.h"
#import "AGBsViewController.h"


@implementation ImprintViewController

@synthesize recommendButton;
@synthesize imprintWebView;
@synthesize imageCreditsWebView;
@synthesize scrollView;
@synthesize contentView;


- (id) init {
    
    if (self = [super initWithNibName:@"ImprintViewController" bundle:[NSBundle mainBundle]]) {
        
        [self.navigationItem setTitle:@"Impressum"];
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
    
    
    self.contentView.backgroundColor = [UIColor colorWithPatternImage:resource(@"Images.TableViews.BackgroundPattern")];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:resource(@"Images.TableViews.BackgroundPattern")];

    
    imprintWebView.scrollView.bounces = FALSE;
    imageCreditsWebView.scrollView.bounces = FALSE;
    
    
    UIFont* descFont = resource(@"Fonts.Imprint.Font.Font");
    
    NSString* imprintFileName = resource(@"Dictionaries.Imprint.Imprint");
    NSString* imprintFilePath = [[NSBundle mainBundle] pathForResource:imprintFileName ofType:nil];
    NSString* imprintString = [NSString stringWithContentsOfFile:imprintFilePath encoding:NSUTF8StringEncoding error:nil];
    imprintString = [imprintString stringByReplacingOccurrencesOfString:@"FONT_NAME" withString:descFont.fontName];
    imprintString = [imprintString stringByReplacingOccurrencesOfString:@"FONT_SIZE" withString:[NSString stringWithFormat:@"%f", descFont.pointSize]];
    [imprintWebView loadHTMLString:imprintString baseURL:nil];
    
    NSString* creditsFileName = resource(@"Dictionaries.Imprint.ImageCredits");
    NSString* creditsFilePath = [[NSBundle mainBundle] pathForResource:creditsFileName ofType:nil];
    NSString* creditsString = [NSString stringWithContentsOfFile:creditsFilePath encoding:NSUTF8StringEncoding error:nil];
    creditsString = [creditsString stringByReplacingOccurrencesOfString:@"FONT_NAME" withString:descFont.fontName];
    creditsString = [creditsString stringByReplacingOccurrencesOfString:@"FONT_SIZE" withString:[NSString stringWithFormat:@"%f", descFont.pointSize]];
    [imageCreditsWebView loadHTMLString:creditsString baseURL:nil];
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
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



- (void) layout {
    
    float posY = imprintWebView.frame.origin.y;
    
    // imprint
    [imprintWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.querySelector('meta[name=viewport]').setAttribute('content', 'width=%d;', false); ",
                                                      (int)imprintWebView.frame.size.width]];
    [imprintWebView setFrameHeight:1];
    CGSize size = [imprintWebView sizeThatFits: CGSizeMake(imprintWebView.frame.size.width, 1000)];
    [imprintWebView setFrameHeight:size.height];
    [imprintWebView setFrameY: posY];
    
    posY += imprintWebView.bounds.size.height + 20;
    
    // seperator
    if (!_seperator) {

        UIImage* seperatorImage = [resource(@"Images.Misc.SeperatorPattern") resizableImageWithCapInsets:UIEdgeInsetsZero];
        _seperator = [[UIImageView alloc] initWithImage:seperatorImage];
        _seperator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_seperator setFrameWidth:self.view.bounds.size.width - 40];
    }
    
    [_seperator setFrameX:20];
    [_seperator setFrameY:posY];
    [_seperator setFrameWidth:imprintWebView.frame.size.width];
    [self.contentView addSubview:_seperator];
    
    posY += _seperator.bounds.size.height + 20;
    
    // credits
    [imageCreditsWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.querySelector('meta[name=viewport]').setAttribute('content', 'width=%d;', false); ",
                                                            (int)imageCreditsWebView.frame.size.width]];
    [imageCreditsWebView setFrameHeight:1];
    size = [imageCreditsWebView sizeThatFits: CGSizeMake(imageCreditsWebView.frame.size.width, 1000)];
    [imageCreditsWebView setFrameHeight:size.height];
    [imageCreditsWebView setFrameY: posY];
    
    posY += imageCreditsWebView.bounds.size.height + 20;
    
    [self.contentView setFrameHeight:posY];
    [self.scrollView setContentSize:self.contentView.bounds.size];
}


#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {

    if (theWebView == imprintWebView) {
        
        _imprintLoaded = TRUE;
    }
    else if (theWebView == imageCreditsWebView) {
        
        _creditsLoaded = TRUE;
    }
    
    if (_imprintLoaded && _creditsLoaded) {
        
        // layout
        
        [self layout];
    }

}


- (IBAction) recommend {

	MFMailComposeViewController* mailController = [[MFMailComposeViewController alloc] init];
    
    if (mailController == nil) {
        
        UIAlertView* alertView = [[UIAlertView alloc]
                                   initWithTitle:resource(@"Dictionaries.Imprint.Recommend.AlertTitle")
                                   message:resource(@"Dictionaries.Imprint.Recommend.CheckEmailSettings")
                                   delegate:nil
                                   cancelButtonTitle:@"Ok"
                                   otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    
	mailController.mailComposeDelegate = self;
	
    NSString* bodyFileName = resource(@"Dictionaries.Imprint.Recommend.BodyFile");
    NSString* bodyPath = [[NSBundle mainBundle] pathForResource:bodyFileName ofType:nil];
    NSString* bodyString = [NSString stringWithContentsOfFile:bodyPath encoding:NSUTF8StringEncoding error:nil];
    
    NSString* subjectString = resource(@"Dictionaries.Imprint.Recommend.Subject");
    
    [mailController setSubject:subjectString];
    [mailController setMessageBody:bodyString isHTML:false];
    [self presentModalViewController:mailController animated:true];
    
 
}


- (IBAction) actionAGBs {
    
    AGBsViewController* controller = [[AGBsViewController alloc] init];
    [self.navigationController pushViewController:controller animated:true];
}


- (void) mailComposeController:(MFMailComposeViewController *) oController
           didFinishWithResult:(MFMailComposeResult) nResult
                         error:(NSError *) oError {

    NSString* message = nil;
    
	switch (nResult) {

		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
            message = resource(@"Dictionaries.Imprint.Recommend.ThanksForRecommending");
			break;
		case MFMailComposeResultFailed:
            message = resource(@"Dictionaries.Imprint.Recommend.ErrorEmailSettings");
            break;
		default:
			break;
	}
    
    if (message) {
        UIAlertView* alertView = [[UIAlertView alloc]
                                   initWithTitle:resource(@"Dictionaries.Imprint.Recommend.AlertTitle")
                                   message:message
                                   delegate:nil
                                   cancelButtonTitle:@"Ok"
                                   otherButtonTitles:nil];
        [alertView show];
    }
    
	[self dismissModalViewControllerAnimated:true];
}


@end
