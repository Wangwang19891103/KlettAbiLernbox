//
//  MethodsViewController.h
//  KlettAbiLernboxen
//
//  Created by Wang on 07.12.12.
//
//

#import <Foundation/Foundation.h>

@interface MethodsViewController : UIViewController <UIWebViewDelegate> {
    
    UIScrollView* __strong _scrollView;
    UIView* __strong _contentView;
    UIWebView* __strong _webView;
}

@end
