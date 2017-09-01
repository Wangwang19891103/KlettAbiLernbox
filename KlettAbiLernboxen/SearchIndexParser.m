//
//  SearchIndexParser.m
//  KlettAbiLernboxen
//
//  Created by Wang on 04.09.12.
//
//

#import "SearchIndexParser.h"



#define String_Context_Radius 10
#define ENABLE_MATCH_CHECKS TRUE


static NSCharacterSet* kDecimalDigitCharacterSet;


@implementation SearchIndexParser


#pragma mark - Initializers

//- (id) initWithString:(NSString *)theString {
//    
//    if (self = [super init]) {
//        
//        _string = theString;
//        _cursor = 0;
//        _currentToken = [_string substringWithRange:NSMakeRange(0, 1)];
//        _shouldRun = TRUE;
//        _rootNode = [[SearchIndexNode alloc] init];
//    }
//    
//    return self;
//}


//- (id) initWithPath:(NSString *)path {
//    
//    if (self = [super init]) {
//        
//        _fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
//        _shouldRun = TRUE;
//        _rootNode = [[SearchIndexNode alloc] init];
//        [self nextToken];
//    }
//    
//    return self;
//}


- (id) initWithData:(NSData *)data {
    
    if (self = [super init]) {
        
        if (!kDecimalDigitCharacterSet) {
            kDecimalDigitCharacterSet = [NSCharacterSet decimalDigitCharacterSet];
        }
        
        _shouldRun = TRUE;
        _rootNode = [[SearchIndexNode alloc] init];
        _buffer = (unsigned char*) [data bytes];
        _cursor = 0;
        _bufferLength = [data length];
        [self nextToken];
    }
    
    return self;
}

#pragma mark - Public Methods

//- (SearchIndexNode*) rootNodeFromSerializedString:(NSString *)theString {
//
//    NSArray* childNodes = [self matchNodeList];
//    
//    [_rootNode addChildNodes:childNodes];
//    
//    NSLog(@"SearchIndexParser done parsing.");
//    
//    return _rootNode;
//}


- (SearchIndexNode*) rootNode {
    
    NSArray* childNodes;
    
    childNodes = [self matchNodeList];
    
    [_rootNode addChildNodes:childNodes];
    
    NSLog(@"SearchIndexParser done parsing.");
    
    return _rootNode;
}




#pragma mark - Private Methods

//- (void) nextToken {
//    
//    if (!_shouldRun) return;
//    
//    ++_cursor;
//    
//    if (_cursor >= _string.length) {
//     
//        NSLog(@"SearchIndexParser: end of string reached.");
//        _shouldRun = FALSE;
//        return;
//    }
//    
//    _currentToken = [_string substringWithRange:NSMakeRange(_cursor, 1)];
//}

- (void) nextToken {

    if (_cursor != _bufferLength) {
        
        _currentToken = _buffer[_cursor];
        ++_cursor;
    }
    else {
          
        NSLog(@"SearchIndexParser: end of string reached.");
    }
}


- (void) reportParseErrorWithMessage:(NSString *)message, ... {

    _shouldRun = FALSE;

    va_list args;
    va_start(args, message);
    
    NSLog(@"SearchIndexParser error: %@", [NSString stringWithFormat:message, args]);
}


- (void) reportParseErrorWithPosition:(uint)position expectedToken:(unsigned char)expectedToken foundToken:(unsigned char)foundToken {

    _shouldRun = FALSE;

    /* find string context */
    int lowerIndex = position - String_Context_Radius;
    uint upperIndex = position + String_Context_Radius;
    if (lowerIndex < 0) lowerIndex = 0;
    if (upperIndex >= _string.length) upperIndex = _string.length - 1;
    NSString* contextString = [_string substringWithRange:NSMakeRange(lowerIndex, upperIndex - lowerIndex)];
    contextString = [contextString stringByReplacingCharactersInRange:NSMakeRange(position - lowerIndex, 1) withString:[NSString stringWithFormat:@"___%c___", foundToken]];
    
    NSLog(@"SearchIndexParser parse error:\n\texpected \"%c\"\n\tat position=%d,\n\tfound token=\"%c\",\n\tcontext=\"%@\"", expectedToken, position, foundToken, contextString);
}



#pragma mark - Found Methods

- (BOOL) foundEnd {
    
    return (_cursor == _string.length);
}


- (BOOL) foundChar:(unsigned char) character {
    
    return (_currentToken == character);
}


- (BOOL) foundOpen {
    
    return [self foundChar:'['];
}


- (BOOL) foundClose {
    
    return [self foundChar:']'];
}


