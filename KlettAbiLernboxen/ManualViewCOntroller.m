//
//  ManualViewCOntroller.m
//  KlettAbiLernboxen
//
//  Created by Wang on 06.12.12.
//
//

#import "ManualViewCOntroller.h"


#define MarginBottom 20



@implementation ManualViewCOntroller

@synthesize scrollView;
@synthesize contentView;


- (id) init {
    
    if (self = [super init]) {
        
//        _customNavigationItem = [[CustomNavigationItem alloc] init];
//        _customNavigationItem.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0];
//        _customNavigationItem.textColor = [UIColor whiteColor];
//        _customNavigationItem.title = @"";
        
        [self.navigationItem setTitle:@"Anleitung"];

    }
    
    return self;
}


//- (UINavigationItem*) navigationItem {
//    
//    return _customNavigationItem;
//}


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
    
    
    // view
    [self.view setFrame:CGRectMake(0, 0, 320, 480)];
    self.view.autoresizesSubviews = TRUE;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.backgroundColor = [UIColor colorWithPatternImage:resource(@"Images.TableViews.BackgroundPattern")];
    
    // scrollview
    
//    float posY = ti_int(20);
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    scrollView.bounces = FALSE;
    scrollView.autoresizesSubviews = TRUE;

    // contentview
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth; // | UIViewAutoresizingFlexibleHeight;
    contentView.autoresizesSubviews = TRUE;
    
    [scrollView addSubview:contentView];
    [self.view addSubview:scrollView];
    
    
    // dropDownViewController
    CGRect dropDownViewRect = CGRectMake(0, 0, 320, 30);
    
    NSArray* array = resource(@"Arrays.Manual");
    
    _dropDownController = [[DropDownViewController alloc] initWithArray:array];
    _dropDownController.font = resource(@"Fonts.Shop.MenuItem.Font");
    _dropDownController.font2 = resource(@"Fonts.Shop.MenuText.Font");
    _dropDownController.delegate = self;
    [_dropDownController.view setFrame:dropDownViewRect];
    
    [contentView addSubview:_dropDownController.view];
    
    [_dropDownController viewDidAppear:FALSE];
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
    
    [_dropDownController layout];
}


#pragma mark DropDownViewControllerDelegate

- (void) dropDownViewController:(DropDownViewController *)controller didChangeHeight:(float)height {
    
    NSLog(@"dropDownViewController:didChangeHeight: height=%f", height);
    
    float newHeight = controller.view.frame.origin.y + height + MarginBottom;
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        
        [contentView setFrameHeight:newHeight];
        
        [scrollView setContentSize:CGSizeMake(scrollView.contentSize.width, newHeight)];
    }
                     completion:^(BOOL finished) {
                         
                     }
     ];
}


- (void) dropDownViewController:(DropDownViewController *)controller didSelectView:(UIView *)view {
    
    CGRect relativeRect = [view.superview convertRect:view.frame toView:self.contentView];
    
    [self.scrollView scrollRectToVisible:relativeRect animated:TRUE];
}


- (void) dealloc {
    
    
    
    NSLog(@"ManualViewController DEALLOC");
}


@end
