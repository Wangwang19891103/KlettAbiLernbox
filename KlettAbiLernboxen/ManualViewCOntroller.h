//
//  ManualViewCOntroller.h
//  KlettAbiLernboxen
//
//  Created by Wang on 06.12.12.
//
//

#import <Foundation/Foundation.h>
#import "DropDownViewController.h"
#import "CustomNavigationItem.h"


@interface ManualViewCOntroller : UIViewController <DropDownViewControllerDelegate> {
    
    DropDownViewController* __strong _dropDownController;
    
//    CustomNavigationItem* __strong _customNavigationItem;

}

@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;

@property (nonatomic, strong) IBOutlet UIView* contentView;

@end
