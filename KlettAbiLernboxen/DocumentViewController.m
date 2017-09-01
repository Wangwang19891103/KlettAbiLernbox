//
//  DocumentViewController.m
//  KlettAbiLernboxen
//
//  Created by Wang on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DocumentViewController.h"
#import "PDFView.h"
#import "PageViewController.h"
#import "CGExtensions.h"
#import "PDFManager.h"
#import "ThumbnailsViewController.h"
#import "ThumbnailCreator.h"
#import "ModuleManager.h"
#import "UIColor+Extensions.h"
#import "ContentsOverlayViewController.h"
#import "GlobalCounter.h"
#import "StopTimer.h"
#import "OperationManager.h"


#define PopupMenu_Height 50
#define PopupMenu_Animation_Duration 0.2


@implementation DocumentViewController

@synthesize scrollView1, contentView1, contentsOverlayViewController;
//@synthesize keywords;
@synthesize startingDocumentType;
@synthesize startingOpenNote;
@synthesize thumbnailsBar;
@synthesize popupMenu;
@synthesize menuButton;


- (id) initWithCategory:(NSString *)category pageNumber:(uint)number { 
    
    if (self = [super initWithNibName:@"DocumentViewController" bundle:[NSBundle mainBundle]]) {
        
        _pageViewControllers = [NSMutableDictionary dictionary];
        _model = [[DocumentViewModel alloc] initWithCategory:category];
        _model.delegate = self;
        _viewAppeared = FALSE;
        _modelLoaded = FALSE;
        
        _startingPage = number;
        startingDocumentType = DocumentTypeExercise;

        NSRange pageRange = [[PDFManager manager] pageRangeForCategory:category];
        _currentPage = number - pageRange.location;
        
        self.hidesBottomBarWhenPushed = TRUE;
        _menuOpen = TRUE;  // weil visible im XIB file (wird später invisible gemacht)
        _createNote = FALSE;
        _showNotes = TRUE;
        
        _customNavigationItem = [[CustomNavigationItem alloc] init];
        _customNavigationItem.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0];
        _customNavigationItem.textColor = [UIColor whiteColor];
        _customNavigationItem.title = @"";
        
//        PBaddObserver(self);
        
        // notifications for keyboard events
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
//        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    
    return self;
}


//- (UINavigationItem*) navigationItem {
//    
//    return _customNavigationItem;
//}


- (void) variableValueChangedForName:(NSString *)name {
    
    if ([name isEqualToString:@"thumbnail width"]) {
        
        NSArray* thumbnails = [[PDFManager manager] thumbnailsForCategory:_model.category];
        
        [thumbnailsBar setImages:thumbnails];
        
        [thumbnailsBar setNeedsDisplay];
    }
}


- (void) viewDidLoad {
    
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithPatternImage:resource(@"Images.TableViews.BackgroundPattern")];


    /* ThumbnailBar */
    
    NSArray* thumbnails = [[PDFManager manager] thumbnailsForCategory:_model.category];
    thumbnailsBar.delegate = self;
    thumbnailsBar.blendColor = [[ModuleManager manager] colorForModule:[PDFManager manager].moduleName];
    [thumbnailsBar setImages:thumbnails];
    [thumbnailsBar scrollToPage:_currentPage animated:FALSE];
    
    
    /* PopupMenu */
    
    popupMenu.delegate = self;
    [self setPopupMenuOpen:FALSE animated:FALSE];
    
    popupMenu.showNotesButton.selected = _showNotes;
    
    
    
    self.navigationItem.title = _model.category;
    
    self.contentsOverlayViewController = [[ContentsOverlayViewController alloc] initWithCategory:_model.category pageNumber:_currentPage];
    self.contentsOverlayViewController.view.frame = self.scrollView1.frame;
    self.contentsOverlayViewController.view.alpha = 0.0;
    [self.view addSubview:self.contentsOverlayViewController.view];
    

    self.scrollView1.documentViewController = self;
   
    
    NSLog(@"DocumentViewController viewDidLoad - finished");
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];

    NSLog(@"DocumentViewController viewWillAppear");
    
    [self.navigationController setToolbarHidden:TRUE animated:FALSE];
}


- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    NSLog(@"DocumentViewController viewDidAppear");
    
    _viewAppeared = TRUE;
    
    counter_printall;
    counter_removeAll;
}



- (NSUInteger) supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskAll;
}



