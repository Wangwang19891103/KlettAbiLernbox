//
//  AppDelegate.m
//  PDFSearchIndexer
//
//  Created by Wang on 28.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
//#import "PDFTextParser.h"
//#import "pdf.h"
//#import "TET_ios/TET_objc.h"
#import "NSArray+Extensions.h"
#import "PDFManager.h"
//#import "Scanner.h"
#import "Functions.h"
#import "SBJson.h"
#import "Collections+Size.h"
//#import "SearchIndex.h"
#import "ProgressLogger.h"
#import "Sorting.h"


//#define PRODUCT_ID @"KlettAbiGeschichte"
//#define MODULE_NAME @"Geschichte"

//#define PRODUCT_ID @"BiologieDEMO"
#define MODULE_NAME @"Deutsch"






#define CONTENT_PATH @"content"
#define CONTENT_DIRECTORY [[NSBundle mainBundle] pathForResource:@"content" ofType:nil]
//#define CONTENT_DIRECTORY kUADownloadDirectory



//#define SELECT_CATEGORY @"Analytische Geometrie"
//#define SELECT_DOCUMENT 1
//#define SELECT_PAGE 1

#define SHOULD_IMPORT 1
#define SEARCHWORD @"englisch"
#define WRITE_PAGE_FILES 0


@implementation AppDelegate

@synthesize window = _window, stopWords;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    
//    NSString* fullPath = [[NSBundle mainBundle] pathForResource:[CONTENT_PATH stringByAppendingPathComponent:@"modules"] ofType:@"plist"];
//    
//    NSArray* modulesArray = [NSArray arrayWithContentsOfFile:fullPath];
    
    UIColor* color;
    
    NSArray* pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [pathArray lastObject];
    
//    [[PDFManager manager] setProductID:PRODUCT_ID];
    [[PDFManager manager] loadModule:MODULE_NAME];
    
//    NSString* productPath = [CONTENT_DIRECTORY stringByAppendingPathComponent:PRODUCT_ID];
    
