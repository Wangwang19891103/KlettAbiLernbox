//
//  ImprintViewController.h
//  KlettAbiLernboxen
//
//  Created by Wang on 06.12.12.
//
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface ImprintViewController : UIViewController <UIWebViewDelegate, MFMailComposeViewControllerDelegate> {
    
    BOOL _imprintLoaded;
    BOOL _creditsLoaded;
    
    UIImageView* __strong _seperator;
}

@property (nonatomic, strong) IBOutlet UIButton* recommendButton;

@property (nonatomic, strong) IBOutlet UIWebView* imprintWebView;

@property (nonatomic, strong) IBOutlet UIWebView* imageCreditsWebView;

@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;

@property (nonatomic, strong) IBOutlet UIView* contentView;


- (IBAction) actionAGBs;

@end
