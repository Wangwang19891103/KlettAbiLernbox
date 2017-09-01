//
//  PDFManager2.m
//  KlettAbiLernboxen
//
//  Created by Wang on xxxxxx.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PDFManager.h"
#import "ModuleManager.h"
#import "UADownloadManager.h"
#import "SBJson.h"
#import "OperationManager.h"
#import "Alerts.h"
#import "DataManager.h"
#import "NSArray+Extensions.h"
#import "ContentsPage.h"

#import "Functions.h"
#import "UserDataManager.h"


#define SEARCH_INDEX_FILENAME @"searchIndex.txt"




@implementation PDFManager

@synthesize /*moduleDict,*/ moduleName, useSubcategories, exercisesDocumentRef, solutionsDocumentRef, knowledgeDocumentRef;
@synthesize delegate;
@synthesize searchIndex;
@synthesize dataManager;
@synthesize installationStatus;
@synthesize modulePath;
@synthesize correctionRects;
@synthesize bottomCorrections;
@synthesize seperatorRect;
@synthesize isDemo;
@synthesize loadSuccess;


- (id) init {
    
    if (self = [super init]) {
        
        //        self.moduleDict = [self populateModules];
    }
    
    return self;
}


+ (PDFManager*) manager {
    
    static PDFManager* _instance;
    
    @synchronized(self) {
        
        if (!_instance) {
            
            _instance = [[PDFManager alloc] init];
        }
    }
    
    return _instance;
}


- (void) loadModule:(NSString *)theModuleName {

    // reset
    loadSuccess = FALSE;
    _seperatorRectPages = nil;  // reset special cases for pages
    _bottomCorrectionPages = nil;
    
    self.moduleName = theModuleName;
    self.modulePath = [[ModuleManager manager] pathForModule:theModuleName];
//    self.modulePath = [NSString stringWithFormat:@"%@/Contents", self.modulePath];
    
    isDemo = ([[ModuleManager manager] installationStatusForModule:theModuleName] == ModuleInstallationStatusDemo);
    
    // check if module exists
    if (!modulePath) {
        
        NSLog(@"Module not found: %@", theModuleName);
        return;
    }
    
    NSLog(@"modulePath: %@", modulePath);
    
    NSString* contentsPath = [modulePath stringByAppendingPathComponent:@"contents.sqlite"];
    
    NSLog(@"path to contents.sqlite: %@", contentsPath);
    
    // check if module has contents.plist
    if (![[NSFileManager defaultManager] fileExistsAtPath:contentsPath isDirectory:nil]) {
        alert(@"No contents.sqlite found for module: %@", theModuleName);
        return;
    }
    

    self.dataManager = [[DataManager alloc] initWithModelName:@"contents" path:contentsPath];


    self.useSubcategories = ([[self.dataManager fetchDataForEntityName:@"ContentsSubcategory" withPredicate:nil sortedBy:nil] count] != 0);
    

    /* load pdf documents */
    NSString* exercisesPath = [modulePath stringByAppendingPathComponent:@"exercises.pdf"];
    NSString* solutionsPath = [modulePath stringByAppendingPathComponent:@"solutions.pdf"];
    NSString* knowledgePath = [modulePath stringByAppendingPathComponent:@"knowledge.pdf"];
    
//    if (![[NSFileManager defaultManager] fileExistsAtPath:exercisesPath isDirectory:nil]
//        || ![[NSFileManager defaultManager] fileExistsAtPath:solutionsPath isDirectory:nil]
//        || ![[NSFileManager defaultManager] fileExistsAtPath:knowledgePath isDirectory:nil]) {

    if (![[NSFileManager defaultManager] fileExistsAtPath:exercisesPath isDirectory:nil]
        || ![[NSFileManager defaultManager] fileExistsAtPath:solutionsPath isDirectory:nil]) {

        alert(@"Missing exercises/solutions/knowledge directory/-ies for module: %@", self.moduleName);
        return;
    }
    
    self.exercisesDocumentRef = [self loadDocumentFromPath:exercisesPath];
    self.solutionsDocumentRef = [self loadDocumentFromPath:solutionsPath];
    self.knowledgeDocumentRef = [self loadDocumentFromPath:knowledgePath];
    
    // check if all 3 documents were successfully loaded

//    if (!(self.exercisesDocumentRef && self.solutionsDocumentRef && self.knowledgeDocumentRef)) {

    if (!(self.exercisesDocumentRef && self.solutionsDocumentRef)) {

        return; // return without loadSuccess
    }
    
    
    /* actual page numbers */
    
    NSMutableDictionary* actualPageNumbers = [NSMutableDictionary dictionaryWithCapacity:100];
    NSArray* pages = [self pages];
    
    for (ContentsPage* page in pages) {
        
        [actualPageNumbers setObject:page.actualPageNumber forKey:page.position];
    }
    
    _actualPageNumbers = actualPageNumbers;
    
    
    
//    NSString* sqlitePath = [productPath stringByAppendingPathComponent:@"contents"];
    
    [self.delegate pdfManagerDidLoadModule:theModuleName];
    
    [[OperationManager queueNamed:@"default"] addOperationWithTarget:self selector:@selector(loadSearchIndex) object:nil];
    
    correctionRects = [[ModuleManager manager] correctionRectsForModule:theModuleName];
    bottomCorrections = [[ModuleManager manager] bottomCorrectionsForModule:theModuleName];
    seperatorRect = [[ModuleManager manager] seperatorRectForModule:theModuleName];
    _seperatorRectPages = [[ModuleManager manager] seperatorRectPagesForModule:theModuleName];
    _bottomCorrectionPages = [[ModuleManager manager] bottomCorrectionPagesForModule:theModuleName];
    
    loadSuccess = TRUE;
}


