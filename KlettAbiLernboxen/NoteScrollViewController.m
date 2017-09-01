//
//  NoteScrollViewController.m
//  KlettAbiLernboxen
//
//  Created by Wang on 21.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NoteScrollViewController.h"
#import "PDFManager.h"
#import "UserDataManager.h"
#import "NoteViewAnimationLayer.h"
#import "PropertyBoard.h"


#define ICON_OFFSET CGPointMake(-2, -1)
#define MAX_EDITVIEW_OFFSET CGSizeMake(100, 100)
#define EDITVIEW_MAX_SIZE_IPAD CGSizeMake(300, 330)
#define EDITVIEW_MAX_SIZE_IPHONE CGSizeMake(200, 230)
#define EDITVIEW_MIN_SIZE CGSizeMake(100, 130)
#define EDITVIEW_DEFAULT_SIZE CGSizeMake(150, 180)
#define NOTEVIEW_ANIMATION_LAYER_SIZE CGSizeMake(200,200)
#define NOTEVIEW_ANIMATION_FRAMES 30
#define EDITVIEW_TOP_BAR_HEIGHT 0



#pragma mark - NoteScrollViewController

@implementation NoteScrollViewController

@synthesize forwardView, currentDocumentType, pageNumber, activeTextView;
@synthesize delegate;


- (id) init {
    
    if (self = [super init]) {
        
        _zoomScale = 1.0;
        _offset = CGPointMake(0, 0);
        _noteViews = [NSMutableArray array];
    }
    
    return self;
}


- (id) initWithModel:(PageViewModel *)model {
    
    if (self = [self init]) {
        
        _model = model;
    }
    
    return self;
}


- (void) setForwardView:(UIView *)theForwardView {
    
    forwardView = theForwardView;
    
    ((NoteScrollViewControllerView*)self.view).forwardView = theForwardView;
}


- (void) viewDidLoad {
    
    [super viewDidLoad];

    self.view = [[NoteScrollViewControllerView alloc] init];
    ((NoteScrollViewControllerView*)self.view).noteScrollViewcontroller = self;
    ((NoteScrollViewControllerView*)self.view).forwardView = self.forwardView;
    
    self.view.clipsToBounds = TRUE;
    
    UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self.view addGestureRecognizer:recognizer];
    
    UIPanGestureRecognizer* recognizer2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleFakePanGesture:)];
    recognizer2.delaysTouchesBegan = TRUE;
    [self.view addGestureRecognizer:recognizer2];
    
//    UILongPressGestureRecognizer* recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
//    self.view.userInteractionEnabled = TRUE;
//    [self.view addGestureRecognizer:recognizer];
    
//    self.view.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
}


- (void) addNote:(NoteView *)noteView {
    
//    CGPoint translatedPosition = [self translatePositionFromNeutral:noteView.neutralPosition];
//    
//    [noteView setFrameOrigin:translatedPosition];

    [self.view addSubview:noteView];
//    [self.view performSelectorOnMainThread:@selector(addSubview:) withObject:noteView waitUntilDone:YES];
    
    [_noteViews addObject:noteView];
    
//    [self updatePositionForNote:noteView animated:TRUE];
}


- (CGPoint) translatePositionFromNeutral:(CGPoint)position {
    
    float x = (position.x * _zoomScale) - _offset.x + ICON_OFFSET.x;
    float y = (position.y * _zoomScale) - _offset.y + ICON_OFFSET.y;
    
    return CGPointMake(x, y);
}


- (CGPoint) translatePositionToNeutral:(CGPoint)position {
    
    float x = (position.x + _offset.x - ICON_OFFSET.x) / _zoomScale;
    float y = (position.y + _offset.y - ICON_OFFSET.y) / _zoomScale;
    
    return CGPointMake(x, y);
}


