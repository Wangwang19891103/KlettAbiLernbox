//
//  Contents1ViewController.m
//  KlettAbiLernboxen
//
//  Created by Wang on 28.08.12.
//
//

#import "Contents1ViewController.h"
#import "Contents2ViewController.h"
#import "NotesTableViewController.h"
#import "PDFManager.h"
#import "ModuleManager.h"
#import "UIColor+Extensions.h"
#import "NSArray+Extensions.h"
#import "NSSet+Extensions.h"
#import "TableCells.h"
#import "ResourceManager.h"
#import "UIImage+Extensions.h"
#import "UserDataManager.h"
#import "LearningProgressBarImage.h"
#import "PropertyBoard.h"


#define SearchBar_Placeholder_String @"Suche"


@implementation Contents1ViewController

@synthesize mySearchDisplayController;
@synthesize tableModelMode;


#pragma mark - Initializers

- (id) initWithTableModelMode:(TableModelMode)mode {
    
    if (self = [super initWithStyle:UITableViewStylePlain]) {

        tableModelMode = mode;
        _model = [[Content1TableModel alloc] initWithMode:mode filtered:FALSE];
        _filteredModel = [[Content1TableModel alloc] initWithMode:mode filtered:TRUE];
        _zigzagImageView = nil;
        
//        _customNavigationItem = [[CustomNavigationItem alloc] init];
//        _customNavigationItem.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0];
//        _customNavigationItem.textColor = [UIColor whiteColor];
//        _customNavigationItem.title = @"";
        
    }

    return self;
}


//- (UINavigationItem*) navigationItem {
//    
//    return _customNavigationItem;
//}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    
//    alert(@"viewDidLoad width: %f", self.view.bounds.size.width);
    
    [super viewDidLoad];
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchBar.showsCancelButton = TRUE;
    searchBar.placeholder = SearchBar_Placeholder_String;
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.showsCancelButton = FALSE;
    
    self.mySearchDisplayController = [[MySearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.mySearchDisplayController.delegate = self;
    self.mySearchDisplayController.searchResultsDelegate = self;
    self.mySearchDisplayController.searchResultsDataSource = self;
    
    self.tableView.tableHeaderView = searchBar;
    
    
//    self.tableView.bounces = FALSE;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:resource(@"Images.TableViews.BackgroundPattern")];
    
//    self.mySearchDisplayController.searchResultsTableView.bounces = FALSE;
//    self.mySearchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.mySearchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithPatternImage:resource(@"Images.TableViews.BackgroundPattern")];
//    
//    [[UITableView appearance] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//    [[UITableView appearance] setBackgroundColor:[UIColor colorWithPatternImage:resource(@"Images.TableViews.BackgroundPattern")]];

    

//    UIImage* backgroundImage = resource(@"Images.TableViews.BackgroundPattern");
//    backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsZero];
    
//    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
//    self.tableView.backgroundView.frame = CGRectMake(0, 0, 320, 480);
//    self.tableView.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
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

    
//    [[PropertyBoard instance] addChangeObserver:self];
}


- (void) variableValueChangedForName:(NSString *)name {
    
    UIColor* barColor = [[ModuleManager manager] colorForModule:[PDFManager manager].moduleName];
    //    barColor = [barColor colorByDarkingByPercent:0.3];
    barColor = [barColor colorWithSaturationFactor:PBintVarValue(@"pattern saturation") * 0.01];
    //    barColor = [barColor colorWithBrightnessFactor:PBintVarValue(@"brightness") * 0.01];
    
    UIImage* patternImage = resource(@"Images.TableViews.ZigzagPattern");
    patternImage = [patternImage imageWithAdjustmentColor:barColor];
    patternImage = [patternImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [_zigzagImageView removeFromSuperview];
    _zigzagImageView = [[UIImageView alloc] initWithImage:patternImage];
    _zigzagImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_zigzagImageView setFrameWidth:320];
    [_zigzagImageView setFrameY:mySearchDisplayController.searchBar.frame.size.height];
    [mySearchDisplayController.searchBar addSubview:_zigzagImageView];
    
    UIImage* bgImage = resource(@"Images.TableViews.LinedPattern");
    bgImage = [bgImage imageWithAdjustmentColor:barColor];
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [mySearchDisplayController.searchBar setBackgroundImage:bgImage];
    
    [mySearchDisplayController.searchBar setNeedsDisplay];
    
    [self.tableView reloadData];
}

/*
 * navigation bar title
 *
 * settings tint colors for:
 * - search bar
 * - navigation bar
 *
 * setting colorized background images for:
 * - navigation bar (port and land)
 * - tabbar
 * - tabbar selection
 * - searchbar
 * 
 * adding views for:
 * - zigzag for searchbar (remove and reapply)
 * - bottom shadow for navigation bar (once)
 *
 * reload both models
 *
 * reload tableview
 *
 * reload search tableview
 *
 */
- (void) viewWillAppear:(BOOL)animated {

//    alert(@"viewWillAppear width: %f", self.view.bounds.size.width);

    [super viewWillAppear:animated];
    
    [self.navigationItem setTitle:[PDFManager manager].moduleName];
    
    UIColor* barColor = [[ModuleManager manager] colorForModule:[PDFManager manager].moduleName];
    
    [[UISearchBar appearance] setTintColor:[barColor colorByDarkingByPercent:0.3]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    
    UIImage* bgImage = resource(@"Images.NavigationBar.Background");
    bgImage = [bgImage imageWithAdjustmentColor:[barColor colorByDarkingByPercent:0.3]];
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 2, 1)];
    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    
    /* shadow image */

    if (!_shadowInitialized) {

        UIView *navShadowView = [[UIView alloc] initWithFrame:CGRectMake(0.f,
                                                                  self.navigationController.navigationBar.frame.size.height,
                                                                  self.navigationController.navigationBar.frame.size.width,
                                                                  1.f)];
        navShadowView.backgroundColor = [UIColor colorWithPatternImage:bgImage];
        navShadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self.navigationController.navigationBar addSubview:navShadowView];
        
        _shadowInitialized = TRUE;
    }

