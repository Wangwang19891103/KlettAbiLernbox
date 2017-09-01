//
//  PDFManager.h
//  KlettAbiLernboxen
//
//  Created by Wang on 06.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentsPage.h"
#import "ContentsSubcategory.h"
#import "ContentsCategory.h"
#import "DataManager.h"
#import "SearchIndex.h"
#import "ModuleManager.h"


@protocol PDFManagerDelegate

- (void) pdfManagerDidLoadModule:(NSString*) moduleName;

- (void) pdfManagerDidUnloadModule;

@end


@interface PDFManager : NSObject {
    
    SearchIndex* _searchIndex;
    
    NSDictionary* __strong _actualPageNumbers;
    
    NSDictionary* __strong _seperatorRectPages;
    
    NSDictionary* __strong _bottomCorrectionPages;
}

@property (nonatomic, assign) id<PDFManagerDelegate> delegate;

@property (nonatomic, copy) NSString* moduleName;

//@property (nonatomic, copy) NSString* productID;

@property (nonatomic, copy) NSString* modulePath;

@property (nonatomic, assign) BOOL useSubcategories;

@property (nonatomic, assign) CGPDFDocumentRef exercisesDocumentRef;

@property (nonatomic, assign) CGPDFDocumentRef solutionsDocumentRef;

@property (nonatomic, assign) CGPDFDocumentRef knowledgeDocumentRef;

@property (nonatomic, strong) NSDictionary* searchIndex;

@property (nonatomic, strong) DataManager* dataManager;

@property (nonatomic, readonly) ModuleInstallationStatus installationStatus;

@property (nonatomic, readonly) NSArray* correctionRects;

@property (nonatomic, readonly) NSArray* bottomCorrections;

@property (nonatomic, readonly) CGRect seperatorRect;

@property (nonatomic, readonly) BOOL isDemo;

@property (nonatomic, readonly) BOOL loadSuccess;


+ (PDFManager*) manager;

- (void) loadModule:(NSString*) moduleName;

- (void) unloadModule;

//- (void) loadCategory:(NSString*) category;

- (void) loadSearchIndex;

- (CGPDFDocumentRef) loadDocumentFromPath:(NSString*) path;

- (NSArray*) categories;

- (NSArray*) categoryNames;

- (NSArray*) subcategoriesForCategory:(NSString*) categoryName;

- (NSArray*) pages;

- (ContentsPage*) pageForPageNumber:(uint) number;

- (NSArray*) pagesForCategory:(NSString*) categoryName;

- (NSArray*) pagesForSubcategory:(ContentsSubcategory*) subcategory;

- (uint) actualPageNumberForPosition:(uint) position;

- (NSArray*) titlesForPageNumber:(uint) number;

//- (NSArray*) titlesForCategory:(NSString*) category;

- (uint) pageNumberForIndexPath:(NSIndexPath*) indexPath inCategory:(NSString*) categoryName;

- (uint) pageCount;

- (uint) pageCountForCategory:(NSString*) categoryName;

- (NSRange) pageRangeForCategory:(NSString*) categoryName;

- (NSRange) pageRangeForCategory:(NSString *)categoryName subcategory:(NSString*) subcategoryName;

- (NSArray*) actualPageNumbersForCategory:(NSString*) categoryName;

- (NSArray*) thumbnailsForCategory:(NSString*) categoryName;

- (NSString*) randomStringFromSearchIndexWithNumberOfSentencesFrom:(uint) minSentence to:(uint) maxSentence wordCountPerSentenceFrom:(uint) minCount to:(uint) maxCount;

- (SearchIndexResults*) searchResultsForKeywords:(NSArray*) keywords;

- (CGRect) seperatorRectForPageNumber:(uint) number;

- (CGRect) bottomCorrectionRectForPageNumber:(uint) number documentType:(uint) type;


@end
