//
//  ContentsOverlayViewController.m
//  KlettAbiLernboxen
//
//  Created by Wang on 23.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ContentsOverlayViewController.h"
#import "PDFManager.h"
#import "TranslateIdiom.h"


//#define CAT_FONT [UIFont fontWithName:@"helvetica" size:ti_int(14)]
//#define PAGE_FONT [UIFont fontWithName:@"helvetica" size:ti_int(12)]
//#define CAT_COLOR [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0]
//#define PAGE_COLOR [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0]
//#define PAGE_COLOR_HIGHLIGHTED [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0]

#define CONTAINER_SIZE ti_size(CGSizeMake(240,200))
#define SCROLLVIEW2_HEIGHT ti_int(50)


@implementation ContentsOverlayViewController

@synthesize containerView, containerBackgroundImageView, scrollView, scrollView2, contentView, contentView2;
@synthesize categoryName;


- (id) initWithCategory:(NSString *)categoryName pageNumber:(uint)pageNumber {
    
    if (self = [super initWithNibName:@"ContentsOverlayViewController" bundle:[NSBundle mainBundle]]) {
        
        self.categoryName = categoryName;
        _pageLabels = [NSMutableArray array];
        _pageNumberLabels = [NSMutableArray array];
        _activePageLabel = nil;
        _activePageNumberLabel = nil;
        _currentPage = pageNumber;
        
        _categoryFont = resource(@"Fonts.ContentOverlay.Categories.Font");
        _categoryColor = resource(@"Fonts.ContentOverlay.Categories.Color");
        _pageFont = resource(@"Fonts.ContentOverlay.Pages.Normal.Font");
        _pageColor = resource(@"Fonts.ContentOverlay.Pages.Normal.Color");
        _pageColorHighlighted = resource(@"Fonts.ContentOverlay.Pages.Highlighted.Color");
    }
    
    return self;
}

