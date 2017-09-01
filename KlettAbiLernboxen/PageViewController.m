//
//  PDFViewController.m
//  KlettAbiLernboxen
//
//  Created by Wang on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PageViewController.h"
#import "PDFView.h"
#import "PDFManager.h"
#import "UserDataManager.h"
#import "ModuleManager.h"
#import "UIColor+Extensions.h"
#import "NoteScrollViewController.h"
#import "ResourceManager.h"
#import "UIImage+Extensions.h"



#define Keyboard_Height_iPhone_Portrait 216
#define Keyboard_Height_iPhone_Landscape 162
#define Keyboard_Height_iPad_Portrait 264
#define Keyboard_Height_iPad_Landscape 352

#define Scrollview_Resize_Animation_Duration 0.3

#define Note_ScrollToVisible_Padding 15




@implementation PageViewController

@synthesize checkButton;
@synthesize favoritesButton;
@synthesize crossButton;
@synthesize segmentedControl;

@synthesize titleLabel, containerView, exerciseView, solutionView, activeDocumentView, knowledgeView, popupMenuView, popupBGImageView;
@synthesize noteScrollViewController;
@synthesize keywords;
@synthesize activityIndicator;
@synthesize pageNumber;
@synthesize delegate;
@synthesize titleImageView;
@synthesize model;
@synthesize startingDocumentType;


//- (id) initWithPageNumber:(uint) number {
//    
//    if (self = [super init]) {
//        
//        _isMenuShowing = FALSE;
//        _currentDocumentType = DocumentTypeExercise;
//
//    }
//    
//    return self;
//}

- (id) initWithModel:(id)theModel {
    
    if (self = [super init]) {
        
        _isMenuShowing = FALSE;
        _currentDocumentType = DocumentTypeExercise;
        model = theModel;
        
        /* init NoteScrollViewController */
        self.noteScrollViewController = [[NoteScrollViewController alloc] initWithModel:model];
        self.noteScrollViewController.delegate = self;
        self.noteScrollViewController.currentDocumentType = _currentDocumentType;
        self.noteScrollViewController.pageNumber = model.pageNumber;    // 1-based
        self.noteScrollViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
//        _scrollManager = [[ScrollManager alloc] init];
        
//        [[PropertyBoard instance] addChangeObserver:self];
        
        _zigzagImageView = nil;
        
        


    }
    
    return self;
}


- (uint) pageNumber {
    
    return model.relativePageNumber;
}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"PageViewController viewDidLoad");
    
    timer_start(@"PageViewController_viewDidLoad");
    
//    timer_start(@"pageview_viewdidload");
    
//    CGPDFPageRef exercisePageRef = CGPDFDocumentGetPage([PDFManager manager].exercisesDocumentRef, _pageNumber);
//    self.exerciseView = [[PDFView alloc] initWithPage:exercisePageRef];
//    [self.scrollView addSubview:_pdfView];
//    [self.scrollView setContentSize:_pdfView.frame.size];

    UIColor* barColor = [[ModuleManager manager] colorForModule:[PDFManager manager].moduleName];
    //    NSLog(@"barColor: %@", barColor);
//    self.segmentedControl.tintColor = [barColor colorByDarkingByPercent:0.3];
//    self.titleLabel.text = [model.titles componentsJoinedByString:@" | "];
    self.titleLabel.text = [model.titles lastObject];
    
//    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    self.activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    self.activityIndicator.frame = self.view.bounds;
//    [self.view addSubview:self.activityIndicator];
//    [self.activityIndicator startAnimating];

    barColor = [barColor colorWithSaturationFactor:PBintVarValue(@"pattern saturation") * 0.01];
    
    UIImage* patternImage = resource(@"Images.TableViews.LinedPattern");
    patternImage = [patternImage imageWithAdjustmentColor:[barColor colorByDarkingByPercent:0.3]];
    patternImage = [patternImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    titleImageView.image = patternImage;
    
    patternImage = resource(@"Images.TableViews.ZigzagPattern");
    patternImage = [patternImage imageWithAdjustmentColor:barColor];
    patternImage = [patternImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    [_zigzagImageView removeFromSuperview];
    _zigzagImageView = [[UIImageView alloc] initWithImage:patternImage];
    _zigzagImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_zigzagImageView setFrameWidth:self.titleImageView.frame.size.width];
    [_zigzagImageView setFrameY:self.titleImageView.frame.size.height];
    [self.titleImageView addSubview:_zigzagImageView];
    
    [self initializeView];
    
//    counter_incF(@"pageview_viewdidload", timer_passed(@"pageview_viewdidload"));
    
    timer_add(@"PageViewController_viewDidLoad");
    
    NSLog(@"PageViewController viewDidLoad - finished");
    
//    [self.delegate pageViewControllerDidFinishLoading:self];
    
}


