//
//  UserDataManager.m
//  KlettAbiLernboxen
//
//  Created by Wang on 10.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserDataManager.h"
#import "DataManager.h"
#import "NSArray+Extensions.h"
#import "Functions.h"
#import "PDFManager.h"


@implementation UserDataManager


#pragma mark Fetch or create

+ (Page*) fetchOrCreatePageForModule:(NSString *)moduleName pageNumber:(uint)pageNumber {
    
    NSArray* results = nil;
    Module* module = nil;
    Page* page = nil;
    
    results = [[DataManager instanceNamed:@"user"] fetchDataForEntityName:@"Module" withPredicate:[NSPredicate predicateWithFormat:@"name == %@", moduleName] sortedBy:nil];
    
    if ([results count] == 0) {
        module = [[DataManager instanceNamed:@"user"] insertNewObjectForEntityName:@"Module"];
        module.name = moduleName;
    }
    else {
        module = [results objectAtIndex:0];
    }
    
    results = [[DataManager instanceNamed:@"user"] fetchDataForEntityName:@"Page" withPredicate:[NSPredicate predicateWithFormat:@"module.name == %@ AND number == %d", moduleName, pageNumber] sortedBy:nil];
    
    if ([results count] == 0) {
        page = [[DataManager instanceNamed:@"user"] insertNewObjectForEntityName:@"Page"];
        page.module = module;
        page.number = [NSNumber numberWithInt:pageNumber];
        page.isFavorite = [NSNumber numberWithBool:FALSE];
        page.learnStatus = [NSNumber numberWithInt:PageLearnStatusNew];
        
        [[DataManager instanceNamed:@"user"] save];
    }
    else {
        page = [results objectAtIndex:0];
    }

    return page;
}


#pragma mark Pages

+ (NSDictionary*) pagesForModule:(NSString *)moduleName {
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"module.name == %@", moduleName];
    NSArray* pages = [[DataManager instanceNamed:@"user"] fetchDataForEntityName:@"Page" withPredicate:predicate sortedBy:@"number", nil];
    
    NSMutableDictionary* returnDict = [NSMutableDictionary dictionary];
    
    for (Page* page in pages) {
        [returnDict setObject:page forKey:page.number];
    }
    
    return returnDict;
}


+ (NSDictionary*) pagesForModule:(NSString *)moduleName inRange:(NSRange)range {
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"module.name == %@ AND number >= %@ AND number < %@", moduleName, [NSNumber numberWithInt:range.location], [NSNumber numberWithInt:(range.location + range.length)]];
    NSArray* pages = [[DataManager instanceNamed:@"user"] fetchDataForEntityName:@"Page" withPredicate:predicate sortedBy:@"number", nil];
    
    NSMutableDictionary* returnDict = [NSMutableDictionary dictionary];
    
    for (Page* page in pages) {
        [returnDict setObject:page forKey:page.number];
    }
    
    return returnDict;
}


+ (NSDictionary*) pagesForModule:(NSString *)moduleName forActualPageNumbers:(NSArray *)numberArray {

    NSMutableDictionary* returnDict = [NSMutableDictionary dictionary];
    
    for (NSDictionary* pageDict in numberArray) {
        
        NSNumber* position = [pageDict objectForKey:@"position"];
        NSNumber* actualPageNumber = [pageDict objectForKey:@"actualPageNumber"];
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"module.name == %@ AND number == %@", moduleName, actualPageNumber];
        NSArray* results = [[DataManager instanceNamed:@"user"] fetchDataForEntityName:@"Page" withPredicate:predicate sortedBy:nil];

        if (results.count == 1) {
         
            [returnDict setObject:[results objectAtIndex:0] forKey:position];
        }
    }
    
    return returnDict;
}


#pragma mark Favorites

+ (BOOL) isFavoriteForModule:(NSString*) moduleName pageNumber:(uint) pageNumber {
    
    NSArray* results = [[DataManager instanceNamed:@"user"] fetchDataForEntityName:@"Page" withPredicate:[NSPredicate predicateWithFormat:@"module.name == %@ AND number == %d", moduleName, pageNumber] sortedBy:nil];
    
    if (results.count == 0) return FALSE;
    else return [[[results firstElement] isFavorite] boolValue];
}