- (void) viewDidLoad {
    
    NSLog(@"ContentsOverlay viewdidload");
    
    [super viewDidLoad];
    
    UIImage* image = [[UIImage imageNamed:@"contents_overlay_bg.png"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
    self.containerBackgroundImageView.image = image;
    
    [self.containerView setFrameSize:CONTAINER_SIZE];
    [self.containerView centerXInSuperview];
    [self.containerView centerYInSuperview];
    
    
//    UIFont* categoryFont = resource(@"Fonts.ContentOverlay.Categories.Font");
//    UIColor* categoryColor = resource(@"Fonts.ContentOverlay.Categories.Color");
//    UIFont* pageFont = resource(@"Fonts.ContentOverlay.Pages.Normal.Font");
//    UIColor* pageColor = resource(@"Fonts.ContentOverlay.Pages.Normal.Color");
    
    
    
    if ([PDFManager manager].useSubcategories) {
        
        self.scrollView2 = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 5, self.containerView.frame.size.width - 10, SCROLLVIEW2_HEIGHT)];
        [self.containerView addSubview:self.scrollView2];

        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5, SCROLLVIEW2_HEIGHT + 5, self.containerView.frame.size.width - 10, self.containerView.frame.size.height - SCROLLVIEW2_HEIGHT - 10)];
        [self.containerView addSubview:self.scrollView];
        
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self.scrollView addSubview:self.contentView];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.contentView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self.scrollView2 addSubview:self.contentView2];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    else {
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 5, self.containerView.frame.size.width - 10, self.containerView.frame.size.height - 10)];
        [self.containerView addSubview:self.scrollView];
        
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [self.scrollView addSubview:self.contentView];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    // populate content view

    uint margin = ti_int(10);
    uint padding = ti_int(5);
    
    uint posX = margin;
    uint posY = margin;
    
    uint pageWidth = self.scrollView.frame.size.width;
    CGRect labelRect = CGRectMake(0, 0, pageWidth - 2*margin, ti_int(100));
    
    
    uint maxY = 0;
    uint currentPage = [[PDFManager manager] pageRangeForCategory:self.categoryName].location;
    
    // if subcategories
    if ([PDFManager manager].useSubcategories) {

        NSArray* subcategories = [[PDFManager manager] subcategoriesForCategory:self.categoryName];

        for (ContentsSubcategory* subcategory in subcategories) {
            
            NSString* subcatName = subcategory.name;
            NSArray* pages = [[PDFManager manager] pagesForSubcategory:subcategory];
            
            NSLog(@"subcat: %@", subcatName);
            
            UILabel* categoryLabel = [[UILabel alloc] init];
            categoryLabel.numberOfLines = 0;
            categoryLabel.lineBreakMode = UILineBreakModeWordWrap;
            [categoryLabel setFrameOrigin:CGPointMake(posX, posY)];
            categoryLabel.text = subcatName;
            CGSize textSize = [categoryLabel.text sizeWithFont:_categoryFont constrainedToSize:CGSizeMake(pageWidth - 2*margin, self.scrollView2.frame.size.height) lineBreakMode:UILineBreakModeWordWrap];
            [categoryLabel setFrameSize:textSize];
            categoryLabel.textColor = _categoryColor;
            categoryLabel.backgroundColor = [UIColor clearColor];
            categoryLabel.font = _categoryFont;
//            categoryLabel.textAlignment = UITextAlignmentCenter;
            [self.contentView2 addSubview:categoryLabel];
            
            
            
            for (ContentsPage* page in pages) {
                
                NSLog(@"page: %@", page.name);
                
                // pagenumber label
                UILabel* pageNumberLabel = [[UILabel alloc] init];
                [pageNumberLabel setFrameOrigin:CGPointMake(posX, posY)];
                pageNumberLabel.text = [NSString stringWithFormat:@"%d.", currentPage];
                pageNumberLabel.font = _pageFont;
                pageNumberLabel.textColor = _pageColor;
                pageNumberLabel.textAlignment = UITextAlignmentRight;
                pageNumberLabel.backgroundColor = [UIColor clearColor];
                CGSize textSize = [@"100." sizeWithFont:_pageFont];
                [pageNumberLabel setFrameSize:textSize];
                [self.contentView addSubview:pageNumberLabel];
                [_pageNumberLabels addObject:pageNumberLabel];
                
                uint offsetX = pageNumberLabel.frame.origin.x + pageNumberLabel.frame.size.width + ti_int2(5, 1.5);
                CGRect labelRect2 = CGRectMake(0,
                                               0,
                                               scrollView.bounds.size.width - (2*margin) - (offsetX - posX),
                                               ti_int(100));
                
                // pagetext label
                UILabel* pageLabel = [[UILabel alloc] init];
                pageLabel.numberOfLines = 0;
                pageLabel.lineBreakMode = UILineBreakModeWordWrap;
                [pageLabel setFrameOrigin:CGPointMake(offsetX, posY)];
                pageLabel.text = page.name;
                textSize = [pageLabel.text sizeWithFont:_pageFont constrainedToSize:labelRect2.size lineBreakMode:UILineBreakModeWordWrap];
                [pageLabel setFrameSize:textSize];
                pageLabel.textColor = _pageColor;
                pageLabel.backgroundColor = [UIColor clearColor];
                pageLabel.font = _pageFont;
                [self.contentView addSubview:pageLabel];
                [_pageLabels addObject:pageLabel];
                
                posY += padding + pageLabel.frame.size.height;
                
                ++currentPage;
            }
            
            maxY = MAX(maxY, posY);
            
            posX += pageWidth;
            posY = margin;
        }

        [self.contentView2 setFrameSize:CGSizeMake(posX, self.scrollView2.frame.size.height)];
        [self.scrollView2 setContentSize:self.contentView2.frame.size];
        [self.scrollView2 setContentOffset:CGPointZero animated:FALSE];
        
        [self.contentView setFrameSize:CGSizeMake(posX, maxY + 50)];
        [self.scrollView setContentSize:self.contentView.frame.size];
        [self.scrollView setContentOffset:CGPointZero animated:FALSE];
    }
    else {
        
        NSArray* pages = [[PDFManager manager] pagesForCategory:self.categoryName];
        
        for (ContentsPage* page in pages) {
            
            NSLog(@"page: %@", page.name);
            
            // pagenumber label
            UILabel* pageNumberLabel = [[UILabel alloc] init];
            [pageNumberLabel setFrameOrigin:CGPointMake(posX, posY)];
            pageNumberLabel.text = [NSString stringWithFormat:@"%d.", currentPage];
            pageNumberLabel.font = _pageFont;
            pageNumberLabel.textColor = _pageColor;
            pageNumberLabel.textAlignment = UITextAlignmentRight;
            pageNumberLabel.backgroundColor = [UIColor clearColor];
            CGSize textSize = [@"100" sizeWithFont:_pageFont];
            [pageNumberLabel setFrameSize:textSize];
            [self.contentView addSubview:pageNumberLabel];
            [_pageNumberLabels addObject:pageNumberLabel];
            
            uint offsetX = pageNumberLabel.frame.origin.x + pageNumberLabel.frame.size.width + ti_int2(10, 1.5);
            CGRect labelRect2 = CGRectMake(0,
                                          0,
                                          scrollView.bounds.size.width - margin - offsetX,
                                          ti_int(100));
            
            // pagetext label
            UILabel* pageLabel = [[UILabel alloc] init];
            pageLabel.numberOfLines = 0;
            pageLabel.lineBreakMode = UILineBreakModeWordWrap;
            [pageLabel setFrameOrigin:CGPointMake(offsetX, posY)];
            pageLabel.text = page.name;
            textSize = [pageLabel.text sizeWithFont:_pageFont constrainedToSize:labelRect2.size lineBreakMode:UILineBreakModeWordWrap];
            [pageLabel setFrameSize:textSize];
            pageLabel.textColor = _pageColor;
            pageLabel.backgroundColor = [UIColor clearColor];
            pageLabel.font = _pageFont;
            [self.contentView addSubview:pageLabel];
            [_pageLabels addObject:pageLabel];
            
            posY += padding + pageLabel.frame.size.height;
            
            ++currentPage;
        }
        
        maxY = posY;
        
        [self.contentView setFrameSize:CGSizeMake(posX, maxY + 50)];
        [self.scrollView setContentSize:self.contentView.frame.size];
        [self.scrollView setContentOffset:CGPointZero animated:FALSE];
    }
    