- (void) viewWillAppear:(BOOL)animated {
    
    UIView* dummyView = nil;
    UIScrollView* scrollView = nil;
    CGSize size;
    
    // exercise
    scrollView = self.exerciseView;
    dummyView = (UIView*)[scrollView.subviews objectAtIndex:0];
    size = [self contentSizeForScrollView:scrollView withMinimumSize:dummyView.bounds.size];
    
    [dummyView setFrameSize:size];
    [scrollView setContentSize:size];

    
    // solution
    scrollView = self.solutionView;
    dummyView = (UIView*)[scrollView.subviews objectAtIndex:0];
    size = [self contentSizeForScrollView:scrollView withMinimumSize:dummyView.bounds.size];
    
    [dummyView setFrameSize:size];
    [scrollView setContentSize:size];

    
    // knowledge
    if (self.knowledgeView) {

        scrollView = self.knowledgeView;
        dummyView = (UIView*)[scrollView.subviews objectAtIndex:0];
        size = [self contentSizeForScrollView:scrollView withMinimumSize:dummyView.bounds.size];
        
        [dummyView setFrameSize:size];
        [scrollView setContentSize:size];
    }
    
    [super viewWillAppear:animated];
}


- (void) variableValueChangedForName:(NSString *)name {
    
    if ([name isEqualToString:@"pattern saturation"]) {
        
        UIColor* barColor = [[ModuleManager manager] colorForModule:[PDFManager manager].moduleName];
        barColor = [barColor colorWithSaturationFactor:PBintVarValue(@"pattern saturation") * 0.01];
        
        UIImage* patternImage = resource(@"Images.TableViews.LinedPattern");
        patternImage = [patternImage imageWithAdjustmentColor:[barColor colorByDarkingByPercent:0.3]];
        patternImage = [patternImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        titleImageView.image = patternImage;
        
        patternImage = resource(@"Images.TableViews.ZigzagPattern");
        patternImage = [patternImage imageWithAdjustmentColor:barColor];
        patternImage = [patternImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        [_zigzagImageView removeFromSuperview];
        _zigzagImageView = [[UIImageView alloc] initWithImage:patternImage];
        _zigzagImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_zigzagImageView setFrameWidth:self.titleImageView.frame.size.width];
        [_zigzagImageView setFrameY:self.titleImageView.frame.size.height];
        [self.titleImageView addSubview:_zigzagImageView];
    }
}


- (void) initializeView {
    
//    CGPDFPageRef exercisePageRef = CGPDFDocumentGetPage([PDFManager manager].exercisesDocumentRef, _model.pageNumber);
//    CGPDFPageRef solutionPageRef = CGPDFDocumentGetPage([PDFManager manager].solutionsDocumentRef, _model.pageNumber);
//    CGPDFPageRef knowledgePageRef = CGPDFDocumentGetPage([PDFManager manager].knowledgeDocumentRef, _model.pageNumber);
    
    timer_start(@"PageViewController_create_scrollviews");
    self.exerciseView = [self createDocumentScrollViewFromPage:model.exercisesRef withDocumentType:0];
    self.solutionView = [self createDocumentScrollViewFromPage:model.solutionsRef withDocumentType:1];
    self.knowledgeView = [self createDocumentScrollViewFromPage:model.knowledgeRef withDocumentType:2];
    self.activeDocumentView = self.exerciseView;
    _scrollManager.scrollView = exerciseView;           // ScrollManager
    [self.containerView addSubview:self.exerciseView];
    timer_add(@"PageViewController_create_scrollviews");
    
    timer_start(@"PageViewController_noteScrollViewController_update");
    self.noteScrollViewController.forwardView = self.activeDocumentView;
    self.noteScrollViewController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:self.noteScrollViewController.view];
    [self.noteScrollViewController update];
    timer_add(@"PageViewController_noteScrollViewController_update");
    
    timer_start(@"PageViewController_updateButtons");
    [self updateFavoriteButton];
    [self updateLearnStatusButtons];
    timer_add(@"PageViewController_updateButtons");
    
    
    if (self.knowledgeView) {
    
        [self.segmentedControl setTitles:[NSArray arrayWithObjects:
                                          @"Aufgabe",
                                          @"Lösung",
                                          @"Wissen",
                                          nil]];
    }
    else {
        
        [self.segmentedControl setTitles:[NSArray arrayWithObjects:
                                          @"Aufgabe",
                                          @"Lösung",
                                          nil]];
    }

    
    [self.segmentedControl setValueChangedSelector:@selector(switchDocument:) onTarget:self];
    
    if (startingDocumentType != DocumentTypeExercise) {
        
        segmentedControl.selectedIndex = startingDocumentType;
        [segmentedControl setNeedsDisplay];

        [self switchToDocument:startingDocumentType];
    }
}