+ (NSArray*) favoritesForModule:(NSString *)moduleName inRange:(NSRange)range {
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"module.name == %@ AND number >= %@ AND number < %@ AND isFavorite == TRUE", moduleName, [NSNumber numberWithInt:range.location], [NSNumber numberWithInt:(range.location + range.length)]];
    return [[DataManager instanceNamed:@"user"] fetchDataForEntityName:@"Page" withPredicate:predicate sortedBy:@"number", nil];
}


#pragma mark Learn status

+ (PageLearnStatus) learnStatusForModule:(NSString *)moduleName pageNumber:(uint)pageNumber {
    
    NSArray* results = [[DataManager instanceNamed:@"user"] fetchDataForEntityName:@"Page" withPredicate:[NSPredicate predicateWithFormat:@"module.name == %@ AND number == %d", moduleName, pageNumber] sortedBy:nil];
    
    if (results.count == 0) return FALSE;
    else return [[[results firstElement] learnStatus] intValue];
}


+ (uint) numberOfUnderstoodPageForModule:(NSString *)moduleName {
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"module.name == %@ AND learnStatus == %@", moduleName, [NSNumber numberWithInt:PageLearnStatusUnderstood]];
    NSArray* results = [[DataManager instanceNamed:@"user"] fetchDataForEntityName:@"Page" withPredicate:predicate sortedBy:nil];
    
//    for (Page* page in results) {
//        NSLog(@"module: %@, category: %@, learnStatus: %d", page.category.module.name, page.category.name, [page.learnStatus intValue]);
//    }
    
    return results.count;
}


+ (uint) numberOfUnderstoodPageForModule:(NSString *)moduleName inRange:(NSRange)range {
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"module.name == %@ AND number >= %@ AND number < %@ AND learnStatus == %@", moduleName, [NSNumber numberWithInt:range.location], [NSNumber numberWithInt:(range.location + range.length)], [NSNumber numberWithInt:PageLearnStatusUnderstood]];
    NSArray* results = [[DataManager instanceNamed:@"user"] fetchDataForEntityName:@"Page" withPredicate:predicate sortedBy:nil];
    
    //    for (Page* page in results) {
    //        NSLog(@"module: %@, category: %@, learnStatus: %d", page.category.module.name, page.category.name, [page.learnStatus intValue]);
    //    }
    
    return results.count;
}


+ (uint) numberOfNotUnderstoodPageForModule:(NSString *)moduleName {
    
    NSArray* results = [[DataManager instanceNamed:@"user"] fetchDataForEntityName:@"Page" withPredicate:[NSPredicate predicateWithFormat:@"module.name == %@ AND learnStatus == %d", moduleName, PageLearnStatusNotUnderstood] sortedBy:nil];
    
    return results.count;
}


+ (uint) numberOfNotUnderstoodPageForModule:(NSString *)moduleName inRange:(NSRange)range {
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"module.name == %@ AND number >= %@ AND number < %@ AND learnStatus == %@", moduleName, [NSNumber numberWithInt:range.location], [NSNumber numberWithInt:(range.location + range.length)], [NSNumber numberWithInt:PageLearnStatusNotUnderstood]];
    NSArray* results = [[DataManager instanceNamed:@"user"] fetchDataForEntityName:@"Page" withPredicate:predicate sortedBy:nil];
    
    //    for (Page* page in results) {
    //        NSLog(@"module: %@, category: %@, learnStatus: %d", page.category.module.name, page.category.name, [page.learnStatus intValue]);
    //    }
    
    return results.count;
}


#pragma mark Notes

