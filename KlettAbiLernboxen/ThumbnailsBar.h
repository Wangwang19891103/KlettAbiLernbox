//
//  ThumbnailsBar.h
//  KlettAbiLernboxen
//
//  Created by Wang on 19.11.12.
//
//

#import <UIKit/UIKit.h>
#import "ThumbnailsContentView.h"
#import "ThumbnailBarDelegate.h"


@interface ThumbnailsBar : UIView <UIScrollViewDelegate, PropertyBoardChangeObserver> {
    
    UIImage* __strong _backgroundImage;
    UIImage* __strong _selectionImage;
    
    ThumbnailsContentView* __strong _contentView;
    
    NSMutableArray* __strong _thumbnails;
}

@property (nonatomic, strong) UIScrollView* scrollView;

@property (nonatomic, assign) id<ThumbnailBarDelegate> delegate;

@property (nonatomic, readonly) uint pageNumber;

@property (nonatomic, strong) UIColor* blendColor;


- (void) layout;

- (void) scrollToPage:(uint) page animated:(BOOL) animated;

- (void) setImages:(NSArray*) images;

- (void) handleTap:(UIGestureRecognizer*) recognizer;

@end
