//
//  TableCells.m
//  KlettAbiLernboxen
//
//  Created by Wang on 20.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TableCells.h"
#import "ResourceManager.h"
#import "UIImage+Extensions.h"


static UIImage* backgroundImage = nil;
static UIImage* backgroundImageSelected = nil;



@implementation CardCell

@synthesize cardImageView, titleLabel, learnStatusImageView, pageNumberLabel;
@synthesize title, pageNumber, isFavorite, learnStatus;
@synthesize backgroundImageView;





//- (id) initWithLearnStatus:(PageLearnStatus) learnStatus isFavorite:(BOOL)isFavorite {
//    
//    if ((self = [[[NSBundle mainBundle] loadNibNamed:@"CardCell" owner:nil options:nil] objectAtIndex:0]))  {
//     
//        UIImage* learnStatusImage = nil;
//
//        switch (learnStatus) {
//                
//            case PageLearnStatusUnderstood:
//                learnStatusImage = [UIImage imageNamed:@"gewusst_cell.png"];
//                break;
//                
//            case PageLearnStatusNotUnderstood:
//                learnStatusImage = [UIImage imageNamed:@"wiederholen_cell.png"];
//                break;
//                
//            default:
//                break;
//        }
//        
//        self.learnStatusImageView.image = learnStatusImage;
//        
//        
//        self.cardImageView.image = [UIImage imageNamed:(isFavorite) ? @"card_favorite.png" : @"card.png"];
//    }
//    
//    return self;
//}


- (id) init {
    
    if ((self = [[[NSBundle mainBundle] loadNibNamed:@"CardCell" owner:nil options:nil] objectAtIndex:0])) {
        
        
        if (!backgroundImage) {
            
            backgroundImage = [[self createBackgroundImage] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 10, 1)];
        }
        if (!backgroundImageSelected) {
            
            backgroundImageSelected = [[self createBackgroundImageSelected] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 10, 1)];
        }
        
        titleLabel.font = resource(@"Fonts.TableViews.Title.Font");
        titleLabel.textColor = resource(@"Fonts.TableViews.Title.Color");
        
        pageNumberLabel.font = resource(@"Fonts.TableViews.PageNumber.Font");
        pageNumberLabel.textColor = resource(@"Fonts.TableViews.PageNumber.Color");
        
        self.backgroundImageView.image = backgroundImage;
    }
    
    return self;
}


- (void) setTitle:(NSString *)theTitle {
    
    title = theTitle;
    
    self.titleLabel.text = theTitle;
}


- (void) setPageNumber:(uint)thePageNumber {
    
    pageNumber = thePageNumber;
    
    self.pageNumberLabel.text = [NSString stringWithFormat:@"%d", thePageNumber];
}


- (void) setIsFavorite:(BOOL)theIsFavorite {
    
    isFavorite = theIsFavorite;
    
    UIImage* iconImage = isFavorite ? resource(@"Images.TableViews.Icons.Card.Favorite") : resource(@"Images.TableViews.Icons.Card.Normal");
    
    self.cardImageView.image = iconImage;
}


- (void) setLearnStatus:(uint)theLearnStatus {
    
    learnStatus = theLearnStatus;
    
    UIImage* learnStatusImage = nil;

    switch (theLearnStatus) {
            
        case PageLearnStatusUnderstood:
            learnStatusImage = resource(@"Images.TableViews.Icons.LearnStatus.Check");
            break;
            
        case PageLearnStatusNotUnderstood:
            learnStatusImage = resource(@"Images.TableViews.Icons.LearnStatus.Cross");
            break;
            
        default:
            break;
    }
    
    self.learnStatusImageView.image = learnStatusImage;
}


- (void) setCellSelected:(BOOL)selected {
    
    NSLog(@"selected");
    
    if (selected) {
        
        self.backgroundImageView.image = backgroundImageSelected;
    }
    else {
        
        self.backgroundImageView.image = backgroundImage;
    }
    
    [self setNeedsDisplay];
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
}