//    _currentPage = 0;
    

    
    NSLog(@"contenview size: %@", NSStringFromCGSize(self.scrollView.contentSize));
}


- (void) highlightPageNumber:(uint)pageNumber {
    
//    NSLog(@"hit page number: %d", pageNumber);
    
    _activePageLabel.textColor = _pageColor;
    _activePageNumberLabel.textColor = _pageColor;
    
    UILabel* newActiveLabel = (UILabel*)[_pageLabels objectAtIndex:pageNumber];
    [newActiveLabel setTextColor:_pageColorHighlighted];
    _activePageLabel = newActiveLabel;
    UILabel* newActiveNumberLabel = (UILabel*)[_pageNumberLabels objectAtIndex:pageNumber];
     [newActiveNumberLabel setTextColor:_pageColorHighlighted];
    _activePageNumberLabel = newActiveNumberLabel;

    
    uint page = floor(newActiveLabel.frame.origin.x / self.scrollView.frame.size.width);
    CGRect rect = CGRectMake(self.scrollView.frame.size.width * page, newActiveLabel.frame.origin.y - 10, self.scrollView.frame.size.width, newActiveLabel.frame.size.height + 20);
    
    // if page switch then scroll to top
    if (page > _currentPage) {
        rect.origin.y = 0;
    }
    if (page != _currentPage) {
        // scroll scrollView2
        if ([PDFManager manager].useSubcategories) {
            [UIView animateWithDuration:0.2 animations:^(void) {
                self.scrollView2.contentOffset = CGPointMake(page * self.scrollView2.frame.size.width, 0);
            }];
        }
    }
    
    [self scrollRectToVisible:rect withHorizontalMargin:0 verticalMargin:25 preferTop:TRUE];
    _currentPage = page;
}


- (void) scrollRectToVisible:(CGRect)rect withHorizontalMargin:(uint)marginH verticalMargin:(uint)marginV preferTop:(BOOL)preferTop {
    
//    NSLog(@"scrollrecttovisle: %@", NSStringFromCGRect(rect));
    
    CGPoint offset = self.scrollView.contentOffset;
    CGSize size = self.scrollView.frame.size;
    CGPoint newOffset = offset;
    
    // vertical
    if (offset.y - rect.origin.y + marginV > 0) {     // top-border is ABOVE frame-top-border
//        NSLog(@"rect is ABOVE");
        newOffset.y = rect.origin.y - marginV;
    }
    else if (rect.origin.y + rect.size.height + marginV - offset.y - size.height > 0) {     // bottom-border is BELOW frame-bottom-border
//        NSLog(@"rect is BELOW");
//        if (preferTop) {
//            newOffset.y = rect.origin.y + marginV;
//        }
//        else {
            newOffset.y = rect.origin.y + rect.size.height + marginV - size.height;
//        }
    }
    else {      // rect is completely visible in frame-rect
//        NSLog(@"rect is VISIBLE");
        if (preferTop) {
            // offset shud be closest to top as possible => rect as far bottom as possible
            newOffset.y = rect.origin.y + rect.size.height + marginV - size.height;
        }
    }

    // horizontal
    if (offset.x - rect.origin.x + marginH > 0) {
        newOffset.x = rect.origin.x - marginH;
    }
    else if (rect.origin.x + rect.size.width + marginH - offset.x - size.width > 0) {
        newOffset.x = rect.origin.x + rect.size.width + marginH - size.width;
    }

    // check if below zero
    if (newOffset.x < 0) {
        newOffset.x = 0;
    }
    if (newOffset.y < 0) {
        newOffset.y = 0;
    }
    
//    // check if above frame bounds
//    if (newOffset.x + size.width > self.contentView.frame.size.width) {
//        newOffset.x = self.contentView.frame.size.width - size.width;
//    }
//    if (newOffset.y + size.height > self.contentView.frame.size.height) {
//        newOffset.y = self.contentView.frame.size.height - size.height;
//    }

//    NSLog(@"new offset: %@", NSStringFromCGPoint(newOffset));
    
    [UIView animateWithDuration:0.2 
                          delay:0.0 
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^(void) {
                         self.scrollView.contentOffset = newOffset;
                     }
                     completion:^(BOOL finished){}]; 
}


- (void) dealloc {
    
    NSLog(@"%@ DEALLOC", [self class]);
}

@end





