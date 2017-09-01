//
//  PDFTextParser.m
//  PDFViewer
//
//  Created by Wang on 19.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PDFTextParser.h"
#import "GlobalCounter.h"


@implementation PDFTextParser

@synthesize currentTextObject, textObjects, fontDictionary, currentFontObject;


- (id) initWithPDFPage:(CGPDFPageRef)pageRef {
    
    if ((self = [super init])) {
        
        // Operator Table
        _operatorTable = CGPDFOperatorTableCreate();

        CGPDFOperatorTableSetCallback(_operatorTable, "BT", operator_BT);     // begin text
        CGPDFOperatorTableSetCallback(_operatorTable, "Tf", operator_Tf);     // font
        CGPDFOperatorTableSetCallback(_operatorTable, "TJ", operator_TJ);     // array with strings
        CGPDFOperatorTableSetCallback(_operatorTable, "Tj", operator_Tj);     // string
        CGPDFOperatorTableSetCallback(_operatorTable, "'", operator_T_quot);     // string
        CGPDFOperatorTableSetCallback(_operatorTable, "Td", operator_Td);     // ???
        CGPDFOperatorTableSetCallback(_operatorTable, "TD", operator_TD);     // ???
        CGPDFOperatorTableSetCallback(_operatorTable, "Tm", operator_Td);     // text matrix
        CGPDFOperatorTableSetCallback(_operatorTable, "Tc", operator_Tc);     // char spacing
        CGPDFOperatorTableSetCallback(_operatorTable, "Ts", operator_Ts);     // text rise
        CGPDFOperatorTableSetCallback(_operatorTable, "T*", operator_T_asterisk);     // move to next line
        CGPDFOperatorTableSetCallback(_operatorTable, "ET", operator_ET);     // end text
        
        _lastPopSuccessful = false;
        self.textObjects = [NSMutableArray array];
        
        
        // Font dictionary
        
        CGPDFDictionaryRef pageDict = CGPDFPageGetDictionary(pageRef);
        
        CGPDFDictionaryRef resourceDict;
        CGPDFDictionaryGetDictionary(pageDict, "Resources", &resourceDict);
        CGPDFDictionaryGetDictionary(resourceDict, "Font", &_fontDictionary);
        
//        NSLog(@"FONT DICT: %@", _fontDictionary);
        
//        NSLog(@"Font dictionary count: %d", (int)CGPDFDictionaryGetCount(_fontDictionary));
        
        CGPDFContentStreamRef contentStream = CGPDFContentStreamCreateWithPage(pageRef);
        _scanner = CGPDFScannerCreate(contentStream, _operatorTable, self);
        CGPDFScannerScan(_scanner);
        CGPDFScannerRelease(_scanner);
        CGPDFContentStreamRelease(contentStream);
        
        counter_printall;
        counter_removeAll;
    }
    
    return self;
}


- (CGPDFDictionaryRef) fontDictionary {
    
    return _fontDictionary;
}


- (void) printAll {
    
    NSLog(@"text objects count: %d", [self.textObjects count]);
    
    for (PDFTextObject* textObject in self.textObjects) {
        
        NSLog(@"%@", textObject.convertedString);
        NSLog(@"%@", textObject.fontObject.toUnicode);
    }
}


- (NSString*) getRawText {
    
    NSMutableString* rawText = [NSMutableString string];
    
    for (PDFTextObject* textObject in self.textObjects) {
    
        NSString* string = textObject.convertedString;
        
        [rawText appendString:string];
//        NSLog(@"%@", string);
    }
    
    return rawText;
}


@end



#pragma mark - Operator functions

void operator_BT(CGPDFScannerRef inScanner, void* userInfo) {
    
    counter_incI(@"BT", 1);
    
    NSLog(@"BT");
    
//    NSLog(@"\n%@", ((PDFTextParser*)userInfo).currentTextObject.convertedString);
    
//    NSLog(@"-------------------------------------- NEW TEXT OBJECT -------------------------------------------------");
    
//    PDFTextObject* newTextObject = [[PDFTextObject alloc] init];
//    ((PDFTextParser*)userInfo).currentTextObject = newTextObject;
//    [((PDFTextParser*)userInfo).textObjects addObject:newTextObject];
}