//- (void) loadPageViewControllersIfReady {
//    
//    if (!_viewAppeared || !_modelLoaded) return;
//    
//    uint numberOfPages = _model.pageRange.length;
//    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
//    
//    for (int count = 1, done = 0, page = _startingPage, direction = 1; done < numberOfPages; page+=(count * direction), direction *= -1, ++count) {
//        
//        if (page < _model.pageRange.location || page >= (_model.pageRange.location + _model.pageRange.length)) continue;
//        
//        NSLog(@"Loading page: %d", page);
//        
//        counter_incI(@"number_of_pages", 1); //---
//        
//        timer_start(@"PageViewController_init");
//        PageViewController* pageViewController = [[PageViewController alloc] initWithModel:[_model pageViewModelForPageNumber:page]];
//        pageViewController.delegate = self;
////        pageViewController.keywords = self.keywords;
//        timer_add(@"PageViewController_init");
//        
//        
//        dispatch_async(queue, ^(void) {
//            
//            dispatch_sync(dispatch_get_main_queue(), ^(void) {
//                
//                [self addPageViewController2:pageViewController];
//            });
//        });
//        
//        ++done;
//    }
//}



//- (void) addPageViewController:(PageViewController*) controller {
//    
//    [self performSelectorOnMainThread:@selector(addPageViewController2:) withObject:controller waitUntilDone:YES];
//}


- (void) addPageViewController2:(PageViewController*) controller {

    NSLog(@"addPageViewController: %@", controller);
    
    [_pageViewControllers setObject:controller forKey:[NSNumber numberWithInt:controller.pageNumber]];

    // set starting document type (coming from notes)
    if (controller.model.relativePageNumber == _currentPage) {
        
        controller.startingDocumentType = self.startingDocumentType;
    }
    
    [self.contentView1 addSubview:controller.view];

    timer_start(@"PageViewController_layoutPageViewController");
    [self layoutPageViewController:controller];
    timer_add(@"PageViewController_layoutPageViewController");
    
    timer_start(@"PageViewController_updateViews");
    [controller updateViews];
    timer_add(@"PageViewController_updateViews");
    
    counter_printall;
    
    
    
    if (controller.model.relativePageNumber == _currentPage) {
        
        [self updateFavoriteButton];
        [self updateLearnStatusButtons];
    }
}


- (void) documentViewModelDidFinishLoading:(DocumentViewModel *)model {
    
    NSLog(@"document view model did finish loading");
    
    _modelLoaded = TRUE;
    
    /* add PageViewControllers to queue */
    NSMutableArray* pages = [NSMutableArray array];
    PageViewController* pageViewController = nil;
    
    for (int i = _model.pageRange.location; i < (_model.pageRange.location + _model.pageRange.length); ++i) {
    
        pageViewController = [[PageViewController alloc] initWithModel:[_model pageViewModelForPageNumber:i]];
        pageViewController.delegate = self;
//        pageViewController.keywords = self.keywords;
        
        [pages addObject:pageViewController];
    }

    _pageQueue = [[PageQueue alloc] initWithPages:pages];
    _pageQueue.delegate = self;
    _pageQueue.order = PageQueueDiverging;
    _pageQueue.startingIndex = _startingPage - _model.pageRange.location;
    [_pageQueue startQueue];
}


- (BOOL) pageQueueShouldDequeueNextPage:(PageQueue *)queue {
    
    BOOL shouldDequeue = (_viewAppeared && !self.scrollView1.dragging && !thumbnailsBar.scrollView.dragging);
    
    NSLog(@"PageQueues asked for dequeuing. Answering: %d", shouldDequeue);
    
    return shouldDequeue;
}


- (void) pageQueue:(PageQueue *)queue didDequeuePage:(id)page {
    
    [self addPageViewController2:page];
}



- (void) handleTap:(UIGestureRecognizer *)recognizer {
    
    NSLog(@"tap on contentview");
}


- (IBAction) handleSwitchMenu:(id)sender {
    
    [self setPopupMenuOpen:!_menuOpen animated:TRUE];
}


- (void) viewDidLayoutSubviews {
    
    if (_fullscreenAnimating) return;
    
    NSLog(@"DocumentViewController viewDidLayoutSubviews");
    
    [self layout];
}


- (void) layout {
    
    NSLog(@"DocumentViewController layout");

    // resizing subviews in contentview1
//    uint count = 0;
    CGFloat width = self.scrollView1.frame.size.width;
    CGFloat height = self.scrollView1.frame.size.height;
    
    for (NSNumber* key in _pageViewControllers.allKeys) {

        PageViewController* pageViewController = [_pageViewControllers objectForKey:key];
        
        [self layoutPageViewController:pageViewController];
    }
    
    [self.contentView1 setFrameSize:CGSizeMake(width * _model.pageRange.length, height)];
    [self.scrollView1 setContentSize:self.contentView1.frame.size];
    
    // setting content offset properly
    CGFloat currentOffsetTop = self.scrollView1.contentOffset.y;
    self.scrollView1.contentOffset = CGPointMake(_currentPage * self.scrollView1.frame.size.width, currentOffsetTop);
    
    [thumbnailsBar layout];
    
    [popupMenu layout];
    

}


