//
//  ThumbnailsBar.m
//  KlettAbiLernboxen
//
//  Created by Wang on 19.11.12.
//
//

#import "ThumbnailsBar.h"
#import "UIImage+Extensions.h"
#import "UIColor+Extensions.h"
#import "Thumbnail.h"
#import <QuartzCore/QuartzCore.h>


#define Cap_Insets_Background UIEdgeInsetsMake(0,2,0,2)
#define Selection_PosY 4
#define Image_Container_Width 40
#define Animation_Duration 0.1f
#define Pushout_Distance 5



@implementation ThumbnailsBar

@synthesize scrollView;
@synthesize delegate;
@synthesize pageNumber;
@synthesize blendColor;


#pragma mark Initializer

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        
        UIColor* barColor = [[ModuleManager manager] colorForModule:[PDFManager manager].moduleName];
        
        _backgroundImage = [[(UIImage*)resource(@"Images.TabBar.Background") imageWithAdjustmentColor:[barColor colorByDarkingByPercent:0.3]] resizableImageWithCapInsets:Cap_Insets_Background];
        
        _selectionImage = [(UIImage*)resource(@"Images.DocumentView.ThumbnailsBar.Selection") imageWithAdjustmentColor:[barColor colorByDarkingByPercent:0.3]];

        barColor = [barColor colorWithSaturationFactor:PBintVarValue(@"thumbnailbar saturation") * 0.01];

        
        NSArray* pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [pathArray lastObject];
        NSString* filePath = [documentsDirectory stringByAppendingPathComponent:@"selectionImage.png"];
        [UIImagePNGRepresentation(_selectionImage) writeToFile:filePath atomically:TRUE];
        
//        _backgroundImage = (UIImage*)resource(@"Images.DocumentView.ThumbnailsBar.Background");
//        _selectionImage = (UIImage*)resource(@"Images.DocumentView.ThumbnailsBar.Selection");
        
        /* top shadow */
        
        UIImage* bgImage = [[ResourceManager instance] resourceForKeyPath:@"Images.TabBar.TopShadow"];
        bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
        UIImageView* topShadowImageView = [[UIImageView alloc] initWithImage:bgImage];
        topShadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [topShadowImageView setFrameY:topShadowImageView.bounds.size.height * (-1)];
        self.clipsToBounds = FALSE;
        [self addSubview:topShadowImageView];
        
        
        _contentView = nil;
        _thumbnails = nil;
        blendColor = [UIColor clearColor];

        /* create scrollview */
        
        uint posX = (self.bounds.size.width - Image_Container_Width) * 0.5;

        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(posX, Selection_PosY, Image_Container_Width, _selectionImage.size.height)];
        scrollView.clipsToBounds = FALSE;
        scrollView.pagingEnabled = TRUE;
        scrollView.bounces = FALSE;
        scrollView.showsHorizontalScrollIndicator = FALSE;
//        scrollView.backgroundColor = [UIColor redColor];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        scrollView.delegate = self;
        
        [self addSubview:scrollView];
        
        UITapGestureRecognizer* recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:recognizer];
        
        PBaddObserver(self);
    }
    
    return self;
}


- (void) variableValueChangedForName:(NSString *)name {
    
    if ([name isEqualToString:@"thumbnail alpha"]) {
        
        [_thumbnails makeObjectsPerformSelector:@selector(setNeedsDisplay)];
    }
    else if ([name isEqualToString:@"thumbnailbar saturation"]) {
        
        UIColor* barColor = [[ModuleManager manager] colorForModule:[PDFManager manager].moduleName];
        barColor = [barColor colorWithSaturationFactor:PBintVarValue(@"thumbnailbar saturation") * 0.01];
        
//        _backgroundImage = [[(UIImage*)resource(@"Images.DocumentView.ThumbnailsBar.Background") imageWithAdjustmentColor:barColor] resizableImageWithCapInsets:Cap_Insets_Background resizingMode:UIImageResizingModeStretch];
        _backgroundImage = [[(UIImage*)resource(@"Images.DocumentView.ThumbnailsBar.Background") imageWithAdjustmentColor:barColor] resizableImageWithCapInsets:Cap_Insets_Background];
        
        _selectionImage = [(UIImage*)resource(@"Images.DocumentView.ThumbnailsBar.Selection") imageWithAdjustmentColor:barColor];

        [self setNeedsDisplay];
    }
}


