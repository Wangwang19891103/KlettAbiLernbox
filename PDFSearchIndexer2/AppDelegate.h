//
//  AppDelegate.h
//  PDFSearchIndexer2
//
//  Created by Wang on 12.12.14.
//
//

#import <UIKit/UIKit.h>
#import "LogViewController.h"
#import "PDFTextScanner.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, PDFTextScannerDelegate> {
    
    LogViewController* _log;
    uint _errorCount;
    NSArray* _stopWords;
    NSDictionary* _actualPageNumbers;
    NSMutableDictionary* _indexDict;
}

@property (strong, nonatomic) UIWindow *window;


@end

