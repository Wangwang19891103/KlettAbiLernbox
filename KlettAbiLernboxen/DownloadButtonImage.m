//
//  DownloadButton.m
//  KlettAbiLernboxen
//
//  Created by Wang on 14.11.12.
//
//

#import "DownloadButtonImage.h"
#import "ResourceManager.h"


#define Bar_Rect CGRectMake(5,26,58,6)
#define Bar_Foreground_Margin 1
#define Minimum_Progress_Width 3

#define Shop_Bar_Rect CGRectMake(6,27,60,6)
#define Shop_Bar_Foreground_Margin 1

@implementation DownloadButtonImage

+ (UIImage*) imageWithProgress:(float)progress buttonName:(NSString *)buttonName {
    
    UIImage* backgroundImage = [[ResourceManager instance] resourceForKeyPath:[NSString stringWithFormat:@"Images.ModuleCells.Buttons.%@", buttonName]];
                                
    UIImage* barBackgroundImage = [[ResourceManager instance] resourceForKeyPath:@"Images.ModuleCells.Buttons.DownloadBar.Background"];
    barBackgroundImage = [barBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    UIImage* barForegroundImage = [[ResourceManager instance] resourceForKeyPath:@"Images.ModuleCells.Buttons.DownloadBar.Foreground"];
    barForegroundImage = [barForegroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(backgroundImage.size.width, backgroundImage.size.height), FALSE, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    /* drawing */
    
//    CGRect rect = CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height);

    [backgroundImage drawAtPoint:CGPointZero];
    
    [barBackgroundImage drawInRect:Bar_Rect];
    
    int progressWidth = (int)((Bar_Rect.size.width - (2 * Bar_Foreground_Margin)) * progress);
    if (progressWidth > 0 && progressWidth < Minimum_Progress_Width) {
        progressWidth = Minimum_Progress_Width;
    }
    
    CGRect foregroundRect = CGRectMake(Bar_Rect.origin.x + Bar_Foreground_Margin,
                                       Bar_Rect.origin.y + Bar_Foreground_Margin,
                                       progressWidth,
                                       Bar_Rect.size.height - (2 * Bar_Foreground_Margin));
    
    [barForegroundImage drawInRect:foregroundRect];
    
    /* /drawing */
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


+ (UIImage*) shopImageWithProgress:(float)progress buttonName:(NSString *)buttonName {
    
    UIImage* backgroundImage = [[ResourceManager instance] resourceForKeyPath:[NSString stringWithFormat:@"Images.Shop.Buttons.%@", buttonName]];
    
    UIImage* barBackgroundImage = [[ResourceManager instance] resourceForKeyPath:@"Images.Shop.Buttons.DownloadBar.Background"];
    barBackgroundImage = [barBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    UIImage* barForegroundImage = [[ResourceManager instance] resourceForKeyPath:@"Images.Shop.Buttons.DownloadBar.Foreground"];
    barForegroundImage = [barForegroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(backgroundImage.size.width, backgroundImage.size.height), FALSE, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    /* drawing */
    
    //    CGRect rect = CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height);
    
    [backgroundImage drawAtPoint:CGPointZero];
    
    [barBackgroundImage drawInRect:Shop_Bar_Rect];
    
    int progressWidth = (int)((Shop_Bar_Rect.size.width - (2 * Shop_Bar_Foreground_Margin)) * progress);
    if (progressWidth > 0 && progressWidth < Minimum_Progress_Width) {
        progressWidth = Minimum_Progress_Width;
    }
    
    CGRect foregroundRect = CGRectMake(Shop_Bar_Rect.origin.x + Shop_Bar_Foreground_Margin,
                                       Shop_Bar_Rect.origin.y + Shop_Bar_Foreground_Margin,
                                       progressWidth,
                                       Shop_Bar_Rect.size.height - (2 * Shop_Bar_Foreground_Margin));
    
    [barForegroundImage drawInRect:foregroundRect];
    
    /* /drawing */
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
