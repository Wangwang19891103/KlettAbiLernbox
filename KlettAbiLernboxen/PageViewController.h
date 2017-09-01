//
//  PDFViewController.h
//  KlettAbiLernboxen
//
//  Created by Wang on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFView.h"
#import "NoteScrollViewController.h"
#import "PageViewModel.h"
#import "ScrollManager.h"
#import "CustomSegmentedControl.h"
#import "ResourceManager.h"
#import "NoteScrollViewControllerDelegate.h"
#import "PageViewControllerDelegate.h"




@interface PageViewController : UIViewController <UIScrollViewDelegate, PropertyBoardChangeObserver, NoteScrollViewControllerDelegate> {

//    PageViewModel* _model;
    
//    uint _pageNumber;
    CGPDFPageRef _exercisePageRef;
//    PDFView* __strong _pdfView;
    
    BOOL _isMenuShowing;
    
    DocumentType _currentDocumentType;
    
    ScrollManager* __strong _scrollManager;
    
    UIImageView* __strong _zigzagImageView;
}

@property (nonatomic, assign) id<PageViewControllerDelegate> delegate;

@property (nonatomic, readonly) PageViewModel* model;

//@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, strong) IBOutlet UIImageView* titleImageView;

@property (nonatomic, strong) IBOutlet UIView* containerView;

@property (nonatomic, strong) UIScrollView* exerciseView;

@property (nonatomic, strong) UIScrollView* solutionView;

@property (nonatomic, strong) UIScrollView* knowledgeView;

@property (nonatomic, assign) UIScrollView* activeDocumentView;

@property (strong, nonatomic) IBOutlet UIButton *checkButton;

@property (strong, nonatomic) IBOutlet UIButton *favoritesButton;

@property (strong, nonatomic) IBOutlet UIButton *crossButton;

@property (strong, nonatomic) IBOutlet CustomSegmentedControl *segmentedControl;

@property (nonatomic, strong) IBOutlet UIView* popupMenuView;

@property (nonatomic, strong) IBOutlet UIImageView* popupBGImageView;

@property (nonatomic, strong) NoteScrollViewController* noteScrollViewController;

@property (nonatomic, copy) NSArray* keywords;

@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;

@property (nonatomic, readonly) uint pageNumber; // relative page number to category (for calculating x-offsets etc)

@property (nonatomic, assign) uint startingDocumentType;


//- (id) initWithPageNumber:(uint) number;

- (id) initWithModel:(PageViewModel*) model;

- (void) initializeView;

- (void) updateViews;

- (void) updateNotes;

- (void) layout;

- (IBAction) switchDocument:(id) sender;

//- (UIScrollView*) createDocumentScrollViewFromPage:(CGPDFPageRef) pageRef;

- (void) updateFavoriteButton;

- (IBAction) switchFavorite;
- (IBAction) switchUnderstood;
- (IBAction) switchNotUnderstood;

- (void) updateLearnStatusButtons;

- (IBAction) switchPopupMenu;

- (void) handleLongPress:(UIGestureRecognizer*) recognizer;

- (void) handleTapGesture:(UIGestureRecognizer*) recognizer;

- (void) handleDoubleTap:(UIGestureRecognizer*) recognizer;

- (BOOL) documentViewControllerShouldScroll;

- (void) keyboardWillShow:(NSNotification*) notification;
- (void) keyboardDidShow:(NSNotification*) notification;
- (void) keyboardWillHide:(NSNotification*) notification;

@end






@interface MyImageView : UIImageView

- (void) handleTap:(UIGestureRecognizer*) recognizer;

@end