- (UIImage*) createBackgroundImage {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, TRUE, 0.0f);
    
    UIImage* pattern = resource(@"Images.ModuleCells.BackgroundPattern");
    UIImage* separator = resource(@"Images.Misc.SeperatorPattern");
    
    [[pattern resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] drawInRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - separator.size.height)];
    
    [[separator resizableImageWithCapInsets:UIEdgeInsetsZero] drawInRect:CGRectMake(0, self.bounds.size.height - separator.size.height, self.bounds.size.width, separator.size.height)];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (UIImage*) createBackgroundImageSelected {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, TRUE, 0.0f);
    
    UIImage* pattern = resource(@"Images.ModuleCells.BackgroundPattern");
    UIImage* separator = resource(@"Images.Misc.SeperatorPattern");
    
    pattern = [pattern imageWithAdjustmentBrightness:[UIColor colorWithHue:0 saturation:0 brightness:0.85 alpha:1.0]];

    [[pattern resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] drawInRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - separator.size.height)];
    
    [[separator resizableImageWithCapInsets:UIEdgeInsetsZero] drawInRect:CGRectMake(0, self.bounds.size.height - separator.size.height, self.bounds.size.width, separator.size.height)];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end


@implementation CardResultCell
    
@synthesize hitsLabel, hits;


- (id) init {
    
    if ((self = [[[NSBundle mainBundle] loadNibNamed:@"CardResultCell" owner:nil options:nil] objectAtIndex:0])) {
        
        static UIImage* backgroundImage = nil;
        
        if (!backgroundImage) {
            
            backgroundImage = [[self createBackgroundImage] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 10, 1)];
        }
        
        self.titleLabel.font = resource(@"Fonts.TableViews.Title.Font");
        self.titleLabel.textColor = resource(@"Fonts.TableViews.Title.Color");
        
        self.pageNumberLabel.font = resource(@"Fonts.TableViews.PageNumber.Font");
        self.pageNumberLabel.textColor = resource(@"Fonts.TableViews.PageNumber.Color");
        
        self.hitsLabel.font = resource(@"Fonts.TableViews.Hits.Font");
        self.hitsLabel.textColor = resource(@"Fonts.TableViews.Hits.Color");
        
        self.backgroundImageView.image = backgroundImage;
    }
    
    return self;
}


- (void) setHits:(uint)theHits {
    
    hits = theHits;
    
    self.hitsLabel.text = [NSString stringWithFormat:@"%d", hits];
}


@end



@implementation CardCell2

#define CardCell_CardImage_Position CGPointMake(7,7)
#define CardCell_CardImage_Size CGSizeMake(30,30)
#define CardCell_StatusImage_MarginRight 7          // center vertically
#define CardCell_StatusImage_Size CGSizeMake(30,30)
#define CardCell_PageNumberLabel_PositionX (36 + 27)       // center vertically, align right
#define CardCell_PageNumberLabel_Size CGSizeMake(27,21)
#define CardCell_PageNumberLabel_Font [UIFont fontWithName:@"Helvetica" size:13.0]
#define CardCell_PageNumberLabel_TextColor [UIColor blueColor]
#define CardCell_TitleLabel_PositionX 75            // center vertically
#define CardCell_TitleLabel_Height 43
#define CardCell_TitleLabel_MarginRight 45
#define CardCell_TitleLabel_Font [UIFont fontWithName:@"Helvetica" size:13.0]
#define CardCell_TitleLabel_TextColor [UIColor blackColor]

@synthesize isFavorite, learnStatus, pageNumber, title;


- (id) init {
    
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CardCell"]) {
        
        self.clearsContextBeforeDrawing = TRUE;
    }
    
    return self;
}


- (void) didMoveToSuperview {
    
    [super didMoveToSuperview];
    
    NSLog(@"CardCell2 didMoveToSuperview (pageNumber: %d", self.pageNumber);
}


- (void) prepareForReuse {
    
    [super prepareForReuse];
    
    [self setNeedsDisplay];
}


