//
//  ViewController.m
//  TEST_scrollviews
//
//  Created by Stefan Ueter on 29.10.14.
//
//

#import "ViewController.h"
#import "PageViewController.h"


@implementation ViewController


@synthesize scrollView1;
@synthesize contentView1;


- (void)viewDidLoad {

    [super viewDidLoad];

    CGRect frame = self.scrollView1.frame;
    frame.size.width *= 5;
    
    self.contentView1.frame = frame;
    
    self.scrollView1.pagingEnabled = YES;
    [self.scrollView1 setContentSize:frame.size];
    
    for (uint i = 0; i < 5; ++i) {
        
        PageViewController* pageController = [[PageViewController alloc] init];
        
        CGRect frame = pageController.view.frame;
        frame.origin.x = i * frame.size.width;
        pageController.view.frame = frame;
        
        [self.contentView1 addSubview:pageController.view];
        [self addChildViewController:pageController];

        pageController.contentView2.backgroundColor = i % 2 ? [UIColor blueColor] : [UIColor redColor];
    
        
    }
}


@end