- (void) layoutPageViewController:(PageViewController*)controller {

//    NSLog(@"layoutPageViewController: %@", controller);
    
    CGFloat width = self.scrollView1.frame.size.width;
    CGFloat height = self.scrollView1.frame.size.height;

    [controller.view setFrame:CGRectMake(width * controller.pageNumber, 0, width, height)];
    [controller layout];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    return true;  // seems to not matter
}


- (BOOL) shouldAutorotate {
    
    return TRUE;  // seems to not matter
}


- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
}


- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    
    [_customNavigationItem updateTitleView];
    
    if (_isFullscreen) {
        
        [self layoutFrameAnimated:FALSE];  // layouting starts from non-fullscreen as base because it gets reset somehow by the navi or tabbar controller
    }
    
}


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
//    [self layout];
    

}


- (PageViewController*) visiblePageViewController {
    
    return [_pageViewControllers objectForKey:[NSNumber numberWithInt:_currentPage]];
}


- (void) switchFullscreen {
    
    _isFullscreen = !_isFullscreen;

    [self layoutFrameAnimated:TRUE];
}


/* layouts navigation controller view (for fullscreen mode) */
- (void) layoutFrameAnimated:(BOOL) animated {
    
    CGFloat navBarHeight, segmentedHeight, thumbnailsHeight;
    
    navBarHeight = self.navigationController.navigationBar.bounds.size.height;
    segmentedHeight = [self visiblePageViewController].segmentedControl.bounds.size.height;
    thumbnailsHeight = thumbnailsBar.bounds.size.height;
    
    
    UIView* theView = self.navigationController.view;
 
    CGFloat posY, height;
    
    if (_isFullscreen) {
        
        posY = 0 - navBarHeight;
        height = theView.bounds.size.height + navBarHeight + thumbnailsHeight;
    }
    else {
        
        posY = 0;
        height = theView.bounds.size.height - navBarHeight - thumbnailsHeight;
    }

//    contentHeight = theView.bounds.size.height;  // its the same...
    
    
    
    
    
    
//    contentHeight = self.scrollView1.frame.size.height;
    

    
    // block
    
    void (^layouts)() = ^(void) {
        
        [theView setFrame:CGRectMake(0, posY, theView.bounds.size.width, height)];
        [self.contentView1 setFrameHeight:self.scrollView1.bounds.size.height];
        [self.scrollView1 setContentSize:self.contentView1.frame.size];
    };
    
    
    void (^layouts2)() = ^(void) {
        
        // layouting pageviewcontrollers

        for (NSNumber* key in _pageViewControllers.allKeys) {
            
            PageViewController* pageViewController = [_pageViewControllers objectForKey:key];
            
            [self layoutPageViewController:pageViewController];
        }
    };

    
    if (animated) {
        
        if (_isFullscreen) {
            
            _fullscreenAnimating = TRUE;

            layouts2();
            
            [UIView animateWithDuration:0.5
                             animations:^(void) {
                
                                 layouts();
                                 layouts2();
                             }
                             completion:^(BOOL finished) {
                                 
                                 _fullscreenAnimating = FALSE;
                             }];
        }
        else {
            
            _fullscreenAnimating = TRUE;
            
            [UIView animateWithDuration:0.5 animations:layouts
                             completion:^(BOOL finished) {
                                 
                                 layouts2();
                                 _fullscreenAnimating = FALSE;
                             }];
        }
    }
    else {

        layouts();
        layouts2();
        
//        [theView setFrame:CGRectMake(0, posY, theView.bounds.size.width, height)];
        //        [contentView1 setFrameHeight:contentHeight];
    }

    
    


    
    NSLog(@"navbar: %f, segmented: %f, thumbnail: %f ---> posY: %f, height: %f", navBarHeight, segmentedHeight, thumbnailsHeight, posY, height);

    
//    [self.contentView1 setFrameSize:CGSizeMake(width * _model.pageRange.length, height)];
//    [self.scrollView1 setContentSize:self.contentView1.frame.size];
}





#pragma mark Keyboard Event Handlers

- (void) keyboardWillShow:(NSNotification *)notification {
    
    [[self visiblePageViewController] keyboardWillShow:notification];
}


