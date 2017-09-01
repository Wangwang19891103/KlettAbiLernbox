//
//  ScrollManager.h
//  Sprachenraetsel
//
//  Created by Wang on 17.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


// Konstanten

extern NSString* const ScrollManagerShouldScrollViewToVisibleRange;


@interface ScrollManager : NSObject {

    BOOL _isScrolling;
    BOOL _isSmoothScrolling;
    BOOL _isEditing;
    BOOL _isKeyboardShowing;
    
    int _visibleHeightWithKeyboard;
    int _originalHeight;
}

@property (nonatomic, readonly) BOOL isScrolling;

@property (nonatomic, assign) UIScrollView* scrollView;


- (id) init;

- (void) handleInputFieldDidBeginEditing:(NSNotification*) notification;

- (void) handleScrollViewToVisibleRange:(NSNotification*) notification;

- (void) scrollViewToVisibleRange:(UIView*) view;

- (void) testNotification:(NSNotification*) notification;

- (void) handleScrollViewWillScroll;
- (void) handleScrollViewDidScroll;
- (void) handleScrollViewWillStartSmoothScrolling;
- (void) handleScrollViewDidEndSmoothScrolling;

- (void) keyboardWillShow;
- (void) keyboardDidShow;
- (void) keyboardWillHide;

@end



extern NSString* const ScrollManagableInputFieldDidBeginEditing;
extern NSString* const ScrollManagableInputFieldShouldEndEditing;
extern NSString* const ScrollManagableInputFieldDidReceiveInput;


@protocol ScrollManagableInputField
@property (nonatomic, assign) UIView* scrollManagedView;
@end
