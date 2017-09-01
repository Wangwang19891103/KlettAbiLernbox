//
//  CustomProductDetailViewController.m
//  KlettAbiLernboxen
//
//  Created by Wang on 14.09.12.
//
//

#import "CustomProductDetailViewController.h"
#import "DataManager.h"
#import "ContentsCategory.h"
#import "ContentsSubcategory.h"
#import "ContentsPage.h"
#import "TranslateIdiom.h"
#import "DownloadButtonImage.h"



#define MarginBottom 20




@implementation CustomProductDetailViewController

@synthesize scrollView;
@synthesize contentView;
@synthesize webView;
@synthesize dropDownView;
@synthesize iconImageView;
@synthesize titleLabel;
@synthesize priceLabel;
@synthesize button;
@synthesize product;
@synthesize moduleName;


- (id) initWithModule:(NSString *)theModuleName {
    
    if (self = [super initWithNibName:@"CustomProductDetailViewController" bundle:[NSBundle mainBundle]]) {
        
        moduleName = theModuleName;
        
        [self.navigationItem setTitle:@"Shop"];

    }
    
    return self;
}


- (void) viewDidLoad {
    
    [super viewDidLoad];

//    /* populate array */
//    NSMutableArray* array = [NSMutableArray array];
//    
//    NSArray* pages1 = [NSArray arrayWithObjects:@"Page 1", @"Page 2", @"Page 3", nil];
//    
//    NSArray* cat1 = [NSArray arrayWithObjects:@"Category1", pages1, nil];
//    
//    [array addObject:cat1];
    
    
    [[ModuleManager manager] addObserver:self forModule:moduleName];
    
    titleLabel.text = moduleName;
    priceLabel.text = product.price;
    
    [self refreshButton];
    
    // navigation bar image
    UIImage* bgImage = [[ResourceManager instance] resourceForKeyPath:@"Images.NavigationBar.Background"];
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 2, 1)];
    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    
//    bgImage = [[ResourceManager instance] resourceForKeyPath:@"Images.NavigationBar.BackgroundLandscape"];
//    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 2, 1)];
//    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsLandscapePhone];

//    UIImage* bgImage = [[ResourceManager instance] resourceForKeyPath:@"Images.NavigationBar.BackgroundLogo"];
//    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 80, 2, 1)];
//    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
//    
//    bgImage = [[ResourceManager instance] resourceForKeyPath:@"Images.NavigationBar.BackgroundLogoLandscape"];
//    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 80, 2, 1)];
//    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsLandscapePhone];
    
    
    
    
    NSString* moduleImageResourceName = [NSString stringWithFormat:@"Images.ModuleCells.Icons.%@", moduleName];
    UIImage* moduleImage = [[ResourceManager instance] resourceForKeyPath:moduleImageResourceName];
    
    UIColor* moduleColor = [[ModuleManager manager] colorForModule:moduleName];
    
    moduleImage = [moduleImage imageWithAdjustmentColor:moduleColor];
    
    iconImageView.image = moduleImage;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:resource(@"Images.TableViews.BackgroundPattern")];
    contentView.backgroundColor = [UIColor colorWithPatternImage:resource(@"Images.TableViews.BackgroundPattern")];
    
    
    NSMutableArray* array = [NSMutableArray array];
    
//    NSString* sqlPath = [[NSBundle mainBundle] pathForResource:@"contents/KlettAbiPhysik/contents.sqlite" ofType:nil];
    
    DataManager* dataManager = [[DataManager alloc] initWithModelName:@"contents" path:[CONTENT_DIRECTORY stringByAppendingPathComponent:@"contents.sqlite"]];
    
    NSArray* categories = [dataManager fetchDataForEntityName:@"ContentsCategory" withPredicate:[NSPredicate predicateWithFormat:@"module.name == %@", moduleName] sortedBy:@"position", nil];
    