- (void) unloadModule {
    
    if (!self.moduleName) return;
    
    self.moduleName = nil;
    self.modulePath = nil;
    self.dataManager = nil;
    correctionRects = nil;
    bottomCorrections = nil;
    seperatorRect = CGRectZero;
    loadSuccess = FALSE;
    
    
    if (self.exercisesDocumentRef)
        CGPDFDocumentRelease(self.exercisesDocumentRef);
    
    if (self.solutionsDocumentRef)
        CGPDFDocumentRelease(self.solutionsDocumentRef);
    
    if (self.knowledgeDocumentRef)
        CGPDFDocumentRelease(self.knowledgeDocumentRef);
    
    [self.delegate pdfManagerDidUnloadModule];
}


//- (void) loadCategory:(NSString *)category {
//    
//    for (NSDictionary* dict in self.contentsArray) {
//        if ([[dict objectForKey:@"category"] isEqualToString:category]) {
//            self.categoryDict = dict;
//        }
//    }
//    
//    // check if category exists in contents dict
//    if (!self.categoryDict) {
//        NSLog(@"Category not found: %@ for module: %@", category, self.moduleName);
//        return;
//    }
//    
//    self.categoryName = category;
//    
//    NSString* productPath = [CONTENT_DIRECTORY stringByAppendingPathComponent:self.productID];
//    
//    //    NSString* moduleDirectory = [self.moduleDict objectForKey:self.moduleName];
//    
//    NSString* exercisesPath = [productPath stringByAppendingPathComponent:@"exercises"];
//    NSString* solutionsPath = [productPath stringByAppendingPathComponent:@"solutions"];
//    NSString* knowledgePath = [productPath stringByAppendingPathComponent:@"knowledge"];
//    
//    // check if module has exercises directory
//    if (![[NSFileManager defaultManager] fileExistsAtPath:exercisesPath isDirectory:nil]
//        || ![[NSFileManager defaultManager] fileExistsAtPath:solutionsPath isDirectory:nil]
//        || ![[NSFileManager defaultManager] fileExistsAtPath:knowledgePath isDirectory:nil]) {
//        
//        NSLog(@"Missing exercises/solutions/knowledge directory/-ies for module: %@", self.moduleName);
//        return;
//    }
//    
//    NSString* category2 = [category stringByReplacingOccurrencesOfString:@" " withString:@"_"];
//    category2 = [category2 stringByReplacingOccurrencesOfString:@"ä" withString:@"ae"];
//    category2 = [category2 stringByReplacingOccurrencesOfString:@"ö" withString:@"oe"];
//    category2 = [category2 stringByReplacingOccurrencesOfString:@"ü" withString:@"ue"];
//    category2 = [category2 stringByReplacingOccurrencesOfString:@"Ä" withString:@"Ae"];
//    category2 = [category2 stringByReplacingOccurrencesOfString:@"Ö" withString:@"Oe"];
//    category2 = [category2 stringByReplacingOccurrencesOfString:@"Ü" withString:@"Ue"];
//    category2 = [category2 stringByReplacingOccurrencesOfString:@"," withString:@""];
//    NSString* exercisesFilePath = [exercisesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", category2]];
//    NSString* solutionsFilePath = [solutionsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", category2]];
//    NSString* knowledgeFilePath = [knowledgePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf", category2]];
//    
//    // check if exercises directory contains category pdf
//    if (![[NSFileManager defaultManager] fileExistsAtPath:exercisesFilePath isDirectory:nil]
//        || ![[NSFileManager defaultManager] fileExistsAtPath:solutionsFilePath isDirectory:nil]
//        || ![[NSFileManager defaultManager] fileExistsAtPath:knowledgeFilePath isDirectory:nil]) {
//        
//        NSLog(@"No category pdf: %@ in exercises/solutions/knowledge path/-s", exercisesFilePath);
//        NSLog(@"path: %@", exercisesFilePath);
//        return;
//    }
//    
//    self.exercisesDocumentRef = [self loadDocumentFromPath:exercisesFilePath];
//    self.solutionsDocumentRef = [self loadDocumentFromPath:solutionsFilePath];
//    self.knowledgeDocumentRef = [self loadDocumentFromPath:knowledgeFilePath];
//}


