//
//  AppDelegate.m
//  PDFSearchIndexer2
//
//  Created by Wang on 12.12.14.
//
//

#import "AppDelegate.h"
#import "ContentsPage.h"
#import "DataManager.h"
#import "SearchIndex.h"
#import "Sorting.h"


//#define PATH                        @"content/Schulwissen/demo/Deutsch"

//#define PATH                        @"content/Schulwissen/full/Deutsch"
//#define PATH                        @"content/Schulwissen/full/Englisch"
//#define PATH                        @"content/Schulwissen/full/Geschichte"
#define PATH                        @"content/Schulwissen/full/Physik"

#define WORD_MIN_LENGTH             3



@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    _log = [[LogViewController alloc] init];
    [self.window setRootViewController:_log];
    [self.window makeKeyAndVisible];
    
    
    // stop words
    
    NSString* stopWordsPath = [[NSBundle mainBundle] pathForResource:@"stopwords" ofType:@"txt"];
    NSString* stopWordsString = [NSString stringWithContentsOfFile:stopWordsPath encoding:NSUTF8StringEncoding error:nil];
    _stopWords = [stopWordsString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \n"]];
    
    
    // actual page numbers
    
    NSMutableDictionary* actualPageNumbers = [NSMutableDictionary dictionaryWithCapacity:100];
    NSString* contentsPath = [[[NSBundle mainBundle] pathForResource:PATH ofType:nil] stringByAppendingPathComponent:@"contents.sqlite"];
    DataManager* dataManager = [[DataManager alloc] initWithModelName:@"contents" path:contentsPath];
    NSArray* pages = [dataManager fetchDataForEntityName:@"ContentsPage" withPredicate:nil sortedBy:@"position", nil];
    for (ContentsPage* page in pages) {
        
        [actualPageNumbers setObject:page.actualPageNumber forKey:page.position];
    }
    _actualPageNumbers = actualPageNumbers;
    
    
    _indexDict = [NSMutableDictionary dictionary];
    
    
    [self import];
    
    [self printIndex];
    
    [self showImportantNotes];
    
    return YES;
}



- (void) import {
    
    [_log addEntry:[NSString stringWithFormat:@"Import path = \"%@\"", PATH] withColor:nil];
    [_log addSeparator];
    
    NSString* absolutePath = [[NSBundle mainBundle] pathForResource:PATH ofType:nil];
    BOOL pathExists = [[NSFileManager defaultManager] fileExistsAtPath:absolutePath];
    
    if (!pathExists) {
        
        [_log addEntry:@"[ERROR] Path does not exist." withColor:[UIColor redColor]];
        ++_errorCount;
        return;
    }
    
    NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:absolutePath];
    NSString* filePath = nil;
    NSMutableArray* filePaths = [NSMutableArray array];

    while ((filePath = [enumerator nextObject])) {
        
        if (![[filePath pathExtension] isEqualToString:@"txt"]) continue;
        
        [filePaths addObject:filePath];
        [_log addEntry:[NSString stringWithFormat:@"File found: %@", filePath] withColor:nil];
    }
    
    [_log addSeparator];
    
    for (NSString* filePath in filePaths) {
        
        if (_errorCount > 0) break;
        
        [self importFilePath:filePath];
        [_log addSeparator];
    }
    
    if (_errorCount > 0) return;
    
    [self createSearchIndex];
}


- (void) importFilePath:(NSString*) filePath {
    
    NSString* absoluteFilePath = [[NSBundle mainBundle] pathForResource:[PATH stringByAppendingPathComponent:filePath] ofType:nil];

    [_log addEntry:[NSString stringWithFormat:@"Importing file path: %@", absoluteFilePath] withColor:nil];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:absoluteFilePath]) {
        
        [_log addEntry:@"[ERROR] File does not exist." withColor:[UIColor redColor]];
        ++_errorCount;
        return;
    }
    
    NSError* error;
    NSString* fileContent = [self contentsFromFileAtPath:absoluteFilePath error:&error];

    if (error) {
        
        [_log addEntry:[NSString stringWithFormat:@"[ERROR] %@", error.description] withColor:[UIColor redColor]];
        ++_errorCount;
        return;
    }
    
    if (fileContent.length == 0) {
        
        [_log addEntry:@"[ERROR] File is empty." withColor:[UIColor redColor]];
        ++_errorCount;
        return;
    }
    
//    NSLog(@"%@", fileContent);
    
//    [_log addEntry:fileContent withColor:nil];
    
    [_log addEntry:@"Parsing PDF Text file" withColor:nil];
    
    PDFTextScanner* scanner = [[PDFTextScanner alloc] initWithString:fileContent];
    scanner.delegate = self;
    NSDictionary* nextWord = nil;
    
    while ((nextWord = [scanner nextWord])) {
        
        if ([self wordIsValid:nextWord[@"string"]]) {

            [self addWordDictionary:nextWord];
        }
    }
    
}


- (void) addWordDictionary:(NSDictionary*) wordDict {
    
    uint actualPageNumber = [_actualPageNumbers[wordDict[@"page"]] integerValue];
    NSString* word = wordDict[@"string"];
    
    [self increaseCountForWord:word page:actualPageNumber];
}


