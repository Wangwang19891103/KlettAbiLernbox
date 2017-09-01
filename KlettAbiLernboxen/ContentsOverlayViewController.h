//
//  ContentsOverlayViewController.h
//  KlettAbiLernboxen
//
//  Created by Wang on 23.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContentsOverlayViewController : UIViewController {
    
    NSMutableArray* __strong _pageLabels;
    
    NSMutableArray* __strong _pageNumberLabels;
    
    UILabel* __weak _activePageLabel;
    
    UILabel* __weak _activePageNumberLabel;
    
    uint _currentPage;
    
    UIFont* _categoryFont;
    UIFont* _pageFont;
    UIColor* _categoryColor;
    UIColor* _pageColor;
    UIColor* _pageColorHighlighted;
}

@property (nonatomic, copy) NSString* categoryName;

@property (nonatomic, strong) IBOutlet UIView* containerView;

@property (nonatomic, strong) IBOutlet UIImageView* containerBackgroundImageView;

@property (nonatomic, strong) UIScrollView* scrollView;

@property (nonatomic, strong) UIScrollView* scrollView2;

@property (nonatomic, strong) UIView* contentView;

@property (nonatomic, strong) UIView* contentView2;


- (id) initWithCategory:(NSString*) categoryName pageNumber:(uint) pageNumber;

- (void) highlightPageNumber:(uint) pageNumber;

- (void) scrollRectToVisible:(CGRect) rect withHorizontalMargin:(uint) marginH verticalMargin:(uint) marginV preferTop:(BOOL) preferTop;

@end




