//
//  PropertyBoardViewController.h
//  KlettAbiLernboxen
//
//  Created by Wang on 15.10.12.
//
//

#import <Foundation/Foundation.h>
#import "PropertyBoardChangeObserver.h"


#pragma mark - PropertyBoardViewController

@interface PropertyBoardViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PropertyBoardChangeObserver> {
}

@property (nonatomic, strong) IBOutlet UITableView* tableView;


@end



#pragma mark - PropertyTableViewCell

@interface PropertyTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* typeLabel;

@property (nonatomic, strong) IBOutlet UILabel* classLabel;

@property (nonatomic, strong) IBOutlet UILabel* valueLabel;

@end