- (void) drawRect:(CGRect)rect {
    
    NSLog(@"CardCell drawRect (pageNumber: %d", self.pageNumber);
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    UIImage* cardImage = [UIImage imageNamed:(isFavorite) ? @"card_favorite.png" : @"card.png"];
    UIImage* learnStatusImage = nil;
    if (self.learnStatus != PageLearnStatusNew) {
        learnStatusImage = [UIImage imageNamed:(self.learnStatus == PageLearnStatusUnderstood) ? @"gewusst_cell.png" : @"wiederholen_cell.png"];
    }
 
    NSString* text;
    CGSize textSize;
    CGPoint textPoint;
    
    // draw card image
    [cardImage drawAtPoint:CardCell_CardImage_Position];
    
    // draw pagenumber
    CGContextSetFillColorWithColor(context, CardCell_PageNumberLabel_TextColor.CGColor);
    text = [NSString stringWithFormat:@"%d", self.pageNumber];
    textSize = [text sizeWithFont:CardCell_PageNumberLabel_Font];
    textPoint = CGPointMake(CardCell_PageNumberLabel_PositionX - textSize.width, round((rect.size.height - textSize.height) / 2));
    [text drawAtPoint:textPoint withFont:CardCell_PageNumberLabel_Font];
    
    // draw title
    CGContextSetFillColorWithColor(context, CardCell_TitleLabel_TextColor.CGColor);
    text = self.title;
    textSize = [text sizeWithFont:CardCell_TitleLabel_Font constrainedToSize:CGSizeMake(rect.size.width - CardCell_TitleLabel_PositionX - CardCell_TitleLabel_MarginRight, rect.size.height) lineBreakMode:UILineBreakModeWordWrap];
    textPoint = CGPointMake(CardCell_TitleLabel_PositionX, round((rect.size.height - textSize.height) / 2));
    [text drawAtPoint:textPoint withFont:CardCell_TitleLabel_Font];
    
    // draw status image
    [learnStatusImage drawAtPoint:CGPointMake(rect.size.width - CardCell_StatusImage_Size.width - CardCell_StatusImage_MarginRight, round((rect.size.height - CardCell_StatusImage_Size.height) / 2))];
    
    
}

@end



@implementation CategoryCell

@synthesize titleLabel, countLabel;
@synthesize backgroundImageView;
@synthesize learningProgressBarImageView, learningProgressLabel;


//static UIImage* backgroundImage = nil;
//static UIImage* backgroundImageSelected = nil;


- (id) init {
    
    if ((self = [[[NSBundle mainBundle] loadNibNamed:@"CategoryCell" owner:nil options:nil] objectAtIndex:0])) {
        
        
        if (!backgroundImage) {
            
            backgroundImage = [[self createBackgroundImage] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 10, 1)];
        }
        if (!backgroundImageSelected) {
            
            backgroundImageSelected = [[self createBackgroundImageSelected] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 10, 1)];
        }
        
        titleLabel.font = resource(@"Fonts.TableViews.Title.Font");
        titleLabel.textColor = resource(@"Fonts.TableViews.Title.Color");
        
        countLabel.font = resource(@"Fonts.TableViews.Counter.Font");
        countLabel.textColor = resource(@"Fonts.TableViews.Counter.Color");
        
        learningProgressLabel.font = resource(@"Fonts.TableViews.Percentage.Font");
        learningProgressLabel.textColor = resource(@"Fonts.TableViews.Percentage.Color");
        
        self.backgroundImageView.image = backgroundImage;
    }
    
    return self;
}


- (void) prepareForReuse {
    
    learningProgressBarImageView.hidden = FALSE;
    learningProgressLabel.hidden = FALSE;
}


- (void) setCellSelected:(BOOL)selected {
    
    NSLog(@"selected");
    
    if (selected) {
        
        self.backgroundImageView.image = backgroundImageSelected;
    }
    else {
        
        self.backgroundImageView.image = backgroundImage;
    }
    
    [self setNeedsDisplay];
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
}


- (UIImage*) createBackgroundImage {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, TRUE, 0.0f);
    
    UIImage* pattern = resource(@"Images.ModuleCells.BackgroundPattern");
    UIImage* separator = resource(@"Images.Misc.SeperatorPattern");
    
    [[pattern resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] drawInRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - separator.size.height)];
    
    [[separator resizableImageWithCapInsets:UIEdgeInsetsZero] drawInRect:CGRectMake(0, self.bounds.size.height - separator.size.height, self.bounds.size.width, separator.size.height)];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (UIImage*) createBackgroundImageSelected {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, TRUE, 0.0f);
    
    UIImage* pattern = resource(@"Images.ModuleCells.BackgroundPattern");
    UIImage* separator = resource(@"Images.Misc.SeperatorPattern");
    
    pattern = [pattern imageWithAdjustmentBrightness:[UIColor colorWithHue:0 saturation:0 brightness:0.85 alpha:1.0]];

    [[pattern resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] drawInRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - separator.size.height)];
    
    [[separator resizableImageWithCapInsets:UIEdgeInsetsZero] drawInRect:CGRectMake(0, self.bounds.size.height - separator.size.height, self.bounds.size.width, separator.size.height)];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end


