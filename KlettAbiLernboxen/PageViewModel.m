//
//  PageViewModel.m
//  KlettAbiLernboxen
//
//  Created by Wang on 17.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PageViewModel.h"
#import "PDFManager.h"


@implementation PageViewModel

@synthesize category;
@synthesize pageNumber;
@synthesize actualPageNumber;
@synthesize relativePageNumber;
@synthesize page;
@synthesize titles;
@synthesize isFavorite;
@synthesize learnStatus;
@synthesize exercisesRef;
@synthesize solutionsRef;
@synthesize knowledgeRef;



#pragma mark - Getters

- (PageLearnStatus) learnStatus {
    
    if (self.page) {
        return [self.page.learnStatus intValue];
    }
    else return PageLearnStatusNew;
}


- (BOOL) isFavorite {

    if (self.page) {
        return [self.page.isFavorite boolValue];
    }
    else return FALSE;
}




#pragma mark - Switchers

- (BOOL) switchFavorite {
    
    [self createPageIfNeeded];
    
    BOOL newValue = ![page.isFavorite boolValue];
    
    self.page.isFavorite = [NSNumber numberWithBool:newValue];
    [self saveChanges];
    
    
//    alert(@"page: number=%@, isFavorite=%@", self.page.number, self.page.isFavorite);

    
    return newValue;
}


- (void) switchLearnStatus:(PageLearnStatus)status {
    
    [self createPageIfNeeded];
    
    if ([self.page.learnStatus intValue] == status) {
        self.page.learnStatus = [NSNumber numberWithInt:PageLearnStatusNew];
    }
    else {
        self.page.learnStatus = [NSNumber numberWithInt:status];
    }
    
    
    [self saveChanges];
}


#pragma mark - Misc

- (NSArray*) notesForDocumentType:(uint)type {
    
    NSMutableArray* returnArray = [NSMutableArray array];

    if (self.page) {

        for (Note* note in self.page.notes) {
            
            if ([note.documentType intValue] == type) {
                [returnArray addObject:note];
            }
        }
    }
        
    return returnArray;
}


- (Note*) createNoteForDocumentType:(uint)type {
    
    [self createPageIfNeeded];
    
    return [UserDataManager createNoteForPage:self.page documentType:type];
}


- (void) createPageIfNeeded {
    
    if (!self.page) {
        
        self.page = [UserDataManager fetchOrCreatePageForModule:[PDFManager manager].moduleName pageNumber:self.actualPageNumber];
    }
}


- (void) saveChanges {
    
    [UserDataManager save];
}



@end
