//
//  PageViewController.h
//  KlettAbiLernboxen
//
//  Created by Stefan Ueter on 29.10.14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ScrollView2.h"

@interface PageViewController : UIViewController

@property (nonatomic, strong) IBOutlet ScrollView2* scrollView2;

@property (nonatomic, strong) IBOutlet UIView* contentView2;

@end
