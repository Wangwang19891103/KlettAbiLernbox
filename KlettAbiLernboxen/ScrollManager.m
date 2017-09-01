//
//  ScrollManager.m
//  Sprachenraetsel
//
//  Created by Wang on 17.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScrollManager.h"
#import "UIView+Extensions.h"
//#import "ViewLineLayoutManager.h"
#import "TranslateIdiom.h"


// global constants

NSString* const ScrollManagableInputFieldShouldScrollToVisibleRange =  @"ScrollManagableInputFieldShouldScrollToVisibleRange";
NSString* const ScrollManagableInputFieldDidBeginEditing = @"ScrollManagableInputFieldDidBeginEditing";
NSString* const ScrollManagableInputFieldShouldEndEditing = @"ScrollManagableInputFieldShouldEndEditing";
NSString* const ScrollManagableInputFieldDidReceiveInput = @"ScrollManagableInputFieldDidReceiveInput";



#define KEYBOARD_POSITION_Y ((is_ipad) ? (1024 - 264) : (480 - 216))  // keyboard height: 216 // ipad = 264
#define OFFSET_TOP ti_relInt(10, TranslateIdiomAlignmentVertical)
#define OFFSET_BOTTOM ti_relInt(10, TranslateIdiomAlignmentVertical)



@implementation ScrollManager

@synthesize isScrolling = _isScrolling;
@synthesize scrollView;


#pragma mark Initializers

- (id) init {
    
    if ((self = [super init])) {
        


//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScrollViewToVisibleRange:) name:ScrollManagerShouldScrollViewToVisibleRange object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInputFieldDidBeginEditing:) name:ScrollManagableInputFieldDidBeginEditing object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScrollViewToVisibleRange:) name:ScrollManagableInputFieldShouldScrollToVisibleRange object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScrollViewToVisibleRange:) name:ScrollManagableInputFieldDidReceiveInput object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScrollViewWillScroll) name:@"UITextSelectionWillScroll" object:scrollView];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScrollViewDidScroll) name:@"UITextSelectionDidScroll" object:scrollView];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScrollViewWillStartSmoothScrolling) name:@"WillStartSmoothScrolling" object:scrollView];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleScrollViewDidEndSmoothScrolling) name:@"DidEndSmoothScrolling" object:scrollView];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow) name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];

//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(testNotification:) name:nil object:_scrollView];
        
        _isScrolling = FALSE;
        _isSmoothScrolling = FALSE;
        
        CGPoint relativePointScrollViewToWindow = [scrollView.superview convertPoint:scrollView.frame.origin toView:scrollView.window];
        
//        NSLog(@"scrollview: %@\nsuperview: %@\nwindow: %@", _scrollView, _scrollView.superview, _scrollView.window);
        
        _visibleHeightWithKeyboard = KEYBOARD_POSITION_Y - relativePointScrollViewToWindow.y;
        
        _originalHeight = scrollView.frame.size.height;
        
//        NSLog(@"visible height: %d, relative y: %f", _visibleHeightWithKeyboard, relativePointScrollViewToWindow.y);
    }
    
    return self;
}

     
#pragma mark Handler Methods

- (void) handleInputFieldDidBeginEditing:(NSNotification *)notification {
    
    _isEditing = TRUE;
    
    id sender = (UIView*)[notification object];
    UIView* scrollManagedView = [(id<ScrollManagableInputField>)sender scrollManagedView];
    
//    NSLog(@"scrolling view to visible range: %@", scrollManagedView);
    
    [self scrollViewToVisibleRange:scrollManagedView];
}

- (void) handleScrollViewToVisibleRange:(NSNotification *)notification {

//    NSLog(@"handdle scroll view to visible range, for view: %@", [notification object]);
    
    id sender = (UIView*)[notification object];
    UIView* scrollManagedView = [(id<ScrollManagableInputField>)sender scrollManagedView];
    
    NSLog(@"scrolling view to visible range: %@", scrollManagedView);
    
    [self scrollViewToVisibleRange:scrollManagedView];
}


#pragma mark ScrollView Handlers

- (void) handleScrollViewWillScroll {
    
//    NSLog(@"will scroll");
    
    _isScrolling = TRUE;
    
    NSLog(@"start (%@)", scrollView);
}

- (void) handleScrollViewDidScroll {
    
//    NSLog(@"did scroll");
    
    if (!_isSmoothScrolling) {
        _isScrolling = FALSE;
        NSLog(@"stop");
    }
}

