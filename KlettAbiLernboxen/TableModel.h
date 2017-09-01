//
//  TableModel.h
//  KlettAbiLernboxen
//
//  Created by Wang on 27.08.12.
//
//

#import <Foundation/Foundation.h>


typedef enum {
    TableModelModeAll,
    TableModelModeNotes,
    TableModelModeFavorites
} TableModelMode;



@protocol TableModel <NSObject>

- (uint) numberOfSections;

- (NSString*) titleForHeaderInSection:(uint) section;

- (uint)numberOfRowsInSection:(uint) section;

- (NSString*) titleForCellAtIndexPath:(NSIndexPath*) indexPath;

- (void) reload;

@end