- (void) handleLongPressComplete:(UIGestureRecognizer *)recognizer {
    
    UIView* view = [recognizer.view.subviews objectAtIndex:0];
    CGPoint point = [recognizer locationInView:view];
    
    NSLog(@"Longpress at point: %@", NSStringFromCGPoint(point));
    
//    CGPoint neutralPosition = [self translatePositionToNeutral:point];
    
    NoteView* noteView = [self createNoteAtPosition:point];
    [self addNote:noteView];
    
    [self updatePositionForNote:noteView animated:TRUE];
}


- (void) handleTapGesture:(UIGestureRecognizer *)recognizer {

    if (self.activeTextView) {
        [self.activeTextView resignFirstResponder];
        self.activeTextView = nil;
    }
    else if ([delegate noteScrollViewControllerShouldCreateNote:self]) {
        
        UIView* view = [recognizer.view.subviews objectAtIndex:0];
        CGPoint point = [recognizer locationInView:view];
        
        NoteView* noteView = [self createNoteAtPosition:point];
        [self addNote:noteView];
        
        [self updatePositionForNote:noteView animated:TRUE];
        
        [delegate NoteScrollViewControllerDidCreateNote:self];
    }
}


- (void) handleFakePanGesture:(UIGestureRecognizer *)recognizer {
    
//    NSLog(@"fake pan");
}


- (void) handleScrollViewDidScroll:(UIScrollView *)scrollView {
    
    _offset = scrollView.contentOffset;

//    NSLog(@"offset: %@", NSStringFromCGPoint(_offset));
//    NSLog(@"scrollview\tdragging=%d, tracking=%d, zooming=%d", scrollView.dragging, scrollView.tracking, scrollView.zooming);
    
//    [self updateNotePositionsAnimated:scrollView.dragging];
    [self updateNotePositionsAnimated:true];
}


- (void) handleScrollViewDidZoom:(UIScrollView *)scrollView {
    
    _zoomScale = scrollView.zoomScale;
    
//    NSLog(@"zoomScale: %0.2f", _zoomScale);
//    NSLog(@"scrollview\tdragging=%d, tracking=%d, zooming=%d", scrollView.dragging, scrollView.tracking, scrollView.zooming);

//    if (scrollView.zooming)
//        [self updateNotePositionsAnimated:scrollView.zooming];
    
    [self updateNotePositionsAnimated:true];
}


- (void) updateNotePositionsAnimated:(BOOL) animated {

    for (NoteView* noteView in _noteViews) {
        [self updatePositionForNote:noteView animated:TRUE];
    }
}


