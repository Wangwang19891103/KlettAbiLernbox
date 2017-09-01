//
//  SearchIndex.h
//  KlettAbiLernboxen
//
//  Created by Wang on 03.09.12.
//
//

#import <Foundation/Foundation.h>
#import "SearchIndexResults.h"

@class SearchIndexNode;


@interface SearchIndex : NSObject {

    SearchIndexNode* _rootNode;
}

//- (id) initFromSerializedString:(NSString*) theString;

- (id) initWithContentsOfFile:(NSString*) path;

- (void) insertString:(NSString*) theString withPageDict:(NSDictionary*) pageDict;

- (NSArray*) searchString:(NSString*) theString;

- (NSString*) description;

- (NSString*) serializeToString;

- (void) parseSerializedString:(NSString*) theString;

- (SearchIndexResults*) searchResultsForStrings:(NSArray*) theStrings;

- (NSString*) randomString;

@end









