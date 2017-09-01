//
//  LearningProgressBarImage.m
//  KlettAbiLernboxen
//
//  Created by Wang on 14.11.12.
//
//

#import "LearningProgressBarImage.h"
#import "ResourceManager.h"
#import "UIImage+Extensions.h"
#import "PropertyBoard.h"

//#define Bar_Rect CGRectMake(0,0,155,10)
//#define Bar_Height 10
#define Bar_Foreground_Margin 0
#define Minimum_Progress_Width 10


@implementation LearningProgressBarImage

static UIImage* bluePattern = nil;
static UIImage* redPattern = nil;
static UIColor* grayColor = nil;


+ (void) initialize {
    
    if (!bluePattern) {
        
        bluePattern = resource(@"Images.Misc.PatternLinedBlue");
        redPattern = resource(@"Images.Misc.PatternLinedRed");
        grayColor = [UIColor colorWithHue:0 saturation:0 brightness:0.3 alpha:1];
    }
}


+ (UIImage*) imageWithProgress:(float)progress size:(CGSize)size {
    
    return [LearningProgressBarImage imageWithProgressNumber:progress totalNumber:1.0 size:size];
}


+ (UIImage*) imageWithProgressNumber:(float)progress totalNumber:(float)total size:(CGSize)size {
    
    [LearningProgressBarImage initialize];

    
    UIImage* barBackgroundImage = [[ResourceManager instance] resourceForKeyPath:@"Images.Misc.LearnStatusProgressBar.Background"];
    barBackgroundImage = [barBackgroundImage imageWithAdjustmentBrightness:[UIColor colorWithHue:1 saturation:PBintVarValue(@"bar saturation") * 0.01 brightness:PBintVarValue(@"bar brightness") * 0.01 alpha:1]];
    barBackgroundImage = [barBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(2, 5, 2, 5)];
    UIImage* barForegroundImage = [[ResourceManager instance] resourceForKeyPath:@"Images.Misc.LearnStatusProgressBar.Foreground"];
    barForegroundImage = [barForegroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    
    UIGraphicsBeginImageContextWithOptions(size, FALSE, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    /* drawing */
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    [barBackgroundImage drawInRect:rect];

    int progressWidth = (int)((rect.size.width - (2 * Bar_Foreground_Margin)) * (progress / total));
    if (progressWidth > 0 && progressWidth < Minimum_Progress_Width) {
        progressWidth = Minimum_Progress_Width;
    }
    
    CGRect foregroundRect = CGRectMake(rect.origin.x + Bar_Foreground_Margin,
                                       rect.origin.y + Bar_Foreground_Margin,
                                       progressWidth,
                                       rect.size.height - (2 * Bar_Foreground_Margin));
    
    [barForegroundImage drawInRect:foregroundRect];
    
    /* /drawing */
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}


+ (UIImage*) imageWithProgressNumber:(float)progress progress2:(float)progress2 totalNumber:(float)total size:(CGSize)size {
    
    [LearningProgressBarImage initialize];
    
    
//    UIImage* barBackgroundImage = [[ResourceManager instance] resourceForKeyPath:@"Images.Misc.LearnStatusProgressBar.Background"];
    UIImage* barBackgroundImage = [UIImage imageWithColor:grayColor];
    barBackgroundImage = [barBackgroundImage imageWithAdjustmentBrightness:[UIColor colorWithHue:1 saturation:PBintVarValue(@"bar saturation") * 0.01 brightness:PBintVarValue(@"bar brightness") * 0.01 alpha:1]];
    barBackgroundImage = [barBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(0,0,0,0)];
    UIImage* barForegroundImage = [bluePattern resizableImageWithCapInsets:UIEdgeInsetsMake(0,0,0,0)];
    UIImage* barForegroundImage2 = [redPattern resizableImageWithCapInsets:UIEdgeInsetsMake(0,0,0,0)];

    
    UIGraphicsBeginImageContextWithOptions(size, FALSE, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    /* drawing */
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    [barBackgroundImage drawInRect:rect];
    
    // blue
    int progressWidth = (int)((rect.size.width - (2 * Bar_Foreground_Margin)) * (progress / total));
    if (progressWidth > 0 && progressWidth < Minimum_Progress_Width) {
        progressWidth = Minimum_Progress_Width;
    }
    
    CGRect foregroundRect = CGRectMake(rect.origin.x + Bar_Foreground_Margin,
                                       rect.origin.y + Bar_Foreground_Margin,
                                       progressWidth,
                                       rect.size.height - (2 * Bar_Foreground_Margin));
    
    
    
    [barForegroundImage drawInRect:foregroundRect];

    // red
    int progressWidth2 = (int)((rect.size.width - (2 * Bar_Foreground_Margin)) * (progress2 / total));
    if (progressWidth2 > 0 && progressWidth2 < Minimum_Progress_Width) {
        progressWidth2 = Minimum_Progress_Width;
    }
    
    CGRect foregroundRect2 = CGRectMake(foregroundRect.origin.x + foregroundRect.size.width,
                                       rect.origin.y + Bar_Foreground_Margin,
                                       progressWidth2,
                                       rect.size.height - (2 * Bar_Foreground_Margin));
    
    
    
    [barForegroundImage2 drawInRect:foregroundRect2];

    
    /* /drawing */
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return [image imageWithRoundedCornersUsingRadius:3];
}


@end