- (void) updatePositionForNote:(NoteView*)noteView animated:(BOOL)animated {

    [noteView setFrameOrigin:[self translatePositionFromNeutral:noteView.neutralPosition]];
    
//    NSLog(@"note position: %@", NSStringFromCGPoint(noteView.frame.origin));

    
    // update edit view position if != nil
    if (noteView.editView) {
        
        if (!noteView.editView.superview) {

//            [noteView.editView setFrameOrigin:noteView.frame.origin];
            [self.view addSubview:noteView.editView];
//            [self.view performSelectorOnMainThread:@selector(addSubview:) withObject:noteView.editView waitUntilDone:YES];
        }
        
        CGPoint notePosition = noteView.frame.origin;
        CGSize editViewSize = noteView.editView.frame.size;
        CGSize superviewSize = self.view.frame.size;
        CGPoint preferredPosition = CGPointMake(notePosition.x - ICON_OFFSET.x, notePosition.y - ICON_OFFSET.y);
        
//        NSLog(@"editview size: %@", NSStringFromCGSize(editViewSize));
        
        BOOL horizontalVisible = TRUE;
        BOOL verticalVisible = TRUE;
        
        
        // check horizontal
        CGSize offsetToBottomRight = CGSizeMake(superviewSize.width - (preferredPosition.x + editViewSize.width), superviewSize.height - (preferredPosition.y + editViewSize.height));

        if (preferredPosition.x < 0) {
            
            if (preferredPosition.x > -editViewSize.width) {
                preferredPosition.x = 0;
                horizontalVisible = TRUE;
            }
            else {
                horizontalVisible = FALSE;
            }
        }
        else if (offsetToBottomRight.width < 0) {
            
            if (offsetToBottomRight.width > -editViewSize.width) {
                preferredPosition.x += offsetToBottomRight.width;
                horizontalVisible = TRUE;
            }
            else {
                horizontalVisible = FALSE;
            }
        }

        
        // check vertical
        
        if (preferredPosition.y - EDITVIEW_TOP_BAR_HEIGHT < 0) {
            
            if (preferredPosition.y + EDITVIEW_TOP_BAR_HEIGHT > -editViewSize.height) {
                preferredPosition.y = EDITVIEW_TOP_BAR_HEIGHT;
                verticalVisible = TRUE;
            }
            else {
                verticalVisible = FALSE;
            }
        }
        else if (offsetToBottomRight.height < 0) {
            
            if (offsetToBottomRight.height > -editViewSize.height) {
                preferredPosition.y += offsetToBottomRight.height;
                verticalVisible = TRUE;
            }
            else {
                verticalVisible = FALSE;
            }
        }

        
        BOOL willBeVisible = horizontalVisible && verticalVisible;
        
        
//        NSLog(@"was visible: %d, will be visible: %d", noteView.editView.isInVisibleArea, willBeVisible);
        
        
        if (noteView.editView.isInVisibleArea != willBeVisible && animated) {
            
            [UIView animateWithDuration:0.3 animations:^(void) {
                [noteView.editView setFrameOrigin:preferredPosition];
//                [noteView.editView layoutButtons];
            }];
        }
        else {
            [noteView.editView setFrameOrigin:preferredPosition];
//            [noteView.editView layoutButtons];
        }
        
        noteView.editView.isInVisibleArea = willBeVisible;
        
        
    }
}


- (NoteView*) createNoteAtPosition:(CGPoint)position {

    NSString* moduleName = [PDFManager manager].moduleName;
//    NSString* categoryName = [PDFManager manager].categoryName;
    
//    Note* note = [UserDataManager createNoteForModule:moduleName category:categoryName pageNumber:pageNumber documentType:self.currentDocumentType withPosition:position];
    
    Note* note = [_model createNoteForDocumentType:self.currentDocumentType];
    note.positionX = [NSNumber numberWithFloat:position.x];
    note.positionY = [NSNumber numberWithFloat:position.y];
    
    NoteView* noteView = [[NoteView alloc] init];
//    [noteView startAnimation];
    noteView.note = note;
    noteView.noteScrollViewController = self;
    noteView.neutralPosition = position;
    
    NSLog(@"creating note: module = %@, category = %@, page = %d, documentType = %d, position: %@", moduleName, _model.category, self.pageNumber, self.currentDocumentType, NSStringFromCGPoint(noteView.neutralPosition));   
    NSLog(@"Note: %@", note);

    return noteView;
}


//- (void) saveNote:(NoteView *)noteView {
//    
//    NSString* moduleName = [PDFManager manager].moduleName;
//    NSString* categoryName = [PDFManager manager].categoryName;
//    NSLog(@"saving note: module = %@, category = %@, page = %d, documentType = %d, position: %@", moduleName, categoryName, self.pageNumber, self.currentDocumentType, NSStringFromCGPoint(noteView.neutralPosition));
//    
////    [UserDataManager updatePosition:noteView.neutralPosition forNoteForModule:moduleName category:categoryName pageNumber:pageNumber documentType:self.currentDocumentType position
//}


- (void) loadNotes {
    
//    NSLog(@"loadNotes");
    
//    [_notes makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (NoteView* noteView in _noteViews) {
        
        [noteView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:YES];
        
        if (noteView.editView) {
//            [noteView.editView removeFromSuperview];
            [noteView.editView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:YES];
        }
    }
    
    [_noteViews removeAllObjects];
    
//    NSString* moduleName = [PDFManager manager].moduleName;
//    NSString* categoryName = [PDFManager manager].categoryName;
    
