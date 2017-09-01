//
//  Contents1ViewController.h
//  KlettAbiLernboxen
//
//  Created by Wang on 28.08.12.
//
//

#import <Foundation/Foundation.h>
#import "MySearchDisplayController.h"
#import "Content1TableModel.h"
#import "PropertyBoard.h"
#import "CustomNavigationItem.h"


@interface Contents1ViewController : UITableViewController <UISearchDisplayDelegate, PropertyBoardChangeObserver> {
    
    Content1TableModel* __strong _model;
    Content1TableModel* __strong _filteredModel;
    
    UIImageView* __strong _zigzagImageView;
    
    UISearchBar* __strong searchBar;

    BOOL _shadowInitialized;
    
//    CustomNavigationItem* __strong _customNavigationItem;

}

@property (nonatomic, strong) MySearchDisplayController* mySearchDisplayController;

@property (nonatomic, readonly) TableModelMode tableModelMode;


- (id) initWithTableModelMode:(TableModelMode) mode;

- (void) actionBack;

@end
