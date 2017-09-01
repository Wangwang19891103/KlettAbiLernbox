//
//  ModuleViewController.m
//  KlettAbiLernboxen
//
//  Created by Wang on 10.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModuleViewController.h"
#import "ModuleManager.h"
#import "PDFManager.h"
//#import "UAProduct.h"
//#import "UAStoreFront.h"
//#import "UAProductDetailViewController.h"
#import "CustomProductDetailViewController.h"
//#import "ModuleCell.h"
#import "ResourceManager.h"
#import "UIImage+Extensions.h"
#import "GeneralCell.h"
#import "ManualViewCOntroller.h"
#import "ImprintViewController.h"
#import "MethodsViewController.h"
#import "AboutViewController.h"
#import "Contents1ViewController.h"
#import "StatisticsViewController2.h"
#import "AlertManager.h"


#define MODULE_SECTION_INDEX 0
#define Header_Section_Height 26.0f


static UIColor* defaultBarColor;
static UIColor* defaultTabBarColor;



@implementation ModuleViewController


- (id) init {
    
    if (self = [super init]) {
        
        _lastProduct = nil;
        _alertID = 0;
        
//        NSMutableArray* array = [NSMutableArray array];
//        
//        for (NSString* key in [PDFManager manager].moduleDict.keyEnumerator) {
//            [array addObject:key];
//        }
//        
//        _modulesArray = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
//        _customNavigationItem = [[CustomNavigationItem alloc] init];
//        _customNavigationItem.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0];
//        _customNavigationItem.textColor = [UIColor whiteColor];
//        _customNavigationItem.title = @"";
        
#ifdef SCHULWISSEN
        [self.navigationItem setTitle:@"Schulwissen 5-10"];
#else
        [self.navigationItem setTitle:@"Abi-Lernbox"];
#endif
        
        
//        [ModuleManager manager].delegate = self;
        
        [[ModuleManager manager] loadInventory];
        
        self.hidesBottomBarWhenPushed = TRUE;
        
        _moduleCells = [NSMutableArray array];
        
        for (NSDictionary* moduleDict in [ModuleManager manager].modulesArray) {
            
            ModuleCell* cell = [ModuleCell cellWithModuleDict:moduleDict];
            cell.delegate = self;
            
            [_moduleCells addObject:cell];
        }
        
        _zigzagImageView = nil;
        
//        UIImage* logoImage = [UIImage imageNamed:@"navigation_bar_logo.png"];
//        _logoImageView = [[UIImageView alloc] initWithImage:logoImage];
//        [_logoImageView setFrameOrigin:CGPointMake(2,2)];

        
        [UAStoreFront registerObserver:self];
        [UAStoreFront shared].sfObserver.delegate = self;
    }
    
    return self;
}

//
//- (UINavigationItem*) navigationItem {
//    
//    return _customNavigationItem;
//}



//- (void) moduleManagerDidLoadInventory {
//    
//    [_moduleCells makeObjectsPerformSelector:@selector(refreshView)];
//}


- (void) viewDidLoad {
    
    NSLog(@"module view controller viewdidload");
    
    [super viewDidLoad];
    
    if (!defaultBarColor) {
        defaultBarColor = self.navigationController.navigationBar.tintColor;
        defaultBarColor = [UIColor darkGrayColor];
    }
    if (!defaultTabBarColor) {
        defaultTabBarColor = self.tabBarController.tabBar.tintColor;
    }
    
//    self.tableView.bounces = FALSE;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:resource(@"Images.TableViews.BackgroundPattern")];
    
    
//    self.navigationController.navigationBar.tintColor = [UIColor colorWithHue:207.0/255 saturation:255.0/255 brightness:255.0/255 alpha:1.0];
    
    
#ifdef SCHULWISSEN
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [UIColor blackColor],
                                                                    UITextAttributeTextColor,
                                                                    nil];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
#else
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
#endif
    
    
    // restore button
    
    _restoreItem = [[UIBarButtonItem alloc] initWithTitle:@"Restore" style:UIBarButtonItemStylePlain target:self action:@selector(actionRestoreAll)];
//    _restoreItem.enabled = false;
    [self.navigationItem setRightBarButtonItem:_restoreItem];

    
