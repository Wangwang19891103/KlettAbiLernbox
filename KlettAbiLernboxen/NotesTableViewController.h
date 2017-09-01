//
//  NotesTableViewController.h
//  KlettAbiLernboxen
//
//  Created by Wang on 29.08.12.
//
//

#import <Foundation/Foundation.h>
#import "MySearchDisplayController.h"
#import "NotesTableModel.h"
#import "SectionHeader.h"
#import "CustomNavigationItem.h"



@interface NotesTableViewController : UITableViewController <UISearchDisplayDelegate, PropertyBoardChangeObserver> {
    
    NotesTableModel* _model;
    NotesTableModel* _filteredModel;
    
    UIImageView* __strong _zigzagImageView;

    SectionHeader* __strong _sectionHeaderView;

//    CustomNavigationItem* __strong _customNavigationItem;

}

@property (nonatomic, copy) NSString* categoryName;

@property (nonatomic, strong) MySearchDisplayController* mySearchDisplayController;

//@property (nonatomic, readonly) TableModelMode tableModelMode;

@property (nonatomic, copy) NSString* keyWords;
// only for starting the viewcontroller


- (id) initWithCategory:(NSString*) categoryName;

@end
