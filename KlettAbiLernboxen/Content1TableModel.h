//
//  Content3TableModel.h
//  KlettAbiLernboxen
//
//  Created by Wang on 27.08.12.
//
//

#import <Foundation/Foundation.h>
#import "TableModel.h"


@interface Content1TableModel : NSObject <TableModel> {
    
    NSArray* __strong _data;
    /* structure for _data:
     * rows (array)
     *     rowDict (dict)
     *         title (string)
     *         pageRange (range)
     *         hits (int)  (optional)
     *         pageHits (int)  (optional)
     */
    
}

@property (nonatomic, readonly) TableModelMode mode;

@property (nonatomic, readonly) BOOL filtered;

@property (nonatomic, strong) NSDictionary* filterDict;



- (id) initWithMode:(TableModelMode) theMode  filtered:(BOOL) filtered;

- (NSRange) pageRangeForCellAtIndexPath:(NSIndexPath*) indexPath;

- (uint) pageHitsForCellAtIndexPath:(NSIndexPath*) indexPath;

- (uint) hitsForCellAtIndexPath:(NSIndexPath*) indexPath;



@end