//    NSLog(@"loading notes: module = %@, category = %@, page = %d, documentType = %d", moduleName, categoryName, self.pageNumber, self.currentDocumentType);   
    
//    NSArray* notes = [UserDataManager notesForModule:moduleName category:categoryName pageNumber:self.pageNumber documentType:self.currentDocumentType];
    
    if (![delegate NoteScrollViewControllerShouldShowNotes:self]) {
        return;
    }
    
    NSArray* notes = [_model notesForDocumentType:self.currentDocumentType];
    
    for (Note* note in notes) {
        
        NSLog(@"note: %@", note);
        
        NoteView* noteView = [[NoteView alloc] init];
        noteView.noteScrollViewController = self;
        noteView.note = note;
        noteView.neutralPosition = CGPointMake([note.positionX floatValue], [note.positionY floatValue]);

        [self addNote:noteView];
        
        if ([noteView.note.isOpen boolValue]) {
            [noteView openEditView];
            [self.view addSubview:noteView.editView];
        }
        
        [self updatePositionForNote:noteView animated:FALSE];
        
//        if (noteView.note.isOpen) {
//            [self.view addSubview:noteView.editView];
//        }
    }
}


- (void) update {
    
    [self loadNotes];
}


- (void) handleDeleteNote:(NoteView *)noteView {

    _noteToBeDeleted = noteView;
    
    [[[UIAlertView alloc] initWithTitle:@"Notiz löschen"
                                message:@"Möchten Sie diese Notiz löschen?"
                               delegate:self
                      cancelButtonTitle:@"Ja"
                       otherButtonTitles:@"Nein", nil] show];
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        if (_noteToBeDeleted.editView) {
            
            [_noteToBeDeleted.editView removeFromSuperview];
        }
        
        Note* note = _noteToBeDeleted.note;
        
        [_noteViews removeObject:_noteToBeDeleted];
        [_noteToBeDeleted removeFromSuperview];
        
        [UserDataManager deleteNote:note];
    }
    
    _noteToBeDeleted = nil;
}


- (BOOL) documentViewControllerShouldScroll {
    
    return (self.activeTextView == nil);
}


@end



#pragma mark - NoteScrollViewControllerView

@implementation NoteScrollViewControllerView

@synthesize forwardView, noteScrollViewcontroller;


- (UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView* hitView = [super hitTest:point withEvent:event];
    
    NSLog(@"hitview = %@", hitView);
    
    
//    if (self.noteScrollViewcontroller.activeTextView) {
//        
//        NSLog(@"blocking... returning self (NoteScrollViewControllerview)");
//        
//        return self;
//    }
    
    
//    if (![[super hitTest:point withEvent:event] isKindOfClass:[NoteView class]]) {
//        return self.forwardView;
//    }
//    else {
//        return [super hitTest:point withEvent:event];
//    }
    
    if ([hitView isKindOfClass:[NoteView class]] ||
        [hitView isKindOfClass:[NoteEditView class]] ||
        [hitView isKindOfClass:[UITextView class]] ||
        [hitView isKindOfClass:[UIButton class]]) {
        
        NSLog(@"returning hitView, which is of class: %@", [hitView class]);
        
        return hitView;
    }
    else {
        
        NSLog(@"returning forwardView = %@", self.forwardView);
        
        return self.forwardView;
    }
    
}




@end



#pragma mark - NoteView

@implementation NoteView

@synthesize neutralPosition, noteScrollViewController, note, editView;


