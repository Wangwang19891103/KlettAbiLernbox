//
//  Content3TableModel.m
//  KlettAbiLernboxen
//
//  Created by Wang on 27.08.12.
//
//

#import "Content1TableModel.h"
#import "PDFManager.h"
#import "UserDataManager.h"
#import "Sorting.h"


@implementation Content1TableModel

@synthesize mode;
@synthesize filtered;
@synthesize filterDict;


#pragma mark - Initializers

- (id) initWithMode:(TableModelMode)theMode filtered:(BOOL)theFiltered {
    
    if (self = [super init]) {

        mode = theMode;
        filtered = theFiltered;
        filterDict = (theFiltered) ? [NSDictionary dictionary] : nil;
        [self initialize];
    }
    
    return self;
}


#pragma mark - Private Methods

- (void) initialize {

    NSMutableArray* rowsTemp = [NSMutableArray array];
    
    NSArray* categories = [[PDFManager manager] categories];
    
    NSMutableDictionary* rowDict = nil;
    
    for (ContentsCategory* category in categories) {

        NSRange pageRange = [[PDFManager manager] pageRangeForCategory:category.name];
        NSArray* pages = [[PDFManager manager] pagesForCategory:category.name];
        NSDictionary* userPages = [UserDataManager pagesForModule:[PDFManager manager].moduleName];

        uint relevantCount = 0;
        uint hitCount = 0;
        
        for (ContentsPage* page in pages) {
            
            uint actualPageNumber = [[PDFManager manager] actualPageNumberForPosition:[page.position intValue]];
            
            Page* userPage = [userPages objectForKey:[NSNumber numberWithInt:actualPageNumber]];

            // if page filter exists and current page is not inside the page set -> dont add page to data
            if (filtered && ![filterDict objectForKey:[NSNumber numberWithInt:actualPageNumber]]) continue;
            
            if (mode == TableModelModeFavorites && !(userPage && [userPage.isFavorite boolValue]))
                continue;
            
            else if (mode == TableModelModeNotes && !(userPage && (userPage.notes.count != 0)))
                continue;
            
            ++relevantCount;
            
            if (filtered) {
                hitCount += [[filterDict objectForKey:[NSNumber numberWithInt:actualPageNumber]] intValue];
            }
            else if (mode == TableModelModeNotes) {
                hitCount += userPage.notes.count;
            }
        }

        if (relevantCount != 0) {
            rowDict = [NSMutableDictionary dictionary];
            [rowDict setObject:category.name forKey:@"title"];
            [rowDict setObject:NSStringFromRange(pageRange) forKey:@"pageRange"];
            [rowDict setObject:[NSNumber numberWithInt:relevantCount] forKey:@"pageHits"];
            [rowDict setObject:[NSNumber numberWithInt:hitCount] forKey:@"hits"];
            [rowsTemp addObject:rowDict];
        }
        
        NSLog(@"category: %@ - relevantCount: %d", category.name, relevantCount);
    }

    // if filtered -> sort by hitCount
    if (filtered) {
        
        _data = [rowsTemp sortBySumUsingKey:@"hits" ascending:NO];
    }
    else {
        
        _data = rowsTemp;
    }
}



#pragma mark - TableModel Methods

- (uint) numberOfSections {
    
    return 1;
}


- (NSString*) titleForHeaderInSection:(uint)section {
    
    return nil;
}


- (uint) numberOfRowsInSection:(uint)section {
    
    return _data.count;
}


- (NSString*) titleForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    return [[_data objectAtIndex:indexPath.row] objectForKey:@"title"];
}


- (NSRange) pageRangeForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    return NSRangeFromString([[_data objectAtIndex:indexPath.row] objectForKey:@"pageRange"]);
}


- (uint) pageHitsForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    if (filtered || mode == TableModelModeNotes) {

        return [[[_data objectAtIndex:indexPath.row] objectForKey:@"pageHits"] intValue];
    }
    else return -1;
}


- (uint) hitsForCellAtIndexPath:(NSIndexPath *)indexPath {

    if (filtered || mode == TableModelModeNotes) {
        
        return [[[_data objectAtIndex:indexPath.row] objectForKey:@"hits"] intValue];
    }
    else return -1;
}


- (void) reload {
    
    _data = nil;
    [self initialize];
}


@end