- (void) updateViews {
    
    [self.segmentedControl setNeedsDisplay];
    [self.activeDocumentView setNeedsDisplay];
    [[self.activeDocumentView.subviews objectAtIndex:0] setNeedsDisplay];
    [self.view setNeedsDisplay];
}


- (void) updateNotes {

    [noteScrollViewController update];
}


- (UIView*) viewForZoomingInScrollView:(UIScrollView *)theScrollView {
    
    return [[theScrollView subviews] objectAtIndex:0];
}


- (void) scrollViewDidScroll:(UIScrollView *)theScrollView {
    
    [self.noteScrollViewController handleScrollViewDidScroll:theScrollView];
}

- (void) scrollViewDidZoom:(UIScrollView *)theScrollView {
    
    [self.noteScrollViewController handleScrollViewDidZoom:theScrollView];
}


- (UIScrollView*) createDocumentScrollViewFromPage:(CGPDFPageRef)pageRef withDocumentType:(uint) type {

    if (!pageRef) return nil;
    
    PDFView* pdfView = [[PDFView alloc] initWithPage:pageRef];
    pdfView.documentType = type;
    pdfView.keywords = self.keywords;
    pdfView.pageNumber = model.pageNumber;
    
    UIScrollView* theScrollView = [[UIScrollView alloc] init];
    theScrollView.frame = self.containerView.bounds;
    theScrollView.delegate = self;
    theScrollView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    theScrollView.bounces = false;
    theScrollView.bouncesZoom = false;
    
    
    // main thread
//    [theScrollView performSelectorOnMainThread:@selector(addSubview:) withObject:pdfView waitUntilDone:YES];

    UIView* dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, pdfView.bounds.size.width, pdfView.bounds.size.height)];
    dummyView.backgroundColor = [UIColor colorWithPatternImage:resource(@"Images.DocumentView.Background")];
    [dummyView addSubview:pdfView];

    
    [theScrollView addSubview:dummyView];
    [theScrollView setContentSize:dummyView.bounds.size];
//    [theScrollView setContentSize:[self contentSizeWithMinimumSize:pdfView.bounds.size]];

    //    dispatch_async(dispatch_get_main_queue(), ^ {
//        [theScrollView addSubview:pdfView];
//    });
    
//    [theScrollView setContentSize:pdfView.bounds.size];
    
//    UILongPressGestureRecognizer* recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
//    [theScrollView addGestureRecognizer:recognizer];
    
    UITapGestureRecognizer* recognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    recognizer2.numberOfTapsRequired = 2;
    recognizer2.numberOfTouchesRequired = 1;
    [theScrollView addGestureRecognizer:recognizer2];
    
    UITapGestureRecognizer* recognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [recognizer3 requireGestureRecognizerToFail:recognizer2];
    [theScrollView addGestureRecognizer:recognizer3];
    
    
    
    