- (id) init {
    
    if (self = [super initWithFrame:CGRectMake(0, 0, 23, 28)]) {
    
        UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        self.userInteractionEnabled = TRUE;
        [self addGestureRecognizer:recognizer];
        
//        UILongPressGestureRecognizer* recognizer2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
//        [self addGestureRecognizer:recognizer2];
        
        UITapGestureRecognizer* recognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [self addGestureRecognizer:recognizer3];
        
        self.clipsToBounds = FALSE;

        
        _animationLayer = [[NoteViewAnimationLayer alloc] initWithFrame:CGSizeCenterInRect(NOTEVIEW_ANIMATION_LAYER_SIZE, self.frame)];
        _animationLayer.repeatCount = HUGE_VALF;
        _animationLayer.autoreverses = TRUE;
        [self.layer addSublayer:_animationLayer];
        
        CALayer* imageLayer = [CALayer layer];
        imageLayer.frame = self.bounds;
        UIImage* image = resource(@"Images.DocumentView.NoteIcon");
        imageLayer.contents = (id)image.CGImage;
        [self.layer addSublayer:imageLayer];

        
//        [PropertyBoard instance].ringOffset = [NSNumber numberWithInt:1];
//        [[PropertyBoard instance] registerIntPropertyKey:@"ringOffset" forObject:[PropertyBoard instance]];
        
//        [PropertyBoard instance].lineWidth = [NSNumber numberWithInt:1];
//        [[PropertyBoard instance] registerIntPropertyKey:@"lineWidth" forObject:[PropertyBoard instance]];
    }
    
    return self;
}


- (void) startAnimation {
    
    [_animationLayer animateWithDuration:0.5];
}



- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    NSLog(@"observeValueForKeyPath: %@, change: %@", keyPath, change);
}


#pragma mark Methods

- (void) handlePanGesture:(UIGestureRecognizer *)recognizer {

    static CGPoint touchOffset;
    
    CGPoint position = [recognizer locationInView:self.superview];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"pan started");
        touchOffset = CGPointMake(position.x - self.frame.origin.x, position.y - self.frame.origin.y);
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint relativePosition = CGPointMake(position.x - touchOffset.x, position.y - touchOffset.y);
        [self setFrameOrigin:relativePosition];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"pan ended");
        CGPoint relativePosition = CGPointMake(position.x - touchOffset.x, position.y - touchOffset.y);
        self.neutralPosition = [self.noteScrollViewController translatePositionToNeutral:relativePosition];
        [self save];
    }
}


//- (void) handleLongPressGesture:(UIGestureRecognizer *)recognizer {
//    
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//    }
//}


- (void) deleteNote {
    
    [self.noteScrollViewController handleDeleteNote:self];
}


- (void) handleTapGesture:(UIGestureRecognizer *)recognizer {
    
    NSLog(@"tap");

    [self openEditView];
}

- (void) openEditView {
    
    self.editView = [[NoteEditView alloc] init];
    [self.editView setFrameSize:CGSizeMake(EDITVIEW_DEFAULT_SIZE.width * [self.note.scale floatValue], EDITVIEW_DEFAULT_SIZE.height * [self.note.scale floatValue])];
    self.editView.noteView = self;
    self.editView.textView.text = self.note.text;
    self.note.isOpen = [NSNumber numberWithBool:TRUE];
    
    [self.noteScrollViewController updatePositionForNote:self animated:FALSE];
    
    self.hidden = TRUE;
    
    [self save];
}


- (void) handleEditTapGesture {
    
    NSLog(@"edit view tap");
    
    [self.editView removeFromSuperview];
    self.editView = nil;
    
    self.note.isOpen = [NSNumber numberWithBool:FALSE];
    
    self.hidden = FALSE;
    
    [self save];
}