//    bgImage = resource(@"Images.NavigationBar.BackgroundLandscape");
//    bgImage = [bgImage imageWithAdjustmentColor:[barColor colorByDarkingByPercent:0.3]];
//    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 2, 1)];
//    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsLandscapePhone];

    
    
//    NSData* imageData = UIImagePNGRepresentation(bgImage);
//    NSArray* pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString* documentsDirectory = [pathArray lastObject];
//    BOOL success = [imageData writeToFile:[documentsDirectory stringByAppendingPathComponent:@"bgImage.png"] atomically:YES];
//    
//    alert(@"success: %d", success);
    
    
//    self.tabBarController.tabBar.tintColor = [barColor colorByDarkingByPercent:0.6];
    bgImage = resource(@"Images.TabBar.Background");
    bgImage = [bgImage imageWithAdjustmentColor:[barColor colorByDarkingByPercent:0.3]];
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 2)];
    [self.tabBarController.tabBar setBackgroundImage:bgImage];
    
    bgImage = resource(@"Images.TabBar.Selection");
    bgImage = [bgImage imageWithAdjustmentColor:[barColor colorByDarkingByPercent:0.3]];
    [self.tabBarController.tabBar setSelectionIndicatorImage:bgImage];

    /* COLOR CHANGE */
    
    barColor = [barColor colorWithSaturationFactor:PBintVarValue(@"pattern saturation") * 0.01];

    
    bgImage = resource(@"Images.TableViews.LinedPattern");
    bgImage = [bgImage imageWithAdjustmentColor:barColor];
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [mySearchDisplayController.searchBar setBackgroundImage:bgImage];
    
    
    UIImage* patternImage = resource(@"Images.TableViews.ZigzagPattern");
    patternImage = [patternImage imageWithAdjustmentColor:barColor];
    patternImage = [patternImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [_zigzagImageView removeFromSuperview];
    _zigzagImageView = [[UIImageView alloc] initWithImage:patternImage];
    _zigzagImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_zigzagImageView setFrameWidth:self.view.bounds.size.width];
    [_zigzagImageView setFrameY:mySearchDisplayController.searchBar.frame.size.height];
    [mySearchDisplayController.searchBar addSubview:_zigzagImageView];
    
    [_model reload];
    [_filteredModel reload];
    
    [self.tableView reloadData];
    
    if (self.mySearchDisplayController.active) {
        [self.mySearchDisplayController.searchResultsTableView reloadData];
    }
}


