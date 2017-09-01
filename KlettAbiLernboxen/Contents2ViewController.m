//
//  Contents2ViewController.m
//  KlettAbiLernboxen
//
//  Created by Wang on 28.08.12.
//
//

#import "Contents2ViewController.h"
#import "UserDataManager.h"
#import "TableCells.h"
#import "DocumentViewController.h"
#import "PDFManager.h"
#import "NSArray+Extensions.h"
#import "NSSet+Extensions.h"
#import "ResourceManager.h"
#import "UIImage+Extensions.h"
#import "UIColor+Extensions.h"
#import "PropertyBoard.h"


#define SearchBar_Placeholder_String @"Suche"
#define Header_Section_Height 26.0f


@implementation Contents2ViewController

@synthesize mySearchDisplayController;
@synthesize tableModelMode;
@synthesize categoryName;
@synthesize keyWords;


#pragma mark - Initializers

- (id) initWithCategory:(NSString*) theCategoryName tableModelMode:(TableModelMode) mode {
    
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        
        categoryName = theCategoryName;
        tableModelMode = mode;
        _model = [[Content2TableModel alloc] initWithCategory:theCategoryName mode:mode filtered:FALSE];
        _filteredModel = [[Content2TableModel alloc] initWithCategory:theCategoryName mode:mode filtered:TRUE];
        
        _zigzagImageView = nil;
        
//        _customNavigationItem = [[CustomNavigationItem alloc] init];
//        _customNavigationItem.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0];
//        _customNavigationItem.textColor = [UIColor whiteColor];
//        _customNavigationItem.title = @"";
        
        [self.navigationItem setTitle:theCategoryName];
    }
    
    return self;
}


//- (UINavigationItem*) navigationItem {
//    
//    return _customNavigationItem;
//}


#pragma mark - View Lifecycle

