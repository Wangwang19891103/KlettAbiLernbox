//
//  Content4TableModel.h
//  KlettAbiLernboxen
//
//  Created by Wang on 24.08.12.
//
//

#import <Foundation/Foundation.h>
#import "TableModel.h"




@interface Content2TableModel : NSObject <TableModel> {
    
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
}

@property (nonatomic, copy) NSString* categoryName;

@property (nonatomic, readonly) TableModelMode mode;

@property (nonatomic, readonly) BOOL filtered;

@property (nonatomic, strong) NSDictionary* filterDict;


- (id) initWithCategory:(NSString *)theCategoryName mode:(TableModelMode) theMode filtered:(BOOL) filtered;

- (uint) pageNumberForCellAtIndexPath:(NSIndexPath*) indexPath;

- (BOOL) isFavoriteForCellAtIndexPath:(NSIndexPath*) indexPath;

- (uint) learnStatusForCellAtIndexPath:(NSIndexPath*) indexPath;

- (uint) hitsForCellAtIndexPath:(NSIndexPath*) indexPath;


- (void) printData;

@end