//    UIImage* bgImage = resource(@"Images.NavigationBar.BottomShadow");
//    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
//    
//    //    [self.navigationController.navigationBar setShadowImage:bgImage];
//    
//    if ([self.navigationController.navigationBar respondsToSelector:@selector(shadowImage)]) {
//        
//        [self.navigationController.navigationBar setShadowImage:bgImage];
//    }
//    else {
//        
//        UIImageView* shadowView = [[UIImageView alloc] initWithImage:bgImage];
//        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//        shadowView.frame = CGRectMake(0, self.navigationController.navigationBar.bounds.size.height, self.view.bounds.size.width, bgImage.size.height);
//        [self.navigationController.navigationBar addSubview:shadowView];
//    }
    
    
//    // tabbar shadow image
//    
//    UIImage* bgImage = [[ResourceManager instance] resourceForKeyPath:@"Images.TabBar.TopShadow"];
//    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
//    UIImageView* topShadowImageView = [[UIImageView alloc] initWithImage:bgImage];
//    topShadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    [topShadowImageView setFrameWidth:self.view.bounds.size.width];
//    [topShadowImageView setFrameY:topShadowImageView.bounds.size.height * (-1)];
//    self.tabBarController.tabBar.clipsToBounds = FALSE;
//    [self.tabBarController.tabBar addSubview:topShadowImageView];
    
    
    _sectionHeaderView = [[SectionHeader alloc] init];
#ifdef SCHULWISSEN
    UIImage* patternImage = [UIImage imageNamed:@"search_bar_pattern_start"];
#else
    UIImage* patternImage = resource(@"Images.TableViews.LinedPattern");
#endif
    patternImage = [patternImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    _sectionHeaderView.backgroundImage.image = patternImage;
    

#ifdef SCHULWISSEN
    patternImage = [UIImage imageNamed:@"zigzag_start"];
#else
    patternImage = resource(@"Images.TableViews.ZigzagPattern");
#endif
    patternImage = [patternImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    _sectionHeaderView.zigzagImage.image = patternImage;

    
    
    UIImage* bgImage = [[ResourceManager instance] resourceForKeyPath:@"Images.NavigationBar.BackgroundLogo"];
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 80, 2, 1)];
    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    
//    bgImage = [[ResourceManager instance] resourceForKeyPath:@"Images.NavigationBar.BackgroundLogoLandscape"];
//    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 80, 2, 1)];
//    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsLandscapePhone];
    
    
    
//    [[PropertyBoard instance] addChangeObserver:self];
}

- (void) viewWillAppear:(BOOL)animated {
    
    
    UIImage* navImage = [[ResourceManager instance] resourceForKeyPath:@"Images.NavigationBar.BackgroundLogo"];
    navImage = [navImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 80, 2, 1)];
    
//    UIImage* navImage2 = [[ResourceManager instance] resourceForKeyPath:@"Images.NavigationBar.BackgroundLogoLandscape"];
//    navImage2 = [navImage2 resizableImageWithCapInsets:UIEdgeInsetsMake(1, 80, 2, 1)];

    [self.navigationController.navigationBar setBackgroundImage:navImage forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setBackgroundImage:navImage2 forBarMetrics:UIBarMetricsLandscapePhone];

    
//    [UIView animateWithDuration:0.3 animations:^(void) {
//
//    }];

    
    
    [super viewWillAppear:animated];
    
    
//    self.navigationController.navigationBar.tintColor = defaultBarColor;
    
//    UIImage* bgImage = [[ResourceManager instance] resourceForKeyPath:@"Images.NavigationBar.BackgroundLogo"];
//    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 80, 2, 1)];
//    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
//    
//    bgImage = [[ResourceManager instance] resourceForKeyPath:@"Images.NavigationBar.BackgroundLogoLandscape"];
//    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 60, 2, 1)];
//    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsLandscapePhone];
    
    
//    [self.navigationController.navigationBar setShadowImage:nil];
    


    
//    UIImageView* botShadowView = [[UIImageView alloc] initWithImage:bgImage];
//    botShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    botShadowView.frame = CGRectMake(0, self.navigationController.navigationBar.bounds.size.height, 320, bgImage.size.height);
//    [self.navigationController.navigationBar addSubview:botShadowView];

    
    [[PDFManager manager] unloadModule];

    [_moduleCells makeObjectsPerformSelector:@selector(refreshView)];
    
//    self.tabBarController.tabBar.tintColor = defaultTabBarColor;

//    UIColor* barColor = [UIColor colorWithRed:255/255.0 green:204/255.0 blue:1/255.0 alpha:1.0];  // schulwissen color
    
    
#ifdef SCHULWISSEN
    UIImage* bgImage = [UIImage imageNamed:@"tab_bar_background_start"];
#else
    UIImage* bgImage = [[ResourceManager instance] resourceForKeyPath:@"Images.TabBar.Background"];
#endif
    //    bgImage = [bgImage imageWithAdjustmentColor:barColor];
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 2)];
    [self.tabBarController.tabBar setBackgroundImage:bgImage];
    

