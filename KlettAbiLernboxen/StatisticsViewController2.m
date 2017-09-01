//
//  StatisticsViewController2.m
//  KlettAbiLernboxen
//
//  Created by Wang on 25.11.12.
//
//

#import "StatisticsViewController2.h"
#import "PieChart.h"
#import "UserDataManager.h"
#import "UIImage+Extensions.h"
#import "UIColor+Extensions.h"
#import "LearningProgressBarImage.h"


@implementation StatisticsViewController2

static UIImage* bluePattern = nil;
static UIImage* redPattern = nil;
static UIColor* grayColor = nil;
static UIImage* seperator = nil;


- (id) init {
    
    if (self = [super init]) {
        
        if (!bluePattern) {
            
            bluePattern = [resource(@"Images.Misc.PatternLinedBlue") resizableImageWithCapInsets:UIEdgeInsetsZero];
            redPattern = [resource(@"Images.Misc.PatternLinedRed") resizableImageWithCapInsets:UIEdgeInsetsZero];
            grayColor = [UIColor colorWithHue:0 saturation:0 brightness:0.3 alpha:1];
            seperator = [resource(@"Images.Misc.SeperatorPattern") resizableImageWithCapInsets:UIEdgeInsetsZero];
            
//            _customNavigationItem = [[CustomNavigationItem alloc] init];
//            _customNavigationItem.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0];
//            _customNavigationItem.textColor = [UIColor whiteColor];
//            _customNavigationItem.title = @"";
        }
    }
    
    return self;
}


//- (UINavigationItem*) navigationItem {
//    
//    return _customNavigationItem;
//}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    UIColor* barColor = [[ModuleManager manager] colorForModule:[PDFManager manager].moduleName];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.view.autoresizesSubviews = TRUE;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:resource(@"Images.TableViews.BackgroundPattern")];

    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.autoresizesSubviews = TRUE;
//    _scrollView.bounces = FALSE;
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_scrollView addSubview:_contentView];
    [_scrollView setContentSize:_contentView.bounds.size];
    
    [self.view addSubview:_scrollView];
    
    
    [self setupView];
    
    
    /* setting up UI */
    
//    UIColor* barColor = [[ModuleManager manager] colorForModule:[PDFManager manager].moduleName];
    
    UIImage* bgImage = resource(@"Images.NavigationBar.Background");
    bgImage = [bgImage imageWithAdjustmentColor:[barColor colorByDarkingByPercent:0.3]];
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 2, 1)];
    
    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    
//    bgImage = resource(@"Images.TabBar.Background");
//    bgImage = [bgImage imageWithAdjustmentColor:[barColor colorByDarkingByPercent:0.3]];
//    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 2)];
//    [self.tabBarController.tabBar setBackgroundImage:bgImage];
//    
//    bgImage = resource(@"Images.TabBar.Selection");
//    bgImage = [bgImage imageWithAdjustmentColor:[barColor colorByDarkingByPercent:0.3]];
//    [self.tabBarController.tabBar setSelectionIndicatorImage:bgImage];
    
//    /* shadow image */
//    
//    bgImage = resource(@"Images.NavigationBar.BottomShadow");
//    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
//    
//    if (![self.navigationController.navigationBar respondsToSelector:@selector(shadowImage)]) {
//        
//        UIImageView* shadowView = [[UIImageView alloc] initWithImage:bgImage];
//        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//        shadowView.frame = CGRectMake(0, self.navigationController.navigationBar.bounds.size.height, self.view.bounds.size.width, bgImage.size.height);
//        [self.navigationController.navigationBar addSubview:shadowView];
//    }
}


- (void) viewWillAppear:(BOOL)animated {
    
    [self.navigationItem setTitle:[PDFManager manager].moduleName];

    UIColor* barColor = [[ModuleManager manager] colorForModule:[PDFManager manager].moduleName];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];;
    
    
    UIImage* bgImage = resource(@"Images.NavigationBar.Background");
    bgImage = [bgImage imageWithAdjustmentColor:[barColor colorByDarkingByPercent:0.3]];
    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 2, 1)];
    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsDefault];
    
//    bgImage = resource(@"Images.NavigationBar.BackgroundLandscape");
//    bgImage = [bgImage imageWithAdjustmentColor:[barColor colorByDarkingByPercent:0.3]];
//    bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 2, 1)];
//    [self.navigationController.navigationBar setBackgroundImage:bgImage forBarMetrics:UIBarMetricsLandscapePhone];
    
    
//    /* shadow image */
//    
//    if (!_shadowInitialized) {
//        
//        bgImage = resource(@"Images.NavigationBar.BottomShadow");
//        bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
//        
//        if (![self.navigationController.navigationBar respondsToSelector:@selector(shadowImage)]) {
//            
//            UIImageView* shadowView = [[UIImageView alloc] initWithImage:bgImage];
//            shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//            shadowView.frame = CGRectMake(0, self.navigationController.navigationBar.bounds.size.height, self.view.bounds.size.width, bgImage.size.height);
//            [self.navigationController.navigationBar addSubview:shadowView];
//        }
//        
//        _shadowInitialized = TRUE;
//    }
    
    
    [self setupView];
    
    
    [super viewWillAppear:animated];
    
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
    return true;
}