#pragma mark View

- (void) drawRect:(CGRect)rect {

    [_backgroundImage drawInRect:rect];
    
    uint posX = (rect.size.width - _selectionImage.size.width) * 0.5;
    
    CGRect selectionRect;
    selectionRect.size = _selectionImage.size;
    selectionRect.origin = CGPointMake(posX, Selection_PosY);
    
    [_selectionImage drawInRect:selectionRect];
}


- (UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event {

    UIView* hitView = [super hitTest:point withEvent:event];
    
    NSLog(@"[ThumbnailsBar] hitview: %@ (self.frame=%@)", hitView, NSStringFromCGRect(self.frame));
    
    if (hitView == self) {

        NSLog(@"[ThumbnailsBar] hitview == self, returning scrollview");
        
        return scrollView;
    }
    else return hitView;
}



#pragma mark Public Methods

- (void) setImages:(NSArray *)images {
    
    [_contentView removeFromSuperview];
    
    uint contentViewWidth = images.count * Image_Container_Width;
//    + (_selectionImage.size.width - Image_Container_Width);
    CGRect contentViewFrame = CGRectMake(0, 0, contentViewWidth, _selectionImage.size.height);
    
    _contentView = [[ThumbnailsContentView alloc] initWithFrame:contentViewFrame];
    _contentView.forwardView = scrollView;
    _contentView.clipsToBounds = FALSE;
//    _contentView.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.5];
    
    CGSize imageSize = [(UIImage*)[images objectAtIndex:0] size];
    CGRect imageContainerRect = CGRectMake(0, 0, Image_Container_Width, _selectionImage.size.height);
    CGRect imageRelativeRect = CGSizeCenterInRect(imageSize, imageContainerRect);

//    alert(@"scrollview frame: %@", NSStringFromCGRect(scrollView.frame));
//    alert(@"contentview frame: %@", NSStringFromCGRect(_contentView.frame));
    
    uint count = 0;
    _thumbnails = [NSMutableArray arrayWithCapacity:images.count];
    
    for (UIImage* image in images) {

        Thumbnail* thumbnail = [[Thumbnail alloc] initWithImage:image blendColor:blendColor];

        thumbnail.position = count;
        thumbnail.middleX = (count * imageContainerRect.size.width) + imageRelativeRect.origin.x;
        thumbnail.leftX = thumbnail.middleX - (_selectionImage.size.width - imageContainerRect.size.width) * 0.5;
        thumbnail.rightX = thumbnail.middleX + (_selectionImage.size.width - imageContainerRect.size.width) * 0.5;
        
        NSLog(@"thumbnail (%d): left=%d, middle=%d, right=%d", count, thumbnail.leftX, thumbnail.middleX, thumbnail.rightX);
        
        [thumbnail setFrameOrigin:CGPointMake(thumbnail.leftX, (int)imageRelativeRect.origin.y)];
        
        NSLog(@"thumbnail frame: %@", NSStringFromCGRect(thumbnail.frame));
        
        [_contentView addSubview:thumbnail];
        [_thumbnails addObject:thumbnail];
        
        ++count;
    }
    
    [scrollView addSubview:_contentView];
    scrollView.contentSize = _contentView.bounds.size;
}


- (void) layout {
    
    [self setNeedsDisplay];
}


- (void) handleTap:(UIGestureRecognizer *)recognizer {
    
    CGPoint location = [recognizer locationInView:_contentView];
    
    if (location.x < 0 || location.x > _contentView.frame.size.width) {
        return;
    }
    
    CGRect selectionRect = CGRectMake((scrollView.bounds.size.width - _selectionImage.size.width) * 0.5, 0, _selectionImage.size.width, _selectionImage.size.height); // relative to scrollview
    
    uint page;
    CGRect imageContainerRect = CGRectMake(0, 0, Image_Container_Width, _selectionImage.size.height);
    float offsetX = (_selectionImage.size.width - imageContainerRect.size.width) * 0.5;
    
    /* 2 cases: tap is left or right of the selection image */
    
    if (location.x < scrollView.contentOffset.x + selectionRect.origin.x) {
    
        page = floor((location.x + offsetX) / Image_Container_Width);
    }
    else if (location.x > scrollView.contentOffset.x + selectionRect.origin.x + selectionRect.size.width) {

        page = floor((location.x - offsetX) / Image_Container_Width);
    }
    else {
        
        return;
    }
    
//    uint page = floor(location.x / Image_Container_Width);
    
    NSLog(@"page=%d, location.x=%f", page, location.x);
    
    /* safety */
    if (page >= _thumbnails.count) {
        
//        alert(@"thumbnailBar page=%d", page);
        return;
    }
    
    [self.scrollView setContentOffset:CGPointMake(page * Image_Container_Width, 0) animated:TRUE];
    
    [self.delegate thumbnailWasSelectedForPage:page];
    
//    [(Thumbnail*)[_thumbnails objectAtIndex:pageNumber] setSelected:FALSE];
//    [(Thumbnail*)[_thumbnails objectAtIndex:page] setSelected:TRUE];
    
    pageNumber = page;
}


- (void) scrollToPage:(uint) page animated:(BOOL) animated {
    
    
    pageNumber = page;
    
    int scrollOffset = (page * scrollView.bounds.size.width);
    
    [scrollView setContentOffset:CGPointMake(scrollOffset, 0) animated:animated];
    
    if (!animated) {

        [(Thumbnail*)[_thumbnails objectAtIndex:page] setSelected:TRUE];

        [self layoutThumbnailsForPage:page animated:FALSE];
    }
}


- (void) layoutThumbnailsForPage:(uint) page animated:(BOOL) animated {
    
    if (animated) {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:Animation_Duration];
    }
    
    uint count = 0;
    
    for (Thumbnail* thumbnail in _thumbnails) {
        
        int newX;
        
        if (count < page) {
            
            newX = thumbnail.leftX;
        }
        else if (count == page) {
            
            newX = thumbnail.middleX;
        }
        else {
            
            newX = thumbnail.rightX;
        }
        
        [thumbnail setFrameX:newX];
        
        ++count;
    }
    
    if (animated) {
        
        [UIView commitAnimations];
    }
}


