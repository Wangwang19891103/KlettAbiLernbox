//
//  ModuleCell.m
//  KlettAbiLernboxen
//
//  Created by Wang on 17.10.12.
//
//

#import "ModuleCell.h"
#import "UIColor+Extensions.h"
#import "ResourceManager.h"
#import "DownloadButtonImage.h"
#import "LearningProgressBarImage.h"
#import "UserDataManager.h"
#import "PropertyBoard.h"
#import "UIImage+Extensions.h"



@implementation ModuleCell

@synthesize moduleTitleLabel, descriptionTextView, priceLabel, moduleImageView, statusLabel, progressLabel, product, contentInstallationStatus;
@synthesize shopButton;
@synthesize buyButton;
@synthesize delegate;

@synthesize moduleName;
@synthesize backgroundImageView;
@synthesize learningProgressBarImageView;
@synthesize learningProgressLabel;
@synthesize learningProgressLabel2;


static UIImage* backgroundImage = nil;
static UIImage* backgroundImageSelected = nil;


+ (ModuleCell*) cellWithModuleDict:(NSDictionary*) dict {

    ModuleCell* cell = [[[NSBundle mainBundle] loadNibNamed:@"ModuleCell" owner:nil options:nil] objectAtIndex:0];

    

    
    if (!backgroundImage) {
        
        backgroundImage = [[cell createBackgroundImage] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 10, 1)];
    }

    if (!backgroundImageSelected) {
        
        backgroundImageSelected = [[cell createBackgroundImageSelected] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 10, 1)];
    }
    
    
    cell.moduleTitleLabel.font = resource(@"Fonts.ModuleCells.Title.Font");
    cell.moduleTitleLabel.textColor = resource(@"Fonts.ModuleCells.Title.Color");
    
    cell.descriptionTextView.font = resource(@"Fonts.ModuleCells.Description.Font");
    cell.descriptionTextView.textColor = resource(@"Fonts.ModuleCells.Description.Color");
    
    cell.progressLabel.font = resource(@"Fonts.ModuleCells.Percentage.Font");
    cell.progressLabel.textColor = resource(@"Fonts.ModuleCells.Percentage.Color");
    
//    cell.backgroundImageView.image = (uint)(arc4random() % 2) ? backgroundImage : backgroundImageSelected;
    cell.backgroundImageView.image = backgroundImage;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.moduleName = [dict objectForKey:@"title"];
    
    [[ModuleManager manager] addObserver:cell forModule:cell.moduleName];
    
    cell.moduleTitleLabel.text = [dict objectForKey:@"title"];
    cell.descriptionTextView.text = [dict objectForKey:@"shortDescription"];
//    [cell.moduleImageView setImage:[ModuleImage imageWithText:nil color:[UIColor colorFromString:[dict objectForKey:@"color"]]]];
    
//    NSString* moduleImageResourceName = [NSString stringWithFormat:@"Images.ModuleCells.Icons.%@", cell.moduleName];
//    UIImage* moduleImage = [[ResourceManager instance] resourceForKeyPath:moduleImageResourceName];
    UIImage* moduleImage = [[ModuleManager manager] iconImageForModule:cell.moduleName];
    
    UIColor* moduleColor = [[ModuleManager manager] colorForModule:cell.moduleName];

    moduleImage = [moduleImage imageWithAdjustmentColor:moduleColor];
    
    cell.moduleImageView.image = moduleImage;
    
//    UIImage* backgroundImage = [[ResourceManager instance] resourceForKeyPath:@"Images.ModuleCells.BackgroundPattern"];
//    backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 2)];
//    cell.backgroundImageView.image = backgroundImage;
    
    
    [cell.contentView addSubview:cell.shopButton];
    [cell.contentView addSubview:cell.buyButton];

    [cell refreshView];
    
    return cell;
}



#pragma mark ModuleManagerObserver

- (void) product:(UAProduct *)product loadedForModule:(NSString *)theModuleName {

    NSLog(@"product:loadedForModule:(%@)", theModuleName);
    
    self.product = product;
    
    [self refreshView];
}


- (void) product:(UAProduct *)product statusChangedTo:(NSNumber *)status forModule:(NSString *)theModuleName {
    
    NSLog(@"product:statusChangeTo:(%@)forModule:(%@)", status, theModuleName);
    
    [self refreshView];
}


- (void) product:(UAProduct *)product progressChangedTo:(NSNumber *)progress forModule:(NSString *)theModuleName {
    
//    NSLog(@"product:progressChangedTo:(%@)forModule:(%@)", progress, theModuleName);
//
//    UIImage* shopButtonImage = [DownloadButtonImage imageWithProgress:[progress floatValue] buttonName:@"Downloading"];
//    
//    [self.shopButton setImage:shopButtonImage forState:UIControlStateNormal];
//    
//    uint percent = floor([progress floatValue] * 100);
//    self.progressLabel.text = [NSString stringWithFormat:@"%d%%", percent];
}


