//
//  AGBsViewController.h
//  KlettAbiLernboxen
//
//  Created by Wang on 17.06.13
//
//

#import <Foundation/Foundation.h>

@interface AGBsViewController : UIViewController <UIWebViewDelegate> {
    
    UIScrollView* __strong _scrollView;
    UIView* __strong _contentView;
    UIWebView* __strong _webView;
}

@end