#ifdef SCHULWISSEN
    bgImage = [UIImage imageNamed:@"tab_bar_selection_start"];
#else
    bgImage = [[ResourceManager instance] resourceForKeyPath:@"Images.TabBar.Selection"];
#endif
//    bgImage = [bgImage imageWithAdjustmentColor:barColor];
    [self.tabBarController.tabBar setSelectionIndicatorImage:bgImage];
}

- (void) viewDidAppear:(BOOL)animated {
    [self layoutTableViewFrame];
    [self.tabBarController.tabBar setHidden:NO];
//    [self.navigationController.navigationBar addSubview:_logoImageView];

    [super viewDidAppear:animated];
    
//    UIImage* bgImage = [[ResourceManager instance] resourceForKeyPath:@"Images.NavigationBar.BackgroundLogo"];
//    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 80, 2, 1)];
//    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
//    
//    bgImage = [[ResourceManager instance] resourceForKeyPath:@"Images.NavigationBar.BackgroundLogoLandscape"];
//    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 80, 2, 1)];
//    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsLandscapePhone];
    
    
}


- (void) viewWillDisappear:(BOOL)animated {
    
//    [_logoImageView removeFromSuperview];
    
    [super viewWillDisappear:animated];

}


- (void) viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];
    
    [self deselectAllCells];
}


- (void) deselectAllCells {
    
    for (uint s = 0; s < [self.tableView numberOfSections]; ++s) {
        
        for (uint r = 0; r < [self.tableView numberOfRowsInSection:s]; ++r) {
            
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]];
            
            if ([cell isKindOfClass:[ModuleCell class]]) {
               
                [(ModuleCell*)cell setCellSelected:false];
            }
            else if ([cell isKindOfClass:[GeneralCell class]]) {
                
                [(GeneralCell*)cell setCellSelected:false];
            }
        }
    }
}


- (void) variableValueChangedForName:(NSString *)name {
    
    if ([name isEqualToString:@"bar saturation"]
        || [name isEqualToString:@"bar brightness"]
        || [name isEqualToString:@"hide empty bars"]) {
        
        [_moduleCells makeObjectsPerformSelector:@selector(layout)];
    }
}

//- (void) viewDidLayoutSubviews {
//
//    
//}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self layoutTableViewFrame];
    [_moduleCells makeObjectsPerformSelector:@selector(layout)];
}


- (void) actionRestoreAll {
    
    NSString* title = resource(@"Dictionaries.Alerts.RestoreAllBegin.Title");
    NSString* message = resource(@"Dictionaries.Alerts.RestoreAllBegin.Message");
    
    [[AlertManager instance] yesNoAlertWithTitle:title message:message yesBlock:^(void) {
        
        _restoreItem.enabled = false;  NSLog(@"ITEM disabled");
        _restoring = true;

        [UAStoreFront restoreAllProducts];
    }];
}



//- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    
//    [_customNavigationItem updateTitleView];
//}

//- (void) viewDidAppear:(BOOL)animated {
//    
//    [super viewDidAppear:animated];
//    
//    NSLog(@"viewDidAppear");
//    
//    NSMutableArray* indexPaths = [NSMutableArray array];
//    for (int i = 0; i < [self tableView:self.tableView numberOfRowsInSection:MODULE_SECTION_INDEX]; ++i) {
//        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:MODULE_SECTION_INDEX]];
//    }
//    
//    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
//}



#pragma mark - UITableViewController