- (void) actionBack {
    
    [self.navigationController popToRootViewControllerAnimated:TRUE];
}


- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [self.tableView bringSubviewToFront:self.mySearchDisplayController.searchResultsTableView];
}


- (void) viewDidDisappear:(BOOL)animated {
    
    [super viewDidDisappear:animated];

    [self deselectAllCells];
}


- (void) deselectAllCells {
    
    for (uint s = 0; s < [self.tableView numberOfSections]; ++s) {
        
        for (uint r = 0; r < [self.tableView numberOfRowsInSection:s]; ++r) {
            
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:r inSection:s]];
            
            if ([cell isKindOfClass:[CategoryCell class]]) {
                
                [(CategoryCell*)cell setCellSelected:false];
            }
            else if ([cell isKindOfClass:[CategoryResultCell class]]) {
                
                [(CategoryResultCell*)cell setCellSelected:false];
            }
        }
    }
}


- (void) refreshZigZag {
    
    [_zigzagImageView removeFromSuperview];
    [mySearchDisplayController.searchBar addSubview:_zigzagImageView];
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


//- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    
////    [_customNavigationItem updateTitleView];
//}



#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    uint numberOfSections;
    
    if (tableView == self.mySearchDisplayController.searchResultsTableView) {

        numberOfSections = [_filteredModel numberOfSections];
    }
    else {

        numberOfSections = [_model numberOfSections];
    }
    
    return numberOfSections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    Content1TableModel* model = nil;
    
    if (tableView == self.mySearchDisplayController.searchResultsTableView) {

        model = _filteredModel;
    }
    else {
        
        model = _model;
    }
    
    uint numberOfRows = [model numberOfRowsInSection:section];
    
    
    if (model == _model) {
        
        // DEMO Content
        if ([PDFManager manager].isDemo
            && _model.mode == TableModelModeAll) {
            
            ++numberOfRows;
        }
        
        // No Favorites/Notes
        else if ((model.mode == TableModelModeFavorites
                 || model.mode == TableModelModeNotes)
                 && numberOfRows == 0
                 && section == 0) {
            
            return 1;
        }
    }
    
    return numberOfRows;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    Content1TableModel* model = nil;
    
    if (tableView == self.mySearchDisplayController.searchResultsTableView) {
        
        model = _filteredModel;
    }
    else {
        
        model = _model;
    }
    
    if (model == _model) {
        
        // DEMO Content
        if ([PDFManager manager].isDemo
            && _model.mode == TableModelModeAll
            && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
            
            return 100;
        }
        
        // No Favorites/Notes
        else if ((model.mode == TableModelModeFavorites
                  || model.mode == TableModelModeNotes)
                 && [model numberOfRowsInSection:0] == 0
                 && indexPath.section == 0) {
            
            return 100;
        }
    }
    return (is_ipad) ? 72 : 48;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    Content1TableModel* model = nil;
    
    if (tableView == self.mySearchDisplayController.searchResultsTableView) {
        
        model = _filteredModel;
    }
    else {
        
        model = _model;
    }
    
    // DEMO Content

    if (model == _model
        && [PDFManager manager].isDemo
        && _model.mode == TableModelModeAll
        && indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
        
        InfoCell* cell = (InfoCell*)[tableView dequeueReusableCellWithIdentifier:@"infoCell"];
        
        if (!cell) {
            
            cell = [[InfoCell alloc] init];
        }
        
        NSString* title = resource(@"Dictionaries.InfoCells.DemoContent");
        NSString* moduleName = [PDFManager manager].moduleName;
        if (!moduleName) moduleName = @"";  //FIXME: tableview reloads demo cell when module has already been unloaded
        title = [title stringByReplacingOccurrencesOfString:@"[MODULE_NAME]" withString:moduleName];
        
        cell.titleLabel.text = title;
        
        return cell;
    }
    
    // No Favorites/Notes
    else if (model == _model
             && (model.mode == TableModelModeFavorites
                 || model.mode == TableModelModeNotes)
             && [model numberOfRowsInSection:0] == 0
             && indexPath.section == 0) {
            
        InfoCell* cell = (InfoCell*)[tableView dequeueReusableCellWithIdentifier:@"infoCell"];
        
        if (!cell) {
            
            cell = [[InfoCell alloc] init];
        }
        
        NSString* title = nil;
        
        
        if (model.mode == TableModelModeFavorites) {
            
            title = resource(@"Dictionaries.InfoCells.NoFavorites");
        }
        else if (model.mode == TableModelModeNotes) {
            
            title = resource(@"Dictionaries.InfoCells.NoNotes");
        }
        
        cell.titleLabel.text = title;
        
        return cell;
    }

    else if (tableModelMode == TableModelModeNotes || (tableView == self.mySearchDisplayController.searchResultsTableView)) {
        
        CategoryResultCell* cell = (CategoryResultCell*)[tableView dequeueReusableCellWithIdentifier:@"categoryResultCell"];
        
        if (!cell) {
            
            cell = [[CategoryResultCell alloc] init];
        }
        
        Content1TableModel* model = (tableView == self.mySearchDisplayController.searchResultsTableView) ? _filteredModel : _model;

//        NSString* string2 = (tableModelMode == TableModelModeNotes) ? @"Notizen" : @"Treffer";
        
        NSString* pageTitle = [model titleForCellAtIndexPath:indexPath];
        NSRange pageRange = [model pageRangeForCellAtIndexPath:indexPath];
        uint pageHits = [model pageHitsForCellAtIndexPath:indexPath];
        uint hits = [model hitsForCellAtIndexPath:indexPath];
        
        cell.titleLabel.text = [NSString stringWithFormat:@"%@ (%d - %d)", pageTitle, pageRange.location, (pageRange.location + pageRange.length - 1)];
        cell.pageHitsLabel.text = [NSString stringWithFormat:@"%d", pageHits];
        cell.hitsLabel.text = [NSString stringWithFormat:@"%d", hits];

        return cell;
        
    }
    else  {
        
        CategoryCell* cell = (CategoryCell*)[tableView dequeueReusableCellWithIdentifier:@"categoryCell"];
        
        if (!cell) {
            
            cell = [[CategoryCell alloc] init];
        }
        
        NSString* pageTitle = [_model titleForCellAtIndexPath:indexPath];
        NSRange pageRange = [_model pageRangeForCellAtIndexPath:indexPath];
        
        cell.titleLabel.text = [NSString stringWithFormat:@"%@ (%d - %d)", pageTitle, pageRange.location, (pageRange.location + pageRange.length - 1)];
        cell.countLabel.text = [NSString stringWithFormat:@"%d", pageRange.length];
        
        
        uint understoodPages = [UserDataManager numberOfUnderstoodPageForModule:[PDFManager manager].moduleName inRange:pageRange];

        int progressPercent = round((understoodPages / (float)pageRange.length) * 100);

        NSLog(@"%@, %@, %d, %d%%", pageTitle, NSStringFromRange(pageRange), understoodPages, progressPercent);
        
        UIImage* learningProgressBarImage = [LearningProgressBarImage imageWithProgress:(understoodPages / (float)pageRange.length) size:cell.learningProgressBarImageView.frame.size];

        cell.learningProgressBarImageView.image = learningProgressBarImage;
        
        NSString* progressString = [NSString stringWithFormat:@"%d%%", progressPercent];
        cell.learningProgressLabel.text = progressString;

        if (PBintVarValue(@"hide empty bars") == 1
            && progressPercent == 0) {
                
            cell.learningProgressBarImageView.hidden = TRUE;
            cell.learningProgressLabel.hidden = TRUE;
        }
        else {
            
            cell.learningProgressBarImageView.hidden = FALSE;
            cell.learningProgressLabel.hidden = FALSE;
        }
        
        return cell;
    }
    
    
}



