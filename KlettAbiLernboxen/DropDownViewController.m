//
//  DropDownView.m
//  KlettAbiLernboxen
//
//  Created by Wang on 14.09.12.
//
//

#import "DropDownViewController.h"
#import "NSObject+Extensions.h"
#import "UIColor+Extensions.h"


#define LabelHeight 38
#define PageTitleHeight ti_int2(20, 1.5)
#define Icon_Size CGSizeMake(15,15)
#define Icon_Text_Distance 6
#define AnimationDuration 0.3
#define PrefixStringExpanded @"[-]"
#define PrefixStringCollapsed @"[+]"

static NSString* __colors[2] = {@"255,255,255", @"255,255,255"};
static NSString* __textColors[2] = {@"0,0,0", @"0,0,0"};
static int __indents[3] = {13,34,55};

static UIImage* arrowDownImage = nil;
static UIImage* arrowRightImage = nil;
static UIImage* seperatorImage = nil;



#pragma mark - DropDownViewController

@implementation DropDownViewController

@synthesize delegate;
@synthesize font, font2;


- (id) initWithArray:(NSArray*) theArray {
    
    if (self = [super init]) {
        
        _array = theArray;
        _views = [NSMutableArray array];
        
        arrowDownImage = resource(@"Images.Misc.BlueArrowDown");
        arrowRightImage = resource(@"Images.Misc.BlueArrowRight");
        seperatorImage = [resource(@"Images.Misc.SeperatorPattern") resizableImageWithCapInsets:UIEdgeInsetsZero];
        
//        NSLog(@"%@", _array);
        
    }
    
    return self;
}


- (void) viewDidLoad {
    
    [super viewDidLoad];

    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.view.backgroundColor = [UIColor redColor];
    self.view.clipsToBounds = TRUE;
    self.view.autoresizesSubviews = TRUE;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:resource(@"Images.TableViews.BackgroundPattern")];
    
