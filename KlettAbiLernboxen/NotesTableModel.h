//
//  NotesTableModel.h
//  KlettAbiLernboxen
//
//  Created by Wang on 29.08.12.
//
//

#import <Foundation/Foundation.h>
#import "TableModel.h"




@interface NotesTableModel : NSObject <TableModel> {
    
    NSArray* __strong _data;
    /* structure for _data:
     * sections (array)
     *     sectionDict (dict)
     *         title (string, optional)
     *         rows (array)
     *             rowDict (dict)
     *                 title (string)
     *                 pageNumber (int)
     *                 isFavorite (bool)
     *                 learnStatus (int)
     */
    
    //    NSSet* __strong _pageSet;
    
    NSMutableArray* __strong _sectionIndexTitles;
    
    NSMutableArray* __strong _indexPathsForSectionIndexTitles;
    
    uint _currentSectionIndex;
    uint _currentRowIndex;
}

@property (nonatomic, copy) NSString* categoryName;

//@property (nonatomic, readonly) TableModelMode mode;

@property (nonatomic, readonly) BOOL filtered;

@property (nonatomic, strong) NSSet* filterSet;


- (id) initWithCategory:(NSString *)theCategoryName filtered:(BOOL) filtered;

- (uint) pageNumberForCellAtIndexPath:(NSIndexPath*) indexPath;

- (BOOL) isFavoriteForCellAtIndexPath:(NSIndexPath*) indexPath;

- (uint) learnStatusForCellAtIndexPath:(NSIndexPath*) indexPath;

- (NSString*) noteTextForCellAtIndexPath:(NSIndexPath*) indexPath;

- (uint) documentTypeForCellAtIndexPath:(NSIndexPath*) indexPath;

- (NSArray*) sectionIndexTitles;

- (NSIndexPath*) indexPathForSectionIndex:(uint) index;


- (void) printData;

@end
