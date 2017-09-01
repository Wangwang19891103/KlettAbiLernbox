//
//  UserDataManager.h
//  KlettAbiLernboxen
//
//  Created by Wang on 10.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Module.h"
#import "Page.h"
#import "Note.h"


typedef enum {
    PageLearnStatusNew,
    PageLearnStatusUnderstood,
    PageLearnStatusNotUnderstood
} PageLearnStatus;


@interface UserDataManager : NSObject


#pragma mark Fetch or create

+ (Page*) fetchOrCreatePageForModule:(NSString*) moduleName pageNumber:(uint) pageNumber;


#pragma mark Pages

+ (NSDictionary*) pagesForModule:(NSString*) moduleName;

+ (NSDictionary*) pagesForModule:(NSString *)moduleName inRange:(NSRange)range;

+ (NSDictionary*) pagesForModule:(NSString*) moduleName forActualPageNumbers:(NSArray*) numberArray;

#pragma mark Favorites

+ (BOOL) isFavoriteForModule:(NSString*) moduleName pageNumber:(uint) pageNumber;

+ (NSArray*) favoritesForModule:(NSString*) moduleName inRange:(NSRange) range;


#pragma mark Learn status

+ (PageLearnStatus) learnStatusForModule:(NSString*) moduleName pageNumber:(uint) pageNumber;

+ (uint) numberOfUnderstoodPageForModule:(NSString*) moduleName;

+ (uint) numberOfUnderstoodPageForModule:(NSString*) moduleName inRange:(NSRange) range;

+ (uint) numberOfNotUnderstoodPageForModule:(NSString *)moduleName;

+ (uint) numberOfNotUnderstoodPageForModule:(NSString*) moduleName inRange:(NSRange) range;

#pragma mark Notes

//+ (Note*) createNoteForModule:(NSString*) moduleName pageNumber:(uint) pageNumber documentType:(uint) documentType withPosition:(CGPoint) position;

+ (Note*) createNoteForPage:(Page *)page documentType:(uint) type;

+ (NSDictionary*) notesForModule:(NSString*) moduleName;

+ (NSDictionary*) notesForModule:(NSString *)moduleName inRange:(NSRange) range;

//+ (uint) numberOfNotesInModule:(NSString*) moduleName;

+ (void) deleteNote:(Note*) note;

+ (void) deleteAllNotesForModule:(NSString*) moduleName;


#pragma mark Misc

+ (void) save;

+ (void) printToFile;

//+ (void) createRandomNotesForModule:(NSString*) moduleName minCount:(uint) minCount maxCount:(uint) maxCount inRect:(CGRect) rect chanceForNotes:(float) chance;



@end