//    _topSeperator = [[UIImageView alloc] initWithImage:seperatorImage];
//    _topSeperator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    [_topSeperator setFrameX:0];
//    [_topSeperator setFrameY:0];
//    [_topSeperator setFrameWidth:320];
//    [self.view addSubview:_topSeperator];
    
    /* iterate categores */
    uint count = 0;
    for (NSArray* catArray in _array) {
        
        NSString* catTitle = [catArray objectAtIndex:0];
        NSArray* catSubContents = [catArray objectAtIndex:1];
        
        UIImageView* seperator = [[UIImageView alloc] initWithImage:seperatorImage];
        seperator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [seperator setFrameX:0];
        [seperator setFrameWidth:self.view.bounds.size.width];
        [self.view addSubview:seperator];
        
        DropDownHubView* catHubView = [[DropDownHubView alloc] initWithTitle:catTitle atLevel:0];
        catHubView.font = font;
        catHubView.delegate = self;
        [catHubView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
        [_views addObject:catHubView];
        [self.view addSubview:catHubView];
        
        /* iterate pages OR subcategories */
        uint subcatCount = 0;
        for (id catSubContentEntry in catSubContents) {

            if ([catSubContentEntry isKindOfClass:[NSString class]]) {

                NSString* pageTitle = (NSString*)catSubContentEntry;

                NSArray* comps = [pageTitle componentsSeparatedByString:@"::"];
                
                if (comps.count == 2 && [[comps objectAtIndex:0] isEqualToString:@"pdf"]) {
                    
                    NSString* path = [comps objectAtIndex:1];
                    
                    DropDownWebView* view = [[DropDownWebView alloc] initWithHTMLPath:path atLevel:2];
                    view.font = font2;
                    [view setFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
                    [catHubView addView:view];
                }
                else {
                    
                    DropDownView* view = [[DropDownView alloc] initWithTitle:pageTitle atLevel:2];
                    view.font = font2;
                    [view setFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
                    [catHubView addView:view];
                }
                
//                DropDownView* view = [[DropDownView alloc] initWithTitle:pageTitle atLevel:1];
//                view.font = font;
//                [view setFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
//                [catHubView addView:view];
            }
            else if ([catSubContentEntry isKindOfClass:[NSArray class]]){
                
                NSArray* catSubContentArray = (NSArray*)catSubContentEntry;
                
                NSString* subcatTitle = [catSubContentArray objectAtIndex:0];
                
                if ([[catSubContentArray objectAtIndex:1] isKindOfClass:[NSArray class]]) {
                
                    NSArray* pageTitles = [catSubContentArray objectAtIndex:1];
                    
                    UIImageView* seperator = [[UIImageView alloc] initWithImage:seperatorImage];
                    seperator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                    [seperator setFrameX:0];
                    [seperator setFrameWidth:self.view.bounds.size.width];
                    [catHubView addSubview:seperator];
                    
                    DropDownHubView* subcatHubView = [[DropDownHubView alloc] initWithTitle:subcatTitle atLevel:1];
                    subcatHubView.font = font;
                    [subcatHubView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
                    subcatHubView.delegate = catHubView;
                    [catHubView addView:subcatHubView];
                    
                    /* iterate pages */
                    for (NSString* pageTitle in pageTitles) {
                        
                        DropDownView* view = [[DropDownView alloc] initWithTitle:pageTitle atLevel:2];
                        view.font = font2;
                        [view setFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
                        [subcatHubView addView:view];
                    }
                    
                }
                else if ([[catSubContentArray objectAtIndex:1] isKindOfClass:[NSString class]]) {
                    
                    NSString* pageTitle = [catSubContentArray objectAtIndex:1];
                    
                    UIImageView* seperator = [[UIImageView alloc] initWithImage:seperatorImage];
                    seperator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                    [seperator setFrameX:0];
                    [seperator setFrameWidth:self.view.bounds.size.width];
                    [catHubView addSubview:seperator];
                    
                    DropDownHubView* subcatHubView = [[DropDownHubView alloc] initWithTitle:subcatTitle atLevel:1];
                    subcatHubView.font = font;
                    [subcatHubView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
                    subcatHubView.delegate = catHubView;
                    [catHubView addView:subcatHubView];

                    
                    NSArray* comps = [pageTitle componentsSeparatedByString:@"::"];
                    
                    if (comps.count == 2 && [[comps objectAtIndex:0] isEqualToString:@"pdf"]) {
                        
                        NSString* path = [comps objectAtIndex:1];
                        
                        DropDownWebView* view = [[DropDownWebView alloc] initWithHTMLPath:path atLevel:2];
                        view.font = font2;
                        [view setFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
                        [subcatHubView addView:view];
                    }
                    else {
                     
                        DropDownView* view = [[DropDownView alloc] initWithTitle:pageTitle atLevel:2];
                        view.font = font2;
                        [view setFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
                        [subcatHubView addView:view];
                    }
                }
                
            }
            
            ++subcatCount;
        }
        
        
        ++count;
    }
    
    _bottomSeperator = [[UIImageView alloc] initWithImage:seperatorImage];
    _bottomSeperator.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_bottomSeperator setFrameX:0];
    [_bottomSeperator setFrameWidth:self.view.bounds.size.width];
    [self.view addSubview:_bottomSeperator];
    
//    [self refreshViewAnimated:FALSE];

//    NSLog(@"%@", _views);
//    NSLog(@"self height: %f", self.view.frame.size.height);
    
    self.view.clipsToBounds = TRUE;
}


- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];

    [self resetView];
}


- (void) layout {
    
    float posY = 0;
    
    for (UIView* view in self.view.subviews) {
        
        if ([view isKindOfClass:[DropDownHubView class]]) {
            
            DropDownHubView* hubView = (DropDownHubView*) view;
            
            [hubView layoutAnimated];
            
            [hubView setFrameY:posY];
            
            posY += hubView.totalHeight;
        }
        else {
            
            [view setFrameY:posY];
            
            posY += view.frame.size.height;
        }
    }
    
    [UIView animateWithDuration:AnimationDuration animations:^(void) {

        [self.view setFrameHeight:posY];
    }];
    
    [delegate dropDownViewController:self didChangeHeight:posY];
}


- (void) resetView {
    
    float posY = 0;
    
    for (UIView* view in self.view.subviews) {
        
        if ([view isKindOfClass:[DropDownHubView class]]) {

            DropDownHubView* hubView = (DropDownHubView*) view;
            
            [hubView resetView];
            
            [hubView setFrameY:posY];
            
            posY += hubView.totalHeight;
        }
        else {
            
            [view setFrameY:posY];
            
            posY += view.frame.size.height;
        }
    }
    
//    [_bottomSeperator setFrameY:posY];
//    
//    posY += _bottomSeperator.frame.size.height;
    
    [self.view setFrameHeight:posY];
    
    [delegate dropDownViewController:self didChangeHeight:posY];
}


- (void) expandHubView:(NSArray *)hubViewStack {
    
//    NSLog(@"expandHubView at Root Hubview");
    
    float __block posY = 0;
    
    for (UIView* view in self.view.subviews) {
        
        if ([view isKindOfClass:[DropDownHubView class]]) {
        
            DropDownHubView* childHubView = (DropDownHubView*) view;
            
            if ([hubViewStack objectAtIndex:0] == childHubView) {
                
                [childHubView expandHubView:hubViewStack];
            }
            else if (childHubView.isExpanded) {
                
                [childHubView collapseHubView:[NSArray arrayWithObject:childHubView]];
            }
            
            [UIView animateWithDuration:AnimationDuration delay:0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^(void) {
                                 
                                 [childHubView setFrameY:posY];
                             }
                             completion:^(BOOL finished) {}];
            
            posY += childHubView.totalHeight;
        }
        else {
            
            
            [UIView animateWithDuration:AnimationDuration delay:0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^(void) {
                                 
                                 [view setFrameY:posY];
                             }
                             completion:^(BOOL finished) {}];
            
            posY += view.frame.size.height;
        }
    }
    
    [UIView animateWithDuration:AnimationDuration delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^(void) {
                         
//                         [_bottomSeperator setFrameY:posY];
//                         
//                         posY += _bottomSeperator.frame.size.height;
                         
                         [self.view setFrameHeight:posY];
                        }
                     completion:^(BOOL finished) {}];
    
    [delegate dropDownViewController:self didChangeHeight:posY];
}


- (void) collapseHubView:(NSArray *)hubViewStack {
    
    NSLog(@"collapseHubView at Root HubView");
    
    float __block posY = 0;
    
    for (UIView* view in self.view.subviews) {
        
        if ([view isKindOfClass:[DropDownHubView class]]) {
        
            DropDownHubView* childHubView = (DropDownHubView*) view;
            
            if ([hubViewStack objectAtIndex:0] == childHubView) {
                
                [childHubView collapseHubView:hubViewStack];
            }
            
            [UIView animateWithDuration:AnimationDuration
                                  delay:0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^(void) {
                                 
                                 [childHubView setFrameY:posY];
                             }
                             completion:^(BOOL finished) {
                             }];
            
            posY += childHubView.totalHeight;
        }
        else {
            
            [UIView animateWithDuration:AnimationDuration
                                  delay:0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^(void) {
                                 
                                 [view setFrameY:posY];
                             }
                             completion:^(BOOL finished) {
                             }];
            
            posY += view.frame.size.height;
        }
    }
    
    [UIView animateWithDuration:AnimationDuration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^(void) {
                         
//                         [_bottomSeperator setFrameY:posY];
//                         
//                         posY += _bottomSeperator.frame.size.height;
                         
                         [self.view setFrameHeight:posY];
                     }
                     completion:^(BOOL finished) {
                     }];
    
    [delegate dropDownViewController:self didChangeHeight:posY];
}


//- (void) refreshViewAnimated:(BOOL)animated {
//    
//    NSLog(@"(base) refresh view");
//    
//    float posY = 0;
//    
//    for (DropDownHubView* hubView in _views) {
//        
//        [hubView refreshViewAnimated:false];
//        
//        NSLog(@"hubView height: %f", hubView.totalHeight);
//
//        if (animated) {
//            
//            [UIView animateWithDuration:0.3 animations:^(void) {
//
//                [hubView setFrameY:posY];
//            }];
//        }
//        else {
//            
//            [hubView setFrameY:posY];
//        }
//
//        posY += hubView.totalHeight;
//    }
//    
//    if (animated) {
//        
//        [UIView animateWithDuration:0.3 animations:^(void) {
//            
//            [self.view setFrameHeight:posY];
//        }];
//    }
//    else {
//        
//        [self.view setFrameHeight:posY];
//    }
//    
//    
//    [delegate dropDownViewController:self didChangeHeight:posY];
//}


//- (void) hubViewWasTouched:(DropDownHubView *)hubView {
//    
//    NSLog(@"hubview was touched, height=%f", hubView.totalHeight);
//    
//    NSLog(@"hubview: %@", hubView);
//    
//    for (UIView* view in _views) {
//        
//        if ([view isKindOfClass:[DropDownHubView class]]) {
//            
//            NSLog(@"view: %@", view);
//            
//            if (view != hubView) {
//                
//                NSLog(@"ungleich");
//
//                DropDownHubView* hubView = (DropDownHubView*) view;
//
//                [hubView setExpanded:FALSE];
//            }
//        }
//    }
//    
//    [self refreshViewAnimated:TRUE];
//}


- (void) hubViewShouldExpand:(NSMutableArray *)hubViewStack {
    
//    NSLog(@"hubViewShouldExpend at Root HubView");

    [self printStack:hubViewStack];

    [self expandHubView:hubViewStack];
    
    if ([(NSObject*)self.delegate respondsToSelector:@selector(dropDownViewController:didSelectView:)]) {
     
        [self.delegate dropDownViewController:self didSelectView:[hubViewStack lastObject]];
    }
}


- (void) hubViewShouldCollapse:(NSMutableArray *)hubViewStack {
    
//    NSLog(@"hubViewShouldCollapse at Root HubView");
    
    [self printStack:hubViewStack];

    [self collapseHubView:hubViewStack];
}

//- (void) hubViewRequestedRefresh:(DropDownHubView *)hubView {
//    
//    [self refreshViewAnimated:TRUE];
//}



- (void) printStack:(NSArray *)hubViewStack {
    
//    NSLog(@"Printing HubView stack:");
    
    for (DropDownHubView* hubView in hubViewStack) {
        
//        NSLog(@"%@", hubView);
    }
}

@end



#pragma mark - DropDownHubView

@implementation  DropDownHubView

@synthesize totalHeight;
@synthesize minimumHeight;
@synthesize delegate;
@synthesize isExpanded;
@synthesize level = _level;
@synthesize title = _title;
@synthesize font;
@synthesize imageView;


#pragma mark Initializer

- (id) initWithTitle:(NSString *)title atLevel:(uint)level {
    
    if (self = [super init]) {
        
        _title = [title copy];
        _views = [NSMutableArray array];
        isExpanded = FALSE;
        _level = level;

        
        self.clipsToBounds = TRUE;
//        self.backgroundColor = [UIColor colorFromString:__colors[_level]];
        self.backgroundColor = [UIColor colorWithPatternImage:resource(@"Images.TableViews.BackgroundPattern")];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.autoresizesSubviews = TRUE;
    }
    
    return self;
}


#pragma mark View Lifecycle

- (void) didMoveToSuperview {
    
//    NSLog(@"move to superview");
    
    [super didMoveToSuperview];
    
    if (self.superview) {
        
        UIView* titleView = [[UIView alloc] init];
        titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        imageView = [[UIImageView alloc] initWithImage:arrowRightImage];
        [imageView setFrameOrigin:CGPointMake(__indents[_level], floor((LabelHeight - imageView.bounds.size.height) * 0.5))];
        [titleView addSubview:imageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = font;
        _titleLabel.numberOfLines = 1;
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
//        CGSize textSize = [_title sizeWithFont:font constrainedToSize:CGSizeMake(self.frame.size.width - __indents[_level], 40)];
        
//        textSize = [_title sizeWithFont:font forWidth:self.frame.size.width - __indents[_level] lineBreakMode:UILineBreakModeWordWrap];
        
//        textSize = [_title sizeWithFont:font];
        
//        NSLog(@"title: %@", _title);
//        NSLog(@"font: %@", font);
//        NSLog(@"textSize: %@", NSStringFromCGSize(textSize));
        
//        [_titleLabel setFrameOrigin:CGPointMake(__indents[_level], 0)];
//        [_titleLabel setFrameSize:textSize];
        
        int posX = imageView.frame.origin.x + imageView.frame.size.width + Icon_Text_Distance;
        
        [_titleLabel setFrame:CGRectMake(posX,
                                         0,
                                         self.frame.size.width - posX,
                                         LabelHeight)];
        _titleLabel.text = _title;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        
        [titleView addSubview:_titleLabel];
        
        UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        _titleLabel.userInteractionEnabled = TRUE;
        [self addGestureRecognizer:recognizer];
        
        minimumHeight = LabelHeight;
        
        
        [self addSubview:titleView];
        [titleView setFrame: CGRectMake(0, 0, 320, LabelHeight)];
        
    }
    
//    [self refreshViewAnimated:FALSE];
}


#pragma mark Methods

- (void) addView:(UIView *)view {
    
    [_views addObject:view];
    [self addSubview:view];
//    view.hidden = TRUE;
    
//    [view setFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
    
//    [self refreshViewAnimated:FALSE];
}




- (void) resetView {
    
//    NSLog(@"resetView at HubView: %@", self);
    
    float posY = 0;
    
    isExpanded = FALSE;
    
    [self adjustTitleLabel];
    
    for (UIView* view in self.subviews) {
        
        if ([view isKindOfClass:[DropDownHubView class]]) {
            
            DropDownHubView* hubView = (DropDownHubView*) view;
            
            [hubView resetView];
            
            [hubView setFrameY:posY];
            
            posY += hubView.totalHeight;
        }
        else {
            
            [view setFrameY:posY];
            
            posY += view.frame.size.height;
        }
    }
    
    totalHeight = minimumHeight;
    
    [self setFrameHeight:totalHeight];
}


- (void) layoutAnimated {
    
    float posY = 0;
    
//    [self adjustTitleLabel];
    
    for (UIView* view in self.subviews) {
        
        if ([view isKindOfClass:[DropDownHubView class]]) {
            
            DropDownHubView* hubView = (DropDownHubView*) view;
            
            [hubView layoutAnimated];
            
            [hubView setFrameY:posY];
            
            posY += hubView.totalHeight;
        }
        else if ([view isKindOfClass:[DropDownWebView class]]) {
            
            DropDownWebView* webView = (DropDownWebView*) view;
            
            [webView layoutAnimated];
            
            [webView setFrameY:posY];
            
            posY += webView.frame.size.height;
        }
        else {
            
            [view setFrameY:posY];
            
            posY += view.frame.size.height;
        }
    }
    
    if (isExpanded) {
        
        totalHeight = posY;
    }
    else {
        
        totalHeight = minimumHeight;
    }
    
    [UIView animateWithDuration:AnimationDuration animations:^(void) {
    
        [self setFrameHeight:totalHeight];
    }];
}


- (void) expandHubView:(NSArray *)hubViewStack {
    
//    NSLog(@"expandHubView at HubView: %@", self);
    
    float __block posY = 0;
    
    for (UIView* view in self.subviews) {
        
        if ([view isKindOfClass:[DropDownHubView class]]) {
            
            DropDownHubView* childHubView = (DropDownHubView*) view;
            
            // if level of calling hubview not reached yet
            if (_level < hubViewStack.count - 1) {
                
                if ([hubViewStack objectAtIndex:_level + 1] == childHubView) {
                
                    [childHubView expandHubView:hubViewStack];
                }
            }

            if (_level == hubViewStack.count - 2 && [hubViewStack objectAtIndex:_level + 1] != childHubView) {
            
//                NSLog(@"HubView is expanded and shud collapse: %@", childHubView);
                
                // if hubview is expanded
                if (childHubView.isExpanded) {

                    NSMutableArray* hubViewStack2 = [NSMutableArray array];
                    [hubViewStack2 addObject:self];
                    [hubViewStack2 addObject:childHubView];
                    
                    // tell delegate to collapse down to the hubview
                    [delegate hubViewShouldCollapse:hubViewStack2];
                }
            }
            
            [UIView animateWithDuration:AnimationDuration
                                  delay:0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^(void) {
                                 
                                 [childHubView setFrameY:posY];
                             }
                             completion:^(BOOL finished) {}];
            
            posY += childHubView.totalHeight;
        }
        else {
            
            [UIView animateWithDuration:AnimationDuration
                                  delay:0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^(void) {
                                 
                                 [view setFrameY:posY];
                             }
                             completion:^(BOOL finished) {}];
            
            posY += view.frame.size.height;
        }
    }
    
    totalHeight = posY;

    
    [UIView animateWithDuration:AnimationDuration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^(void) {
                         
                         [self setFrameHeight:posY];
                     }
                     completion:^(BOOL finished) {
                     
//                         [self adjustTitleLabel];
                     }];
    
    // print stack if found final hubview
    if (hubViewStack.count == _level + 1) {
        
//        NSLog(@"Final HubView to expand found: %@", self);

        isExpanded = TRUE;
        
        [self adjustTitleLabel];
    }
    
}

- (void) collapseHubView:(NSArray *)hubViewStack {
    
    NSLog(@"collapseHubView at HubView: %@", self);
    
    float posY = 0;
    
    if (hubViewStack.count == _level + 1) {
        
        NSLog(@"Final HubView to collapse found: %@", self);
        
        totalHeight = minimumHeight;
        isExpanded = FALSE;

//        [self adjustTitleLabel];
        
        [self performBlock:^(void) {

            [self resetView];
        }
                afterDelay:AnimationDuration];
        
//        for (UIView* view in _views) {
//            
//            if ([view isKindOfClass:[DropDownHubView class]]) {
//                
//                DropDownHubView* childHubView = (DropDownHubView*) view;
//                
//                [childHubView resetView];
//            }
//        }
    }
    else {
        
        for (UIView* view in self.subviews) {
            
            NSLog(@"subview");
            
            if ([view isKindOfClass:[DropDownHubView class]]) {
                
                NSLog(@"... is HubView");
                
                DropDownHubView* childHubView = (DropDownHubView*) view;
                
                if (hubViewStack.count > _level + 1 && [hubViewStack objectAtIndex:_level + 1] == childHubView) {
                    
                    [childHubView collapseHubView:hubViewStack];
                }
                
                [UIView animateWithDuration:AnimationDuration
                                      delay:0
                                    options:UIViewAnimationOptionBeginFromCurrentState
                                 animations:^(void) {
                                     
                                     [childHubView setFrameY:posY];
                                 }
                                 completion:^(BOOL finished) {
                                     
//                                     [childHubView adjustTitleLabel];
                                 }];
                
                posY += childHubView.totalHeight;
            }
            else {

                [UIView animateWithDuration:AnimationDuration
                                      delay:0
                                    options:UIViewAnimationOptionBeginFromCurrentState
                                 animations:^(void) {
                                     
                                     [view setFrameY:posY];
                                 }
                                 completion:^(BOOL finished) {
                                     
                                     //                                     [childHubView adjustTitleLabel];
                                 }];
                
                posY += view.frame.size.height;
            }
        }
        
        totalHeight = posY;
    }


    
    [UIView animateWithDuration:AnimationDuration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^(void) {
                         
                         [self setFrameHeight:totalHeight];
                     }
                     completion:^(BOOL finished) {
                     
                         [self adjustTitleLabel];
                     }];
}


//- (void) collapse {
//    
//    isExpanded = FALSE;
//    totalHeight = minimumHeight;
//    [self setFrameHeight:totalHeight];
//    
//    for (UIView* view in _views) {
//        
//        if ([view isKindOfClass:[DropDownHubView class]]) {
//
//            DropDownHubView* childHubView = (DropDownHubView*) view;
//
//            if (childHubView.isExpanded) {
//                
//                [childHubView collapse];
//            }
//        }
//    }
//}




- (void) scheduleCollapseAfterDelay:(float)delay {
    
    [self performBlock:^(void) {
        
        [self resetView];
    }
            afterDelay:0.3];
}


//- (void) refreshViewAnimated:(BOOL)animated {
//
//    NSLog(@"(%d) refreshview", _level);
//    
//    float posY = _titleLabel.frame.size.height;
//    
////    [self setFrameHeight:posY];
//    totalHeight = posY;
//
//    if (isExpanded) {
//        
//        for (UIView* view in _views) {
//            
//            view.hidden = FALSE;
//            
//            if ([view isKindOfClass:[DropDownHubView class]]) {
//                
//                DropDownHubView* hubView = (DropDownHubView*)view;
//                
//                [hubView refreshViewAnimated:animated];
//                
//                if (animated) {
//                    
//                    [UIView animateWithDuration:0.3 animations:^(void) {
//                        
//                        [hubView setFrameY:posY];
//                    }];
//                }
//                else {
//                    
//                    [hubView setFrameY:posY];
//                }
//                
//                posY += [hubView totalHeight];
//            }
//            else if ([view isKindOfClass:[DropDownView class]]) {
//                
////                if (animated) {
////                    
////                    [UIView animateWithDuration:0.3 animations:^(void) {
//                        
//                        [view setFrameY:posY];
////                    }];
////                }
////                else {
////                    
////                    [view setFrameY:posY];
////                }
//                
//                posY += view.frame.size.height;
//            }
//        }
//        
//        if (animated) {
//            
//            [UIView animateWithDuration:0.3 animations:^(void) {
//                
//                [self setFrameHeight:posY];
//            }];
//        }
//        else {
//            
//            [self setFrameHeight:posY];
//        }
//
//        totalHeight = posY;
//    }
//    else {
//        
//        
//        
//        [self performBlock:^(void) {
//            
//            [self setFrameHeight:posY];
//            totalHeight = posY;
//            
//            for (UIView* view in _views) {
//                
//                view.hidden = TRUE;
//            }
//        }
//                afterDelay:0.3];
//    }
//
//
//}


- (void) handleTap:(UIGestureRecognizer *)recognizer {
    
//    NSLog(@"-------------------------------------------------------------------");
//    NSLog(@"Tap on HubView: %@", self);
    
    NSMutableArray* hubViewStack = [NSMutableArray array];
    [hubViewStack addObject:self];
    
    if (isExpanded) {
        
        [delegate hubViewShouldCollapse:(hubViewStack)];
    }
    else {

        [delegate hubViewShouldExpand:hubViewStack];
    }
    
//    isExpanded = !isExpanded;
    
    
    
//    [delegate hubViewWasTouched:self];
    
//    [self refreshViewAnimated:TRUE];
}


- (void) hubViewShouldExpand:(NSMutableArray *)hubViewStack {
    
//    NSLog(@"hubViewShouldExpend at HubView: %@", self);
    
    [hubViewStack insertObject:self atIndex:0];
    
    [delegate hubViewShouldExpand:hubViewStack];
}


- (void) hubViewShouldCollapse:(NSMutableArray *)hubViewStack {
    
//    NSLog(@"hubViewShouldCollapse at HubView: %@", self);
    
    [hubViewStack insertObject:self atIndex:0];
    
    [delegate hubViewShouldCollapse:hubViewStack];
}


- (void) setExpanded:(BOOL)expanded {
    
//    if (isExpanded != expanded) {
//        
//        [self refreshViewAnimated:TRUE];
//    }
    
//    NSLog(@"set expanded: %d", expanded);
    
    isExpanded = expanded;
}


- (void) adjustTitleLabel {
    
    UIImage* iconImage = (isExpanded) ? arrowDownImage : arrowRightImage;
    
    imageView.image = iconImage;
    
    NSLog(@"adjustTitleLabel: %@", _title);
    
//    NSString* prefixString = (isExpanded) ? PrefixStringExpanded : PrefixStringCollapsed;
//    
//    _titleLabel.text = [NSString stringWithFormat:@"%@ %@", prefixString, _title];
}


#pragma mark DropDownHubViewDelegate

- (void) hubViewWasTouched:(DropDownHubView *)hubView {
    
//    NSLog(@"hubview was touched, height=%f", hubView.totalHeight);
    
    for (UIView* view in _views) {
        
        if ([view isKindOfClass:[DropDownHubView class]]) {

            DropDownHubView* hubView = (DropDownHubView*) view;
            
            if (view != hubView) {
                
                [hubView setExpanded:FALSE];
            }
        }
    }
    
    [delegate hubViewRequestedRefresh:self];
}

- (void) hubViewRequestedRefresh:(DropDownHubView *)hubView {
    
    [delegate hubViewRequestedRefresh:hubView];
}




- (NSString*) description {
    
    return [NSString stringWithFormat:@"(DropDownHubView: level=%d, title=%@)", _level, _title];
}


@end



#pragma mark - DropDownView

@implementation DropDownView

@synthesize font;


- (id) initWithTitle:(NSString *)title atLevel:(uint)level {
    
    if (self = [super init]) {
        
        _title = [title copy];
        _level = level;
//        self.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor colorWithPatternImage:resource(@"Images.TableViews.BackgroundPattern")];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.autoresizesSubviews = TRUE;
    }
    
    return self;
}


- (void) didMoveToSuperview {
    
    [super didMoveToSuperview];
    
    
    if (self.superview) {

        UILabel* titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
        titleLabel.font = font;
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
//        CGSize textSize = [_title sizeWithFont:font constrainedToSize:CGSizeMake(self.frame.size.width - __indents[_level], 40)];
        
//        textSize = [_title sizeWithFont:font];
        
//        [titleLabel setFrameOrigin:CGPointMake(__indents[_level], 0)];
//        [titleLabel setFrameSize:textSize];
        
        [titleLabel setFrame:CGRectMake(__indents[_level], 0, self.frame.size.width - __indents[_level], PageTitleHeight)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.text = _title;
        
        [self addSubview:titleLabel];
        
        [self setFrameHeight:titleLabel.frame.size.height];
        
//        NSLog(@"DropDownView rect: %@", NSStringFromCGRect(self.frame));
    }
}


@end






#pragma mark - DropDownWebView

@implementation DropDownWebView

@synthesize font;


- (id) initWithHTMLPath:(NSString *)path atLevel:(uint)level {
    
    if (self = [super init]) {
        
        _htmlPath = [path copy];
        _level = level;
        self.backgroundColor = [UIColor colorWithPatternImage:resource(@"Images.TableViews.BackgroundPattern")];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.autoresizesSubviews = TRUE;
        self.opaque = FALSE;
        self.scrollView.bounces = FALSE;
//        self.backgroundColor = [UIColor yellowColor];
    }
    
    return self;
}


- (void) didMoveToSuperview {
    
    [super didMoveToSuperview];
    
    if (self.superview) {
        
        NSString* fullPath = [[NSBundle mainBundle] pathForResource:_htmlPath ofType:@"html"];
        NSString* htmlString = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:nil];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"FONT_NAME" withString:font.fontName];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"FONT_SIZE" withString:[NSString stringWithFormat:@"%f", font.pointSize]];
        
//        timer_start(@"parse");
        htmlString = [self parseHTMLString:htmlString];
//        alert(@"parse: %f", timer_passed(@"parse"));
        
        self.delegate = self;
        
//        NSLog(@"%@", htmlString);
        
        NSString* basePath = [[NSBundle mainBundle] bundlePath];
        NSURL* baseURL = [NSURL fileURLWithPath:basePath];
        
        [self loadHTMLString:htmlString baseURL:baseURL];
    }
}


- (void) layoutAnimated {

    NSLog(@"WebView layoutAnimated: frame width: %f", self.frame.size.width);

    // ...
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.querySelector('meta[name=viewport]').setAttribute('content', 'width=%d;', false); ",
                                                  (int)self.frame.size.width]];
    
    [self setFrameHeight:1];
    
    CGSize size = [self sizeThatFits: CGSizeMake(self.frame.size.width, 1000)];
    [self setFrameHeight:size.height];
    

}


#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
    
    NSLog(@"webview did finish load");
    
    [theWebView setFrameHeight:1];
    
    CGSize size = [theWebView sizeThatFits: CGSizeMake(theWebView.frame.size.width, 1000)];
    [theWebView setFrameHeight:size.height];
}