//    // observing scrollview
//    
//    [theScrollView addObserver:self forKeyPath:@"dragging" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
//    [theScrollView addObserver:self forKeyPath:@"tracking" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
//    [theScrollView addObserver:self forKeyPath:@"zooming" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    
    
    return theScrollView;
}


- (CGSize) contentSizeForScrollView:(UIScrollView*) theScrollView withMinimumSize:(CGSize) minimumSize {

    NSLog(@"superview: %@", theScrollView.superview);
    
//    ratio = self.containerView.bounds.size.width / ((UIView*)[self.exerciseView.subviews objectAtIndex:0]).bounds.size.width;

    CGFloat screenWidthInPortraitMode = (is_ipad) ? 768 : 320;
    CGFloat contentWidthInPortraitMode = screenWidthInPortraitMode - 2;
    CGFloat ratio = contentWidthInPortraitMode / minimumSize.width;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;

    CGFloat navigationBarHeightInPortraitMode = 44;
    CGFloat topHeight = /* navigationBarHeightInPortraitMode + */ self.containerView.frame.origin.y;  // height of navbar + segmented + titlebar
    CGFloat contentHeightInPortraitMode = screenSize.height - topHeight;  // minus thumbnail bar (for fullscreen mode)
    
    CGFloat stretchedContentHeight = contentHeightInPortraitMode / ratio;
    
//    alert(@"contentSizeWithMinimumSize: screenHeight=%f, topHeight=%f, ratio=%f, contentHeightInPort=%f", screenSize.height, topHeight, ratio, contentHeightInPortraitMode);
    
    CGSize stretchedContentSize = CGSizeMake(minimumSize.width,
                                             MAX(stretchedContentHeight, minimumSize.height));
    
    return stretchedContentSize;
}

//- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    
//    NSLog(@"observing: %@ new: %@, old: %@", keyPath, [change objectForKey:NSKeyValueChangeNewKey], [change objectForKey:NSKeyValueChangeOldKey]);
//}


- (void) layout {
    
//    NSLog(@"PageViewController layout");
    
//    CGSize scaledSize = CGSizeScaleToSize(_pdfView.frame.size, scrollView.frame.size, YES);
//    _pdfView.frame = CGRectMake(0, 0, scaledSize.width, scaledSize.height);
    
//    NSLog(@"scrollview size: %@", NSStringFromCGSize(self.scrollView.frame.size));
//    NSLog(@"pdfview bounds size: %@", NSStringFromCGSize(_pdfView.bounds.size));
    
//    float ratio = scrollView.frame.size.width / _pdfView.bounds.size.width;
    //    NSLog(@"-- ratio: %f", ratio);
    //    _pdfView.contentScaleFactor = ratio;

    CGFloat ratio;
    
    // exercise view
    self.exerciseView.frame = CGRectMake(0, 0, self.containerView.bounds.size.width, self.containerView.bounds.size.height);
    ratio = self.containerView.bounds.size.width / ((UIView*)[self.exerciseView.subviews objectAtIndex:0]).bounds.size.width;
    self.exerciseView.maximumZoomScale = 8.0 * ratio;
    self.exerciseView.minimumZoomScale = ratio;
    [self.exerciseView setZoomScale:ratio animated:FALSE];
    self.exerciseView.contentOffset = CGPointZero;
//    [self.exerciseView setContentSize:[self contentSizeForScrollView:self.exerciseView withMinimumSize:((UIView*)[self.exerciseView.subviews objectAtIndex:0]).bounds.size]];

    
    

    // solution view
    if (self.solutionView) {
        self.solutionView.frame = CGRectMake(0, 0, self.containerView.bounds.size.width, self.containerView.bounds.size.height);
        ratio = self.containerView.bounds.size.width / ((UIView*)[self.solutionView.subviews objectAtIndex:0]).bounds.size.width;
        self.solutionView.maximumZoomScale = 8.0 * ratio;
        self.solutionView.minimumZoomScale = ratio;
        [self.solutionView setZoomScale:ratio animated:FALSE];
        self.solutionView.contentOffset = CGPointZero;
//        [self.solutionView setContentSize:[self contentSizeForScrollView:self.solutionView withMinimumSize:((UIView*)[self.solutionView.subviews objectAtIndex:0]).bounds.size]];
    }
    
    // knowledge view
    if (self.knowledgeView) {
        self.knowledgeView.frame = CGRectMake(0, 0, self.containerView.bounds.size.width, self.containerView.bounds.size.height);
        ratio = self.containerView.bounds.size.width / ((UIView*)[self.knowledgeView.subviews objectAtIndex:0]).bounds.size.width;
        self.knowledgeView.maximumZoomScale = 8.0 * ratio;
        self.knowledgeView.minimumZoomScale = ratio;
        [self.knowledgeView setZoomScale:ratio animated:FALSE];
        self.knowledgeView.contentOffset = CGPointZero;
//        [self.knowledgeView setContentSize:[self contentSizeForScrollView:self.knowledgeView withMinimumSize:((UIView*)[self.knowledgeView.subviews objectAtIndex:0]).bounds.size]];
    }
    
    assert(self.exerciseView.zoomScale == self.exerciseView.minimumZoomScale);
    
    
    // layout popup menu
    uint marginRight = 10;
    uint favButtonLeftMargin = 79;
    
    [self.popupMenuView setFrameX:self.view.frame.size.width / 2 - favButtonLeftMargin - 22];
    [self.popupMenuView setFrameWidth:self.view.frame.size.width - marginRight - self.popupMenuView.frame.origin.x];

    UIImage* popupBGImage = [[UIImage imageNamed:@"popup_background.png"] stretchableImageWithLeftCapWidth:60 topCapHeight:0];
    
    self.popupBGImageView.image = popupBGImage;
    
//    self.scrollView.contentSize = _pdfView.frame.size;
    
    [self.segmentedControl setNeedsDisplay];
}


