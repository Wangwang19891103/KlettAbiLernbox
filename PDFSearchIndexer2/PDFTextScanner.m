//
//  PDFTextScanner.m
//  KlettAbiLernboxen
//
//  Created by Wang on 16.12.14.
//
//

#import "PDFTextScanner.h"


@implementation PDFTextScanner


@synthesize delegate;



#pragma mark - Public methods

- (id) initWithString:(NSString *)string {
    
    self = [super init];
    
    _scanner = [[NSScanner alloc] initWithString:string];
    _isInsidePage = NO;
    _currentPage = 0;
    _whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    _punctuationSet = [NSCharacterSet punctuationCharacterSet];
    _letterSet = [NSCharacterSet letterCharacterSet];
    _invertedLetterSet = [_letterSet invertedSet];
    _hasError = NO;
    
    return self;
}



    
//    if (!_isInsidePage) {
//        
//        [self _skipToNextPage];
//        
//        if (_isInsidePage) {
//            
//            
//        }
//    }
//    else {
//        
//        
//    }
//    
//    return nil;
//}



#pragma mark - Private methods

- (NSDictionary*) nextWord {
    
    while ([self _keepScanning]) {
    
        [self _getNextWord];
        
        if ([_currentWord isEqualToString:@"---"]) {
            
            if (!_isInsidePage) {  // if outside of page
            
                if ([self _consumeWord:@"Page"]) {
                    
                    uint page = [self _getNumber];
                    
                    [self _consumeWord:@"---"];
                    
                    _currentPage = page;
                    _isInsidePage = YES;
                    
                    NSLog(@"found start of page %d", _currentPage);
                }
            }
            else {  // if inside of page
            
                if ([self _consumeWord:@"Page"]) {
                    
                    uint page = [self _getNumber];
                    
                    [self _consumeWord:@"---"];
                    
                    if (page == _currentPage) {
                        
                        NSLog(@"found end of page %d", _currentPage);

                        _currentPage = 0;
                        _isInsidePage = NO;
                    }
                    else {
                        
                        [self _reportError:@"Found invalid page ending."];
                    }
                    
                }
            }
        }
        else {

            _cleanWord = [self _cleanString:_currentWord];
            
            NSLog(@"%@", _cleanWord);
            
            NSDictionary* wordDict = @{
                                       @"string" : _cleanWord,
                                       @"page" : @(_currentPage)
                                       };
            
            return wordDict;
        }
    }

    return nil;
}


- (void) _getNextWord {
    
    NSString* string;
    
    [_scanner scanUpToCharactersFromSet:_whitespaceSet intoString:&string];
    _currentWord = [string copy];
    
    [self _skipWhitespaceCharacters];
}


- (void) _skipWhitespaceCharacters {
    
    [_scanner scanCharactersFromSet:_whitespaceSet intoString:nil];
}


- (BOOL) _consumeWord:(NSString*) word {
    
    [self _getNextWord];
    
    BOOL success = [self _checkWord:word];
    
    if (!success) {
        
        [self _reportError:@"Expected word \"%@\" at position %d.", word, (_scanner.scanLocation - _currentWord.length)];
    }
    
    return success;
}


- (BOOL) _checkWord:(NSString*) word {
    
    BOOL success = [_currentWord isEqualToString:word];
    
    return success;
}


- (uint) _getNumber {
    
    [self _getNextWord];
    
    uint number = [_currentWord integerValue];
    
    if (number == 0) {
        
        [self _reportError:@"Invalid page number."];
    }
    
    return number;
}


- (NSString*) _cleanString:(NSString*) string {
    
    NSString* newString = [[string componentsSeparatedByCharactersInSet:_invertedLetterSet] componentsJoinedByString:@""];
    newString = [newString lowercaseString];
    
//    // * check for funky chars
//    
//    for (uint i = 0; i < newString.length; ++i) {
//        
//        unichar c = [newString characterAtIndex:i];
//        
//        if (c < 97 || c > 122) {
//            
//            NSLog(@"Warning: Found character '%C' with code %d", c, c);
//        }
//    }
//    
//    //*
    
    return newString;
}


//- (void) _reportWord {
//
//    NSString* newWord = [self _cleanString:_currentWord];
//    
//    if (newWord.length > 1) {
//        
//        NSDictionary* wordDict = @{
//                                   @"string" : newWord,
//                                   @"page" : @(_currentPage)
//                                   };
//        
//        if ([self.delegate respondsToSelector:@selector(PDFTextScanner:didScanWord:)]) {
//            
//            [self.delegate PDFTextScanner:self didScanWord:wordDict];
//        }
//    }
//}






#pragma mark - Error handling

- (void) _reportError:(NSString*) string, ... {
    
    _hasError = YES;
    
    va_list args;
    va_start(args, string);
    
    NSString* message = [[NSString alloc] initWithFormat:string arguments:args];
    
    NSRange range = NSMakeRange(_scanner.scanLocation - _currentWord.length, _currentWord.length);
    
    NSString* errorString = [NSString stringWithFormat:@"%@ (location=%d, string=\"%@\")", message, range.location, [self parserStringForRange:range radius:10]];
    
    va_end(args);

    
    if ([self.delegate respondsToSelector:@selector(PDFTextScanner:didReportError:)]) {
        
        [self.delegate PDFTextScanner:self didReportError:errorString];
    }
    
    NSLog(@"%@", errorString);
}


- (BOOL) _keepScanning {
    
    return !_scanner.isAtEnd && !_hasError;
}








//- (void) print:(NSString*) string, ... {
//    
//    va_list args;
//    va_start(args, string);
//    
//    NSString* message = [[NSString alloc] initWithFormat:string arguments:args];
//    
//    NSLog(@"SparkGLSGLParser: %@", message);
//    
//    va_end(args);
//}


- (NSString*) parserStringForRange:(NSRange) range radius:(int) radius {
    
    NSString* string = _scanner.string;
    uint beginIndex = ((int)range.location - radius >= 0) ? range.location - radius : 0;
    uint endIndex = (range.location + range.length + radius < string.length) ? range.location + range.length + radius : string.length - 1;
    
    NSString* substring = [string substringWithRange:NSMakeRange(beginIndex, endIndex - beginIndex)];
    
    NSRange modifiedRange = NSMakeRange(range.location - beginIndex, range.length);
    
    NSString* stringAtLocation = [substring substringWithRange:modifiedRange];
    NSString* replacementString = [NSString stringWithFormat:@"__%@__", stringAtLocation];
    substring = [substring stringByReplacingCharactersInRange:modifiedRange withString:replacementString];
    
    substring = [self stringByEscapingControlChars:substring];
    
    return substring;
}


- (NSString*) stringByEscapingControlChars:(NSString*) string {
    
    NSString* newString = [string copy];
    
    newString = [newString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    newString = [newString stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
    
    return newString;
}

@end