- (void) keyboardDidShow:(NSNotification *)notification {
    
    [[self visiblePageViewController] keyboardDidShow:notification];
}


- (void) keyboardWillHide:(NSNotification *)notification {
    
    [[self visiblePageViewController] keyboardWillHide:notification];
}




#pragma mark ThumbnailBarDelegate

- (void) thumbnailWillBeginDragging {
    
    [UIView animateWithDuration:0.2 animations:^(void) {
        self.contentsOverlayViewController.view.alpha = 1.0;
    }];
}


- (void) thumbnailDidEndDragging {
    
    [UIView animateWithDuration:0.2 animations:^(void) {
        self.contentsOverlayViewController.view.alpha = 0.0;
    }];
}


- (void) thumbnailDidHitPageNumber:(uint)pageNumber {
    
    [self.contentsOverlayViewController highlightPageNumber:pageNumber];
}


- (void) thumbnailWasSelectedForPage:(uint)page {
    
//    NSLog(@"page %d was selected", page);
    
    [self.scrollView1 setContentOffset:CGPointMake(page * self.scrollView1.frame.size.width, 0) animated:TRUE];
    
    _currentPage = page;
    
    _pageQueue.startingIndex = _currentPage;
    
//    [self updateFavoriteButton];
    
    [self updateFavoriteButton];
    [self updateLearnStatusButtons];
}


#pragma mark PopupMenuDelegate

- (void) popupMenuFavoriteButtonWasTouchedSelected:(BOOL)selected {
    
    NSLog(@"favorite button touched (selected=%d", selected);
    
    [self switchFavorite];
}


- (void) popupMenuCheckButtonWasTouchedSelected:(BOOL)selected {

    NSLog(@"check button touched (selected=%d", selected);
    
    [self switchUnderstood];
}


- (void) popupMenuCrossButtonWasTouchedSelected:(BOOL)selected {
    
    NSLog(@"cross button touched (selected=%d", selected);
    
    [self switchNotUnderstood];
}


- (void) popupMenuShowNotesButtonWasTouchedSelected:(BOOL)selected {
    
    NSLog(@"shownotes button touched (selected=%d", selected);
    
    _showNotes = !_showNotes;
    
    popupMenu.showNotesButton.selected = _showNotes;
    
    [[self visiblePageViewController] updateNotes];
    
}


- (void) popupMenuAddNoteButtonWasTouchedSelected:(BOOL)selected {
    
    NSLog(@"addnote button touched (selected=%d", selected);
    
    _createNote = !_createNote;
    
    popupMenu.addNoteButton.selected = _createNote;
}


- (void) popupMenuFullscreenButtonWasTouchedSelected:(BOOL)selected {

    popupMenu.fullscreenButton.selected = !_isFullscreen;

    [self switchFullscreen];
}



#pragma mark PopupMenu Methods