- (IBAction) switchDocument:(id)sender {

    [self switchToDocument:((CustomSegmentedControl*)sender).selectedIndex];
}


- (void) switchToDocument:(DocumentType) documentType {
    
    [self.activeDocumentView removeFromSuperview];
    
    switch (documentType) {
            
        case 0:
            self.activeDocumentView = self.exerciseView;
            _currentDocumentType = DocumentTypeExercise;
            break;
            
        case 1:
            self.activeDocumentView = solutionView;
            _currentDocumentType = DocumentTypeSolution;
            break;
            
        case 2:
            self.activeDocumentView = self.knowledgeView;
            _currentDocumentType = DocumentTypeKnowledge;
            break;
    }
    
    _scrollManager.scrollView = activeDocumentView;
    
    [self.containerView insertSubview:self.activeDocumentView atIndex:0];
    self.noteScrollViewController.forwardView = self.activeDocumentView;
    self.noteScrollViewController.currentDocumentType = _currentDocumentType;
    
    
    [self.noteScrollViewController update];
}


- (void) updateFavoriteButton {
    
//    BOOL isFavorite = [UserDataManager isFavoriteForModule:[PDFManager manager].moduleName category:[PDFManager manager].categoryName page:_pageNumber];
    
    BOOL isFavorite = model.isFavorite;
    
    if (isFavorite) {
        self.favoritesButton.selected = TRUE;
    }
    else {
        self.favoritesButton.selected = FALSE;
    }
}


- (IBAction) switchFavorite {
    
//    BOOL isFavorite = [UserDataManager switchFavoriteForModule:[PDFManager manager].moduleName category:[PDFManager manager].categoryName page:_pageNumber];
    
    BOOL isFavorite = [model switchFavorite];
    
    if (isFavorite) {
        self.favoritesButton.selected = TRUE;
    }
    else {
        self.favoritesButton.selected = FALSE;
    }
}

- (IBAction) switchUnderstood {
    
//    [UserDataManager switchLearnStatus:PageLearnStatusUnderstood forModule:[PDFManager manager].moduleName category:[PDFManager manager].categoryName page:_pageNumber];

    [model switchLearnStatus:PageLearnStatusUnderstood];
    
    [self updateLearnStatusButtons];
}


- (IBAction) switchNotUnderstood {
    
//    [UserDataManager switchLearnStatus:PageLearnStatusNotUnderstood forModule:[PDFManager manager].moduleName category:[PDFManager manager].categoryName page:_pageNumber];
    
    [model switchLearnStatus:PageLearnStatusNotUnderstood];
    
    [self updateLearnStatusButtons];
}


