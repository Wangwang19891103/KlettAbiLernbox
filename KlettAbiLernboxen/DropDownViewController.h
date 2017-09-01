//
//  DropDownView.h
//  KlettAbiLernboxen
//
//  Created by Wang on 14.09.12.
//
//

#import <Foundation/Foundation.h>


/* forward */
@class DropDownHubView;
@class DropDownViewController;
@class DropDownWebView;


@protocol DropDownHubViewDelegate

- (void) hubViewWasTouched:(DropDownHubView*) hubView;

- (void) hubViewRequestedRefresh:(DropDownHubView*) hubView;

- (void) hubViewShouldExpand:(NSMutableArray*) hubViewStack;

- (void) hubViewShouldCollapse:(NSMutableArray*) hubViewStack;

@end




@protocol DropDownViewControllerDelegate

- (void) dropDownViewController:(DropDownViewController*) controller didChangeHeight:(float) height;

- (void) dropDownViewController:(DropDownViewController*) controller didSelectView:(UIView*) view;

@end




@interface DropDownViewController : UIViewController <DropDownHubViewDelegate> {
    
    NSArray* __strong _array;
    /*
     * structure:
     *
     * array
     *     array
     *         0: title: string (category)
     *         1: subContents: array
     * --------------------------------- alt 1
     *             title: string (page)
     * --------------------------------- alt 2
     *             array
     *                 0: title: string (subcat)
     *                 1: subContents: array
     *                     title: string (page)
     * ---------------------------------
     */
    
    NSMutableArray* __strong _views;
    
    UIImageView* _topSeperator;
    UIImageView* _bottomSeperator;
}

@property (nonatomic, assign) id<DropDownViewControllerDelegate> delegate;

@property (nonatomic, strong) UIFont* font;
@property (nonatomic, strong) UIFont* font2;


- (id) initWithArray:(NSArray*) theArray;

- (void) refreshViewAnimated:(BOOL) animated;

- (void) resetView;

- (void) expandHubView:(NSArray*) hubViewStack;

- (void) collapseHubView:(NSArray*) hubViewStack;

- (void) layout;

@end



@interface DropDownHubView : UIView <DropDownHubViewDelegate> {
    
    NSString* __strong _title;
    NSMutableArray* __strong _views;
    
    UILabel* __strong _titleLabel;
    
    uint _level;

}

@property (nonatomic, strong) UIFont* font;

@property (nonatomic, readonly) NSString* title;

@property (nonatomic, readonly) float totalHeight;

@property (nonatomic, readonly) float minimumHeight;

@property (nonatomic, assign) BOOL isExpanded;

@property (nonatomic, assign) id<DropDownHubViewDelegate> delegate;

@property (nonatomic, readonly) uint level;

@property (nonatomic, strong) UIImageView* imageView;



- (id) initWithTitle:(NSString*) title atLevel:(uint) level;

- (void) addView:(UIView*) view;

- (void) refreshViewAnimated:(BOOL) animated;

- (void) handleTap:(UIGestureRecognizer*) recognizer;

- (void) setExpanded:(BOOL) expanded;

- (void) resetView;
// collapses all levels recursively

- (void) scheduleCollapseAfterDelay:(float) delay;

- (void) expandHubView:(NSArray*) hubViewStack;

- (void) collapseHubView:(NSArray*) hubViewStack;


- (void) layoutAnimated;

//- (void) collapse;

- (void) adjustTitleLabel;


@end



@interface DropDownView : UIView {
    
    NSString* __strong _title;
    uint _level;
}

@property (nonatomic, strong) UIFont* font;



- (id) initWithTitle:(NSString*) title atLevel:(uint) level;

@end




@interface DropDownWebView : UIWebView <UIWebViewDelegate> {
    
    NSString* _htmlPath;
    uint _level;
}

@property (nonatomic, strong) UIFont* font;



- (id) initWithHTMLPath:(NSString*) path atLevel:(uint) level;

- (void) layoutAnimated;

@end
