//
//  GeneralCell.m
//  KlettAbiLernboxen
//
//  Created by Wang on 06.12.12.
//
//

#import "GeneralCell.h"

@implementation GeneralCell

@synthesize titleLabel;
@synthesize backgroundView;


static UIImage* backgroundImage = nil;
static UIImage* backgroundImageSelected = nil;


- (id) init {
    
     if ((self = [[[NSBundle mainBundle] loadNibNamed:@"GeneralCell" owner:nil options:nil] objectAtIndex:0])) {
        
         if (!backgroundImage) {
            
             backgroundImage = [[self createBackgroundImage] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 10, 1)];
         }
         
         if (!backgroundImageSelected) {
             
             backgroundImageSelected = [[self createBackgroundImageSelected] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 10, 1)];
         }
        
         self.titleLabel.font = resource(@"Fonts.GeneralCells.Title.Font");
         self.titleLabel.textColor = resource(@"Fonts.GeneralCells.Title.Color");
         
         self.backgroundView.image = backgroundImage;
         self.selectedBackgroundView = [[UIImageView alloc] initWithImage:backgroundImageSelected];
    }
    
    return self;
}


- (void) setCellSelected:(BOOL)selected {
    
    NSLog(@"selected");
    
    if (selected) {
        
        self.backgroundView.image = backgroundImageSelected;
    }
    else {
        
        self.backgroundView.image = backgroundImage;
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