#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    Content1TableModel* model = nil;
    
    if (tableView == self.mySearchDisplayController.searchResultsTableView) {
        
        model = _filteredModel;
    }
    else {
        
        model = _model;
    }
    
    // No Favorites, No notes, No Results
    if ([model numberOfRowsInSection:0] == 0
        && indexPath.section == 0) {
    
        return;
    }
    
    else if ([PDFManager manager].isDemo &&
             _model.mode == TableModelModeAll &&
             model == _model &&
             indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
        
        return;
    }
    
    
    
    NSString* categoryName;
    
    if (tableView == self.mySearchDisplayController.searchResultsTableView) {

        categoryName = [_filteredModel titleForCellAtIndexPath:indexPath];
    }
    else {

        categoryName = [_model titleForCellAtIndexPath:indexPath];
    }

    UIViewController* controller = nil;
    
    if (tableModelMode == TableModelModeNotes) {

        controller = [[NotesTableViewController alloc] initWithCategory:categoryName];
    }
    else {
    
        controller = [[Contents2ViewController alloc] initWithCategory:categoryName tableModelMode:self.tableModelMode];
    }
    
    if (tableView == self.mySearchDisplayController.searchResultsTableView) {
        [(id)controller setKeyWords:self.mySearchDisplayController.searchBar.text];
    }

    // set cell selected
    CategoryCell* cell = (CategoryCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell setCellSelected:true];
    
    [self.navigationController pushViewController:controller animated:YES];
}



