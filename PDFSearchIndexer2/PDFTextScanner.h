//
//  PDFTextScanner.h
//  KlettAbiLernboxen
//
//  Created by Wang on 16.12.14.
//
//

#import <Foundation/Foundation.h>


@class PDFTextScanner;


@protocol PDFTextScannerDelegate <NSObject>

- (void) PDFTextScanner:(PDFTextScanner*) scanner didReportError:(NSString*) error;

- (void) PDFTextScanner:(PDFTextScanner *)scanner didScanWord:(NSDictionary*) wordDict;

@end


@interface PDFTextScanner : NSObject {
    
    NSScanner* _scanner;
    BOOL _isInsidePage;
    NSCharacterSet* _whitespaceSet;
    NSCharacterSet* _punctuationSet;
    NSCharacterSet* _letterSet;
    NSCharacterSet* _invertedLetterSet;
    uint _currentPage;
    NSString* _currentWord;
    BOOL _hasError;
    NSString* _cleanWord;
}


@property (nonatomic, assign) id<PDFTextScannerDelegate> delegate;


- (id) initWithString:(NSString*) string;

- (NSDictionary*) nextWord;

@end
