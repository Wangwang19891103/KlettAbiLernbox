//
//  NoteScrollViewController.h
//  KlettAbiLernboxen
//
//  Created by Wang on 21.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Note.h"
#import "ScrollManager.h"
#import "PageViewModel.h"
#import <QuartzCore/QuartzCore.h>
#import "AnimationLayer.h"
#import "NoteScrollViewControllerDelegate.h"
#import "NoteViewAnimationLayer.h"


typedef enum {
    
    DocumentTypeExercise,
    DocumentTypeSolution,
    DocumentTypeKnowledge
} DocumentType;



@class NoteView;
@class NoteEditView;
@class NoteTextView;


@interface NoteScrollViewController : UIViewController <UIAlertViewDelegate> {
    
    float _zoomScale;
    CGPoint _offset;
    PageViewModel* _model;
    NSMutableArray* _noteViews;
    
    NoteView* __weak _noteToBeDeleted;
}

@property (nonatomic, assign) id<NoteScrollViewControllerDelegate> delegate;

@property (nonatomic, assign) UIView* forwardView;

@property (nonatomic, assign) DocumentType currentDocumentType;

@property (nonatomic, assign) uint pageNumber;

@property (nonatomic, assign) NoteTextView* activeTextView;


- (id) initWithModel:(PageViewModel*) model;

- (void) handleLongPressComplete:(UIGestureRecognizer*) recognizer;

- (void) handleTapGesture:(UIGestureRecognizer*) recognizer;

- (void) handleScrollViewDidScroll:(UIScrollView*) scrollView;

- (void) handleScrollViewDidZoom:(UIScrollView*) scrollView;

- (void) addNote:(NoteView*) noteView;

//- (void) updateNotePositions;

- (void) updatePositionForNote:(NoteView*) noteView animated:(BOOL) animated;

- (CGPoint) translatePositionFromNeutral:(CGPoint) position;

- (CGPoint) translatePositionToNeutral:(CGPoint) position;

- (NoteView*) createNoteAtPosition:(CGPoint) position;

- (void) loadNotes;

- (void) update;

- (void) handleDeleteNote:(NoteView*) noteView;

- (void) handleFakePanGesture:(UIGestureRecognizer*) recognizer;

- (BOOL) documentViewControllerShouldScroll;

@end



@interface NoteScrollViewControllerView : UIView

@property (nonatomic, assign) NoteScrollViewController* noteScrollViewcontroller;

@property (nonatomic, assign) UIView* forwardView;


@end



@interface NoteView : UIView {
    
    NoteViewAnimationLayer* __strong _animationLayer;
}

@property (nonatomic, assign) CGPoint neutralPosition;

@property (nonatomic, assign) NoteScrollViewController* noteScrollViewController;

@property (nonatomic, strong) Note* note;

@property (nonatomic, strong) NoteEditView* editView;


- (void) startAnimation;

- (void) handlePanGesture:(UIGestureRecognizer*) recognizer;

- (void) handleLongPressGesture:(UIGestureRecognizer*) recognizer;

- (void) handleTapGesture:(UIGestureRecognizer*) recognizer;

- (void) handleEditTapGesture;

- (void) handleEditPinchGesture:(UIPinchGestureRecognizer*) recognizer;

- (void) handleEditLongPress:(UIGestureRecognizer*) recognizer;

- (void) openEditView;

- (void) deleteNote;

- (void) save;

@end



@interface NoteEditView : UIView <UITextViewDelegate, ScrollManagableInputField> {
    
    UIButton* __strong _minimizeButton;
    UIButton* __strong _deleteButton;
}

@property (nonatomic, assign) NoteView* noteView;

@property (nonatomic, assign) BOOL isInVisibleArea;

@property (nonatomic, strong) IBOutlet NoteTextView* textView;

@property (nonatomic, assign) UIView* scrollManagedView;

@property (nonatomic, strong) IBOutlet UIImageView* imageView;


//- (void) layoutButtons;

//- (void) setButtonsVisible:(BOOL) visible;

- (IBAction) handleMinimize:(id)sender;

- (IBAction) handleDelete:(id)sender;

//- (void) handleTapGesture:(UIGestureRecognizer*) recognizer;

- (void) handlePinch:(UIPinchGestureRecognizer*) recognizer;

- (void) handleLongPress:(UIGestureRecognizer*) recognizer;

- (CGSize) boundingSize;

@end



@interface NoteTextView : UITextView 

@property (nonatomic, assign) IBOutlet NoteEditView* editView;

- (IBAction) handleTap:(UIGestureRecognizer*) recognizer;

@end


