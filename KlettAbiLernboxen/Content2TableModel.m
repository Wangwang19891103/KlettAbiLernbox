//
//  Content4TableModel.m
//  KlettAbiLernboxen
//
//  Created by Wang on 24.08.12.
//
//

#import "Content2TableModel.h"
#import "PDFManager.h"
#import "UserDataManager.h"
#import "Sorting.h"


@implementation Content2TableModel

@synthesize categoryName;
@synthesize mode;
@synthesize filtered;
@synthesize filterDict;


#pragma mark - Initializers

- (id) initWithCategory:(NSString *)theCategoryName mode:(TableModelMode) theMode filtered:(BOOL)theFiltered {
    
    if (self = [super init]) {
    
        categoryName = theCategoryName;
        mode = theMode;
        filtered = theFiltered;
        filterDict = (theFiltered) ? [NSDictionary dictionary] : nil;
        [self initialize];
    }
    
    return self;
}


//- (id) initWithModel:(Content4TableModel *)model pageFilter:(NSSet *)pageSet {
//    
//    if (self = [super init]) {
//        
//        categoryName = model.categoryName;
//        mode = model.mode;
//        _pageSet = pageSet;
//        [self initialize];
//    }
//    
//    return self;
//}
//
//
//- (Content4TableModel*) derivedModelWithPageFilter:(NSSet *)pageSet {
//    
//    return [[Content4TableModel alloc] initWithModel:self pageFilter:pageSet];
//}



#pragma mark - Private Methods

- (void) initialize {

    _data = nil;
    
    NSMutableArray* sectionsTemp = [NSMutableArray array];
    
    NSArray* subcategories = [[PDFManager manager] subcategoriesForCategory:self.categoryName];
    
    NSDictionary* sectionDict = nil;
    
    if (subcategories.count == 0) {
        
        sectionDict = [self populateDictForCategory];
        
        if (sectionDict.count != 0)
            [sectionsTemp addObject:sectionDict];
    }
    else {
        
        for (ContentsSubcategory* subcategory in subcategories) {
            
            sectionDict = [self populateDictForSubcategory:subcategory];

            if (sectionDict.count != 0)
                [sectionsTemp addObject:sectionDict];
        }
    }
    
    if (filtered) {
        
        _data = [sectionsTemp sortBySumUsingKey:@"hits" ascending:NO];
    }
    else {
    
        _data = sectionsTemp;
    }
    
//    NSLog(@"_data count: %d", _data.count);
}


- (NSDictionary*) populateDictForCategory {
    
    NSMutableDictionary* resultDict = [NSMutableDictionary dictionary];
    NSMutableArray* rowArray = [NSMutableArray array];
    
    NSArray* pages = [[PDFManager manager] pagesForCategory:self.categoryName];
    NSRange pageRange = [[PDFManager manager] pageRangeForCategory:self.categoryName];
    NSDictionary* userPages = [UserDataManager pagesForModule:[PDFManager manager].moduleName];
    
    NSMutableDictionary* pageDict = nil;
    
    for (ContentsPage* page in pages) {
        
        uint actualPageNumber = [[PDFManager manager] actualPageNumberForPosition:[page.position intValue]];
        
        Page* userPage = [userPages objectForKey:[NSNumber numberWithInt:actualPageNumber]];

        // if page filter exists and current page is not inside the page set -> dont add page to data
        if (filtered && ![filterDict objectForKey:[NSNumber numberWithInt:actualPageNumber]]) continue;
        
        if (mode == TableModelModeFavorites && !(userPage && [userPage.isFavorite boolValue]))
            continue;
        
        else if (mode == TableModelModeNotes && !(userPage && (userPage.notes.count != 0)))
            continue;
        
        
        pageDict = [NSMutableDictionary dictionary];
        [pageDict setObject:page.name forKey:@"title"];
        [pageDict setObject:page.position forKey:@"pageNumber"];
        
        if (filtered) {
            [pageDict setObject:[filterDict objectForKey:[NSNumber numberWithInt:actualPageNumber]] forKey:@"hits"];
        }
        
        if (userPage) {
            [pageDict setObject:userPage.isFavorite forKey:@"isFavorite"];
            [pageDict setObject:userPage.learnStatus forKey:@"learnStatus"];
        }
        else {
            [pageDict setObject:[NSNumber numberWithBool:FALSE] forKey:@"isFavorite"];
            [pageDict setObject:[NSNumber numberWithInt:0] forKey:@"learnStatus"];
        }
        
        [rowArray addObject:(NSDictionary*) pageDict];
    }
    
    if (rowArray.count != 0) {
        
        // if filtered -> sort row array
        if (filtered) {

            NSArray* sortedArray = [rowArray sortBySumUsingKey:@"hits" ascending:NO];
            
            [resultDict setObject:sortedArray forKey:@"rows"];
        }
        else {
            
            [resultDict setObject:(NSArray*)rowArray forKey:@"rows"];
        }
    }
    
    return resultDict;
}