- (BOOL) shouldAutorotate {
    
    return true;
}


- (NSUInteger) supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskAll;
}


//- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    
//    [_customNavigationItem updateTitleView];
//}


- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    [self setupView];
}


- (void) setupView {
    
    
    [_contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    
    /* Pie Chart */
    
    [_pieChart removeFromSuperview];
    
    NSString* moduleName = [PDFManager manager].moduleName;
    uint understood = [UserDataManager numberOfUnderstoodPageForModule:moduleName];
    uint notunderstood = [UserDataManager numberOfNotUnderstoodPageForModule:moduleName];
    uint new = 100 - understood - notunderstood;
    
    _pieChart = [[PieChart alloc] initWithGray:new Green:understood Red:notunderstood];
    
    _pieChart.frame = CGRectMake(ti_int(20), ti_int(20), ti_int(130), ti_int(130));
    
    [_contentView addSubview:_pieChart];
    
    
    /* Boxes */

    CGSize boxSize = ti_size(CGSizeMake(20, 20));
    uint vPadding = ti_int(19);
    uint marginTop = _pieChart.frame.origin.y + (_pieChart.frame.size.height - (boxSize.height * 3 + vPadding * 2)) * 0.5;
    uint posX = _pieChart.frame.origin.x + _pieChart.frame.size.width + ti_int(13);
//    UIFont* font = [UIFont fontWithName:@"Helvetica-Light" size:ti_int2(14, 1.5)];
    UIFont* font = resource(@"Fonts.TableViews.Title.Font");
    uint textPosX = posX + boxSize.width + ti_int(10);
    NSString* text = nil;
//    float textHeight = [@"Test" sizeWithFont:font].height;
    CGSize textSize;
    CGRect textRect;
//    float textOffsetTop = (boxSize.height - textHeight) * 0.5;
    UILabel* label = nil;
//    UIColor* textColor = [UIColor colorWithHue:0 saturation:0 brightness:0.2 alpha:1];
    UIColor* textColor = resource(@"Fonts.TableViews.Title.Color");
    
    // blue
    
    uint posY = marginTop;
    
    UIImage* boxImage = [[bluePattern imageWithSize:ti_size(CGSizeMake(20, 20))] imageWithRoundedCornersUsingRadius:5];
    
    UIImageView* boxImageView = [[UIImageView alloc] initWithImage:boxImage];
    boxImageView.frame = CGRectMake(posX, posY, boxSize.width, boxSize.height);
    
    [_contentView addSubview:boxImageView];

    text = [NSString stringWithFormat:@"Gewusst: %d", understood];
    textSize = [text sizeWithFont:font];
    textRect = CGRectMake(textPosX, posY, textSize.width, boxSize.height);
    label = [[UILabel alloc] initWithFrame:textRect];
    label.font = font;
    label.text = text;
    label.textColor = textColor;
    label.opaque = FALSE;
    label.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:label];
    
    
    // gray
    
    posY += vPadding + boxSize.height;
    
    boxImage = [[[UIImage imageWithColor:grayColor] imageWithSize:ti_size(CGSizeMake(20, 20))] imageWithRoundedCornersUsingRadius:5];
    
    boxImageView = [[UIImageView alloc] initWithImage:boxImage];
    boxImageView.frame = CGRectMake(posX, posY, boxSize.width, boxSize.height);
    
    [_contentView addSubview:boxImageView];

    text = [NSString stringWithFormat:@"Neu: %d", new];
    textSize = [text sizeWithFont:font];
    textRect = CGRectMake(textPosX, posY, textSize.width, boxSize.height);
    label = [[UILabel alloc] initWithFrame:textRect];
    label.font = font;
    label.text = text;
    label.textColor = textColor;
    label.opaque = FALSE;
    label.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:label];

    
    // red
    
    posY += vPadding + boxSize.height;
    
    boxImage = [[redPattern imageWithSize:ti_size(CGSizeMake(20, 20))] imageWithRoundedCornersUsingRadius:5];
    
    boxImageView = [[UIImageView alloc] initWithImage:boxImage];
    boxImageView.frame = CGRectMake(posX, posY, boxSize.width, boxSize.height);
    
    [_contentView addSubview:boxImageView];

    text = [NSString stringWithFormat:@"Wiederholen: %d", notunderstood];
    textSize = [text sizeWithFont:font];
    textRect = CGRectMake(textPosX, posY, textSize.width, boxSize.height);
    label = [[UILabel alloc] initWithFrame:textRect];
    label.font = font;
    label.text = text;
    label.textColor = textColor;
    label.opaque = FALSE;
    label.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:label];


    posY += boxSize.height + ti_int(50);
    
    UIImageView* seperatorView = [[UIImageView alloc] initWithImage:seperator];
    seperatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [seperatorView setFrameOrigin:CGPointMake(0, posY)];
    [seperatorView setFrameWidth:self.view.bounds.size.width];
    [_contentView addSubview:seperatorView];
    
    
    posY += ti_int(15);
    
    /* Categories */
    
    
    NSArray* categories = [[PDFManager manager] categories];
    UIImage* progressImage = nil;
    UIView* progressView = nil;
    NSString* categoryName = nil;
    uint catProgress, catProgress2;
    NSRange catRange;
    CGSize barSize = ti_size(CGSizeMake(200, 8));
    uint pageCount;
    
    for (ContentsCategory* category in categories) {
        
        categoryName = category.name;
        pageCount = [[PDFManager manager] pageCountForCategory:categoryName];
        
        NSLog(@"category: %@", categoryName);
        
        // label
        
        text = categoryName;
        textSize = [text sizeWithFont:font];
        label = [[UILabel alloc] initWithFrame:CGRectMake(ti_int(20), posY, textSize.width, textSize.height)];
        label.text = text;
        label.textColor = textColor;
        label.font = font;
        label.opaque = FALSE;
        label.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:label];
        
        posY += label.bounds.size.height + ti_int(10);
        
        
        // progress bar
        
        catRange = [[PDFManager manager] pageRangeForCategory:categoryName];
        
        catProgress = [UserDataManager numberOfUnderstoodPageForModule:[PDFManager manager].moduleName inRange:catRange];
        catProgress2 = [UserDataManager numberOfNotUnderstoodPageForModule:[PDFManager manager].moduleName inRange:catRange];
        
        progressImage = [LearningProgressBarImage imageWithProgressNumber:catProgress progress2:catProgress2 totalNumber:pageCount size:barSize];
        
        progressView = [[UIImageView alloc] initWithImage:progressImage];
        [progressView setFrameOrigin:CGPointMake(ti_int(20), posY)];
        [_contentView addSubview:progressView];
        
        
        
        // percent label

        // blue
        text = [NSString stringWithFormat:@"%d%%", (int)roundFDigits(((float)catProgress / pageCount) * 100, 0)];