- (NSString*) parseHTMLString:(NSString*) htmlString {
    
    char currentChar, previousChar;
    uint startingIndex;
    NSString* returnString = [htmlString copy];
    
    for (uint i = 0; i < returnString.length; ++i) {
        
        currentChar = [returnString characterAtIndex:i];
        
//        NSLog(@"currentChar: %c (pos: %d)", currentChar, i);
        
        if (currentChar == '<' && previousChar == '<') {

            startingIndex = i + 1;
        }
        else if (currentChar == '>' && previousChar == '>') {

            uint closingIndex = i - 2;
            
            NSRange tokenRange = NSMakeRange(startingIndex, closingIndex - startingIndex + 1);
            NSRange outerRange = NSMakeRange(startingIndex - 2, closingIndex - startingIndex + 5);
            NSString* token = [returnString substringWithRange:tokenRange];

//            NSLog(@"token: %@", token);
            
            NSArray* tokenComps = [token componentsSeparatedByString:@":"];
            NSString* type = [tokenComps objectAtIndex:0];
            NSString* arg = [tokenComps objectAtIndex:1];
            NSString* replacementString = nil;
            
            if ([type isEqualToString:@"int"]) {
                
                int value = [arg intValue];
                int newValue = [self handleInt:value];
                replacementString = [NSString stringWithFormat:@"%d", newValue];
            }
            else if ([type isEqualToString:@"image"]) {
                
                replacementString = [self handleImage:arg];
            }
            
            returnString = [returnString stringByReplacingCharactersInRange:outerRange withString:replacementString];
            
            uint diffLen = outerRange.length + 4 - replacementString.length;
            
            i -= diffLen;
            
//            NSLog(@"i=%d, len=%d", i, returnString.length);
        }
        
        
        
        previousChar = currentChar;
    }
    
    return returnString;
}


- (int) handleInt:(int) value {

    return (is_ipad) ? value * 1.5 : value;
}


- (NSString*) handleImage:(NSString*) imageName {

    NSArray* comps = [imageName componentsSeparatedByString:@"."];
    BOOL isRetina = [UIScreen mainScreen].scale == 2.0;
    
    return [NSString stringWithFormat:@"%@%@.%@", [comps objectAtIndex:0], (isRetina) ? @"@2x" : @"", [comps objectAtIndex:1]];
}


- (void) dealloc {
    
    NSLog(@"DropDownWebView DEALLOC");
    
    self.delegate = nil;
}

@end





