//
//  PageViewModel.h
//  KlettAbiLernboxen
//
//  Created by Wang on 17.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserDataManager.h"


@interface PageViewModel : NSObject

@property (nonatomic, copy) NSString* category;

@property (nonatomic, assign) uint pageNumber;

@property (nonatomic, assign) uint actualPageNumber;

@property (nonatomic, assign) uint relativePageNumber; // 0-based

@property (nonatomic, weak) Page* page;

@property (nonatomic, strong) NSArray* titles;

@property (nonatomic, readonly) BOOL isFavorite;

@property (nonatomic, readonly) PageLearnStatus learnStatus;

@property (nonatomic, assign) CGPDFPageRef exercisesRef;

@property (nonatomic, assign) CGPDFPageRef solutionsRef;

@property (nonatomic, assign) CGPDFPageRef knowledgeRef;


- (BOOL) switchFavorite;

- (void) switchLearnStatus:(PageLearnStatus) status;

- (NSArray*) notesForDocumentType:(uint) type;

- (Note*) createNoteForDocumentType:(uint) type;

@end