- (void) layoutTableViewFrame
{
    BOOL isPortrait = ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationPortrait ||
                       [UIApplication sharedApplication].statusBarOrientation ==  UIDeviceOrientationPortraitUpsideDown)?YES:NO;
    
    CGFloat _screenHeight = 0;
    if (isPortrait)
        _screenHeight = MAX([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    else
        _screenHeight = MIN([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    
    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x,
                                      self.tableView.frame.origin.y,
                                      self.tableView.frame.size.width,
                                      (_screenHeight-self.tableView.frame.origin.y-self.tabBarController.tabBar.frame.size.height));
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return Header_Section_Height;
}


- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    SectionHeader* headerView = [_sectionHeaderView copy];
    headerView.titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    return headerView;
}


- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case MODULE_SECTION_INDEX:
            
#ifdef SCHULWISSEN
            return @"Fächer";
#else
            return @"Abitur-Fächer";
#endif
            break;
            
        case 1:
            return @"Allgemeines";
            break;
            
        default:
            return nil;
            break;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case MODULE_SECTION_INDEX:
            return _moduleCells.count;
            break;
            
        case 1:
            
#ifdef DIE_ZWEI_LERNMETHODEN
            return 4;
#else
            return 3;
#endif
            
        default:
            return 0;
            break;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    switch (indexPath.section) {
        case MODULE_SECTION_INDEX:
            
#ifdef SCHULWISSEN
            return (is_ipad) ? 123 : 120;  // old: 82 iphone
#else
            return (is_ipad) ? 123 : 103;  // old: 82 iphone
#endif
            break;
            
        default:
            
            return (is_ipad) ? 66 : 44;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"--- cellForRowArIndexPath: %@", indexPath);
    
    switch (indexPath.section) {
        case MODULE_SECTION_INDEX: 
            {
                return [_moduleCells objectAtIndex:indexPath.row];
                break;
            }
            
        case 1:
            {
//                UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"normalCell"];
                
                GeneralCell* cell = [tableView dequeueReusableCellWithIdentifier:@"generalCell"];
                
                if (!cell) {
//                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"normalCell"];
                    
                    cell = [[GeneralCell alloc] init];
                }
                
                switch (indexPath.row) {
                    case 0:
                        cell.titleLabel.text = @"Über diese App";
                        break;
                        
                    case 1:
                        cell.titleLabel.text = @"Anleitung";
                        break;

#ifdef DIE_ZWEI_LERNMETHODEN
                    case 2:
                        cell.titleLabel.text = @"Die zwei Lernmethoden";
                        break;
                        
                    case 3:
                        cell.titleLabel.text = @"Impressum";
                        break;
#else
                    case 2:
                        cell.titleLabel.text = @"Impressum";
                        break;
#endif
                        
                    default:
                        break;
                }
                
                return cell;
            }
            
        default:
            return nil;
            break;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    timer_start(@"select_module");
    timer_start(@"didselectrow");
    
    switch (indexPath.section) {
        case MODULE_SECTION_INDEX: 
            {
                
                ModuleCell* cell = [_moduleCells objectAtIndex:indexPath.row];
                
                if (cell.contentInstallationStatus != ModuleInstallationStatusNone) {
                    
                    [cell setCellSelected:TRUE];
                    
                    [[PDFManager manager] loadModule:cell.moduleName];
                    
                    // handle load error
                    if (![PDFManager manager].loadSuccess) {

                        NSString* title = [[ResourceManager instance] resourceForKeyPath:@"Dictionaries.Alerts.ModuleLoadError.Title"];
                        NSString* message = [[ResourceManager instance] resourceForKeyPath:@"Dictionaries.Alerts.ModuleLoadError.Message"];
                        
                        [[AlertManager instance] okAlertWithTitle:title message:[NSString stringWithFormat:message, cell.moduleName]];
                      
                        [cell setCellSelected:FALSE];
                        
                        return;
                    }
                    
                    
                    // replace viewcontrollers in navigationcontrollers 1-4
                    
                    UIViewController* vc1 = [[Contents1ViewController alloc] initWithTableModelMode:TableModelModeAll];
                    UIViewController* vc2 = [[Contents1ViewController alloc] initWithTableModelMode:TableModelModeFavorites];
                    UIViewController* vc3 = [[Contents1ViewController alloc] initWithTableModelMode:TableModelModeNotes];
                    UIViewController* vc4 = [[StatisticsViewController2 alloc] init];
                    
                    [(UINavigationController*)[self.tabBarController.viewControllers objectAtIndex:1] setViewControllers:[NSArray arrayWithObjects:vc1,nil]];
                    [(UINavigationController*)[self.tabBarController.viewControllers objectAtIndex:2] setViewControllers:[NSArray arrayWithObjects:vc2,nil]];
                    [(UINavigationController*)[self.tabBarController.viewControllers objectAtIndex:3] setViewControllers:[NSArray arrayWithObjects:vc3,nil]];
                    [(UINavigationController*)[self.tabBarController.viewControllers objectAtIndex:4] setViewControllers:[NSArray arrayWithObjects:vc4,nil]];

                    
                    [self.tabBarController setSelectedIndex:1];
                    
//                    [cell setCellSelected:FALSE];

                }
//                else if (cell.product) {
//                    
//                    [self openShopForProduct:cell.product];
//                }
            }
            break;
            
        case 1:
        {
            UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                           initWithTitle: @"Zurück"
                                           style: UIBarButtonItemStylePlain
                                           target: nil
                                           action: nil];
            
            [self.navigationItem setBackBarButtonItem: backButton];
            
            GeneralCell* cell = (GeneralCell*)[tableView cellForRowAtIndexPath:indexPath];;
            
            
            
            [cell setCellSelected:TRUE];
            
            switch (indexPath.row) {

                case 0:
                {
                    
                    AboutViewController* controller = [[AboutViewController alloc] init];
                    
                    [self.navigationController pushViewController:controller animated:TRUE];
                    
                }
                    break;
                    

                    
                case 1:
                    {
                    
                        ManualViewCOntroller* controller = [[ManualViewCOntroller alloc] init];
                        
                        [self.navigationController pushViewController:controller animated:TRUE];
                        
                    }
                    break;
                
#ifdef DIE_ZWEI_LERNMETHODEN
                case 2:
                {
                    
                    MethodsViewController* controller = [[MethodsViewController alloc] init];
                    
                    [self.navigationController pushViewController:controller animated:TRUE];
                    
                }
                    break;
#endif

#ifdef DIE_ZWEI_LERNMETHODEN
                case 3:
#else
                case 2:
#endif
                    {
                    
                        ImprintViewController* controller = [[ImprintViewController alloc] init];
                    
                        [self.navigationController pushViewController:controller animated:TRUE];
                    
                    }
                    break;
                    
                default:
                    break;
            }
            
//            [cell setCellSelected:FALSE];
            
            break;
        }
            
        default:
            break;
    }
}