- (void) updateLearningBar {
    
    /* learning progress bar */
    
    uint understoodPages = [UserDataManager numberOfUnderstoodPageForModule:moduleName];
    
    UIImage* learningProgressBarImage = [LearningProgressBarImage imageWithProgress:(understoodPages / 100.0f)  size:self.learningProgressBarImageView.frame.size];
    self.learningProgressBarImageView.image = learningProgressBarImage;
    
    int progressPercent = understoodPages;  // make relative to max pages!
    NSString* progressString = [NSString stringWithFormat:@"%d%%", progressPercent];
    self.learningProgressLabel.text = progressString;
    
    if (PBintVarValue(@"hide empty bars") == 1
        && progressPercent == 0) {
        
        learningProgressBarImageView.hidden = TRUE;
        learningProgressLabel.hidden = TRUE;
        learningProgressLabel2.hidden = TRUE;
    }
    else {
        
        learningProgressBarImageView.hidden = FALSE;
        learningProgressLabel.hidden = FALSE;
        learningProgressLabel2.hidden = FALSE;
    }
}



- (void) layout {
    
    [self updateLearningBar];
}


- (void) refreshView {
    
    NSLog(@"ModuleCell -refreshView (%@)", moduleName);

    self.contentInstallationStatus = [[ModuleManager manager] contentInstalledForModule:moduleName];

    
    /* background color */

//    if (contentInstallationStatus == ModuleInstallationStatusFull) {
//        
//        self.backgroundView.backgroundColor = [UIColor clearColor];
//    }
//    else if (contentInstallationStatus == ModuleInstallationStatusDemo) {
//        
//        self.backgroundView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
//    }
//    else {
//        
//        self.backgroundView.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
//    }

    
    [self updateLearningBar];
    
    priceLabel.text = product.price;
    
    
    if (self.product) {
        
        self.statusLabel.hidden = FALSE;

        
        /* progress label */
        
//        switch (self.product.status) {
//                
//            case UAProductStatusDownloading:
//                self.progressLabel.hidden = FALSE;
//                break;
//                
//            default:
//                self.progressLabel.hidden = TRUE;
//                break;
//        }

        
        /* status label */
        
//        NSString* statusText = nil;
//        switch (self.product.status) {
//                
//            case UAProductStatusUnpurchased:
//                statusText = @"Nicht gekauft";
//                break;
//                
//            case UAProductStatusPurchasing:
//            case UAProductStatusPurchased:
//            case UAProductStatusVerifyingReceipt:
//            case UAProductStatusDownloading:
//            case UAProductStatusDecompressing:
//                statusText = @"Wird geladen";
//                break;
//                
//            case UAProductStatusInstalled:
//                statusText = @"Installiert";
//                break;
//                
//            case UAProductStatusHasUpdate:
//                statusText = @"Update verf.";
//                break;
//                
//            default:
//                statusText = @"";
//                break;
//        }
//
//        self.statusLabel.text = statusText;

        
        /* price label */
        
//        if (self.product.status == UAProductStatusUnpurchased) {
//            
//            self.priceLabel.text = self.product.price;
//            self.priceLabel.hidden = FALSE;
//        }
//        else if (self.product.status == UAProductStatusHasUpdate) {
//
//            self.priceLabel.text = @"Update";
//            self.priceLabel.hidden = FALSE;
//        }
//        else {
//            
//            self.priceLabel.text = @"";
//            self.priceLabel.hidden = TRUE;
//        }

        
        /* shop button */
        
        shopButton.hidden = FALSE;
        buyButton.hidden = FALSE;
        
        NSString* ButtonName = nil;
        switch (self.product.status) {
                
            case UAProductStatusUnpurchased:
                ButtonName = @"Shop";
                break;
                
            case UAProductStatusPurchasing:
            case UAProductStatusPurchased:
                ButtonName = @"Buying";
                break;
            
            case UAProductStatusVerifyingReceipt:
                ButtonName = @"Checking";
                break;
                
            case UAProductStatusDownloading:
                ButtonName = @"Downloading";
                break;
                
            case UAProductStatusDecompressing:
                ButtonName = @"Installing";
                break;
                
            case UAProductStatusInstalled:
                ButtonName = @"Info";
                break;

            case UAProductStatusHasUpdate:
                ButtonName = @"Update";
                break;
                
            default:
                ButtonName = @"Shop";
                break;
        }

        UIImage* shopButtonImage = nil;
//
//        if ([ButtonName isEqualToString:@"Buying"]) {
//            
//            shopButtonImage = [DownloadButtonImage imageWithProgress:0.0f buttonName:ButtonName];
//        }
//        else if ([ButtonName isEqualToString:@"Checking"]) {
//            
//            shopButtonImage = [DownloadButtonImage imageWithProgress:0.0f buttonName:ButtonName];
//        }
//        else if ([ButtonName isEqualToString:@"Downloading"]) {
//            
//            shopButtonImage = [DownloadButtonImage imageWithProgress:0.0f buttonName:ButtonName];
//        }
//        else if ([ButtonName isEqualToString:@"Installing"]) {
//            
//            shopButtonImage = [DownloadButtonImage imageWithProgress:1.0f buttonName:ButtonName];
//        }
//        else {
//         
//            shopButtonImage = [[ResourceManager instance] resourceForKeyPath:[NSString stringWithFormat:@"Images.ModuleCells.Buttons.%@", ButtonName]];
//        }
//
//        [self.shopButton setImage:shopButtonImage forState:UIControlStateNormal];

    }
    
    [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];  // force run loop to update UI
}


