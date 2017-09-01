//
//  DocumentViewModel.m
//  KlettAbiLernboxen
//
//  Created by Wang on 17.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DocumentViewModel.h"
#import "PDFManager.h"
#import "UserDataManager.h"


@implementation DocumentViewModel

@synthesize category;
@synthesize delegate;
@synthesize pageRange;
//@synthesize titles;
@synthesize pages;
@synthesize thumbnails;
//@synthesize notes;
//@synthesize favorites;
//@synthesize learnStatus;


- (id) initWithCategory:(NSString *)categoryName {
    
    if (self = [super init]) {
        
        self.category = categoryName;
        self.pageRange = [[PDFManager manager] pageRangeForCategory:self.category];
        NSLog(@"page range: %d to %d", pageRange.location, pageRange.location + pageRange.length - 1);
//        alert(@"page range: %d to %d", range.location, range.location + range.length - 1);
        [self initialize];
    }
    
    return self;
}

- (void) initialize {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
        
        timer_start(@"documentViewModel_initialize");
        
        // -------

//        NSArray* actualPageNumbers = [[PDFManager manager] actualPageNumbersForCategory:category];
        
//        self.pages = [UserDataManager pagesForModule:[PDFManager manager].moduleName inRange:pageRange];
//        self.pages = [UserDataManager pagesForModule:[PDFManager manager].moduleName forActualPageNumbers:actualPageNumbers];
        self.pages = [UserDataManager pagesForModule:[PDFManager manager].moduleName];
        
        [(NSObject*)delegate performSelectorOnMainThread:@selector(documentViewModelDidFinishLoading:) withObject:nil waitUntilDone:NO];
        
        
        
        // -------
        
        float passed = timer_passed(@"documentViewModel_initialize");
//        alert(@"Time to load DocumentViewModel: %0.2f", passed);
    });
}

// number is 1-based
- (PageViewModel*) pageViewModelForPageNumber:(uint)number {
    
    PageViewModel* model = [[PageViewModel alloc] init];
    model.category = self.category;
    model.pageNumber = number;
    model.relativePageNumber = number - self.pageRange.location;
    model.titles = [[PDFManager manager] titlesForPageNumber:number];
    model.actualPageNumber = [[PDFManager manager] actualPageNumberForPosition:number];
    model.page = [self.pages objectForKey:[NSNumber numberWithInt:model.actualPageNumber]];
    
    model.exercisesRef = CGPDFDocumentGetPage([PDFManager manager].exercisesDocumentRef, number);
    model.solutionsRef = CGPDFDocumentGetPage([PDFManager manager].solutionsDocumentRef, number);
    model.knowledgeRef = CGPDFDocumentGetPage([PDFManager manager].knowledgeDocumentRef, number);
    
//    model.notes = [self.notes objectForKey:[NSNumber numberWithInt:number]];
//    model.isFavorite = [self.favorites containsObject:[NSNumber numberWithInt:number]];
//    model.learnStatus = [[self.learnStatus objectAtIndex:number - 1] intValue];
    
    return model;
}


- (BOOL) isFavoriteForRelativePageNumber:(uint)pageNumber {
    
    uint absolutePageNumber = [[PDFManager manager] actualPageNumberForPosition:pageNumber];
    Page* page = [self.pages objectForKey:[NSNumber numberWithInt:absolutePageNumber]];
    
    return [page.isFavorite boolValue];
}


- (uint) learnStatusForRelativePageNumber:(uint)pageNumber {
    
    uint absolutePageNumber = [[PDFManager manager] actualPageNumberForPosition:pageNumber];
    Page* page = [self.pages objectForKey:[NSNumber numberWithInt:absolutePageNumber]];
    
    return [page.learnStatus intValue];
}


@end