//- (BOOL) shouldAutorotate {
//    
//    return TRUE;
//}
//
//
//- (NSUInteger) supportedInterfaceOrientations {
//    
//    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
//}
//
//
//- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    
//    return (toInterfaceOrientation == UIInterfaceOrientationPortrait
//            || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
//}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    return true;
}


- (BOOL) shouldAutorotate {
    
    return true;
}


- (NSUInteger) supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskAll;
}


- (void) openShopForProduct:(UAProduct*) product moduleName:(NSString*) moduleName {
    
    CustomProductDetailViewController* controller = [[CustomProductDetailViewController alloc] initWithModule:moduleName];
    [controller setProduct:product];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Zurück"
                                   style: UIBarButtonItemStylePlain
                                   target: nil
                                   action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    
    [self.navigationController pushViewController:controller animated:TRUE];
}


#pragma mark ModuleCellDelegate

- (void) moduleCellDidRequestShop:(ModuleCell *)cell {

    [self openShopForProduct:cell.product moduleName:cell.moduleName];
}


- (void) inventoryStatusChanged:(NSNumber *)status {
    
//    _restoreItem.enabled = ([status intValue] == UAInventoryStatusLoaded) && !_restoring;
}


- (void) storeKitObserverDidDiscardAllRestoredTransactions:(UAStoreKitObserver *)observer {
    
    _restoreItem.enabled = true; NSLog(@"ITEM enabled");
    _restoring = false;
}


- (NSString*) storeKitObserverRequestingNextProductIdentifierFromArray:(NSArray *)array {
    
    NSArray* modules = [ModuleManager manager].modulesArray;
    
    for (NSDictionary* dict in modules) {
        
        NSString* productID = [dict objectForKey:@"productID"];
        
        if ([array containsObject:productID]) {
            
            return productID;
        }
    }
    
    return nil;
}


- (void) storeKitObserverDidFinishRestoringAllProducts {
    
    _restoreItem.enabled = true;  NSLog(@"ITEM enabled");
    _restoring = false;
    
    NSString* title = resource(@"Dictionaries.Alerts.RestoreAllFinished.Title");
    NSString* message = resource(@"Dictionaries.Alerts.RestoreAllFinished.Message");
    
    [[AlertManager instance] okAlertWithTitle:title message:message];
}


//#pragma mark Product Restore
//
//- (void) restoreProduct:(UAProduct*) product {
//    
//
//
//}



//#pragma mark UIAlertViewDelegate
//
//- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//
//    switch (_alertID) {
//
//        case 1: {
//            
//            // check if product has a receipt
//            if (!_lastProduct ||
//                (!_lastProduct.isFree && !_lastProduct.receipt)) {
//                
//                NSString* title = [[ResourceManager instance] resourceForKeyPath:@"Dictionaries.Alerts.RestoreProductError.Title"];
//                NSString* message = [[ResourceManager instance] resourceForKeyPath:@"Dictionaries.Alerts.RestoreProductError.Message"];
//                
//                [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
//
//            }
//            else {
//                
//                NSLog(@"Automatische Wiederherstellung starten");
//                
//                [UAStoreFront purchase:_lastProduct.productIdentifier];
//            }
//            
//            _alertID = 0;
//            
//            break;
//        }
//
//            
//        default:
//            break;
//    }
//
//}


@end