- (void)viewDidLoad {
    
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
//    self.tableView.bounces = FALSE;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:resource(@"Images.TableViews.BackgroundPattern")];
    
//    self.mySearchDisplayController.searchResultsTableView.bounces = FALSE;
    
    
//    UIImage* backgroundImage = resource(@"Images.TableViews.BackgroundPattern");
//    backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsZero];
//    
//    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
//    self.tableView.backgroundView.frame = CGRectMake(0, 0, 320, 480);
//    self.tableView.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    
    if (self.keyWords) {

        [self.searchDisplayController setActive:TRUE];
        self.mySearchDisplayController.searchBar.text = self.keyWords;
        
//        // set cancel button active
//        for (UIView *possibleButton in searchBar.subviews) {
//            
//            if ([possibleButton isKindOfClass:[UIButton class]]) {
//                
//                UIButton *cancelButton = (UIButton*)possibleButton;
//                cancelButton.enabled = YES;
//                
//                break;
//            }
//        }
    }
    
    UIColor* barColor = [[ModuleManager manager] colorForModule:[PDFManager manager].moduleName];
    
    barColor = [barColor colorWithSaturationFactor:PBintVarValue(@"pattern saturation") * 0.01];
    
    _sectionHeaderView = [[SectionHeader alloc] init];
    UIImage* patternImage = resource(@"Images.TableViews.LinedPattern");
    patternImage = [patternImage imageWithAdjustmentColor:[barColor colorByDarkingByPercent:0.3]];
    patternImage = [patternImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    _sectionHeaderView.backgroundImage.image = patternImage;

    [mySearchDisplayController.searchBar setBackgroundImage:patternImage];
    
    
    patternImage = resource(@"Images.TableViews.ZigzagPattern");
    patternImage = [patternImage imageWithAdjustmentColor:[barColor colorByDarkingByPercent:0.3]];
    patternImage = [patternImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];

    if ([self tableView:nil heightForHeaderInSection:0] == 0) {
        
        _zigzagImageView = [[UIImageView alloc] initWithImage:patternImage];
        _zigzagImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_zigzagImageView setFrameWidth:self.view.bounds.size.width];
        [_zigzagImageView setFrameY:searchBar.frame.size.height];
        [searchBar addSubview:_zigzagImageView];
    }
    else {
        _sectionHeaderView.zigzagImage.image = patternImage;
        
        /* dashed line */
        
        UIImage* dashedImage = resource(@"Images.Misc.PatternDashed");
        dashedImage = [dashedImage imageWithAdjustmentColor:[barColor colorByDarkingByPercent:0.3]];
        dashedImage = [dashedImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        UIImageView* dashedView = [[UIImageView alloc] initWithImage:dashedImage];
        dashedView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        dashedView.frame = CGRectMake(0, mySearchDisplayController.searchBar.bounds.size.height - dashedImage.size.height, self.view.bounds.size.width, dashedImage.size.height);
        [mySearchDisplayController.searchBar addSubview:dashedView];
    }
    
//    [[PropertyBoard instance] addChangeObserver:self];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}


- (void) variableValueChangedForName:(NSString *)name {

    UIColor* barColor = [[ModuleManager manager] colorForModule:[PDFManager manager].moduleName];
//    barColor = [barColor colorByDarkingByPercent:0.3];
    barColor = [barColor colorWithSaturationFactor:PBintVarValue(@"pattern saturation") * 0.01];
//    barColor = [barColor colorWithBrightnessFactor:PBintVarValue(@"brightness") * 0.01];
    
    _sectionHeaderView = [[SectionHeader alloc] init];
    UIImage* patternImage = resource(@"Images.TableViews.LinedPattern");
    patternImage = [patternImage imageWithAdjustmentColor:barColor];
    patternImage = [patternImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    _sectionHeaderView.backgroundImage.image = patternImage;

    patternImage = resource(@"Images.TableViews.ZigzagPattern");
    patternImage = [patternImage imageWithAdjustmentColor:barColor];
    patternImage = [patternImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    _sectionHeaderView.zigzagImage.image = patternImage;

    if ([self tableView:nil heightForHeaderInSection:0] == 0) {
        [_zigzagImageView removeFromSuperview];
        _zigzagImageView = [[UIImageView alloc] initWithImage:patternImage];
        _zigzagImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_zigzagImageView setFrameWidth:320];
        [_zigzagImageView setFrameY:searchBar.frame.size.height];
        [searchBar addSubview:_zigzagImageView];
    }
    
    UIImage* bgImage = resource(@"Images.TableViews.LinedPattern");
    bgImage = [bgImage imageWithAdjustmentColor:barColor];
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [searchBar setBackgroundImage:bgImage];
    
    
    [searchBar setNeedsDisplay];
    
    [self.tableView reloadData];
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [_model reload];
    [_filteredModel reload];
    
    [self.tableView reloadData];
    
    if (self.mySearchDisplayController.active) {
        [self.mySearchDisplayController.searchResultsTableView reloadData];
    }
    
    [self.tableView bringSubviewToFront:self.mySearchDisplayController.searchResultsTableView];
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
            
            if ([cell isKindOfClass:[CardCell class]]) {
                
                [(CardCell*)cell setCellSelected:false];
            }
            else if ([cell isKindOfClass:[CardResultCell class]]) {
                
                [(CardResultCell*)cell setCellSelected:false];
            }
        }
    }
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
    
    if (tableView == self.mySearchDisplayController.searchResultsTableView) {

        return [_filteredModel numberOfSections];
    }
    else {

        return [_model numberOfSections];
    }
}


- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (tableView == self.mySearchDisplayController.searchResultsTableView) {

        return [_filteredModel titleForHeaderInSection:section];
    }
    else {

        return [_model titleForHeaderInSection:section];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    Content2TableModel* model = nil;
    
    if (tableView == self.mySearchDisplayController.searchResultsTableView) {
        
        model = _filteredModel;
    }
    else {
        
        model = _model;
    }

    return [model numberOfRowsInSection:section];
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if ([self tableView:tableView titleForHeaderInSection:section]) {

        return Header_Section_Height;
    }
    else return 0;
}


- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    SectionHeader* headerView = [_sectionHeaderView copy];
    headerView.titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    return headerView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return (is_ipad) ? 72 : 48;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableModelMode == TableModelModeNotes || (tableView == self.mySearchDisplayController.searchResultsTableView)) {
     
        CardResultCell* cell = (CardResultCell*)[tableView dequeueReusableCellWithIdentifier:@"cardResultCell"];
        
        if (!cell) {
            
            cell = [[CardResultCell alloc] init];
        }
        
        Content2TableModel* model = (tableView == self.mySearchDisplayController.searchResultsTableView) ? _filteredModel : _model;
        
        uint pageNumber = [model pageNumberForCellAtIndexPath:indexPath];
        NSString* pageTitle = [model titleForCellAtIndexPath:indexPath];
        BOOL isFavorite = [model isFavoriteForCellAtIndexPath:indexPath];
        PageLearnStatus learnStatus = [model learnStatusForCellAtIndexPath:indexPath];
        uint hits = [model hitsForCellAtIndexPath:indexPath];

        cell.title = pageTitle;
        cell.pageNumber = pageNumber;
        cell.isFavorite = isFavorite;
        cell.learnStatus = learnStatus;
        cell.hits = hits;
        
        return cell;
    }
    else {
        
        CardCell* cell = (CardCell*)[tableView dequeueReusableCellWithIdentifier:@"cardCell"];
        
        if (!cell) {
            
            cell = [[CardCell alloc] init];
        }
        
        uint pageNumber = [_model pageNumberForCellAtIndexPath:indexPath];
        NSString* pageTitle = [_model titleForCellAtIndexPath:indexPath];
        BOOL isFavorite = [_model isFavoriteForCellAtIndexPath:indexPath];
        PageLearnStatus learnStatus = [_model learnStatusForCellAtIndexPath:indexPath];
        
        cell.title = pageTitle;
        cell.pageNumber = pageNumber;
        cell.isFavorite = isFavorite;
        cell.learnStatus = learnStatus;
        
        return cell;
    }
}