- (CGPDFDocumentRef) loadDocumentFromPath:(NSString *)path {
    
    CFStringRef path2 = CFStringCreateWithCString (NULL, [path UTF8String], kCFStringEncodingUTF8);
    CFURLRef url = CFURLCreateWithFileSystemPath (NULL, path2, kCFURLPOSIXPathStyle, 0);
    CGPDFDocumentRef documentRef = CGPDFDocumentCreateWithURL(url);
    CFRelease(url);
    CFRelease(path2);
    
    if (!CGPDFDocumentIsEncrypted(documentRef)) {
        
        return nil;
    }
    else {

        CGPDFDocumentUnlockWithPassword(documentRef, "kAEqVs=+dGCp)vaX");
    
        return documentRef;
    }
}

- (void) loadSearchIndex {
    
    timer_start(@"searchindex");
    
    NSString* indexFilePath = [modulePath stringByAppendingPathComponent:SEARCH_INDEX_FILENAME];
    NSError* error = nil;
//    NSString* indexFileString = [NSString stringWithContentsOfFile:indexFilePath encoding:NSUTF8StringEncoding error:&error];
//    if (error) { NSLog(@"error: %@", error); }
    _searchIndex = [[SearchIndex alloc] initWithContentsOfFile:indexFilePath];
    
    float passed = timer_passed(@"searchindex");
    
    NSLog(@"Time to load search index: %0.2f", passed);
    
    //    counter_incF(@"searchindex", passed);
    
    //    alert(@"Time to load search index: %0.2f", passed);
    
    
    
    
//    if ([UserDataManager numberOfNotesInModule:moduleName] == 0) {
//     
//        dispatch_sync(dispatch_get_main_queue(), ^(void) {
//
//            [UserDataManager deleteAllNotesForModule:moduleName];
//            
//            [UserDataManager createRandomNotesForModule:moduleName minCount:1 maxCount:3 inRect:CGRectMake(0, 0, 350, 200) chanceForNotes:0.15];
//            
//            alert(@"Notes wurden erfolgreich generiert.");
//        });
//        
//    }
}


//- (NSDictionary*) populateModules {
//    
//    NSString* contentPath = [[NSBundle mainBundle] pathForResource:CONTENT_PATH ofType:@""];
//    NSError* error = nil;
//    NSArray* list = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:contentPath error:&error];
//    NSMutableArray* directories = [NSMutableArray array];
//    NSMutableDictionary* theModuleDict = [NSMutableDictionary dictionary];
//    
//    BOOL isDirectory;
//
//    // iterate through all files in content path
//    for (NSString* currentFile in list) {
//        
//        NSString* fullPath = [contentPath stringByAppendingPathComponent:currentFile];
//        
//        if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:&isDirectory]) {
//            
//            if (isDirectory) {
//                
//                [directories addObject:fullPath];
//            }
//        }
//    }
//    
//    // iterate through all directories found and add those which contain a config.plist
//    for (NSString* directory in directories) {
//        
//        NSString* configPath = [directory stringByAppendingPathComponent:@"config.plist"];
//        
//        if ([[NSFileManager defaultManager] fileExistsAtPath:configPath isDirectory:nil]) {
//            
//            NSDictionary* configDict = [NSDictionary dictionaryWithContentsOfFile:configPath];
//            [theModuleDict setObject:directory forKey:[configDict objectForKey:@"ModuleName"]];
//        }
//    }
//
//    return theModuleDict;
//}


- (NSArray*) categories {
    
    return [self.dataManager fetchDataForEntityName:@"ContentsCategory" withPredicate:nil sortedBy:@"position", nil];
}

