//
//  CustomProductDetailViewController.h
//  KlettAbiLernboxen
//
//  Created by Wang on 14.09.12.
//
//

#import "UAProductDetailViewController.h"
#import "DropDownViewController.h"
#import "ModuleManager.h"

@interface CustomProductDetailViewController : UIViewController <ModuleManagerObserver, DropDownViewControllerDelegate, UIWebViewDelegate, UIAlertViewDelegate> {
    
    DropDownViewController* __strong _dropDownController;
    
}

- (id) initWithModule:(NSString*) moduleName;

@property (nonatomic, copy) NSString* moduleName;

@property (nonatomic, retain) UAProduct* product;

@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;

@property (nonatomic, strong) IBOutlet UIView* contentView;

@property (nonatomic, strong) IBOutlet UIWebView* webView;

@property (nonatomic, strong) IBOutlet UIView* dropDownView;

@property (strong, nonatomic) IBOutlet UIImageView *iconImageView;

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, strong) IBOutlet UILabel* priceLabel;

@property (nonatomic, strong) IBOutlet UIButton* button;

- (IBAction) purchase:(id) sender;

@end