//    alert(@"product title: %@", self.product.title);
    
    for (ContentsCategory* category in categories) {
        
        if (category.subcategories.count != 0) {
            
            NSArray* subcategories = [dataManager fetchDataForEntityName:@"ContentsSubcategory" withPredicate:[NSPredicate predicateWithFormat:@"category == %@", category] sortedBy:@"position", nil];
            
            NSMutableArray* subcats = [NSMutableArray array];
            
            for (ContentsSubcategory* subcategory in subcategories) {
                
                NSArray* pages = [dataManager fetchDataForEntityName:@"ContentsPage" withPredicate:[NSPredicate predicateWithFormat:@"category == %@ AND subcategory == %@", category, subcategory] sortedBy:@"position", nil];
                
                NSMutableArray* pageTitles = [NSMutableArray array];
                
                for (ContentsPage* page in pages) {
                    
                    [pageTitles addObject:page.name];
                }

                NSArray* subcatArray = [NSArray arrayWithObjects:subcategory.name, pageTitles, nil];
                
                [subcats addObject:subcatArray];
            }
            
            NSArray* catArray = [NSArray arrayWithObjects:category.name, subcats, nil];
            
            [array addObject:catArray];
        }
        else {

            NSArray* pages = [dataManager fetchDataForEntityName:@"ContentsPage" withPredicate:[NSPredicate predicateWithFormat:@"category == %@", category] sortedBy:@"position", nil];
            
            NSMutableArray* pageTitles = [NSMutableArray array];
            
            for (ContentsPage* page in pages) {
                
                [pageTitles addObject:page.name];
            }
            
            NSArray* catArray = [NSArray arrayWithObjects:category.name, pageTitles, nil];
            
            [array addObject:catArray];
        }
    }
    
    
    _dropDownController = [[DropDownViewController alloc] initWithArray:array];
    _dropDownController.font = resource(@"Fonts.Shop.MenuItem.Font");
    _dropDownController.font2 = resource(@"Fonts.Shop.MenuText.Font");
    _dropDownController.delegate = self;
    [_dropDownController.view setFrame:dropDownView.frame];
    
    [contentView addSubview:_dropDownController.view];
    [dropDownView removeFromSuperview];
    dropDownView = _dropDownController.view;
    
    [_dropDownController viewDidAppear:FALSE];
    
    UIFont* descFont = resource(@"Fonts.Shop.Description.Font");
    
//    NSString* htmlFileName = [(NSDictionary*)resource(@"Dictionaries.Shop") objectForKey:moduleName];
    NSString* htmlFileName = [[ModuleManager manager] shopDescriptionFileForModule:moduleName];
    NSString* descriptionPath = [[NSBundle mainBundle] pathForResource:htmlFileName ofType:nil];
    NSString* descriptionString = [NSString stringWithContentsOfFile:descriptionPath encoding:NSUTF8StringEncoding error:nil];
//    descriptionString = [descriptionString stringByReplacingOccurrencesOfString:@"MODULE_NAME" withString:self.product.title];
    descriptionString = [descriptionString stringByReplacingOccurrencesOfString:@"FONT_NAME" withString:descFont.fontName];
    descriptionString = [descriptionString stringByReplacingOccurrencesOfString:@"FONT_SIZE" withString:[NSString stringWithFormat:@"%f", descFont.pointSize]];
    timer_add(@"webview");
    webView.delegate = self;
    [webView loadHTMLString:descriptionString baseURL:nil];
}


