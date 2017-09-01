//
//  NotesTableModel.m
//  KlettAbiLernboxen
//
//  Created by Wang on 29.08.12.
//
//

#import "NotesTableModel.h"
#import "PDFManager.h"
#import "UserDataManager.h"


@implementation NotesTableModel

@synthesize categoryName;
//@synthesize mode;
@synthesize filtered;
@synthesize filterSet;


#pragma mark - Initializers

- (id) initWithCategory:(NSString *)theCategoryName filtered:(BOOL)theFiltered {
    
    if (self = [super init]) {
        
        categoryName = theCategoryName;
//        mode = theMode;
        filtered = theFiltered;
        filterSet = (theFiltered) ? [NSSet set] : nil;
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
    _currentSectionIndex = 0;
    _currentRowIndex = 0;
    
    NSMutableArray* sectionsTemp = [NSMutableArray array];
    
    _sectionIndexTitles = [NSMutableArray array];
    [_sectionIndexTitles addObject:@"{search}"];
    
    _indexPathsForSectionIndexTitles = [NSMutableArray array];    
    
    NSArray* subcategories = [[PDFManager manager] subcategoriesForCategory:self.categoryName];
    
    NSDictionary* sectionDict = nil;
    
    if (subcategories.count == 0) {
        
        sectionDict = [self populateDictForCategory];
        
        if (sectionDict.count != 0) {
            [sectionsTemp addObject:sectionDict];
            ++_currentSectionIndex;  // not really needed
        }
        
    }
    else {
        
        for (ContentsSubcategory* subcategory in subcategories) {
            
            _currentRowIndex = 0;
            
            sectionDict = [self populateDictForSubcategory:subcategory];
            
            if (sectionDict.count != 0) {
                [sectionsTemp addObject:sectionDict];
                ++_currentSectionIndex;
            }
        }
    }
    
    _data = sectionsTemp;
    
    NSLog(@"_data count: %d", _data.count);
}


- (NSDictionary*) populateDictForCategory {
    
    NSMutableDictionary* resultDict = [NSMutableDictionary dictionary];
    NSMutableArray* rowArray = [NSMutableArray array];
    
    NSArray* pages = [[PDFManager manager] pagesForCategory:self.categoryName];
//    NSDictionary* userPages = [UserDataManager pagesForModule:[PDFManager manager].moduleName category:self.categoryName];
//    NSRange pageRange = [[PDFManager manager] pageRangeForCategory:self.categoryName];
    NSDictionary* notes = [UserDataManager notesForModule:[PDFManager manager].moduleName];
    
    NSMutableDictionary* pageDict = nil;
    
    for (ContentsPage* page in pages) {
        
        uint actualPageNumber = [[PDFManager manager] actualPageNumberForPosition:[page.position intValue]];
        
//        Page* userPage = [userPages objectForKey:page.position];
        
        // if page filter exists and current page is not inside the page set -> dont add page to data
        if (filtered && ![filterSet member:[NSNumber numberWithInt:actualPageNumber]]) continue;
        
        for (uint t = 0; t <= 2; ++t) {
         
            NSArray* notesForDocumentType = [[notes objectForKey:[NSNumber numberWithInt:actualPageNumber]] objectForKey:[NSNumber numberWithInt:t]];
        
            for (Note* note in notesForDocumentType) {
            
                pageDict = [NSMutableDictionary dictionary];
                [pageDict setObject:page.name forKey:@"title"];
                [pageDict setObject:page.position forKey:@"pageNumber"];
                [pageDict setObject:note.page.isFavorite forKey:@"isFavorite"];
                [pageDict setObject:note.page.learnStatus forKey:@"learnStatus"];
                [pageDict setObject:[NSNumber numberWithInt:t] forKey:@"documentType"];
                [pageDict setObject:note.text forKey:@"noteText"];
                
                [rowArray addObject:(NSDictionary*) pageDict];
                
                NSString* pageNumberString = [NSString stringWithFormat:@"%@", page.position];
                
                if (![_sectionIndexTitles containsObject:pageNumberString]) {
                    [_sectionIndexTitles addObject:pageNumberString];
                    [_indexPathsForSectionIndexTitles addObject:[NSIndexPath indexPathForRow:_currentRowIndex inSection:_currentSectionIndex]];
                }
                
                ++_currentRowIndex;
            }
        }
    }
    
    if (rowArray.count != 0) {
        [resultDict setObject:(NSArray*)rowArray forKey:@"rows"];
    }
    
    return resultDict;
}


- (NSDictionary*) populateDictForSubcategory:(ContentsSubcategory*) subcategory {
    
    NSMutableDictionary* resultDict = [NSMutableDictionary dictionary];
    NSMutableArray* rowArray = [NSMutableArray array];
    
    NSArray* pages = [[PDFManager manager] pagesForSubcategory:subcategory];
//    NSRange pageRange = [[PDFManager manager] pageRangeForCategory:self.categoryName subcategory:subcategory.name];
//    NSDictionary* userPages = [UserDataManager pagesForModule:[PDFManager manager].moduleName category:self.categoryName inRange:pageRange];
//    NSRange pageRange = [[PDFManager manager] pageRangeForCategory:self.categoryName];
    NSDictionary* notes = [UserDataManager notesForModule:[PDFManager manager].moduleName];
    /* not perfect, fetching too many pages */
    
    //    NSLog(@"pageRange: %d to %d, count: %d", pageRange.location, pageRange.location + pageRange.length - 1, userPages.count);
    
    NSMutableDictionary* pageDict = nil;
    
    for (ContentsPage* page in pages) {
        
        uint actualPageNumber = [[PDFManager manager] actualPageNumberForPosition:[page.position intValue]];

        //        Page* userPage = [userPages objectForKey:page.position];
        
        // if page filter exists and current page is not inside the page set -> dont add page to data
        if (filtered && ![filterSet member:page.position]) continue;
        
        for (uint t = 0; t <= 2; ++t) {
            
            NSArray* notesForDocumentType = [[notes objectForKey:[NSNumber numberWithInt:actualPageNumber]] objectForKey:[NSNumber numberWithInt:t]];
            
            for (Note* note in notesForDocumentType) {
                
                pageDict = [NSMutableDictionary dictionary];
                [pageDict setObject:page.name forKey:@"title"];
                [pageDict setObject:page.position forKey:@"pageNumber"];
                [pageDict setObject:note.page.isFavorite forKey:@"isFavorite"];
                [pageDict setObject:note.page.learnStatus forKey:@"learnStatus"];
                [pageDict setObject:[NSNumber numberWithInt:t] forKey:@"documentType"];
                [pageDict setObject:note.text forKey:@"noteText"];
                [rowArray addObject:(NSDictionary*) pageDict];
                
                NSString* pageNumberString = [NSString stringWithFormat:@"%@", page.position];
                
                if (![_sectionIndexTitles containsObject:pageNumberString]) {
                    [_sectionIndexTitles addObject:pageNumberString];
                    [_indexPathsForSectionIndexTitles addObject:[NSIndexPath indexPathForRow:_currentRowIndex inSection:_currentSectionIndex]];
                }
                
                ++_currentRowIndex;
            }
        }
    }
    
    if (rowArray.count != 0) {
        [resultDict setObject:(NSArray*)rowArray forKey:@"rows"];
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


- (NSString*) noteTextForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    return [[[[_data objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row] objectForKey:@"noteText"];
}


- (uint) documentTypeForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    return [[[[[_data objectAtIndex:indexPath.section] objectForKey:@"rows"] objectAtIndex:indexPath.row] objectForKey:@"documentType"] intValue];
}


- (NSArray*) sectionIndexTitles {
    
//    alert(@"%@", _indexPathsForSectionIndexTitles);
    
    return _sectionIndexTitles;
}


- (NSIndexPath*) indexPathForSectionIndex:(uint)index {
    
    return [_indexPathsForSectionIndexTitles objectAtIndex:index];
}


- (void) printData {
    
    NSLog(@"Content4TableModel:\n%@", _data);
}

@end
