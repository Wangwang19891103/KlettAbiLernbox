//
//  CustomNavigationItem.h
//  KlettAbiLernboxen
//
//  Created by Wang on 02.12.12.
//
//

#import <UIKit/UIKit.h>

@interface CustomNavigationItem : UINavigationItem


//@property (nonatomic, copy) NSString* title;
@property (nonatomic, strong) UIFont* font;
@property (nonatomic, strong) UIColor* textColor;

- (void) updateTitleView;

@end