//+ (Note*) createNoteForModule:(NSString *)moduleName pageNumber:(uint)pageNumber documentType:(uint)documentType withPosition:(CGPoint)position {
//    
//    Page* page = [UserDataManager fetchOrCreatePageForModule:moduleName pageNumber:pageNumber];
//    Note* note = [[DataManager instanceNamed:@"user"] insertNewObjectForEntityName:@"Note"];
//    
//    note.page = page;
//    note.text = @"Text...";
//    note.positionX = [NSNumber numberWithFloat:position.x];
//    note.positionY = [NSNumber numberWithFloat:position.y];
//    note.documentType = [NSNumber numberWithInt:documentType];
//    note.scale = [NSNumber numberWithFloat:1.0f];
//    note.isOpen = [NSNumber numberWithBool:FALSE];
// 
//    [UserDataManager save];
//    
//    return note;
//}


+ (Note*) createNoteForPage:(Page *)page documentType:(uint) type {
    
    Note* note = [[DataManager instanceNamed:@"user"] insertNewObjectForEntityName:@"Note"];
    
    note.page = page;
    note.text = @"";
    note.positionX = [NSNumber numberWithFloat:0.0f];
    note.positionY = [NSNumber numberWithFloat:0.0f];
    note.documentType = [NSNumber numberWithInt:type];
    note.scale = [NSNumber numberWithFloat:1.0f];
    note.isOpen = [NSNumber numberWithBool:FALSE];
    
    [UserDataManager save];
    
    return note;
}


+ (NSDictionary*) notesForModule:(NSString *)moduleName {
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"page.module.name == %@", moduleName];
    
    NSArray* notes = [[DataManager instanceNamed:@"user"] fetchDataForEntityName:@"Note" withPredicate:predicate sortedBy:@"page.number", @"documentType", @"positionX", @"positionY", nil];
    
    NSMutableDictionary* returnDict = [NSMutableDictionary dictionary];
    /* structure returnDict:
     * pageNumbers (dict)
     *     documentTypes (dict)
     *         notes (array)
     */
    
    for (Note* note in notes) {
        
        NSNumber* pageNumber = note.page.number;
        NSNumber* documentType = note.documentType;
        
        if (![returnDict objectForKey:pageNumber]) {
            [returnDict setObject:[NSMutableDictionary dictionary] forKey:pageNumber];
        }
        
        NSMutableDictionary* pageNumberDict = [returnDict objectForKey:pageNumber];
        
        if (![pageNumberDict objectForKey:documentType]) {
            [pageNumberDict setObject:[NSMutableArray array] forKey:documentType];
        }
        
        NSMutableArray* documentTypeArray = [pageNumberDict objectForKey:documentType];
        
        [documentTypeArray addObject:note];
    }
    
    return returnDict;
}


+ (NSDictionary*) notesForModule:(NSString *)moduleName inRange:(NSRange) range {
    
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"page.module.name == %@ AND page.number >= %@ AND page.number < %@", moduleName, [NSNumber numberWithInt:range.location], [NSNumber numberWithInt:(range.location + range.length)]];
    
    NSArray* notes = [[DataManager instanceNamed:@"user"] fetchDataForEntityName:@"Note" withPredicate:predicate sortedBy:@"page.number", @"documentType", @"positionX", @"positionY", nil];

    NSMutableDictionary* returnDict = [NSMutableDictionary dictionary];
    /* structure returnDict:
     * pageNumbers (dict)
     *     documentTypes (dict)
     *         notes (array)
     */
    
    for (Note* note in notes) {
        
        NSNumber* pageNumber = note.page.number;
        NSNumber* documentType = note.documentType;
        
        if (![returnDict objectForKey:pageNumber]) {
            [returnDict setObject:[NSMutableDictionary dictionary] forKey:pageNumber];
        }
        
        NSMutableDictionary* pageNumberDict = [returnDict objectForKey:pageNumber];
        
        if (![pageNumberDict objectForKey:documentType]) {
            [pageNumberDict setObject:[NSMutableArray array] forKey:documentType];
        }
        
        NSMutableArray* documentTypeArray = [pageNumberDict objectForKey:documentType];
        
        [documentTypeArray addObject:note];
    }
    
    return returnDict;
}


//+ (uint) numberOfNotesInModule:(NSString *)moduleName {
//    
//    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"page.category.module.name == %@", moduleName];
//    
//    NSArray* notes = [[DataManager instanceNamed:@"user"] fetchDataForEntityName:@"Note" withPredicate:predicate sortedBy:nil];
//    
//    return notes.count;
//}


