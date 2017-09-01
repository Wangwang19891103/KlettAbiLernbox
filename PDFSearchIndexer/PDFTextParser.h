//
//  PDFTextParser.h
//  PDFViewer
//
//  Created by Wang on 19.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class PDFTextObject;
@class PDFFontObject;


@interface PDFTextParser : NSObject {
    
    CGPDFOperatorTableRef _operatorTable;
    CGPDFScannerRef _scanner;
    BOOL _lastPopSuccessful;
    CGPDFDictionaryRef _fontDictionary;
}

@property (nonatomic, assign)     PDFTextObject* currentTextObject;
@property (nonatomic, retain) PDFFontObject* currentFontObject;
@property (nonatomic, retain) NSMutableArray* textObjects;
@property (nonatomic, readonly) CGPDFDictionaryRef fontDictionary;

- (id) initWithPDFPage:(CGPDFPageRef) pageRef;

- (void) printAll;

- (NSString*) getRawText;


@end



// operator functions

void operator_BT(CGPDFScannerRef inScanner, void* userInfo);

void operator_Tf(CGPDFScannerRef inScanner, void* userInfo);

void operator_TJ(CGPDFScannerRef inScanner, void* userInfo);

void operator_Tj(CGPDFScannerRef inScanner, void* userInfo);

void operator_T_quot(CGPDFScannerRef inScanner, void* userInfo);

void operator_Td(CGPDFScannerRef inScanner, void* userInfo);

void operator_TD(CGPDFScannerRef inScanner, void* userInfo);

void operator_Tm(CGPDFScannerRef inScanner, void* userInfo);

void operator_Tc(CGPDFScannerRef inScanner, void* userInfo);

void operator_Ts(CGPDFScannerRef inScanner, void* userInfo);

void operator_T_asterisk(CGPDFScannerRef inScanner, void* userInfo);

void operator_ET(CGPDFScannerRef inScanner, void* userInfo);


// pop functions

NSString* popName(CGPDFScannerRef scannerRef);

NSString* popString(CGPDFScannerRef scannerRef);

NSNumber* popNumber(CGPDFScannerRef scannerRef);

NSNumber* popInteger(CGPDFScannerRef scannerRef);



NSString* bytesToString(NSData* bytes);

// ------------------------------

@interface PDFTextObject : NSObject {
    
}

@property (nonatomic, retain) NSMutableString* string;
@property (nonatomic, retain) PDFFontObject* fontObject;
@property (nonatomic, readonly) NSString* convertedString;

- (unichar) convertUnichar:(unichar) character;

@end


// ------------------------------

@interface PDFFontObject : NSObject {
    
}

@property (nonatomic, copy) NSString* type;
@property (nonatomic, copy) NSString* subtype;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* basefont;
@property (nonatomic, retain) NSNumber* firstchar;
@property (nonatomic, retain) NSNumber* lastchar;
@property (nonatomic, copy) NSString* encoding;
@property (nonatomic, assign) NSDictionary* toUnicode;

- (id) initWithFontDictionary:(CGPDFDictionaryRef) dictRef;

- (NSDictionary*) parseCMapFromData:(CFDataRef) dataRef;

@end