- (void) updateLearnStatusButtons {

//    PageLearnStatus status = [UserDataManager learnStatusForModule:[PDFManager manager].moduleName category:[PDFManager manager].categoryName page:_pageNumber];
    
    PageLearnStatus status = model.learnStatus;
    
//    NSLog(@"status: %d", status);
    
    switch (status) {
        case PageLearnStatusNew:
            self.checkButton.selected = FALSE;
            self.crossButton.selected = FALSE;
            break;
            
        case PageLearnStatusUnderstood:
            self.checkButton.selected = TRUE;
            self.crossButton.selected = FALSE;
            break;
            
        case PageLearnStatusNotUnderstood:
            self.checkButton.selected = FALSE;
            self.crossButton.selected = TRUE;
            break;
            
        default:
            break;
    }
}


- (IBAction) switchPopupMenu {
    
    if (_isMenuShowing) {
        self.popupMenuView.hidden = TRUE;
        _isMenuShowing = FALSE;
    }
    else {
        self.popupMenuView.hidden = FALSE;
        _isMenuShowing = TRUE;
    }
}



#pragma mark Keyboard Event Handlers


- (uint) keyboardHeight {
    
//    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    UIDeviceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
    
    // iPad
    if (idiom == UIUserInterfaceIdiomPad) {
        
        // iPad portrait
        if (UIDeviceOrientationIsPortrait(orientation)) {

            return Keyboard_Height_iPad_Portrait;
        }
        // iPad landscape
        else if (UIDeviceOrientationIsLandscape(orientation)) {
            
            return Keyboard_Height_iPad_Landscape;
        }
    }
    // else (iPhone and maybe future idioms...)
    else {

        // iPhone portrait
        if (UIDeviceOrientationIsPortrait(orientation)) {
       
            return Keyboard_Height_iPhone_Portrait;
        }
        // iPhone landscape
        else if (UIDeviceOrientationIsLandscape(orientation)) {
            
            return Keyboard_Height_iPhone_Landscape;
        }
    }
    
    return 0; // dummy
}


- (CGSize) correctedWindowSizeBecauseOfStupidApple {
    
    UIDeviceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    if (UIDeviceOrientationIsLandscape(orientation)) {
        
        size = CGSizeMake(size.height, size.width);
    }
    
    return size;
}


- (CGRect) fixConvertedRect:(CGRect) rect becauseOfStupidAppleForOrientation:(UIDeviceOrientation) orientation {
    
    CGSize windowSize = [self correctedWindowSizeBecauseOfStupidApple];
    
    if (orientation == UIDeviceOrientationPortraitUpsideDown) {
        
        rect = CGRectMake(windowSize.width - rect.origin.x - rect.size.width,
                          windowSize.height - rect.origin.y - rect.size.height,
                          rect.size.width,
                          rect.size.height);
    }
    else if (orientation == UIDeviceOrientationLandscapeRight) {

        rect = CGRectMake(rect.origin.y,
                          rect.origin.x,
                          rect.size.height,
                          rect.size.width);
    }
    else if (orientation == UIDeviceOrientationLandscapeLeft) {

        rect = CGRectMake(windowSize.width - rect.origin.y - rect.size.height,
                          windowSize.height - rect.origin.x - rect.size.width,
                          rect.size.height,
                          rect.size.width);
    }
    
    return rect;
}