- (void) handleEditPinchGesture:(UIPinchGestureRecognizer *)recognizer {
    
    NSLog(@"pinch");
    
    static NSValue* __strong originalRect = nil;
    BOOL shouldScale = FALSE;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        shouldScale = TRUE;
        originalRect = [NSValue valueWithCGRect:self.editView.frame];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        shouldScale = TRUE;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        
        // animate moving to original origin

        [UIView animateWithDuration:0.3 animations:^(void) {
            [self.editView setFrameOrigin:CGPointMake([originalRect CGRectValue].origin.x, [originalRect CGRectValue].origin.y)];
//            [self.editView layoutButtons];
        }];
        
        originalRect = nil;
        
        float currentScale = self.editView.frame.size.width / EDITVIEW_DEFAULT_SIZE.width;
        
        self.note.scale = [NSNumber numberWithFloat:currentScale];
        
        [self save];
    }
    
    if (shouldScale) {
        
        float scale = recognizer.scale;

        CGSize newSize = CGSizeMake([originalRect CGRectValue].size.width * scale, [originalRect CGRectValue].size.height * scale);
        
        CGSize maxSize = (is_ipad) ? EDITVIEW_MAX_SIZE_IPAD : EDITVIEW_MAX_SIZE_IPHONE;
        
        if (newSize.width < EDITVIEW_MIN_SIZE.width) {
            newSize = EDITVIEW_MIN_SIZE;
        }
        else if (newSize.width > maxSize.width) {
            newSize = maxSize;
        }

        CGPoint centerPosition = [recognizer locationInView:self.noteScrollViewController.view];
        CGPoint newOrigin = CGPointMake(centerPosition.x - newSize.width / 2, centerPosition.y - newSize.height / 2);
        self.editView.frame = CGRectMake(newOrigin.x, newOrigin.y, newSize.width, newSize.height);
//        [self.editView layoutButtons];
    }
    
}




- (void) save {

    NSLog(@"saving note");
    
    self.note.positionX = [NSNumber numberWithFloat:self.neutralPosition.x];
    self.note.positionY = [NSNumber numberWithFloat:self.neutralPosition.y];
    
    [UserDataManager save];
}


- (void) dealloc {
    
    NSLog(@"NoteView DEALLOC");
}

@end



#pragma mark - NoteEditView

@implementation NoteEditView

@synthesize noteView, isInVisibleArea, textView, scrollManagedView;
@synthesize imageView;


- (id) init {
    
    if ((self = [[[NSBundle mainBundle] loadNibNamed:@"NoteEditView" owner:nil options:nil] objectAtIndex:0])) {
        
//        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
//        self.userInteractionEnabled = TRUE;
        
//        UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
//        [self addGestureRecognizer:recognizer];
        
        UIPinchGestureRecognizer* recognizer2 = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [self addGestureRecognizer:recognizer2];
        
//        UILongPressGestureRecognizer* recognizer3 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
//        [self addGestureRecognizer:recognizer3];
        
        self.isInVisibleArea = TRUE;
        
        self.textView.delegate = self;
        
        self.scrollManagedView = self;
        
        imageView.image = [(UIImage*)resource(@"Images.DocumentView.NoteBackground") resizableImageWithCapInsets:UIEdgeInsetsMake(40,12,12,70)];
        
        textView.font = resource(@"Fonts.DocumentView.Note.Font");
        textView.textColor = resource(@"Fonts.DocumentView.Note.Color");
        
//        UIImage* bgTop = resource(@"Images.DocumentView.NoteBackgroundTop");
//        UIImageView* bgTopView = [[UIImageView alloc] initWithImage:bgTop];
//        bgTopView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//        [bgTopView setFrameOrigin:CGPointMake(imageView.bounds.size.width - bgTopView.bounds.size.width + 1,
//                                              -bgTopView.bounds.size.height + 0.5)];
//        [self addSubview:bgTopView];
        
//        _minimizeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_minimizeButton setImage:resource(@"Images.DocumentView.NoteIconMinimize") forState:UIControlStateNormal];
//        [_minimizeButton setFrameSize:CGSizeMake(30, 30)];
////        [_minimizeButton addTarget:self action:@selector(handleMinimize:) forControlEvents:UIControlEventTouchUpInside];
//        UITapGestureRecognizer* recognizerMinimize = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleMinimize:)];
//        [_minimizeButton addGestureRecognizer:recognizerMinimize];
//        
//        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_deleteButton setImage:resource(@"Images.DocumentView.NoteIconDelete") forState:UIControlStateNormal];
//        [_deleteButton setFrameSize:CGSizeMake(30, 30)];
////        [_deleteButton addTarget:self action:@selector(handleDelete:) forControlEvents:UIControlEventTouchUpInside];
//        UITapGestureRecognizer* recognizerDelete = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDelete:)];
//        [_deleteButton addGestureRecognizer:recognizerDelete];
        
//        [self layoutButtons];
    }
    
    return self;
}