- (NSArray*) categoryNames {
    
    NSArray* results = [self.dataManager fetchDataForEntityName:@"ContentsCategory" withPredicate:nil sortedBy:@"position", nil];
    
    NSMutableArray* names = [NSMutableArray array];
    
    for (ContentsCategory* category in results) {
        [names addObject:category.name];
    }
    
    return names;
}


- (NSArray*) subcategoriesForCategory:(NSString *)categoryName {
    
    return [self.dataManager fetchDataForEntityName:@"ContentsSubcategory" withPredicate:[NSPredicate predicateWithFormat:@"category.name == %@", categoryName] sortedBy:@"position", nil];
}

- (NSArray*) pages {
    
    return [self.dataManager fetchDataForEntityName:@"ContentsPage" withPredicate:nil sortedBy:@"position", nil];
}




- (ContentsPage*) pageForPageNumber:(uint)number {
    
    return [[self.dataManager fetchDataForEntityName:@"ContentsPage" withPredicate:[NSPredicate predicateWithFormat:@"position == %d", number] sortedBy:nil] firstElement];
}

- (NSArray*) pagesForCategory:(NSString *)categoryName {
    
    return [self.dataManager fetchDataForEntityName:@"ContentsPage" withPredicate:[NSPredicate predicateWithFormat:@"category.name == %@", categoryName] sortedBy:@"position", nil];
}

- (NSArray*) pagesForSubcategory:(ContentsSubcategory *)subcategory {

    return [self.dataManager fetchDataForEntityName:@"ContentsPage" withPredicate:[NSPredicate predicateWithFormat:@"subcategory == %@", subcategory] sortedBy:@"position", nil];
}


- (uint) actualPageNumberForPosition:(uint)position {

    return [[_actualPageNumbers objectForKey:[NSNumber numberWithInt:position]] intValue];
}


// number is 1-based
- (NSArray*) titlesForPageNumber:(uint)number {
    
    NSArray* results = [self.dataManager fetchDataForEntityName:@"ContentsPage" withPredicate:[NSPredicate predicateWithFormat:@"position == %d", number] sortedBy:nil];
    
    if (results.count == 1) {
        
        ContentsPage* page = [results objectAtIndex:0];
        
        if (self.useSubcategories) { 
            return [NSArray arrayWithObjects:page.subcategory.name, page.name, nil];
        }
        else {
            return [NSArray arrayWithObjects:page.name, nil];
        }
    }
    else {
        return nil;
    }
}

//
//- (NSArray*) titlesForCategory:(NSString *)category {
//    
//    NSArray* pages = [self pagesForCategory:category];
//    
//    
//}


- (NSRange) pageRangeForCategory:(NSString *)categoryName {
    
    NSArray* results = [self.dataManager fetchDataForEntityName:@"ContentsCategory" withPredicate:[NSPredicate predicateWithFormat:@"name == %@", categoryName] sortedBy:nil];
    
    ContentsCategory* category = [results firstElement];
    
    return NSMakeRange([category.firstPageNumber intValue], [category.numberOfPages intValue]);
}


- (NSRange) pageRangeForCategory:(NSString *)categoryName subcategory:(NSString *)subcategoryName {
    
    NSArray* results = [self.dataManager fetchDataForEntityName:@"ContentsSubcategory" withPredicate:[NSPredicate predicateWithFormat:@"category.name == %@ AND name == %@", categoryName, subcategoryName] sortedBy:nil];
    
    ContentsSubcategory* subcategory = [results firstElement];
    
    return NSMakeRange([subcategory.firstPageNumber intValue], [subcategory.numberOfPages intValue]);
}


- (uint) pageNumberForIndexPath:(NSIndexPath *)indexPath inCategory:(NSString*) categoryName {
    
    NSArray* results = nil;
    
    if (self.useSubcategories) {
     
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"category.name == %@ AND (subcategory.position - category.firstSubcategoryNumber) == %d AND (position - subcategory.firstPageNumber) == %d", categoryName, indexPath.section, indexPath.row];
        
        results = [self.dataManager fetchDataForEntityName:@"ContentsPage" withPredicate:predicate sortedBy:nil];
    }
    else {
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"category.name == %@ AND (position - category.firstPageNumber) == %d", categoryName, indexPath.row];
        
        results = [self.dataManager fetchDataForEntityName:@"ContentsPage" withPredicate:predicate sortedBy:nil];
    }
    
    ContentsPage* page = [results firstElement];

    return [page.position intValue];
}


- (uint) pageCount {
    
    NSArray* results = [self.dataManager fetchDataForEntityName:@"ContentsPage" withPredicate:nil sortedBy:nil];
    
    return [results count];
}