+ (void) deleteNote:(Note *)note {
    
    NSLog(@"Deleting note: %@", note);
    
    [[DataManager instanceNamed:@"user"] deleteObject:note];
    
    [[DataManager instanceNamed:@"user"] save];
}


+ (void) deleteAllNotesForModule:(NSString *)moduleName {
    
    NSArray* notes = [[DataManager instanceNamed:@"user"] fetchDataForEntityName:@"Note" withPredicate:[NSPredicate predicateWithFormat:@"page.module.name == %@", moduleName] sortedBy:nil];
    
    uint deleteCount = 0;
    
    for (Note* note in notes) {
        
        [UserDataManager deleteNote:note];
        ++deleteCount;
    }
    
    NSLog(@"Deleted %d notes.", deleteCount);
}


#pragma mark Misc

+ (void) save {
    
    [[DataManager instanceNamed:@"user"] save];
}


+ (void) printToFile {
    
    NSArray* modules = [[DataManager instanceNamed:@"user"] fetchDataForEntityName:@"Module" withPredicate:nil sortedBy:@"name", nil];
    
    for (Module* module in modules) {
        
        LogM(@"user_database", @"module=%@\n", module.name);
        
        NSArray* pages = [[DataManager instanceNamed:@"user"] fetchDataForEntityName:@"Page" withPredicate:[NSPredicate predicateWithFormat:@"module == %@", module] sortedBy:@"number", nil];
        
        for (Page* page in pages) {
        
            LogM(@"user_database", @"%@\t(learnStatus=%@, isFavorite=%@)\n", page.number, page.learnStatus, page.isFavorite);
            
        }
    }
    
    LogM_write(@"user_database");
}


//+ (void) createRandomNotesForModule:(NSString *)moduleName minCount:(uint)minCount maxCount:(uint)maxCount inRect:(CGRect)rect chanceForNotes:(float)chance {
//
//    NSLog(@"------------------- create random notes for module: %@ ---------------------", moduleName);
//    
////    [[PDFManager manager] loadModule:moduleName];
//    
//    NSArray* categories = [[PDFManager manager] categories];
//        
//    uint totalPages = 0;
//    uint totalNotes = 0;
//    
//    for (ContentsCategory* category in categories) {
//
//        NSLog(@"category: %@", category.name);
//        
//        for (uint p = [category.firstPageNumber intValue], c = 0; c < [category.numberOfPages intValue]; ++p, ++c) {
//            
//            for (uint d = 0; d <= 2; ++d) {
//            
//                float chanceRoll = (arc4random() % 100 + 1) / 100.0f;
//                if (chanceRoll >= chance) continue;
//                
//                uint count = randomIntegerFromTo(minCount, maxCount);
//                
//                NSLog(@"page=%d, count=%d", p, count);
//                
//                Page* page = [UserDataManager fetchOrCreatePageForModule:moduleName category:category.name pageNumber:p];
//                
//                for (int i = 0; i < count; ++i) {
//                    
//                    uint posX = randomIntegerFromTo(rect.origin.x, rect.origin.x + rect.size.width);
//                    uint posY = randomIntegerFromTo(rect.origin.y, rect.origin.y + rect.size.height);
//                    NSString* text = [[PDFManager manager] randomStringFromSearchIndexWithNumberOfSentencesFrom:1 to:7 wordCountPerSentenceFrom:1 to:15];
//                    
//                    Note* note = [UserDataManager createNoteForPage:page documentType:d];
//                    note.positionX = [NSNumber numberWithInt:posX];
//                    note.positionY = [NSNumber numberWithInt:posY];
//                    note.text = text;
//                    
//                    NSLog(@"\tnote posX=%d, posY=%d", posX, posY);
//                }
//                
//                ++totalPages;
//                totalNotes += count;
//            }
//        }
//    }
//    
//    NSLog(@"total pages: %d, total notes: %d", totalPages, totalNotes);
//}




@end


