- (void) didMoveToSuperview {
    
    if (self.superview) {
        
//        [self.superview insertSubview:_minimizeButton aboveSubview:self];
//        [self.superview insertSubview:_deleteButton aboveSubview:self];
//        
//        [self layoutButtons];
    }
}


- (CGSize) boundingSize {

    return CGSizeMake(self.bounds.size.width, self.bounds.size.height + EDITVIEW_TOP_BAR_HEIGHT);
}


//- (void) layoutButtons {
//    
//    CGPoint minimizePosition = CGPointMake(self.frame.origin.x + self.frame.size.width - 60, self.frame.origin.y - 30);
//    [_minimizeButton setFrameOrigin:minimizePosition];
//    
//    CGPoint deletePosition = CGPointMake(self.frame.origin.x + self.frame.size.width - 30, self.frame.origin.y - 30);
//    [_deleteButton setFrameOrigin:deletePosition];
//}


//- (void) setButtonsVisible:(BOOL)visible {
//
//    _minimizeButton.hidden = !visible;
//    _deleteButton.hidden = !visible;
//}


- (void) removeFromSuperview {
    
    [super removeFromSuperview];
    
//    [_minimizeButton removeFromSuperview];
//    [_deleteButton removeFromSuperview];
}


- (IBAction) handleMinimize:(id) sender {
    
    NSLog(@"minimize");
    
    [self.noteView handleEditTapGesture];
}


- (IBAction) handleDelete:(id) sender {

    [self.noteView deleteNote];
}


//- (void) handleTapGesture:(UIGestureRecognizer *)recognizer {
//
//    self.noteView.noteScrollViewController.activeTextView = self.textView;
//    [self.textView becomeFirstResponder];
//    
//
//    
////    if (recognizer.state == UIGestureRecognizerStateBegan) {
////        //        [self.noteView handleEditLongPress:recognizer];
////        
////        self.noteView.noteScrollViewController.activeTextView = self.textView;
////        [self.textView becomeFirstResponder];
////    }
//}

- (void) handlePinch:(UIPinchGestureRecognizer *)recognizer {
    
    [self.noteView handleEditPinchGesture:recognizer];
}

//- (void) handleLongPress:(UIGestureRecognizer *)recognizer {
//    
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
////        [self.noteView handleEditLongPress:recognizer];
//        
//        self.noteView.noteScrollViewController.activeTextView = self.textView;
//        [self.textView becomeFirstResponder];
//    }
//}



- (void) textViewDidBeginEditing:(UITextView *)textView {

    NSLog(@"did begin editing");
    
    self.noteView.noteScrollViewController.activeTextView = self.textView;

    [self.noteView.noteScrollViewController.delegate noteScrollViewControllerDidBeginEditMode:nil];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:ScrollManagableInputFieldDidBeginEditing  object:self];
}


- (BOOL) textViewShouldEndEditing:(UITextView *)theTextView {
    
    NSLog(@"should end editing");
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:ScrollManagableInputFieldShouldEndEditing object:self];

    [self.noteView.noteScrollViewController.delegate noteScrollViewControllerWillEndEditMode:nil];

    
    noteView.note.text = theTextView.text;
    self.noteView.noteScrollViewController.activeTextView = nil;
    
    [noteView save];
    
    return TRUE;
}


- (void) dealloc{
    
    NSLog(@"NoteEditView DEALLOC");
}

@end



#pragma mark - NoteTextView

@implementation NoteTextView

@synthesize editView;


//- (IBAction) handleTap:(UIGestureRecognizer *)recognizer {
//
//    self.editView.noteView.noteScrollViewController.activeTextView = (NoteTextView*)recognizer.view;
//    
//    [self becomeFirstResponder];
//}


//- (UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    
//    return self.superview;
//}

@end