void operator_Tf(CGPDFScannerRef inScanner, void* userInfo) {
  
    counter_incI(@"Tf", 1);

    
//    NSLog(@" ###################### Tf #######################");
    NSNumber* number = popInteger(inScanner);
//    NSLog(@"Number: %@", number);
    NSString* name = popName(inScanner);
//    NSLog(@"Name: %@", name);
    CGPDFDictionaryRef fontDict;
//    NSLog(@"font directory: %@", ((PDFTextParser*)userInfo).fontDictionary);
    bool success = CGPDFDictionaryGetDictionary(((PDFTextParser*)userInfo).fontDictionary, [name UTF8String], &fontDict);
//    NSLog(@"success: %d", success);
    if (success) {
        
        PDFFontObject* fontObject = [[PDFFontObject alloc] initWithFontDictionary:fontDict];
//        NSLog(@"%@", fontObject);
//        ((PDFTextParser*)userInfo).currentTextObject.fontObject = fontObject;
        ((PDFTextParser*)userInfo).currentFontObject = fontObject;
        
        NSLog(@"Tf\t(fontname = %@, fonttype = %@, subtype = %@, number = %d)", name, fontObject.type, fontObject.subtype, [number intValue]);

    }
}

void operator_TJ(CGPDFScannerRef inScanner, void* userInfo) {
    
    counter_incI(@"TJ", 1);
    

    
//    NSLog(@" ###################### TJ #######################");

    PDFTextObject* newTextObject = [[PDFTextObject alloc] init];
    newTextObject.fontObject = ((PDFTextParser*)userInfo).currentFontObject;
    ((PDFTextParser*)userInfo).currentTextObject = newTextObject;
    [((PDFTextParser*)userInfo).textObjects addObject:newTextObject];

    
    CGPDFArrayRef array;
    bool success = CGPDFScannerPopArray(inScanner, &array);
    
    if (success) {
    
        for(size_t n = 0; n < CGPDFArrayGetCount(array); n += 2) {
            
            if(n >= CGPDFArrayGetCount(array))
                continue;
            
            CGPDFStringRef string;
            success = CGPDFArrayGetString(array, n, &string);
            if(success) {
                
//                NSLog(@"string: __%@__", (NSString *)CGPDFStringCopyTextString(string));
                [((PDFTextParser*)userInfo).currentTextObject.string appendString:(NSString *)CGPDFStringCopyTextString(string)];
                
                NSData* bytes = [(NSString *)CGPDFStringCopyTextString(string) dataUsingEncoding:NSUTF8StringEncoding];
                
                NSLog(@"TJ\t(%@)\t(%@)", (NSString *)CGPDFStringCopyTextString(string), bytesToString(bytes));

            }
        }
        
        
        
//        [((PDFTextParser*)userInfo).currentTextObject.string appendString:@"\n"];
    }
    
}