- (uint) pageCountForCategory:(NSString *)categoryName {
    
    NSArray* results = [self.dataManager fetchDataForEntityName:@"ContentsCategory" withPredicate:[NSPredicate predicateWithFormat:@"name == %@", categoryName] sortedBy:nil];
    
    ContentsCategory* category = [results firstElement];
    
    return [category.numberOfPages intValue];
}


- (NSArray*) actualPageNumbersForCategory:(NSString *)categoryName {
    
    NSMutableArray* resultArray = [NSMutableArray array];
    
    NSArray* pages = [self pagesForCategory:categoryName];
    
    for (ContentsPage* page in pages) {
        
        NSDictionary* pageDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  page.position, @"position",
                                  page.actualPageNumber, @"actualPageNumber",
                                  nil];
        
        [resultArray addObject:pageDict];
    }
    
    return resultArray;
}


- (NSArray*) thumbnailsForCategory:(NSString *)categoryName {

    NSRange pageRange = [self pageRangeForCategory:categoryName];
    
    NSMutableArray* images = [NSMutableArray array];
    NSString* productPath = modulePath;
    NSString* productPath2 = [modulePath stringByAppendingPathComponent:@"thumbnails"];  // used for demo content

    
//    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"position >= %@ AND position < %@", [NSNumber numberWithInt:pageRange.location], [NSNumber numberWithInt:(pageRange.location + pageRange.length)]];
//    NSArray* pages = [[DataManager instanceNamed:@"contents"] fetchDataForEntityName:@"ContentsPage" withPredicate:predicate sortedBy:@"position", nil];
    
    for (int i = pageRange.location; i < (pageRange.location + pageRange.length); ++i) {
        
//    for (ContentsPage* page in pages) {

        NSString* filePath = [productPath stringByAppendingPathComponent:[NSString stringWithFormat:@"thumbnail_%d.png", i]];
        UIImage* image = [UIImage imageWithContentsOfFile:filePath];
        
        if (!image) {
            
            filePath = [productPath2 stringByAppendingPathComponent:[NSString stringWithFormat:@"thumbnail_%d.png", i]];
            image = [UIImage imageWithContentsOfFile:filePath];
        }
        
        //        NSLog(@"file not found: %@", filePath);
        
        [images addObject:image];
    }
    
    return images;
}


- (NSString*) randomStringFromSearchIndexWithNumberOfSentencesFrom:(uint)minSentence to:(uint)maxSentence wordCountPerSentenceFrom:(uint)minCount to:(uint)maxCount {
    
    uint sentenceCount = randomIntegerFromTo(minSentence, maxSentence);
//    NSArray* keys = self.searchIndex.allKeys;
    NSMutableString* string = [NSMutableString string];
    
    for (int s = 0; s < sentenceCount; ++s) {
    
        NSMutableArray* words = [NSMutableArray array];

        uint wordCount = randomIntegerFromTo(minCount, maxCount);
        
        for (uint w = 0; w < wordCount; ++w) {
            
//            uint keyIndex = arc4random() % keys.count;
//            [words addObject:[keys objectAtIndex:keyIndex]];
            
            NSString* randomString = [_searchIndex randomString];
            [words addObject:randomString];
        }
        
        [string appendFormat:@"%@\n", [words componentsJoinedByString:@" "]];
    }
    
    return string;
}


- (SearchIndexResults*) searchResultsForKeywords:(NSArray *)keywords {
    
    return [_searchIndex searchResultsForStrings:keywords];
}


- (CGRect) seperatorRectForPageNumber:(uint)number {
    
    NSLog(@"rectPageNumber: %d", number);
    
    NSString* rectString = [_seperatorRectPages objectForKey:[NSString stringWithFormat:@"%d", number]];
    
    NSLog(@"rectString: %@", rectString);
    
    if (rectString) {
        
        return CGRectFromString(rectString);
    }
    else {
        
        return CGRectZero;
    }
}


- (CGRect) bottomCorrectionRectForPageNumber:(uint)number documentType:(uint)type {
    
    NSLog(@"rectPageNumber: %d, type: %d", number, type);
    
    NSString* rectString = [[_bottomCorrectionPages objectForKey:[NSString stringWithFormat:@"%d", number]] objectForKey:[NSString stringWithFormat:@"%d", type]];
    
    NSLog(@"rectString: %@", rectString);
    
    if (rectString) {
        
        return CGRectFromString(rectString);
    }
    else {
        
        return CGRectZero;
    }
}


@end
