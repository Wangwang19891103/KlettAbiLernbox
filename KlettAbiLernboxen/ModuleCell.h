//
//  ModuleCell.h
//  KlettAbiLernboxen
//
//  Created by Wang on 17.10.12.
//
//

#import <Foundation/Foundation.h>
#import "UAStoreFront.h"
#import "ModuleManager.h"
//#import "UAProduct.h"


@class ModuleCell;



@protocol ModuleCellDelegate

- (void) moduleCellDidRequestShop:(ModuleCell* ) cell;

@end



@interface ModuleCell : UITableViewCell <
ModuleManagerObserver>


@property (nonatomic, copy) NSString* moduleName;



//@property (nonatomic, strong) NSString* productID;

@property (nonatomic, assign) ModuleInstallationStatus contentInstallationStatus;

@property (nonatomic, strong) IBOutlet UILabel* moduleTitleLabel;

@property (nonatomic, strong) IBOutlet UITextView* descriptionTextView;

@property (nonatomic, strong) IBOutlet UILabel* priceLabel;

@property (nonatomic, strong) IBOutlet UIImageView* moduleImageView;

@property (nonatomic, strong) IBOutlet UILabel* statusLabel;

@property (nonatomic, strong) IBOutlet UILabel* progressLabel;

@property (nonatomic, weak) UAProduct* product;

@property (nonatomic, strong) IBOutlet UIButton* shopButton;

@property (nonatomic, strong) IBOutlet UIButton* buyButton;

@property (nonatomic, assign) id<ModuleCellDelegate> delegate;

@property (nonatomic, strong) IBOutlet UIImageView* backgroundImageView;

@property (nonatomic, strong) IBOutlet UIImageView* learningProgressBarImageView;

@property (nonatomic, strong) IBOutlet UILabel* learningProgressLabel;

@property (nonatomic, strong) IBOutlet UILabel* learningProgressLabel2;


+ (ModuleCell*) cellWithModuleDict:(NSDictionary*) dict;

- (void) refreshView;

- (void) layout;

- (IBAction) actionShop;

- (IBAction) purchase:(id) sender;

- (void) setCellSelected:(BOOL)selected;

@end



@interface ModuleImage : UIImage

+ (ModuleImage*) imageWithText:(NSString*) text color:(UIColor*) color;

@end
