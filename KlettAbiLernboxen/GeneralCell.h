//
//  GeneralCell.h
//  KlettAbiLernboxen
//
//  Created by Wang on 06.12.12.
//
//

#import <UIKit/UIKit.h>

@interface GeneralCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, strong) IBOutlet UIImageView* backgroundView;


- (void) setCellSelected:(BOOL)selected;

@end