//    TET *tet = [[TET alloc] init];

    
    uint currentPage = 1;
    uint currentTotalPageCount = 0;

    // stopwords
    NSString* stopWordsPath = [[NSBundle mainBundle] pathForResource:@"stopwords" ofType:@"txt"];
    NSString* stopWordsString = [NSString stringWithContentsOfFile:stopWordsPath encoding:NSUTF8StringEncoding error:nil];
    self.stopWords = [stopWordsString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \n"]];
    
    
    NSMutableDictionary* wordsDict = [NSMutableDictionary dictionary];
    
    
    
    uint numberOfDocuments = ([PDFManager manager].knowledgeDocumentRef != nil) ? 3 : 2;

    if (SHOULD_IMPORT)
    for (int documentNumber = 0; documentNumber < numberOfDocuments; ++documentNumber) {
        
#ifdef SELECT_DOCUMENT
        if(documentNumber != SELECT_DOCUMENT) continue;
#endif
        
        NSLog(@"##################### document number: %d ######################", documentNumber);
        
        CGPDFDocumentRef documentRef;
        
        switch (documentNumber) {
            case 0:
                documentRef = [PDFManager manager].exercisesDocumentRef;
                break;

            case 1:
                documentRef = [PDFManager manager].solutionsDocumentRef;
                break;

            case 2:
                documentRef = [PDFManager manager].knowledgeDocumentRef;
                break;

            default:
                break;
        }

        uint numberOfPages = CGPDFDocumentGetNumberOfPages(documentRef);
        
        NSLog(@"number of pages: %d", numberOfPages);
        
        
        for (int currentPageNumber = 1; currentPageNumber <= numberOfPages; ++currentPageNumber) {
            
#ifdef SELECT_PAGE
            if(currentPageNumber != SELECT_PAGE) continue;
#endif
      
            
            NSLog(@"\n---------- page %d ------------", currentPageNumber);
//            LogM(@"empty_unicodeString", @"+++ Category: %@ +++ Document: %@ +++ Page Number: %d +++\n", categoryName, stringSwitchCaseInt(documentNumber, 0, @"Exercises", 1, @"Solutions", 2, @"Knowledge", nil), currentPageNumber);
            
            
            CGPDFPageRef pageRef = CGPDFDocumentGetPage(documentRef, currentPageNumber);
            
//            Scanner* scanner = [[Scanner alloc] initWithDocument:documentRef];
//            [scanner scanDocumentPage:currentPageNumber];
//            
//            NSString* text2 = scanner.content;
            
            NSString* text2 = nil;
            
            
            
            
            
            
            
            // save text to file
            
            NSString* fileName = [NSString stringWithFormat:@"%@_%@_page%d.txt", MODULE_NAME, stringSwitchCaseInt(documentNumber, 0, @"exercises", 1, @"solutions", 2, @"knowledge", nil), currentPageNumber];
            
            NSString* filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
            
            //                NSLog(@"output file: %@", filePath);
            
//            [text2 writeToFile:filePath atomically:TRUE encoding:NSUTF8StringEncoding error:nil];
            
            NSString* logFileName = [NSString stringWithFormat:@"%@_%@_page%d_tags.txt", MODULE_NAME, stringSwitchCaseInt(documentNumber, 0, @"exercises", 1, @"solutions", 2, @"knowledge", nil), currentPageNumber];
            
//            LogM_write2(@"scanner_tags", logFileName);
//            LogM_purge(@"scanner_tags");
            
            //                NSLog(@"\n%@", text2);
            
            
            
            //                PDFTextParser* parser = [[PDFTextParser alloc] initWithPDFPage:pageRef];
            //                NSString* text2 = [parser getRawText];
            
            //    // write export file
            //    NSArray* pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            //    NSString* documentsDirectory = [pathArray lastObject];
            //    NSString* exportPath = [documentsDirectory stringByAppendingPathComponent:OUTPUT_FILE];
            
            //    [text writeToFile:exportPath atomically:TRUE encoding:NSUTF8StringEncoding error:nil];
            //
            //    NSLog(@"%@", text);
            
            //    NSArray* textObjects = parser.textObjects;
            //
            //    for (PDFTextObject* textObject in textObjects) {
            //        NSLog(@"TextObject: %@", textObject.convertedString);
            //    }
            
            //    NSLog(@"%@", [textObjects objectAtIndex:1]);
            
            
            
            //                NSInteger page = [tet open_page:doc pagenumber:currentPageNumber optlist:@"granularity=page"];
            //                NSString* text2 = [tet get_text:page];
            //                [tet close_page:page];
            //
            //                NSLog(@"%@\n", text2);
            
            NSCharacterSet* charSet = [[NSCharacterSet letterCharacterSet] invertedSet];
            
            NSMutableArray* words = (NSMutableArray*)[text2 componentsSeparatedByCharactersInSet:charSet];
            
            
            /* TODO: REGEX WORDS AND SIMPLE NUMBERS LIKE '2000' */
            
            
            NSString* wordsLogString = [words componentsJoinedByString:@"\n"];
            
            NSString* wordsLogFileName = [NSString stringWithFormat:@"%@_%@_page%d_words.txt", MODULE_NAME, stringSwitchCaseInt(documentNumber, 0, @"exercises", 1, @"solutions", 2, @"knowledge", nil), currentPageNumber];
            
            filePath = [documentsDirectory stringByAppendingPathComponent:wordsLogFileName];
            
//            [wordsLogString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];

            
            
            words = [self cleanArray:words];
            
            //                NSLog(@"words:\n%@", words);
            

            
            uint actualPageNumber = [[PDFManager manager] actualPageNumberForPosition:currentPageNumber];

            for (NSString* string in words) {
                
                NSMutableDictionary* pagesDict = [wordsDict objectForKey:string];
                
                if (!pagesDict) {
                    
                    pagesDict = [NSMutableDictionary dictionary];
                    [wordsDict setObject:pagesDict forKey:string];
                }
                
                if (![pagesDict objectForKey:[NSNumber numberWithInt:actualPageNumber]]) {
                    
                    [pagesDict setObject:[NSNumber numberWithInt:1] forKey:[NSNumber numberWithInt:actualPageNumber]];
                }
                else {
                    
                    NSNumber* hitCount = [pagesDict objectForKey:[NSNumber numberWithInt:actualPageNumber]];
                    hitCount = [NSNumber numberWithInt:[hitCount intValue] + 1];
                    [pagesDict setObject:hitCount forKey:[NSNumber numberWithInt:actualPageNumber]];
                }
            }
            
            /* wordsDict structure:
             *
             * dict
             *     key: word (string)
             *     value: dict
             *         key: pageNumber (int)
             *         value: count (int)
             */


            
            
            
//            NSMutableDictionary* pageWordDict = [NSMutableDictionary dictionary];
//            
//            for (NSString* string in words) {
//                
//                if (![pageWordDict objectForKey:string]) {
//                    
//                    [pageWordDict setObject:[NSNumber numberWithInt:0] forKey:string];
//                }
//                
//                [pageWordDict setObject:[NSNumber numberWithInt:[[pageWordDict objectForKey:string] intValue] + 1] forKey:string];
//            }
//            
//            //                NSLog(@"pageWordDict:\n%@", pageWordDict);
//            
//            
//            for (NSString* key in pageWordDict.keyEnumerator) {
//                
//                //                    LogM(@"stemming", @"%@ --> %@", key, [key stem]);
//                
//                if (![wordsDict objectForKey:key]) {
//                    [wordsDict setObject:[NSMutableArray array] forKey:key];
//                }
//                
//                uint p = currentTotalPageCount + currentPageNumber;
//                if (p > 100) {
//                    NSLog(@"ERROR: p = %d", p);
//                    return TRUE;
//                }
//                NSMutableDictionary* nodeDict = [NSMutableDictionary dictionary];
//                [nodeDict setObject:[NSNumber numberWithInt:p] forKey:@"pageNumber"];
//                [nodeDict setObject:[[pageWordDict objectForKey:key] copy] forKey:@"count"];
//
////                // array instead of dict
////                NSArray* nodeArray = [NSArray arrayWithObjects:
////                                      [NSNumber numberWithInt:p],
////                                      [[pageWordDict objectForKey:key] copy],
////                                      nil];
////                
////                //                    WordNode* node = [[WordNode alloc] init];
////                //                    node.pageNumber = currentPageNumber;
////                //                    node.count = [[pageWordDict objectForKey:key] intValue];
////                
////                [[wordsDict objectForKey:key] addObject:nodeArray];
//                
//                [[wordsDict objectForKey:key] addObject:nodeDict];
//            }
            
            //                break;
            
        }
        
        //            [tet close_document:doc];
        
        
            

    }
    
    
//    NSLog(@"-------------------------------------------------------------------------------------------------");
//    
//    NSLog(@"wordsDict:\n%@", wordsDict);
//
//    NSLog(@"words sorted by total count:\n%@", [self wordsSortedByTotalCount:wordsDict]);
    
    
    NSArray* wordsSortedByTotalCount = [wordsDict sortIntoArrayBySumUsingKey:@"<anyNumber>" ascending:NO];
    
    for (NSDictionary* dict in wordsSortedByTotalCount) {
        
        LogM(@"wordsSortedByTotalCount", [NSString stringWithFormat:@"%@ (%@)\n", [dict objectForKey:@"key"], [dict objectForKey:@"sum"]]);
    }
    
    LogM_write2(@"wordsSortedByTotalCount", @"__wordsSortedByTotalCount");
    
    
    
//    return TRUE;
    
    
    ProgressLogger* logger = [[ProgressLogger alloc] initWithCount:wordsDict.count stepWidth:1];
    
    SearchIndex* searchIndex = [[SearchIndex alloc] init];

    NSLog(@"Inserting keys into search index");
    
    
    timer_start(@"searchindex_insert");
    
    for (NSString* key in wordsDict.allKeys) {
        
        NSDictionary* pagesDict = [wordsDict objectForKey:key];
        
//        NSMutableDictionary* pageDict = [NSMutableDictionary dictionary];
        
        
//        NSLog(@"word=%@, pagesDict=%@", key, pagesArray);
        
        [searchIndex insertString:key withPageDict:pagesDict];
        
        [logger count];
    }
    
    timer_add(@"searchindex_insert");
    
    
    NSLog(@"Done inserting keys.");

    
    timer_start(@"searchindex_serialize");
    
    NSString* searchIndexFilePath = [documentsDirectory stringByAppendingPathComponent:@"searchIndex.txt"];
    NSString* serializedIndex = [searchIndex serializeToString];
    [serializedIndex writeToFile:searchIndexFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    timer_add(@"searchindex_serialize");
    
    
//    NSLog(@"serializedString:\n%@", serializedIndex);
    
//    NSArray* searchResults = [searchIndex searchString:@"deu"];
//    
//    NSLog(@"search results:\n%@", searchResults);
    
    
    
    
    
//    return TRUE;
    
    /***********************************/
    
    NSString* filePath_wordsDict = [documentsDirectory stringByAppendingPathComponent:@"__wordIndex.txt"];
    BOOL success = [wordsDict writeToFile:filePath_wordsDict atomically:TRUE];
    NSLog(@"success: %d", success);
    
    
//    [[wordsDict JSONRepresentation] writeToFile:filePath_wordsDict atomically:TRUE encoding:NSUTF8StringEncoding error:nil];

    
//    NSArray* sortedByCount = [self wordsSortedByTotalCount:wordsDict];
//    NSString* filePath_sortedByCount = [documentsDirectory stringByAppendingPathComponent:@"__wordsSortedByCount.txt"];
//    [sortedByCount writeToFile:filePath_sortedByCount atomically:TRUE];
//
//    NSArray* sortedAlphabetically = [self wordsSortedAlphabetically:wordsDict];
//    NSString* filePath_sortedAlphabetically = [documentsDirectory stringByAppendingPathComponent:@"__wordsSortedAlphabetically.txt"];
//    [sortedAlphabetically writeToFile:filePath_sortedAlphabetically atomically:TRUE];
    
    
    
    /* only words alphapetically */
    
    NSMutableString* pureWords = [NSMutableString string];
    
    [pureWords appendFormat:@"word count: %d\n\n\n", wordsDict.count];
    
    NSArray* sortedKeys = [wordsDict.allKeys sortedArrayUsingSelector:@selector(compare:)];
    
    for (NSString* key in sortedKeys) {
        
        [pureWords appendFormat:@"%@\n", key];
    }
    
    [pureWords writeToFile:[documentsDirectory stringByAppendingPathComponent:@"__pure_words_alphabetically.txt"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    
    
    
//    // read json into dict
//    timer_start(@"importFromJsonFile");
//    NSString* jsonContents = [NSString stringWithContentsOfFile:filePath_wordsDict encoding:NSUTF8StringEncoding error:nil];
//    NSDictionary* index = (NSDictionary*)[jsonContents JSONValue];
//    float timepassed = timer_passed(@"importFromJsonFile");
//    NSLog(@"time to import from JSON: %f", timepassed);
////    NSLog(@"index:\n%@", index);
//    
//    NSLog(@"size of index dict: %d", (int)[index collectionSize]);
//    
    counter_printall;
    counter_removeAll;
//
//    LogM_write(@"empty_unicodeString");
//    LogM_write(@"stemming");
    
    
    
    
    
   
//    NSLog(@"\n\n********************* searching for: '%@' **********************", SEARCHWORD);
//    
//    NSArray* searchRetults = [index objectForKey:SEARCHWORD];
//    
//    NSLog(@"%@", searchRetults);
    
    
    return YES;
}


// filters out words with length lower than 3 and turns words into lowercase
- (NSMutableArray*) cleanArray:(NSArray *)array {
    
    NSMutableArray* newArray = [NSMutableArray array];
    
    for (NSString* string in array) {
        
        if (string.length < 3) continue;
        else if ([self.stopWords containsObject:string]) continue;
        
        [newArray addObject:[string lowercaseString]];
    }
    
    return newArray;
}


- (NSArray*) wordsSortedByTotalCount:(NSDictionary *)wordsDict {

    NSMutableArray* words = [NSMutableArray array];
    NSMutableArray* counts = [NSMutableArray array];
    
    for (NSString* key in wordsDict.keyEnumerator) {
//        NSArray* nodes = [wordsDict objectForKey:key];
        NSDictionary* wordDict = [wordsDict objectForKey:key];
        uint totalCount = 0;
//        for (WordNode* node in nodes) {
//            totalCount += node.count;
//        }
//        for (NSDictionary* nodeDict in nodes) {
//            totalCount += [[nodeDict objectForKey:@"count"] intValue];
//        }
        for (NSNumber* pageNumber in wordDict.allKeys) {
            totalCount += [[wordDict objectForKey:pageNumber] intValue];
        }
        [words addObject:key];
        [counts addObject:[NSNumber numberWithInt:totalCount]];
    }
    
    words = [NSArray arrayWithArray:[words sortUsingNumberArray:&counts ascending:FALSE]];
    
    NSMutableArray* returnArray = [NSMutableArray array];
    for (int i = 0; i < words.count; ++i) {
        [returnArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                [counts objectAtIndex:i],
                                [words objectAtIndex:i],
                                nil]];
    }
    
    return returnArray;
}


//- (NSArray*) wordsSortedAlphabetically:(NSDictionary *)wordsDict {
//
//    NSArray* keys = wordsDict.allKeys;
//    keys = [keys sortedArrayUsingSelector:@selector(compare:)];
//    
//    NSMutableArray* returnArray = [NSMutableArray array];
//    
//    for (NSString* key in keys) {
//        
//        NSArray* nodes = [wordsDict objectForKey:key];
//        uint count = 0;
//        
////        for (WordNode* node in nodes) {
////            count += node.count;
////        }
////        for (NSDictionary* nodeDict in nodes) {
////            count += [[nodeDict objectForKey:@"count"] intValue];
////        }
//        for (NSArray* nodeArray in nodes) {
//            count += [[nodeArray objectAtIndex:1] intValue];
//        }
//        
//        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[key copy], @"word", [NSNumber numberWithInt:count], @"count", nil];
//        
//        [returnArray addObject:dict];
//    }
//    
//    return returnArray;
//}


- (CGPDFDocumentRef) createDocumentRefFromPath:(NSString *)path {
    
    CFStringRef path2 = CFStringCreateWithCString (NULL, [path UTF8String],
                                                   kCFStringEncodingUTF8);
    CFURLRef url = CFURLCreateWithFileSystemPath (NULL, path2,
                                                  kCFURLPOSIXPathStyle, 0);
    
    CGPDFDocumentRef docRef = CGPDFDocumentCreateWithURL(url);
    
    CFRelease(url);
    CFRelease(path2);
    
    return docRef;
}

          
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end




@implementation WordNode

@synthesize pageNumber, count;


- (NSString*) description {

    return [NSString stringWithFormat:@"WordNode (pageNumber = %d, count = %d)", self.pageNumber, self.count];
}


@end
