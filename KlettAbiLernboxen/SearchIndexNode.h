//
//  SearchIndexNode.h
//  KlettAbiLernboxen
//
//  Created by Wang on 04.09.12.
//
//

#import <Foundation/Foundation.h>


@interface SearchIndexNode : NSObject

@property (nonatomic, copy) NSString* string;

@property (nonatomic, strong) NSMutableDictionary* childNodes;

@property (nonatomic, strong) NSDictionary* pageDict;
/*
 * pageDict (dict)
 *     key = pageNumber (int)
 *     value = hitCount (int)
 */


- (id) initWithString:(NSString*) theString pages:(NSDictionary*) thePageDict;


- (SearchIndexNode*) nextNodeForString:(NSString*) theString;

- (void) addNodeWithString:(NSString*) theString pageDict:(NSDictionary*) pageDict;

- (void) addChildNodes:(NSArray*) childNodes;

- (void) addNodeAndChildNodesToArray:(NSMutableArray*) theArray;

- (NSString*) description;

- (NSString*) serializeToString;

@end



@interface NSDictionary (serializeToString)

- (NSString*) serializeToString;

@end