#pragma mark UIScrollView Delegate

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self.delegate thumbnailWillBeginDragging];
}


- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (!decelerate) {
        [self reportPage];
    }
    
    [self.delegate thumbnailDidEndDragging];
}


- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSLog(@"(thumbnail scrollview) did end decelerating");
    
    [self reportPage];
}


- (void) scrollViewDidScroll:(UIScrollView *)theScrollView {
    
//    static uint pageNumber = -1;
    
//    NSLog(@"scrollview did scroll");
    
    float div = self.scrollView.contentOffset.x / Image_Container_Width;
    uint fullPage = floor(div);
    float rest = div - fullPage;
    int page = (rest > 0.5) ? fullPage + 1 : fullPage;
    
    
    /* position selected thumbnail */
    
    Thumbnail* selectedThumbnail = [_thumbnails objectAtIndex:page];

    CGRect imageContainerRect = CGRectMake(0, 0, Image_Container_Width, _selectionImage.size.height);
    CGRect imageRelativeRect = CGSizeCenterInRect(selectedThumbnail.bounds.size, imageContainerRect);

    float posX = scrollView.contentOffset.x + imageRelativeRect.origin.x;

    
    /* check touch distance */

    int touchDistanceRight = (selectedThumbnail.rightX + Image_Container_Width) - selectedThumbnail.bounds.size.width - posX;
    int touchDistanceLeft = posX - (selectedThumbnail.leftX - Image_Container_Width) - selectedThumbnail.bounds.size.width;
    
//    NSLog(@"page=%d, pageNumber=%d", page, pageNumber);
//    NSLog(@"touch distance, LEFT=%d, RIGHT=%d (contentOffset=%f, posX=%f)", touchDistanceLeft, touchDistanceRight, scrollView.contentOffset.x, posX);
    
    if (touchDistanceRight < Pushout_Distance) {
        
//        NSLog(@"pushing from RIGHT");
        
        posX -= (Pushout_Distance - touchDistanceRight);
    }
    else if (touchDistanceLeft < Pushout_Distance) {
        
//        NSLog(@"pushing from LEFT");
        
        posX += (Pushout_Distance - touchDistanceLeft);
    }
    
    
    
    
    /* safety */
    if (page < 0 || page >= _thumbnails.count) {
        
//        alert(@"thumbnailBar page=%d", page);
        return;
    }
    
    
    if (page != pageNumber) {
        
        [delegate thumbnailDidHitPageNumber:page];
        
        [(Thumbnail*)[_thumbnails objectAtIndex:pageNumber] setSelected:FALSE];
        [(Thumbnail*)[_thumbnails objectAtIndex:page] setSelected:TRUE];
        
        NSString* __block debug = [NSString stringWithFormat:@"page: %d, pageNumber: %d, pages: ", page, pageNumber];
        
        [UIView animateWithDuration:Animation_Duration
                         animations:^(void) {
  
//                             Thumbnail* pageNumberThumbnail = [_thumbnails objectAtIndex:pageNumber];
                             
                             if (page < pageNumber) {
                                 
                                 for (int p = pageNumber; p > page; --p) {
                                 
                                     debug = [debug stringByAppendingFormat:@"%d, ", p];
                                     
                                     Thumbnail* rightThumbnail = [_thumbnails objectAtIndex:p];
                                     [rightThumbnail setFrameX:rightThumbnail.rightX];
                                 }
                                 
//                                [pageNumberThumbnail setFrameX:pageNumberThumbnail.rightX];
                             }
                             else {

                                 for (int p = pageNumber; p < page; ++p) {
                                 

                                     debug = [debug stringByAppendingFormat:@"%d, ", p];
                                     
                                     Thumbnail* leftThumbnail = [_thumbnails objectAtIndex:p];
                                     [leftThumbnail setFrameX:leftThumbnail.leftX];
                                 }
//                                 [pageNumberThumbnail setFrameX:pageNumberThumbnail.leftX];
                             }
                             
                             [selectedThumbnail setFrameX:posX];
                             
//                             uint count = 0;
//                             
//                             for (Thumbnail* thumbnail in _thumbnails) {
//                                 
//                                 if (count != pageNumber && count != page
//                                     && [thumbnail.layer animationKeys].count == 0) {
//                                     
//                                     int newX;
//                                     
//                                     if (count < page) {
//                                         
//                                         newX = thumbnail.leftX;
//                                     }
//                                     else if (count > page) {
//                                         
//                                         newX = thumbnail.rightX;
//                                     }
//                                     
//                                     [thumbnail setFrameX:newX];
//                                     
//                                     [thumbnail setSelected:FALSE];
//                                 }
//                                 
//                                 ++count;
//                             }
                         }];
        
        debug = [debug stringByAppendingString:@"\n"];
        
        LogM(@"debug", debug);
        LogM_write2(@"debug", @"debug.txt");
        
        pageNumber = page;
    }
    else {

        [selectedThumbnail setFrameX:posX];
    }
    
    

}


- (void) reportPage {
    
    NSLog(@"report page");
    
    //    uint page = floor(self.scrollView.contentOffset.x / THUMBNAIL_SIZE.width);
    float div = self.scrollView.contentOffset.x / Image_Container_Width;
    uint fullPage = floor(div);
    float rest = div - fullPage;
    uint page = (rest > 0.5) ? fullPage + 1 : fullPage;
    pageNumber = page;
    
    [self.delegate thumbnailWasSelectedForPage:page];
}


#pragma mark Private Methods



@end