- (void) handleScrollViewWillStartSmoothScrolling {
    
//    NSLog(@"start smooth scrolling");
    
    _isSmoothScrolling = TRUE;
}

- (void) handleScrollViewDidEndSmoothScrolling {
    
//    NSLog(@"end smooth scrolling");
    
    _isSmoothScrolling = FALSE;
    _isScrolling = FALSE;
    NSLog(@"stop");
}

- (void) testNotification:(NSNotification *)notification {

    NSLog(@"%@", [notification name]);
}


#pragma mark Keyboard Handlers

- (void) keyboardWillShow {
    
    if (_isEditing) {
        return;
    }
    
    NSLog(@"keyboard will show");
    
    _isEditing = TRUE;
}

- (void) keyboardDidShow {
    
    if (_isKeyboardShowing) {
        return;
    }
    
    NSLog(@"scrollview height: %f", scrollView.frame.size.height);
    
    _isKeyboardShowing = TRUE;
    
    NSLog(@"Keyboard did show");
    
//    [_scrollView setFrameHeight:_visibleHeightWithKeyboard];
    
    NSLog(@"scrollview height: %f", scrollView.frame.size.height);

}

- (void) keyboardWillHide {
    
    if (!_isEditing) {
        return;
    }
    
    NSLog(@"Keyboard will hide");
    
    NSLog(@"scrollview height: %f", scrollView.frame.size.height);

    
    float currentOffsetLeft = scrollView.contentOffset.x;
//    [_scrollView setFrameHeight:_originalHeight];
    [scrollView setContentOffset:CGPointMake(currentOffsetLeft, 0) animated:TRUE];
//    [_scrollView setContentOffset:CGPointZero animated:TRUE];
    
    _isEditing = FALSE;
    _isKeyboardShowing = FALSE;
    
    NSLog(@"scrollview height: %f", scrollView.frame.size.height);
}




#pragma mark Methods

- (void) scrollViewToVisibleRange:(UIView*) view {
    
    if (_isScrolling) {
        return;
    }
    
    NSLog(@"scrolling to visible range");
    
//    view = [view parentViewOfClass:[ViewLineLayoutManager class]];
    
//    UIView* formattedView = theInputView;
//    
//    while (![formattedView isKindOfClass:[ViewLineLayoutManager class]]) {
//        formattedView = formattedView.superview;
//    }
    
    //    NSLog(@"formattedView: %@", formattedView);
    
    CGPoint relativePoint = [view.superview convertPoint:view.frame.origin toView:scrollView];
    
//    CGPoint relativePoint = [view.superview convertPoint:view.frame.origin toView:_scrollView.window];
    
    CGPoint relativePointScrollViewToWindow = [scrollView.superview convertPoint:scrollView.frame.origin toView:scrollView.window];
    int visibleHeight;
    
    if (_isEditing) {

        visibleHeight = KEYBOARD_POSITION_Y - relativePointScrollViewToWindow.y;
    }
    else {

        visibleHeight = scrollView.frame.size.height;
    }
    
    
    //    NSLog(@"relative Point: %@", NSStringFromCGPoint(relativePoint));
    
    //        if (relativePoint.y + formattedView.frame.size.height > maximum_offset_top) {
    
    float currentOffsetLeft = scrollView.contentOffset.x;
    
    NSLog(@"currentOffsetLeft = %f", currentOffsetLeft);
    
    // scroll down if view below visible area 
    if (relativePoint.y + view.frame.size.height >=  visibleHeight + scrollView.contentOffset.y) {
        
        NSLog(@"scrollToVisibleRange: up");
        
        int optimalY = visibleHeight - view.frame.size.height - OFFSET_TOP;
        int diffY = relativePoint.y - optimalY;
        
        if (diffY < 0) diffY = 0;
        
        NSLog(@"current offsetY: %f, new offsetY: %d", scrollView.contentOffset.y, diffY);
        
        _isScrolling = TRUE;

        [scrollView setContentOffset:CGPointMake(currentOffsetLeft, diffY) animated:YES];
    }
    
    if (relativePoint.y < scrollView.contentOffset.y) {
        
        NSLog(@"scrollToVisibleRange: down");
        
        int optimalY = OFFSET_BOTTOM;
        int diffY = relativePoint.y - optimalY;
        
        _isScrolling = TRUE;
        [scrollView setContentOffset:CGPointMake(currentOffsetLeft, diffY) animated:YES];
    }
}


#pragma mark Memory Management

- (void) dealloc {

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

@end