#pragma mark - UISearchDisplayControllerDelegate

- (void) searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)theTableView {
    
//    theTableView.bounces = FALSE;
    [theTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [theTableView setBackgroundColor:[UIColor colorWithPatternImage:resource(@"Images.TableViews.BackgroundPattern")]];
    
//    [self refreshZigZag];
}


- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    
    return TRUE;
}


- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    NSLog(@"SDC should reload table for search string: %@", searchString);
    
//    for (UIView* view in controller.searchResultsTableView.subviews) {
//        if ([view isKindOfClass: [UILabel class]]
////            && [[(UILabel*)view text] isEqualToString:@"No Results"]
//            ) {
//            
//            ((UILabel*)view).text = resource(@"Dictionaries.Search.NoResults");
//            break;
//        }
//    }
    
    NSArray* wordArray = [[searchString lowercaseString] componentsSeparatedByString:@" "];
    
    [self filterContentsWithKeywords:wordArray];
    
    return TRUE;
}



#pragma mark - Private Methods

- (void) filterContentsWithKeywords:(NSArray *)keywords {
    
    SearchIndexResults* results = [[PDFManager manager] searchResultsForKeywords:keywords];
    
//    NSLog(@"results all strings:\n%@", [results strings]);
//    NSLog(@"results all page numbers:\n%@", [results pageNumbersForAllStrings]);
    
    NSLog(@"reuslts page dict:\n%@", [results pageDict]);
    
    
//    _filteredModel.filterSet = [NSSet setWithArray:[results pageNumbersForAllStrings]];
    _filteredModel.filterDict = [results pageDict];
    
//    NSLog(@"filterSet: %@\n", _filteredModel.filterSet);
    [_filteredModel reload];
}


- (NSArray*) sortUsingHitsPerPage:(NSArray *)array {
    
    NSMutableArray* newArray = [array mutableCopy];
    
    // insertion sort
    for (int i = 1; i < [newArray count]; ++i) {
        
        NSDictionary* temp = [newArray objectAtIndex:i];
        int i2 = i;
        
        uint totalHitsTemp = [[temp objectForKey:@"totalHits"] intValue];
        uint totalPagesTemp = [[temp objectForKey:@"pages"] count];
        float hitsPerPageTemp = (float)totalHitsTemp / (float)totalPagesTemp;
        
        while (i2 >= 1) {
            
            uint totalHitsCurrent = [[[newArray objectAtIndex:i2 - 1] objectForKey:@"totalHits"] intValue];
            uint totalPagesCurrent = [[[newArray objectAtIndex:i2 - 1] objectForKey:@"pages"] count];
            float hitsPerPageCurrent = (float)totalHitsCurrent / (float)totalPagesCurrent;
            
            if (hitsPerPageCurrent >= hitsPerPageTemp) break;
            
            [newArray replaceObjectAtIndex:i2 withObject:[newArray objectAtIndex:i2 - 1]];
            i2 = i2 - 1;
        }
        
        [newArray replaceObjectAtIndex:i2 withObject:temp];
    }
    
    return newArray;
}


- (void) dealloc {
    
    NSLog(@"Contents1ViewController DEALLOC");
    
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    self.mySearchDisplayController.delegate = nil;
    self.mySearchDisplayController.searchResultsDelegate = nil;
    self.mySearchDisplayController.searchResultsDataSource = nil;
}

@end