void operator_Tj(CGPDFScannerRef inScanner, void* userInfo) {
    
    counter_incI(@"Tj", 1);
    
//    NSLog(@" ###################### Tj #######################");
    
    PDFTextObject* newTextObject = [[PDFTextObject alloc] init];
    newTextObject.fontObject = ((PDFTextParser*)userInfo).currentFontObject;
    ((PDFTextParser*)userInfo).currentTextObject = newTextObject;
    [((PDFTextParser*)userInfo).textObjects addObject:newTextObject];
    
    NSString* newString = popString(inScanner);
//    NSLog(@"string: __%@__", newString);

    [((PDFTextParser*)userInfo).currentTextObject.string appendFormat:@"%@", newString];
    
    NSData* bytes = [newString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Tj\t(%@)\t(%@)", newString, bytesToString(bytes));

    

}

void operator_T_quot(CGPDFScannerRef inScanner, void* userInfo) {

    counter_incI(@"'", 1);
    
    NSString* string = popString(inScanner);

    NSLog(@"'\t(%@)", string);
}


void operator_Td(CGPDFScannerRef inScanner, void* userInfo) {
    
    counter_incI(@"Td", 1);
    
    NSNumber* int1 = popNumber(inScanner);
    NSNumber* int2 = popNumber(inScanner);
    
    NSLog(@"Td\t(%@, %@)", int1, int2);
}

void operator_TD(CGPDFScannerRef inScanner, void* userInfo) {

    counter_incI(@"TD", 1);
    
    NSNumber* int1 = popNumber(inScanner);
    NSNumber* int2 = popNumber(inScanner);
    
    NSLog(@"TD\t(%@, %@)", int1, int2);
}


void operator_Tm(CGPDFScannerRef inScanner, void* userInfo) {
    
    counter_incI(@"Tm", 1);
    
    NSLog(@"Tm");
}

void operator_Ts(CGPDFScannerRef inScanner, void* userInfo) {
    
    counter_incI(@"Ts", 1);
    
    NSLog(@"Ts");
}

void operator_T_asterisk(CGPDFScannerRef inScanner, void* userInfo) {
    
    counter_incI(@"T*", 1);
    
    NSLog(@"T*");
}

void operator_Tc(CGPDFScannerRef inScanner, void* userInfo) {
    
    counter_incI(@"Tc", 1);
    
//    NSNumber* number = popNumber(inScanner);
//    NSLog(@"Tc\t(%f)", [number floatValue]);
    
    NSNumber* number = popInteger(inScanner);
    NSLog(@"Tc\t(%d)", [number intValue]);

}


void operator_ET(CGPDFScannerRef inScanner, void* userInfo) {

    counter_incI(@"ET", 1);
    
    NSLog(@"ET");

//    NSLog(@" ###################### ET #######################");
    
    [((PDFTextParser*)userInfo).currentTextObject.string appendFormat:@"\n"];

    
//    NSLog(@"%@", ((PDFTextParser*)userInfo).currentTextObject.convertedString);
//    NSLog(@"%@", ((PDFTextParser*)userInfo).currentTextObject.fontObject);
    
//    [((PDFTextParser*)userInfo).textObjects addObject:((PDFTextParser*)userInfo).currentTextObject];
}


#pragma mark - Pop functions

NSString* popName(CGPDFScannerRef scannerRef) {

const char* chars;
bool success = CGPDFScannerPopName(scannerRef, &chars);

if (success) return [NSString stringWithCString:chars encoding:NSUTF8StringEncoding];
else return nil;
}


NSString* popString(CGPDFScannerRef scannerRef) {

CGPDFStringRef string;
bool success = CGPDFScannerPopString(scannerRef, &string);

if (success) return (NSString*)CGPDFStringCopyTextString(string);
//    if (success) return (NSString*)CGPDFStreamCopyData(string);
    
    
else return nil;
}


NSNumber* popNumber(CGPDFScannerRef scannerRef) {

CGPDFReal value;
bool success = CGPDFScannerPopNumber(scannerRef, &value);

if (success) return [NSNumber numberWithFloat:(float)value];
else return nil;
}


NSNumber* popInteger(CGPDFScannerRef scannerRef) {

CGPDFInteger value;
bool success = CGPDFScannerPopInteger(scannerRef, &value);

if (success) return [NSNumber numberWithInt:(int)value];
return nil;
}



NSString* bytesToString(NSData* bytes) {
    
    char buffer;
    NSString* bytesString = @"";
    
    for (int i = 0; i < [bytes length]; i+=1) {
        [bytes getBytes:&buffer range:NSMakeRange(i, 1)];
        bytesString = [bytesString stringByAppendingFormat:@"%04x", buffer];
    }
    
    return bytesString;
}






#pragma mark - PDFTextObject

@implementation PDFTextObject

@synthesize string, fontObject, convertedString;


- (id) init {
    
    if ((self = [super init])) {

        self.string = [NSMutableString string];
    }
    
    return self;
}


- (NSString*) convertedString {
    
//    NSLog(@"Converting String **********************************************************");

//    NSLog(@"convertedString, string: __%@__", self.string);
    
    NSData* data = [string dataUsingEncoding:NSUTF16LittleEndianStringEncoding];

    
    // output bytes
    NSString* bytesString = @"";
    unichar buffer;
    
    for (int i = 0; i < [data length]; i+=2) {
        [data getBytes:&buffer range:NSMakeRange(i, 2)];
        unichar convertedChar = [self convertUnichar:buffer];
        BOOL wasConverted = (convertedChar != buffer);
        bytesString = [bytesString stringByAppendingFormat:@"%04x - %C %@\n", buffer, [self convertUnichar:buffer], (wasConverted)?@"(was converted)":@""];
    }
    
//    NSLog(@"Bytes:\n%@", bytesString);

    
    
    //    
    //    NSString* string16 = [[NSString alloc] initWithData:data encoding:NSUTF16BigEndianStringEncoding];
    
    //    NSString* string16 = string;
    
    NSString* finalString = @"";
    
    uint stepWidth;
    uint begin;
    if ([self.fontObject.encoding isEqualToString:@"Identity-H"]) {
        stepWidth = 1;
        begin = 1;
    }
    else {
        stepWidth = 1;
        begin = 0;
    }
    
    for (int i = 0; i <= [self.string length] - stepWidth; i+=stepWidth) {
        
        if (i == [self.string length]) break;
        
        if ([self.string characterAtIndex:i] != ' ') {
//            NSLog(@"++++++++++++++++++++++++++++++++++++ WWWWWWWTTTTTTTTFFFFFFFF +++++++++++++++++++++++++++++++++");
        }
        ++i;

        if (i == [self.string length]) break;
        
        unichar c = [self.string characterAtIndex:i];
//        unichar c = (unichar)[data subdataWithRange:NSMakeRange(i, 2)];
        
//        NSLog(@"char: %C", c);
        //        uint value = (uint)c;
        
        //        finalString = [finalString stringByAppendingFormat:@"%@", [NSString stringWithCharacters:&c length:1]];
        
        
        NSNumber* mappingValue;
        if ((mappingValue = [self.fontObject.toUnicode objectForKey:[NSNumber numberWithInt:c]])) {
            //            finalString = [finalString stringByAppendingFormat:@"%C(%04x)", [mappingValue intValue], [mappingValue intValue]];
            finalString = [finalString stringByAppendingFormat:@"%C", [mappingValue intValue]];
        }
        else {
            finalString = [finalString stringByAppendingFormat:@"%C", c];
        }


    }
    
    
    
    return finalString;
}


- (unichar) convertUnichar:(unichar)character {

    if ((int)character == 42) {
        counter_incI(@"unichar 42 tried to convert", 1);
//        NSLog(@"#################################################################################");
//        NSLog(@"%@", self.fontObject.toUnicode);
    }
    
    NSNumber* mappingChar;
    if ((mappingChar = [self.fontObject.toUnicode objectForKey:[NSNumber numberWithInt:character]])) {
        counter_incI(@"unichars converted", 1);
        

        
        if ([mappingChar intValue] == 74) {
            counter_incI(@"unichar 42 converted to 74", 1);
        }
        
        return [mappingChar intValue];
    }
    else return character;
}


- (NSString*) description {
    
    return [NSString stringWithFormat:@"text:\n%@\n"
                           "convertedString:\n%@\n"
                            "fontObject:\n%@\n", self.string, self.convertedString, self.fontObject];
}

- (void) dealloc {
    
    self.string = nil;
    self.fontObject = nil;
    
    [super dealloc];
}

@end













#pragma mark - PDFFontObject


@implementation PDFFontObject


@synthesize type, subtype, name, basefont, firstchar, lastchar, encoding, toUnicode;


- (id) initWithFontDictionary:(CGPDFDictionaryRef)dictRef {
    
    if ((self = [super init])) {
        
//        NSLog(@"FontObject");
        
        const char* value;
        CGPDFInteger value2;
        CGPDFStreamRef value3;
        
        if (CGPDFDictionaryGetName(dictRef, "Type", &value)) {
            self.type = [NSString stringWithCString:value encoding:NSUTF8StringEncoding];
//            NSLog(@"type: %@", type);
        }
        
        if (CGPDFDictionaryGetName(dictRef, "Subtype", &value))
            self.subtype = [NSString stringWithCString:value encoding:NSUTF8StringEncoding];
        
        if (CGPDFDictionaryGetName(dictRef, "Name", &value))
            self.name = [NSString stringWithCString:value encoding:NSUTF8StringEncoding];
        
        if (CGPDFDictionaryGetName(dictRef, "BaseFont", &value))
            self.basefont = [NSString stringWithCString:value encoding:NSUTF8StringEncoding];
        
        if (CGPDFDictionaryGetInteger(dictRef, "FirstChar", &value2))
            self.firstchar = [NSNumber numberWithInt:(int)value2];
        
        if (CGPDFDictionaryGetInteger(dictRef, "LastChar", &value2))
            self.lastchar = [NSNumber numberWithInt:(int)value2];
        
        if (CGPDFDictionaryGetName(dictRef, "Encoding", &value)) {
            self.encoding = [NSString stringWithCString:value encoding:NSUTF8StringEncoding];
//            NSLog(@"encoding: '%@'", self.encoding);
        }
        
        if (CGPDFDictionaryGetStream(dictRef, "ToUnicode", &value3)) {
            CFDataRef cmapData = CGPDFStreamCopyData(value3, CGPDFDataFormatRaw);
            self.toUnicode = [self parseCMapFromData:cmapData];
//            NSLog(@"toUnicode");
        }
        
    }
    
    return self;
}


- (NSDictionary*) parseCMapFromData:(CFDataRef)dataRef {
    
//    NSLog(@"parse CMAP");
    
    NSString* string = [[NSString alloc] initWithData:(NSData*)dataRef encoding:NSUTF8StringEncoding];
    
//    NSLog(@"%@", string);
    
    // getting CMap Name
    NSRange mapNameRange = [string rangeOfString:@"/CMapName"];
    NSString* substring = [string substringFromIndex:mapNameRange.location + mapNameRange.length + 1];
    NSRange mapNameRange2 = [substring rangeOfString:@"def\n"];
    NSString* mapName = [substring substringWithRange:NSMakeRange(0, mapNameRange2.location - 1)];
    
//    NSLog(@"CMap Name: '%@'", mapName);
    
//    _currentCMapName = mapName;
    
    
    // if CMap already exists in dict -> return                
//    if ([_cmapDict objectForKey:mapName]) return;
    
    // else create
    NSMutableDictionary* cmapDict = [NSMutableDictionary dictionary];
//    [_cmapDict setObject:cmapDict forKey:mapName];
    
    
//    NSLog(@"* * * CMapScanner test * * *");
    
    NSRange lalaRange = [string rangeOfString:@"beginbfrange"];
    if (lalaRange.location != NSNotFound) counter_incI(@"beginbfrange", 1);
    
    // getting char mappings
    NSRange beginRange = [string rangeOfString:@"beginbfchar"];
    if (beginRange.location != NSNotFound) counter_incI(@"beginbfchar", 1);
    NSRange endRange = [string rangeOfString:@"endbfchar"];
    
    NSRange bfCharRange = NSMakeRange(beginRange.location + beginRange.length + 1, endRange.location - beginRange.location - beginRange.length - 2);
    
    NSString* bfCharString = [string substringWithRange:bfCharRange];
    
    //    NSLog(@"%@", bfCharString);
    
    NSArray* bfCharArray = [bfCharString componentsSeparatedByString:@"\n"];
    
    //    NSLog(@"bfCharArray length: %d", [bfCharArray count]);
    
//    NSLog(@"CMAP entries: %d", [bfCharArray count]);
    
    for (NSString* mapString in bfCharArray) {
        
        //        NSLog(@"%@", mapString);
        
        NSString* left = [mapString substringWithRange:NSMakeRange(1, 4)];
        NSString* right = [mapString substringWithRange:NSMakeRange(8, 4)];
        uint leftValue;
        uint rightValue;
        [[NSScanner scannerWithString:left] scanHexInt:&leftValue];
        [[NSScanner scannerWithString:right] scanHexInt:&rightValue];
        
        [cmapDict setObject:[NSNumber numberWithInt:rightValue] forKey:[NSNumber numberWithInt:leftValue]];
        
//        NSLog(@"%@ -> %@", [NSNumber numberWithInt:leftValue], [cmapDict objectForKey:[NSNumber numberWithInt:leftValue]]);
        
//        NSLog(@"%@ (%d, %C) -> %@ (%d, %C)", left, leftValue, leftValue, right, rightValue, rightValue);
    }
    
//    NSLog(@"CMap Dict: %@", cmapDict);
    
//    NSLog(@"* * * **************** * * *");
    
    return cmapDict;
}




- (NSString*) description {
    
    NSString* unicodeString = @"";
    
    for (NSNumber* key in self.toUnicode.keyEnumerator) {
        NSLog(@".");
        NSNumber* value = [self.toUnicode objectForKey:key];
        unicodeString = [unicodeString stringByAppendingFormat:@"%d (%c) -> %d (%c)\n", [key intValue], [key intValue], [value intValue], [value intValue]];
    }
    
    return [NSString stringWithFormat:@"FontObject\n"
            "\tType: %@,\n"
            "\tSubtype: %@\n"
            "\tName: %@\n"
            "\tBaseFont: %@\n"
            "\tFirstChar: %@\n"
            "\tLastChar: %@\n"
            "\tEncoding: %@\n"
            "\tToUnicode: %@\n",
            self.type, self.subtype, self.name, self.basefont, self.firstchar, self.lastchar, self.encoding, unicodeString];
}


@end



