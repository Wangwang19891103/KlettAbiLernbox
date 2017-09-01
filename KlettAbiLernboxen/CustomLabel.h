//
//  CustomLabel.h
//  KlettAbiLernboxen
//
//  Created by Wang on 02.12.12.
//
//

#import <UIKit/UIKit.h>

@interface CustomLabel : UIView <PropertyBoardChangeObserver>

@property (nonatomic, copy) NSString* title;
@property (nonatomic, strong) UIFont* font;
@property (nonatomic, strong) UIColor* textColor;


- (id) initWithTitle:(NSString*) title;

- (void) update;


@end
