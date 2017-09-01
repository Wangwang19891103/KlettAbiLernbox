//
//  ThumbnailsView.h
//  KlettAbiLernboxen
//
//  Created by Wang on 08.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class OverlayView;
@class ThumbnailsContentView;
@protocol ThumbnailDelegate;


@interface ThumbnailsViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;

@property (nonatomic, strong) IBOutlet OverlayView* overlayView;
//@property (nonatomic, strong) IBOutlet OverlayView* overlayViewRight;

@property (nonatomic, strong) ThumbnailsContentView* contentView;

@property (nonatomic, assign) id<ThumbnailDelegate> delegate;

- (id) init;

- (void) layout;

- (void) reportPage;

- (void) scrollToPage:(uint) page animated:(BOOL) animated;

- (IBAction) handleTap:(UIGestureRecognizer*) recognizer;

@end

@interface OverlayView : UIView

@property (nonatomic, weak) IBOutlet UIScrollView* scrollView;

@end


@interface Thumbnails222222222222ContentView : UIView

@end

@interface ThumbnailScrollView : UIScrollView

@end


@protocol ThumbnailDelegate

- (void) thumbnailWasSelectedForPage:(uint) page;

- (void) thumbnailWillBeginDragging;
- (void) thumbnailDidEndDragging;
- (void) thumbnailDidHitPageNumber:(uint) pageNumber;

@end