- (void) setPopupMenuOpen:(BOOL)open animated:(BOOL)animated {
    
    if (open == _menuOpen) return;
    
    _menuOpen = open;
    
    static UIImage* openMenu = nil;
    static UIImage* closeMenu = nil;
    
    if (!openMenu) {
        
        openMenu = resource(@"Images.DocumentView.PopupMenu.Buttons.OpenMenu");
        closeMenu = resource(@"Images.DocumentView.PopupMenu.Buttons.CloseMenu");
    }
    
    
    /* slide in/out menu */
    
    if (open) {
        
        if (animated) {
            
            [UIView animateWithDuration:PopupMenu_Animation_Duration
                                  delay:0
                                options:0
                             animations:^(void) {

                                 [popupMenu setFrameY:popupMenu.frame.origin.y - popupMenu.frame.size.height];
                                 [menuButton setImage:closeMenu forState:UIControlStateNormal];

                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
        else {

            [popupMenu setFrameY:popupMenu.frame.origin.y - popupMenu.frame.size.height];
            [menuButton setImage:closeMenu forState:UIControlStateNormal];
        }
    }
    else {
        if (animated) {
            
            [UIView animateWithDuration:PopupMenu_Animation_Duration
                                  delay:0
                                options:0
                             animations:^(void) {
                                 
                                 [popupMenu setFrameY:popupMenu.frame.origin.y + popupMenu.frame.size.height];
                             }
                             completion:^(BOOL finished) {
                                 
                                 [menuButton setImage:openMenu forState:UIControlStateNormal];
                             }];
        }
        else {
            
            [popupMenu setFrameY:popupMenu.frame.origin.y + popupMenu.frame.size.height];
            [menuButton setImage:openMenu forState:UIControlStateNormal];
        }
    }
}


- (void) updateFavoriteButton {
    
    BOOL isFavorite = [self visiblePageViewController].model.isFavorite;
    
    popupMenu.favoriteButton.selected = isFavorite;
}


- (void) switchFavorite {
    
    BOOL isFavorite = [[self visiblePageViewController].model switchFavorite];

    popupMenu.favoriteButton.selected = isFavorite;
}


- (IBAction) switchUnderstood {
    
    [[self visiblePageViewController].model switchLearnStatus:PageLearnStatusUnderstood];
    
    [self updateLearnStatusButtons];
}


- (IBAction) switchNotUnderstood {
    
    [[self visiblePageViewController].model switchLearnStatus:PageLearnStatusNotUnderstood];
    
    [self updateLearnStatusButtons];
}


- (void) updateLearnStatusButtons {
    
    PageLearnStatus status = [self visiblePageViewController].model.learnStatus;
    
    switch (status) {
        case PageLearnStatusNew:
            popupMenu.checkButton.selected = FALSE;
            popupMenu.crossButton.selected = FALSE;
            break;
            
        case PageLearnStatusUnderstood:
            popupMenu.checkButton.selected = TRUE;
            popupMenu.crossButton.selected = FALSE;
            break;
            
        case PageLearnStatusNotUnderstood:
            popupMenu.checkButton.selected = FALSE;
            popupMenu.crossButton.selected = TRUE;
            break;
            
        default:
            break;
    }
}



#pragma mark PageViewControllerDelegate

- (BOOL) pageViewControllerShouldCreateNote:(PageViewController *)controller {
    
    return _createNote;
}


- (void) pageViewControllerDidCreateNote:(PageViewController *)controller {
    
    _createNote = FALSE;
    
    popupMenu.addNoteButton.selected = FALSE;
    
    // when note has been created, notes will automatically be shown
    
    _showNotes = TRUE;
    
    popupMenu.showNotesButton.selected = _showNotes;
    
    [[self visiblePageViewController] updateNotes];
}


- (BOOL) pageViewControllerShouldShowNotes:(PageViewController *)controller {
    
    return _showNotes;
}


- (CGFloat) bottomHeight {
    
    if (_isFullscreen) {
        
        return 0;
    }
    else {
        
        return thumbnailsBar.bounds.size.height;
    }
}


- (void) noteScrollViewControllerDidBeginEditMode:(NoteScrollViewController *)controller {
    
    self.scrollView1.scrollEnabled = FALSE;
}


- (void) noteScrollViewControllerWillEndEditMode:(NoteScrollViewController *)controller {
    
    self.scrollView1.scrollEnabled = TRUE;
}



#pragma mark UIScrollViewDelegate




- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

//    NSLog(@"DocumentViewController scrollviewdidenddecelerating");

    [self handlePage];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
//    NSLog(@"DocumentViewController scrollViewDidEndDragging");
    
    if (!decelerate) { 
        [self handlePage];
    }
}

- (void) handlePage {

//    NSLog(@"handle page");
    
//    _currentPage = floor(self.scrollView1.contentOffset.x / self.scrollView1.frame.size.width);
    CGFloat div = self.scrollView1.contentOffset.x / self.scrollView1.frame.size.width;
    uint fullPage = floor(div);
    CGFloat rest = div - fullPage;
    _currentPage = (rest > 0.5) ? fullPage + 1 : fullPage;
    
//    NSLog(@"currentPage: %d", _currentPage);
    
    [thumbnailsBar scrollToPage:_currentPage animated:TRUE];
    
    _pageQueue.startingIndex = _currentPage;
    
//    [self updateFavoriteButton];
    
    [self updateFavoriteButton];
    [self updateLearnStatusButtons];
}


- (void) dealloc {
    
    NSLog(@"DocumentViewController dealloc");
    
    [_pageQueue stopQueue];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

@end






@implementation DocumentScrollView

@synthesize documentViewController;


//- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    
//    if (gestureRecognizer == self.panGestureRecognizer
//        && ![[self.documentViewController visiblePageViewController] documentViewControllerShouldScroll]) {
//        
//        NSLog(@"DocumentScrollView blocking...");
//        
//        return FALSE;
//    }
//    else {
//        
//        return [super gestureRecognizerShouldBegin:gestureRecognizer];
//    }
//}


@end







@implementation PageLoadOperation

@synthesize superView, viewController;





- (void) main {
    
    [superView performSelectorOnMainThread:@selector(addSubview:) withObject:viewController.view waitUntilDone:FALSE];
}

@end