- (void) viewDidDisappear:(BOOL)animated {
    
    [[ModuleManager manager] removeObserver:self forModule:moduleName];

    [super viewDidDisappear:animated];
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



- (void) viewDidLayoutSubviews {

    [self layout];
}


- (void) refreshButton {

//    UIImage* shopButtonImage = [DownloadButtonImage imageWithProgress:[progress floatValue] buttonName:@"Downloading"];
//    
//    [self.shopButton setImage:shopButtonImage forState:UIControlStateNormal];

    NSLog(@"refreshButton: product.status=%d", product.status);
    
    
    NSString* ButtonName = nil;
    BOOL buttonEnabled = FALSE;
    BOOL priceVisible = TRUE;
    
    switch (self.product.status) {
            
        case UAProductStatusUnpurchased:
            ButtonName = @"Purchase";
            buttonEnabled = TRUE;
            break;
            
        case UAProductStatusPurchasing:
        case UAProductStatusPurchased:
            ButtonName = @"Buying";
            break;
            
        case UAProductStatusVerifyingReceipt:
            ButtonName = @"Checking";
            break;
            
        case UAProductStatusDownloading:
            ButtonName = @"Downloading";
            break;
            
        case UAProductStatusDecompressing:
            ButtonName = @"Installing";
            break;
            
        case UAProductStatusInstalled:
            ButtonName = @"Restore";
            buttonEnabled = TRUE;
            priceVisible = FALSE;
            break;
            
        case UAProductStatusHasUpdate:
            ButtonName = @"Update";
            buttonEnabled = TRUE;
            priceVisible = FALSE;
            break;
            
        default:
            ButtonName = @"Purchase";
            buttonEnabled = TRUE;
            break;
    }
    
    UIImage* shopButtonImage = nil;
    
    NSLog(@"refreshButton: buttonName=%@", ButtonName);
    
    if ([ButtonName isEqualToString:@"Buying"]) {
        
        shopButtonImage = [DownloadButtonImage shopImageWithProgress:0.0f buttonName:ButtonName];
    }
    else if ([ButtonName isEqualToString:@"Checking"]) {
        
        shopButtonImage = [DownloadButtonImage shopImageWithProgress:0.0f buttonName:ButtonName];
    }
    else if ([ButtonName isEqualToString:@"Downloading"]) {
        
        shopButtonImage = [DownloadButtonImage shopImageWithProgress:0.0f buttonName:ButtonName];
    }
    else if ([ButtonName isEqualToString:@"Installing"]) {
        
        shopButtonImage = [DownloadButtonImage shopImageWithProgress:1.0f buttonName:ButtonName];
    }
    else {
        
        shopButtonImage = [[ResourceManager instance] resourceForKeyPath:[NSString stringWithFormat:@"Images.Shop.Buttons.%@", ButtonName]];
    }
    
    [self.button setImage:shopButtonImage forState:UIControlStateNormal];
    [self.button setEnabled:buttonEnabled];
    [self.priceLabel setHidden:!priceVisible];
}


- (void) layout {
    
    // ...
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.querySelector('meta[name=viewport]').setAttribute('content', 'width=%d;', false); ",
                                                  (int)webView.frame.size.width]];
    
    [webView setFrameHeight:1];
    
    CGSize size = [webView sizeThatFits: CGSizeMake(webView.frame.size.width, 1000)];
    [webView setFrameHeight:size.height];
    
    float posY = webView.frame.origin.y + size.height + 20;
    
    [dropDownView setFrameY:posY];
    
    posY += dropDownView.frame.size.height + MarginBottom;
    
    [contentView setFrameHeight:posY];
    
    [scrollView setContentSize:contentView.frame.size];
}



#pragma mark Actions

//- (IBAction) purchase:(id) sender {
//    
//    if (product.status == UAProductStatusInstalled) {
//        
//        [self restoreProduct];
//    }
//    else {
//        
//        [UAStoreFront purchase:product.productIdentifier];
//    }
//}


- (void) restoreProduct {
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:resource(@"Dictionaries.Shop.Restore.Title") message:resource(@"Dictionaries.Shop.Restore.Body") delegate:self cancelButtonTitle:@"Ja" otherButtonTitles:@"Nein", nil];
    
    [alert show];
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        [UAStoreFront purchase:product.productIdentifier];
    }
}



#pragma mark ModuleManagerObserver

- (void) product:(UAProduct *)theProduct loadedForModule:(NSString *)theModuleName {
    
//    NSLog(@"product:loadedForModule:(%@)", theModuleName);
    
    product = theProduct;
    
    [self refreshButton];
}


- (void) product:(UAProduct *)product statusChangedTo:(NSNumber *)status forModule:(NSString *)theModuleName {
    
    NSLog(@"product:statusChangeTo:(%@)forModule:(%@)", status, theModuleName);
    
    [self refreshButton];
}


- (void) product:(UAProduct *)product progressChangedTo:(NSNumber *)progress forModule:(NSString *)theModuleName {
    
    NSLog(@"product:progressChangedTo:(%@)forModule:(%@)", progress, theModuleName);
    
    UIImage* shopButtonImage = [DownloadButtonImage shopImageWithProgress:[progress floatValue] buttonName:@"Downloading"];
    
    [self.button setImage:shopButtonImage forState:UIControlStateNormal];
}


#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
    
    NSLog(@"webview did finish load");

    NSLog(@"webview time to load: %f", timer_passed(@"webview"));
    [self layout];
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
                         
                         NSLog(@"webview height: %f", webView.frame.size.height);
                     }
     ];
}



- (void)viewDidUnload {
    [self setIconImageView:nil];
    [super viewDidUnload];
}


- (void) dealloc {
    
    NSLog(@"CustomProductDetailViewController DEALLOC");
    
//    [[ModuleManager manager] removeObserver:self forModule:moduleName];
    webView.delegate = nil;
}

@end