- (uint) scrollViewHeightWithKeyboardHeight:(uint) keyboardHeight {

//    static float bottomHeight = -1;
    
    
    NSLog(@"keyboardHeight: %d", keyboardHeight);
    
//    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    UIDeviceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//    CGSize windowSize = [UIScreen mainScreen].bounds.size;
    
    NSLog(@"orientation: %d", orientation);
    
    CGRect relativeContainerRect = [self.view convertRect:self.containerView.frame toView:nil];

    NSLog(@"BEFORE relativeContainerRect: %@", NSStringFromCGRect(relativeContainerRect));

    
    // fixing apples stupidness
    
    CGSize windowSize = [self correctedWindowSizeBecauseOfStupidApple];
    relativeContainerRect = [self fixConvertedRect:relativeContainerRect becauseOfStupidAppleForOrientation:orientation];
    
    
    NSLog(@"AFTER relativeContainerRect: %@", NSStringFromCGRect(relativeContainerRect));
    NSLog(@"windowSize: %@", NSStringFromCGSize(windowSize));
    

//    if (bottomHeight == -1) {
//
//        bottomHeight = windowSize.height - relativeContainerRect.origin.y - relativeContainerRect.size.height;
//    }

    CGFloat bottomHeight = [self.delegate bottomHeight];
    
    
    NSLog(@"marginBottom: %f", bottomHeight);
    
    
    CGFloat occludedHeight = keyboardHeight - bottomHeight;
    CGFloat newScrollViewHeight;
    
    if (keyboardHeight > 0) {

        newScrollViewHeight = self.containerView.bounds.size.height - occludedHeight;
    }
    else {
        
        newScrollViewHeight = windowSize.height - relativeContainerRect.origin.y - bottomHeight;
    }
    
    return newScrollViewHeight;
}


- (void) keyboardWillShow:(NSNotification *)notification {
    
    UIScrollView* scrollView = self.activeDocumentView;
    
    uint scrollViewHeight = [self scrollViewHeightWithKeyboardHeight:[self keyboardHeight]];
    
    NSLog(@"WILL SHOW: from=%f, to=%d (contentSize=%@)", self.containerView.bounds.size.height, scrollViewHeight, NSStringFromCGSize(self.exerciseView.contentSize));
    
    [UIView animateWithDuration:Scrollview_Resize_Animation_Duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^(void) {
                         
                         [self.containerView setFrameHeight:scrollViewHeight];
                     }
                     completion:nil];
    
//    // scrolling editView to visible
//    
//    NoteEditView* editView = self.noteScrollViewController.activeTextView.editView;
//    CGPoint neutralPosition = editView.noteView.neutralPosition;
//    CGSize editViewSize = [editView boundingSize];
//    CGRect editViewRect = CGRectMake(neutralPosition.x + Note_ScrollToVisible_Padding,
//                                     neutralPosition.y + Note_ScrollToVisible_Padding,
//                                     editViewSize.width + (2 * Note_ScrollToVisible_Padding),
//                                     editViewSize.height + (2 * Note_ScrollToVisible_Padding));
//    
//    NSLog(@"editViewRect: %@", NSStringFromCGRect(editViewRect));
//    
//    NSLog(@"scrollview: %@", NSStringFromCGSize(scrollView.bounds.size));
//    
//    [scrollView scrollRectToVisible:editViewRect animated:TRUE];
}


- (void) keyboardDidShow:(NSNotification *)notification {
    
}


- (void) keyboardWillHide:(NSNotification *)notification {

    uint scrollViewHeight = [self scrollViewHeightWithKeyboardHeight:0];

    NSLog(@"WILL SHOW: from=%f, to=%d", self.containerView.bounds.size.height, scrollViewHeight);

    [UIView animateWithDuration:Scrollview_Resize_Animation_Duration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^(void) {
                         
                         [self.containerView setFrameHeight:scrollViewHeight];
                     }
                     completion:nil];
}


#pragma mark NoteScrollViewControllerDelegate

- (BOOL) noteScrollViewControllerShouldCreateNote:(NoteScrollViewController*)controller {

    return [delegate pageViewControllerShouldCreateNote:self];
}


- (void) NoteScrollViewControllerDidCreateNote:(NoteScrollViewController *)controller {
    
    return [delegate pageViewControllerDidCreateNote:self];
}


- (BOOL) NoteScrollViewControllerShouldShowNotes:(NoteScrollViewController *)controller {
    
    return [delegate pageViewControllerShouldShowNotes:self];
}


- (void) noteScrollViewControllerDidBeginEditMode:(NoteScrollViewController *)controller {
    
    [self keyboardWillShow:nil];
    
    [self.delegate noteScrollViewControllerDidBeginEditMode:controller];
}


- (void) noteScrollViewControllerWillEndEditMode:(NoteScrollViewController *)controller {
    
    [self keyboardWillHide:nil];
    
    [self.delegate noteScrollViewControllerWillEndEditMode:controller];
}



#pragma mark DocumentViewController Handler Methods