- (NSDictionary*) populateDictForSubcategory:(ContentsSubcategory*) subcategory {
    
    NSMutableDictionary* resultDict = [NSMutableDictionary dictionary];
    NSMutableArray* rowArray = [NSMutableArray array];
    
    NSArray* pages = [[PDFManager manager] pagesForSubcategory:subcategory];
    NSRange pageRange = [[PDFManager manager] pageRangeForCategory:self.categoryName subcategory:subcategory.name];
    NSDictionary* userPages = [UserDataManager pagesForModule:[PDFManager manager].moduleName];
    
//    NSLog(@"pageRange: %d to %d, count: %d", pageRange.location, pageRange.location + pageRange.length - 1, userPages.count);
    
    NSMutableDictionary* pageDict = nil;
    
    for (ContentsPage* page in pages) {

        uint actualPageNumber = [[PDFManager manager] actualPageNumberForPosition:[page.position intValue]];
        
        Page* userPage = [userPages objectForKey:[NSNumber numberWithInt:actualPageNumber]];

        // if page filter exists and current page is not inside the page set -> dont add page to data
        if (filtered && ![filterDict objectForKey:[NSNumber numberWithInt:actualPageNumber]])
            continue;

        if (mode == TableModelModeFavorites && !(userPage && [userPage.isFavorite boolValue]))
            continue;
        
        else if (mode == TableModelModeNotes && !(userPage && (userPage.notes.count != 0)))
            continue;


        pageDict = [NSMutableDictionary dictionary];
        [pageDict setObject:page.name forKey:@"title"];
        [pageDict setObject:page.position forKey:@"pageNumber"];

        if (filtered) {
            [pageDict setObject:[filterDict objectForKey:[NSNumber numberWithInt:actualPageNumber]] forKey:@"hits"];
        }

        if (userPage) {
            [pageDict setObject:userPage.isFavorite forKey:@"isFavorite"];
            [pageDict setObject:userPage.learnStatus forKey:@"learnStatus"];
        }
        else {
            [pageDict setObject:[NSNumber numberWithBool:FALSE] forKey:@"isFavorite"];
            [pageDict setObject:[NSNumber numberWithInt:0] forKey:@"learnStatus"];
        }
        
        [rowArray addObject:(NSDictionary*) pageDict];
    }
    
    if (rowArray.count != 0) {
        
        // if filtered -> sort row array
        if (filtered) {
            
            NSArray* sortedArray = [rowArray sortBySumUsingKey:@"hits" ascending:NO];
            
            [resultDict setObject:subcategory.name forKey:@"title"];
            [resultDict setObject:sortedArray forKey:@"rows"];
        }
        else {
            
            [resultDict setObject:subcategory.name forKey:@"title"];
            [resultDict setObject:(NSArray*)rowArray forKey:@"rows"];
        }

//        [resultDict setObject:subcategory.name forKey:@"title"];
//        [resultDict setObject:(NSArray*)rowArray forKey:@"rows"];
    }
    
    return resultDict;
}


#pragma mark - TableModel Methods

- (uint) numberOfSections {
    
    return _data.count;
}


- (NSString*) titleForHeaderInSection:(uint)section {
    
    return [[_data objectAtIndex:section] objectForKey:@"title"];
}


- (uint) numberOfRowsInSection:(uint)section {
    
    return [[[_data objectAtIndex:section] objectForKey:@"rows"] count];
}


- (NSString*) titleForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    return [[[[_data objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row] objectForKey:@"title"];
}


- (void) reload {
    
    [self initialize];
}



#pragma mark - Public Methods

- (uint) pageNumberForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    return [[[[[_data objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row] objectForKey:@"pageNumber"] intValue];
}


- (BOOL) isFavoriteForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    return [[[[[_data objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row] objectForKey:@"isFavorite"] boolValue];
}


- (uint) learnStatusForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    return [[[[[_data objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row] objectForKey:@"learnStatus"] intValue];
}


- (uint) hitsForCellAtIndexPath:(NSIndexPath*) indexPath {
    
    return [[[[[_data objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row] objectForKey:@"hits"] intValue];
}


- (void) printData {
    
    NSLog(@"Content4TableModel:\n%@", _data);
}

@end
