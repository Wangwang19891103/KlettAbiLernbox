//
//  ModuleViewController.h
//  KlettAbiLernboxen
//
//  Created by Wang on 10.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModuleCell.h"
#import "PropertyBoard.h"
#import "CustomNavigationItem.h"
#import "SectionHeader.h"
#import "UAStoreKitObserver.h"


@interface ModuleViewController : UITableViewController <ModuleCellDelegate, PropertyBoardChangeObserver,UIAlertViewDelegate, UAStoreFrontObserverProtocol, UAStoreKitObserverDelegate> {
    
//    NSArray* __strong _modulesArray;
    
    NSMutableArray* __strong _moduleCells;
    
//    CustomNavigationItem* __strong _customNavigationItem;
    
    SectionHeader* __strong _sectionHeaderView;

    UIImageView* __strong _zigzagImageView;

//    UIImageView* __strong _logoImageView;
    
    UAProduct* __weak _lastProduct;
    uint _alertID;
    
    UIBarButtonItem* _restoreItem;
    
    BOOL _restoring;
}



@end




