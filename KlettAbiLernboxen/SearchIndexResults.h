//
//  SearchIndexResult.h
//  KlettAbiLernboxen
//
//  Created by Wang on 04.09.12.
//
//

#import <Foundation/Foundation.h>
#import "SearchIndexNode.h"


@interface SearchIndexResults : NSObject {
    
    NSMutableSet* _strings;
    NSDictionary* _pageDict;
}


- (void) addNodeArray:(NSArray*) nodeArray includeChildNodes:(BOOL) includeChildNodes;

- (NSArray*) strings;

- (NSArray*) pageNumbersForAllStrings;

- (uint) hitCountForPageNumber:(NSNumber*) thePageNumber;

- (NSDictionary*) pageDict;

@end
