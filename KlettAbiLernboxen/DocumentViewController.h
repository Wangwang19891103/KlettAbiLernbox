//
//  DocumentViewController.h
//  KlettAbiLernboxen
//
//  Created by Wang on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ThumbnailsViewController.h"
#import "ContentsOverlayViewController.h"
#import "PageViewController.h"
#import "DocumentViewModel.h"
#import "PageQueue.h"
#import "ThumbnailsBar.h"
#import "ThumbnailBarDelegate.h"
#import "PopupMenu.h"
#import "PopupMenuDelegate.h"
#import "PageViewController.h"
#import "PageViewControllerDelegate.h"
#import "CustomNavigationItem.h"


@class DocumentScrollView;



@interface DocumentViewController : UIViewController <UIScrollViewDelegate,  PageViewControllerDelegate, DocumentViewModelDelegate, PageQueueDelegate,
    ThumbnailBarDelegate,
    PropertyBoardChangeObserver,PopupMenuDelegate,
    UIGestureRecognizerDelegate> {
    
    DocumentViewModel* __strong _model;
    
    NSMutableDictionary* __strong _pageViewControllers;
    
    uint _startingPage;
    uint _currentPage; // 0-based
    
    
    BOOL _viewAppeared;
    BOOL _modelLoaded;
    
    PageQueue* __strong _pageQueue;
        
    BOOL _menuOpen;
    BOOL _createNote;
    BOOL _showNotes;
    BOOL _isFullscreen;
    BOOL _fullscreenAnimating;
        
    CustomNavigationItem* __strong _customNavigationItem;

}

@property (nonatomic, strong) IBOutlet DocumentScrollView* scrollView1;

@property (nonatomic, strong) IBOutlet UIView* contentView1;

//@property (nonatomic, strong) IBOutlet UIView* thumbsView;

@property (nonatomic, strong) IBOutlet PopupMenu* popupMenu;

@property (nonatomic, strong) ContentsOverlayViewController* contentsOverlayViewController;

//@property (nonatomic, copy) NSArray* keywords;

@property (nonatomic, assign) uint startingDocumentType;

@property (nonatomic, weak) Note* startingOpenNote;

@property (nonatomic, strong) IBOutlet ThumbnailsBar* thumbnailsBar;

@property (nonatomic, strong) IBOutlet UIButton* menuButton;



- (id) initWithCategory:(NSString*) category pageNumber:(uint) number;

//- (void) loadPageViewController:(PageViewController*) controller;

- (void) layout;

- (void) layoutPageViewController:(PageViewController*) controller;

- (void) handleTap:(UIGestureRecognizer*) recognizer;

- (void) handlePage;

- (IBAction) handleSwitchMenu:(id)sender;

- (void) setPopupMenuOpen:(BOOL) open animated:(BOOL) animated;

- (void) keyboardWillShow:(NSNotification*) notification;
- (void) keyboardDidShow:(NSNotification*) notification;
- (void) keyboardWillHide:(NSNotification*) notification;

@end





//unused
@interface DocumentScrollView : UIScrollView

@property (nonatomic, assign) DocumentViewController* documentViewController;

@end








@interface PageLoadOperation : NSOperation

@property (nonatomic, weak) UIView* superView;

@property (nonatomic, weak) UIViewController* viewController;

@end