#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    uint pageNumber;
    
    if (tableView == self.mySearchDisplayController.searchResultsTableView) {

        pageNumber = [_filteredModel pageNumberForCellAtIndexPath:indexPath];
    }
    else {

        pageNumber = [_model pageNumberForCellAtIndexPath:indexPath];
    }
    
    DocumentViewController* controller = [[DocumentViewController alloc] initWithCategory:self.categoryName pageNumber:pageNumber];
//    controller.keywords = [self.mySearchDisplayController.searchBar.text componentsSeparatedByString:@" "];

    /* back button title */
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Zurück"
                                   style: UIBarButtonItemStylePlain
                                   target: nil
                                   action: nil];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    
    // set cell selected
    CardCell* cell = (CardCell*)[tableView cellForRowAtIndexPath:indexPath];
    [cell setCellSelected:true];
    
    [self.navigationController pushViewController:controller animated:TRUE];
}



#pragma mark - UISearchDisplayControllerDelegate

- (void) searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)theTableView {
    
//    theTableView.bounces = FALSE;
    [theTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [theTableView setBackgroundColor:[UIColor colorWithPatternImage:resource(@"Images.TableViews.BackgroundPattern")]];
}


- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    
    return TRUE;
}


- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    
    NSLog(@"SDC should reload table for search string: %@", searchString);
    
//    for (UIView* view in controller.searchResultsTableView.subviews) {
//        if ([view isKindOfClass: [UILabel class]]
//            //            && [[(UILabel*)view text] isEqualToString:@"No Results"]
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
    
    NSLog(@"results all strings:\n%@", [results strings]);
    NSLog(@"results all page numbers:\n%@", [results pageNumbersForAllStrings]);
    
    
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
    
    NSLog(@"Contents2ViewController DEALLOC");
    
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    self.mySearchDisplayController.delegate = nil;
    self.mySearchDisplayController.searchResultsDelegate = nil;
    self.mySearchDisplayController.searchResultsDataSource = nil;
}

@end