- (void) increaseCountForWord:(NSString*) word page:(uint) pageNumber {
    
    NSMutableDictionary* wordDict = [self dictForWord:word];
    
    NSNumber* count = wordDict[@(pageNumber)];
    
    if (!count) {
        
        count = @(0);
        [wordDict setObject:count forKey:@(pageNumber)];
    }

    [wordDict setObject:@([count integerValue] + 1) forKey:@(pageNumber)];
}


- (NSMutableDictionary*) dictForWord:(NSString*) word {
    
    NSMutableDictionary* wordDict = _indexDict[word];
    
    if (!wordDict) {
        
        wordDict = [NSMutableDictionary dictionary];
        [_indexDict setObject:wordDict forKey:word];
    }
    
    return wordDict;
}


//- (NSMutableDictionary*) dictForWord:(NSString*) word page:(uint) pageNumber {
//    
//    NSMutableDictionary* wordDict = [self dictForWord:word];
//    
//    NSMutableDictionary* pageDict = wordDict[@(pageNumber)];
//    
//    if (!pageDict) {
//        
//        pageDict = [NSMutableDictionary dictionary];
//        [wordDict setObject:pageDict forKey:@(pageNumber)];
//    }
//    
//    return pageDict;
//}


- (NSString*) contentsFromFileAtPath:(NSString*) path error:(NSError**) error {
    
    NSString* contents = nil;
    NSError* error2;
    
    // attempt with NSUTF8StringEncoding
    contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error2];
//    NSLog(@"trying UTF8");
    
    if (error2) {
        
        error2 = nil;
        contents = [NSString stringWithContentsOfFile:path encoding:NSUTF16StringEncoding error:&error2];
        
        if (error2) {
            
            *error = error2;
            return nil;
        }
        
        [_log addEntry:@"Using UTF-16" withColor:nil];
        
        return contents;
    }
    else {
        
        [_log addEntry:@"Using UTF-8" withColor:nil];

        return contents;
    }
}


- (BOOL) wordIsValid:(NSString*) word {
    
    return (word.length >= WORD_MIN_LENGTH
            && ![_stopWords containsObject:word]);
}


- (void) showImportantNotes {
    
    NSString* message = @"Make sure to keep the contents.sqlite up-to-date in order to have the correct page mapping!";
    
    [_log addEntry:message withColor:[UIColor redColor]];
}


- (void) createSearchIndex {
    
    SearchIndex* searchIndex = [[SearchIndex alloc] init];
    
    for (NSString* word in _indexDict.allKeys) {
        
        NSDictionary* wordDict = _indexDict[word];
        [searchIndex insertString:word withPageDict:wordDict];
    }
    
    NSArray* pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [pathArray lastObject];
    
    NSString* searchIndexFilePath = [documentsDirectory stringByAppendingPathComponent:@"searchIndex.txt"];
    NSString* serializedIndex = [searchIndex serializeToString];
    [serializedIndex writeToFile:searchIndexFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


- (void) printIndex {
    
    [_log addSeparator];
    [_log addEntry:@"Words sorted by count:" withColor:nil];
    
    NSArray* wordsSortedByTotalCount = [_indexDict sortIntoArrayBySumUsingKey:@"<anyNumber>" ascending:NO];
    
    for (NSDictionary* dict in wordsSortedByTotalCount) {
        
        [_log addEntry:[NSString stringWithFormat:@"%@ - %@", dict[@"key"], dict[@"sum"]] withColor:nil];
    }
}


//NSCharacterSet* charSet = [[NSCharacterSet letterCharacterSet] invertedSet];
//NSMutableArray* words = (NSMutableArray*)[text2 componentsSeparatedByCharactersInSet:charSet];
//words = [self cleanArray:words];
//uint actualPageNumber = [[PDFManager manager] actualPageNumberForPosition:currentPageNumber];
//
//for (NSString* string in words) {
//    
//    NSMutableDictionary* pagesDict = [wordsDict objectForKey:string];
//    
//    if (!pagesDict) {
//        
//        pagesDict = [NSMutableDictionary dictionary];
//        [wordsDict setObject:pagesDict forKey:string];
//    }
//    
//    if (![pagesDict objectForKey:[NSNumber numberWithInt:actualPageNumber]]) {
//        
//        [pagesDict setObject:[NSNumber numberWithInt:1] forKey:[NSNumber numberWithInt:actualPageNumber]];
//    }
//    else {
//        
//        NSNumber* hitCount = [pagesDict objectForKey:[NSNumber numberWithInt:actualPageNumber]];
//        hitCount = [NSNumber numberWithInt:[hitCount intValue] + 1];
//        [pagesDict setObject:hitCount forKey:[NSNumber numberWithInt:actualPageNumber]];
//    }
//}




//SearchIndex* searchIndex = [[SearchIndex alloc] init];




//for (NSString* key in wordsDict.allKeys) {
//    
//    NSDictionary* pagesDict = [wordsDict objectForKey:key];
//    [searchIndex insertString:key withPageDict:pagesDict];
//}





//NSString* searchIndexFilePath = [documentsDirectory stringByAppendingPathComponent:@"searchIndex.txt"];
//NSString* serializedIndex = [searchIndex serializeToString];
//[serializedIndex writeToFile:searchIndexFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];




#pragma mark - Delegate

- (void) PDFTextScanner:(PDFTextScanner *)scanner didReportError:(NSString *)error {
    
    [_log addEntry:[NSString stringWithFormat:@"[ERROR] PDFTextScanner: %@", error] withColor:[UIColor redColor]];
}


@end
