//
//  Contents2ViewController.h
//  KlettAbiLernboxen
//
//  Created by Wang on 28.08.12.
//
//

#import <Foundation/Foundation.h>
#import "MySearchDisplayController.h"
#import "Content2TableModel.h"
#import "SectionHeader.h"
#import "PropertyBoard.h"
#import "CustomNavigationItem.h"


@interface Contents2ViewController : UITableViewController <UISearchDisplayDelegate, PropertyBoardChangeObserver> {
    
    Content2TableModel* _model;
    Content2TableModel* _filteredModel;
    
    SectionHeader* __strong _sectionHeaderView;
    
    UIImageView* __strong _zigzagImageView;
    
    UISearchBar* __strong searchBar;
    
//    CustomNavigationItem* __strong _customNavigationItem;

}

@property (nonatomic, copy) NSString* categoryName;

@property (nonatomic, strong) MySearchDisplayController* mySearchDisplayController;

@property (nonatomic, readonly) TableModelMode tableModelMode;

@property (nonatomic, copy) NSString* keyWords;
// only for starting the viewcontroller


- (id) initWithCategory:(NSString*) categoryName tableModelMode:(TableModelMode) mode;

@end