- (BOOL) documentViewControllerShouldScroll {
    
    return [noteScrollViewController documentViewControllerShouldScroll];
}


#pragma mark Gestures

- (void) handleLongPress:(UIGestureRecognizer *)recognizer {

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        
        
//        UIView* view = [recognizer.view.subviews objectAtIndex:0];
//        CGPoint point = [recognizer locationInView:view];
//        
//        NSLog(@"Longpress at point: %@", NSStringFromCGPoint(point));
        
//        MyImageView* imageView = [[MyImageView alloc] initWithImage:[UIImage imageNamed:@"note.png"]];
//        [imageView setFrameOrigin:CGPointMake(point.x - 8, point.y - 8)];
//        
//        [view addSubview:imageView];
        
        [self.noteScrollViewController handleLongPressComplete:recognizer];
    }
    
}


- (void) handleTapGesture:(UIGestureRecognizer *)recognizer {

//    alert(@"tap");
    
   
    [self.noteScrollViewController handleTapGesture:recognizer];
}


- (void) handleDoubleTap:(UIGestureRecognizer *)recognizer {
    
    NSLog(@"double tap");
    
    // if (pdfview is zoomed out at 100%) then zoom in to 200% around touch location
    // else zoom out to 100%
    
    UIScrollView* scrollview = (UIScrollView*)[recognizer view];
    
    CGFloat minZoomScale = scrollview.minimumZoomScale;
    CGFloat currentZoomScale = scrollview.zoomScale;
    
    NSLog(@"zoom: %f (max: %f), contentSize: %@", currentZoomScale, minZoomScale, NSStringFromCGSize(scrollview.contentSize));

    if (roundFDigits(currentZoomScale, 2) == roundFDigits(minZoomScale, 2)) {

        CGPoint touchPosition = [recognizer locationInView:[scrollview.subviews objectAtIndex:0]];
        CGSize frameSize = scrollview.bounds.size;
        
        CGSize subviewSize = [(UIView*)[scrollview.subviews objectAtIndex:0] bounds].size;

        NSLog(@"lala: %@", NSStringFromCGSize(subviewSize));
        

        NSLog(@"touch position: %@, frame size: %@", NSStringFromCGPoint(touchPosition), NSStringFromCGSize(frameSize));

        CGRect zoomRect;

        // subview space: at zoom 1x, PDF metrics
        // zoomed content view space: at whatever current zoom factor
        // frame space: like zoomed content space but translated acc. to offset

        CGSize frameSizeInSubviewSpace = CGSizeMake(frameSize.width / minZoomScale, frameSize.height / minZoomScale);
        
        zoomRect.size.width = frameSizeInSubviewSpace.width / 2;
        zoomRect.size.height = frameSizeInSubviewSpace.height / 2;
        
        zoomRect.origin.x = touchPosition.x - (zoomRect.size.width / 2);
        zoomRect.origin.y = touchPosition.y - (zoomRect.size.height / 2);
        
        NSLog(@"zoom rect: %@", NSStringFromCGRect(zoomRect));
        
        [scrollview zoomToRect:zoomRect animated:TRUE];
    }
    else {
        
        [scrollview setZoomScale:minZoomScale animated:TRUE];
    }
}


- (void)viewDidUnload {
    [self setCheckButton:nil];
    [self setFavoritesButton:nil];
    [self setCrossButton:nil];
    [self setSegmentedControl:nil];
    [super viewDidUnload];
}
@end




@implementation MyImageView


- (id) initWithImage:(UIImage *)image {
    
    if (self = [super initWithImage:image]) {
        
        UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        self.userInteractionEnabled = TRUE;
        [self addGestureRecognizer:recognizer];
    }
    
    return self;
}

- (void) setContentScaleFactor:(CGFloat)contentScaleFactor {
    
//    NSLog(@"setContentScaleFactor: %f", contentScaleFactor);
}


- (void) setTransform:(CGAffineTransform)transform {
    
//    NSLog(@"setTransform: %@", NSStringFromCGAffineTransform(transform));
}


- (void) handleTap:(UIGestureRecognizer *)recognizer {
    
//    NSLog(@"transform: %@", NSStringFromCGAffineTransform(self.transform));
}

@end