//        text = [NSString stringWithFormat:@"%d / ", catProgress];
//        textSize = [@"100 / " sizeWithFont:font];
        textSize = [@"100%%" sizeWithFont:font];
        label = [[UILabel alloc] initWithFrame:CGRectMake(progressView.frame.origin.x + progressView.frame.size.width + ti_int(15),
                                                          posY - (textSize.height - progressView.bounds.size.height) * 0.5,
                                                          textSize.width,
                                                          textSize.height)];
        label.text = text;
        label.textColor = textColor;
        label.font = font;
        label.textAlignment = UITextAlignmentRight;
        label.opaque = FALSE;
        label.backgroundColor = [UIColor clearColor];
        [_contentView addSubview:label];

//        // red
//        text = [NSString stringWithFormat:@"%d / ", catProgress2];
//        textSize = [@"100 / " sizeWithFont:font];
//        label = [[UILabel alloc] initWithFrame:CGRectMake(label.frame.origin.x + label.frame.size.width,
//                                                          label.frame.origin.y,
//                                                          textSize.width,
//                                                          textSize.height)];
//        label.text = text;
//        label.textColor = textColor;
//        label.font = font;
//        label.textAlignment = UITextAlignmentRight;
//        label.opaque = FALSE;
//        label.backgroundColor = [UIColor clearColor];
//        [_contentView addSubview:label];
//
//        
//        // total
//        text = [NSString stringWithFormat:@"%d", pageCount];
//        textSize = [@"100" sizeWithFont:font];
//        label = [[UILabel alloc] initWithFrame:CGRectMake(label.frame.origin.x + label.frame.size.width,
//                                                          label.frame.origin.y,
//                                                          textSize.width,
//                                                          textSize.height)];
//        label.text = text;
//        label.textColor = textColor;
//        label.font = font;
//        label.textAlignment = UITextAlignmentRight;
//        label.opaque = FALSE;
//        label.backgroundColor = [UIColor clearColor];
//        [_contentView addSubview:label];

        
        posY += ti_int(20);

        
        
        
        // seperator
        
        UIImageView* seperatorView = [[UIImageView alloc] initWithImage:seperator];
        seperatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [seperatorView setFrameOrigin:CGPointMake(0, posY)];
        [seperatorView setFrameWidth:self.view.bounds.size.width];
        [_contentView addSubview:seperatorView];
        
        posY += ti_int(15);
    }
    

    [_scrollView setContentSize:CGSizeMake(_scrollView.bounds.size.width, posY)];
}



@end