- (BOOL) foundQuote {
    
    return [self foundChar:'"'];
}


- (BOOL) foundCypher {
    
    if ([kDecimalDigitCharacterSet characterIsMember:_currentToken]) {
        
        return TRUE;
    }
    else return FALSE;
}


- (BOOL) foundComma {
    
    return [self foundChar:','];
}




#pragma mark - Match Methods

/* match methods will always "consume" a single character or a complex string and increase the token cursor afterwards */


- (void) matchChar:(unsigned char) character {

    if (ENABLE_MATCH_CHECKS && ![self foundChar:character]) {
        
        [self reportParseErrorWithPosition:_cursor expectedToken:character foundToken:_currentToken];
    }
    else {
        
        [self nextToken];
    }
}


- (void) matchOpen {
    
    [self matchChar:'['];
}


- (void) matchClose {
    
    [self matchChar:']'];
}


- (void) matchComma {

    [self matchChar:','];
}


- (void) matchQuote {
    
    [self matchChar:'"'];
}


- (void) matchEquals {
    
    [self matchChar:'='];
}


- (NSString*) matchString {
    
    [self matchQuote];
    
//    NSMutableString* buffer = [NSMutableString string];
    
    uint startIndex = _cursor - 1;
    NSString* resultString = nil;
    
    while (![self foundQuote]) {
        
        [self nextToken];
    }
    
    resultString = [[NSString alloc] initWithBytes:(_buffer + startIndex)
                             length:(_cursor - startIndex - 1)
                           encoding:NSUTF8StringEncoding];
    
    [self matchQuote];
    
    return resultString;
}


/* parses only positive natural numbers */
- (uint) matchInt {
    
    uint startIndex = _cursor - 1;
    NSString* resultString = nil;
    
    while ([self foundCypher]) {
        
        [self nextToken];
    }
    
    resultString = [[NSString alloc] initWithBytes:(_buffer + startIndex) length:(_cursor - startIndex) encoding:NSUTF8StringEncoding];
    
    return [resultString intValue];
}


/* pageArray has format like: [[0,1],[1,2],...,[20,3]] */
- (NSDictionary*) matchPageDict {
    
    [self matchOpen];
    
    NSMutableDictionary* resultDict = [NSMutableDictionary dictionary];
    NSArray* pageArray = nil;
    
    if ([self foundOpen]) {
        
        pageArray = [self matchPage];
        [resultDict setObject:[pageArray objectAtIndex:1] forKey:[pageArray objectAtIndex:0]];
        
        while ([self foundComma]) {
            
            [self matchComma];
            
            pageArray = [self matchPage];
            [resultDict setObject:[pageArray objectAtIndex:1] forKey:[pageArray objectAtIndex:0]];
        }
    }
    
    [self matchClose];
    
    return resultDict;
}


/* page has format like: [0,1] */
- (NSArray*) matchPage {
    
    [self matchOpen];
    uint pageNumber = [self matchInt];
    [self matchEquals];
    uint wordCount = [self matchInt];
    [self matchClose];
    
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:pageNumber], [NSNumber numberWithInt:wordCount], nil];
}


- (NSArray*) matchChildNodeArray {
    
    [self matchOpen];
    NSArray* nodeArray = [self matchNodeList];
    [self matchClose];
    
    return nodeArray;
}


- (SearchIndexNode*) matchNode {
    
    [self matchOpen];
    NSString* nodeString = [self matchString];
    [self matchComma];
    NSDictionary* pageDict = [self matchPageDict];

//    SearchIndexNode* node = [[SearchIndexNode alloc] initWithString:nodeString pages:pageDict];
    SearchIndexNode* node = [[SearchIndexNode alloc] init];
    
    node.string = nodeString;
    node.pageDict = pageDict;

    /* optional: child nodes */
    if ([self foundComma]) {
        
        [self matchComma];
        NSArray* childNodesArray = [self matchChildNodeArray];
        
        NSMutableDictionary* childNodesDict = [NSMutableDictionary dictionary];
        
        for (SearchIndexNode* node in childNodesArray) {
            
            [childNodesDict setObject:node forKey:node.string];
        }
        
        node.childNodes = childNodesDict;
    }
    
    [self matchClose];
    
    return node;
}


- (NSArray*) matchNodeList {
    
    NSMutableArray* resultsArray = [NSMutableArray array];
    SearchIndexNode* node = nil;
    
    if ([self foundOpen]) {

        node = [self matchNode];
        [resultsArray addObject:node];

        while ([self foundComma]) {
            
            [self matchComma];
            
            node = [self matchNode];
            [resultsArray addObject:node];
        }
    }
    
    return resultsArray;
}



@end