@implementation CategoryResultCell

@synthesize hitsLabel, pageHitsLabel;

- (id) init {
    
    if ((self = [[[NSBundle mainBundle] loadNibNamed:@"CategoryResultCell" owner:nil options:nil] objectAtIndex:0])) {
        
        static UIImage* backgroundImage = nil;
        
        if (!backgroundImage) {
            
            backgroundImage = [[self createBackgroundImage] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 10, 1)];
        }
        
        self.titleLabel.font = resource(@"Fonts.TableViews.Title.Font");
        self.titleLabel.textColor = resource(@"Fonts.TableViews.Title.Color");
        
        self.countLabel.font = resource(@"Fonts.TableViews.Counter.Font");
        self.countLabel.textColor = resource(@"Fonts.TableViews.Counter.Color");
        
//        self.learningProgressLabel.font = resource(@"Fonts.TableViews.Percentage.Font");
//        self.learningProgressLabel.textColor = resource(@"Fonts.TableViews.Percentage.Color");
        
        self.hitsLabel.font = resource(@"Fonts.TableViews.Hits.Font");
        self.hitsLabel.textColor = resource(@"Fonts.TableViews.Hits.Color");

        self.pageHitsLabel.font = resource(@"Fonts.TableViews.Hits.Font");
        self.pageHitsLabel.textColor = resource(@"Fonts.TableViews.Hits.Color");

        self.backgroundImageView.image = backgroundImage;
    }
    
    return self;
}

@end



@implementation NoteCell

@synthesize noteTextLabel;
@synthesize noteText;


- (id) init {
    
    if ((self = [[[NSBundle mainBundle] loadNibNamed:@"NoteCell" owner:nil options:nil] objectAtIndex:0])) {
        
        static UIImage* backgroundImage = nil;
        
        if (!backgroundImage) {
            
            backgroundImage = [[self createBackgroundImage] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 10, 1)];
        }
        if (!backgroundImageSelected) {
            
            backgroundImageSelected = [[self createBackgroundImageSelected] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 10, 1)];
        }
        
        self.titleLabel.font = resource(@"Fonts.TableViews.Title.Font");
        self.titleLabel.textColor = resource(@"Fonts.TableViews.Title.Color");
        
        self.pageNumberLabel.font = resource(@"Fonts.TableViews.PageNumber.Font");
        self.pageNumberLabel.textColor = resource(@"Fonts.TableViews.PageNumber.Color");
        
        self.noteTextLabel.font = resource(@"Fonts.TableViews.Notes.Font");
        self.noteTextLabel.textColor = resource(@"Fonts.TableViews.Notes.Color");
        
        self.backgroundImageView.image = backgroundImage;
    }
    
    return self;
}


- (void) setNoteText:(NSString *)theNoteText {
 
    noteText = theNoteText;
    
    noteTextLabel.text = theNoteText;
}

- (void) setCellSelected:(BOOL)selected {
    
    NSLog(@"selected");
    
    if (selected) {
        
        self.backgroundImageView.image = backgroundImageSelected;
    }
    else {
        
        self.backgroundImageView.image = backgroundImage;
    }
    
    [self setNeedsDisplay];
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
}

@end




@implementation InfoCell

@synthesize titleLabel;
@synthesize backgroundImageView;




- (id) init {
    
    if ((self = [[[NSBundle mainBundle] loadNibNamed:@"InfoCell" owner:nil options:nil] objectAtIndex:0])) {
        
        static UIImage* backgroundImage = nil;
        
        if (!backgroundImage) {
            
            backgroundImage = [[self createBackgroundImage] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 10, 1)];
        }
        
        
        titleLabel.font = resource(@"Fonts.TableViews.Info.Font");
        titleLabel.textColor = resource(@"Fonts.TableViews.Info.Color");
        
        self.backgroundImageView.image = backgroundImage;
    }
    
    return self;
}




- (UIImage*) createBackgroundImage {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, TRUE, 0.0f);
    
    UIImage* pattern = resource(@"Images.ModuleCells.BackgroundPattern");
    UIImage* separator = resource(@"Images.Misc.SeperatorPattern");
    
    [[pattern resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] drawInRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - separator.size.height)];
    
    [[separator resizableImageWithCapInsets:UIEdgeInsetsZero] drawInRect:CGRectMake(0, self.bounds.size.height - separator.size.height, self.bounds.size.width, separator.size.height)];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