- (void) setCellSelected:(BOOL)selected {

    NSLog(@"selected");
    
    if (selected) {
        
        backgroundImageView.image = backgroundImageSelected;
    }
    else {
        
        backgroundImageView.image = backgroundImage;
    }
    
    [self setNeedsDisplay];
    
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
}


- (IBAction) actionShop {
    
    NSLog(@"shop");
    
    [delegate moduleCellDidRequestShop:self];
}

- (IBAction) purchase:(id) sender {
    
    if (product.status == UAProductStatusInstalled) {
        
        [self restoreProduct];
    }
    else {
        
        [UAStoreFront purchase:product.productIdentifier];
    }
}

- (void) restoreProduct {
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:resource(@"Dictionaries.Shop.Restore.Title") message:resource(@"Dictionaries.Shop.Restore.Body") delegate:self cancelButtonTitle:@"Ja" otherButtonTitles:@"Nein", nil];
    
    [alert show];
}

- (UIImage*) createBackgroundImage {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, TRUE, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIImage* pattern = resource(@"Images.ModuleCells.BackgroundPattern");
    UIImage* separator = resource(@"Images.Misc.SeperatorPattern");
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, self.bounds);
    
    [[pattern resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] drawInRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - separator.size.height)];
    
    [[separator resizableImageWithCapInsets:UIEdgeInsetsZero] drawInRect:CGRectMake(0, self.bounds.size.height - separator.size.height, self.bounds.size.width, separator.size.height)];
    
//    [separator drawAsPatternInRect:self.bounds];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    [image saveInDocumentsWithName:@"ModuleCellBG.png"];
    
    NSLog(@"createBackgroundImage: height=%f, separatorSize=%@, separatorPosition=%f",
          self.bounds.size.height,
          NSStringFromCGSize(separator.size),
          self.bounds.size.height - separator.size.height);
    
    return image;
}


- (UIImage*) createBackgroundImageSelected {
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, TRUE, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIImage* pattern = resource(@"Images.ModuleCells.BackgroundPattern");
    UIImage* separator = resource(@"Images.Misc.SeperatorPattern");
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, self.bounds);

    pattern = [pattern imageWithAdjustmentBrightness:[UIColor colorWithHue:0 saturation:0 brightness:0.85 alpha:1.0]];

    [[pattern resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1)] drawInRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - separator.size.height)];
    
    [[separator resizableImageWithCapInsets:UIEdgeInsetsZero] drawInRect:CGRectMake(0, self.bounds.size.height - separator.size.height, self.bounds.size.width, separator.size.height)];
    
    //    [separator drawAsPatternInRect:self.bounds];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    [image saveInDocumentsWithName:@"ModuleCellBG.png"];
    
    NSLog(@"createBackgroundImage: height=%f, separatorSize=%@, separatorPosition=%f",
          self.bounds.size.height,
          NSStringFromCGSize(separator.size),
          self.bounds.size.height - separator.size.height);
    
    return image;
}


#pragma mark Dealloc 

- (void) dealloc {
    
    [[ModuleManager manager] removeObserver:self forModule:moduleName];
}





@end



@implementation ModuleImage

+ (ModuleImage*) imageWithText:(NSString*) text color:(UIColor *)color {
    
    //    NSLog(@"color: %@", color);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(57,57), FALSE, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat redValue, greenValue, blueValue;
    [color getRed:&redValue green:&greenValue blue:&blueValue alpha:nil];
    NSLog(@"ModuleImage: red: %f, green: %f, blue: %f", redValue, greenValue, blueValue);
    
    CGContextSetRGBFillColor(context, redValue, greenValue, blueValue, 1.0);
    CGContextFillRect(context, CGRectMake(0, 0, 57, 57));
    
    UIImage* image =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return (ModuleImage*)image;
}


@end
