//
//  SearchIndex.m
//  KlettAbiLernboxen
//
//  Created by Wang on 03.09.12.
//
//

#import "SearchIndex.h"
#import "NSArray+Extensions.h"
#import "SearchIndexParser.h"
#import "SearchIndexResults.h"



#define Minimum_Search_String_Length 3



@implementation SearchIndex

- (id) init {
    
    if (self = [super init]) {
        
        _rootNode = [[SearchIndexNode alloc] init];
    }
    
    return self;
}


//- (id) initFromSerializedString:(NSString *)theString {
//    
//    if (self = [super init]) {
//        
//        SearchIndexParser* parser = [[SearchIndexParser alloc] initWithString:theString];
//        _rootNode = [parser rootNodeFromSerializedString:theString];
//    }
//    
//    return self;
//}


- (id) initWithContentsOfFile:(NSString *)path {
    
    if (self = [super init]) {
        
        NSData* fileData = [NSData dataWithContentsOfFile:path];
        SearchIndexParser* parser = [[SearchIndexParser alloc] initWithData:fileData];
        _rootNode = [parser rootNode];
    }
    
    return self;
}


- (void) insertString:(NSString *)theString withPageDict:(NSDictionary *)pageDict {

//    NSLog(@"inserting \"%@\"", theString);
    
    
    SearchIndexNode* currentNode = _rootNode;
    SearchIndexNode* parentNode = nil;
    
    while (currentNode) {
        
        parentNode = currentNode;
        currentNode = [currentNode nextNodeForString:theString];
    }
    
    // do what happens when no further node has been found
    
    // add new node with string to be inserted into parentNode // move relevant child nodes to new node
    
    [parentNode addNodeWithString:theString pageDict:pageDict];

//    NSLog(@"inserted \"%@\" under \"%@\"", theString, parentNode.string);
}

/* returns the node (if exact match found) or nodes (beginning with search string) __ WITHOUT child nodes */
- (NSArray*) searchString:(NSString *)theString {
    
//    NSLog(@"searching \"%@\"", theString);
    
    
    SearchIndexNode* currentNode = _rootNode;
    SearchIndexNode* parentNode = nil;
    NSMutableArray* resultArray = [NSMutableArray array];
    
    while (currentNode) {
        
        parentNode = currentNode;
        currentNode = [currentNode nextNodeForString:theString];
        
//        NSLog(@"passing node: \"%@\"", parentNode.string);
    }

    /* if last found node is EQUAL to search string return childnods from that node downwards */
    if ([parentNode.string isEqualToString:theString]) {

        [resultArray addObject:parentNode];
//        [parentNode addNodeAndChildNodesToArray:resultArray];
    }
    /* else search keys of found node which begin with the search string and return childnodes from those (multiple) nodes downwards */
    else {
        
        for (NSString* key in parentNode.childNodes.allKeys) {
            
            if (key.length >= theString.length && [[key substringToIndex:theString.length] isEqualToString:theString]) {
                
                SearchIndexNode* node = [parentNode.childNodes objectForKey:key];

                [resultArray addObject:node];
//                [node addNodeAndChildNodesToArray:resultArray];
            }
        }
    }
    
    
    return resultArray;
}


- (SearchIndexResults*) searchResultsForStrings:(NSArray *)theStrings {
    
//    timer_start(@"SearchIndex_searchResultsForStrings");
    
    SearchIndexResults* results = [[SearchIndexResults alloc] init];
    
    for (NSString* string in theStrings) {
        
        if (string.length < Minimum_Search_String_Length) {
            
            continue;
        }
        
        NSArray* array = [self searchString:string];

//        NSLog(@"SearchIndex searchResultsForStrings: %@", theStrings);
//        NSLog(@"results:\n%@", array);
        
        [results addNodeArray:array includeChildNodes:YES];
    }
    
//    timer_add(@"SearchIndex_searchResultsForStrings");
    
//    counter_printall;
//    counter_removeAll;
    
    return results;
}


- (NSString*) description {

    NSString* returnString = [NSString stringWithFormat:@"SearchIndex: (\n%@)", [_rootNode description]];
    
    return returnString;
}


- (NSString*) serializeToString {

    NSMutableArray* resultArray = [NSMutableArray arrayWithCapacity:_rootNode.childNodes.count];
    
    uint rootChildCount = _rootNode.childNodes.count;
    uint counter = 0;
    uint stepWidth = 5;
    uint nextStep = 0;

    
    for (SearchIndexNode* node in _rootNode.childNodes.objectEnumerator) {
        
        [resultArray addObject:[node serializeToString]];
        
        if (floor((float)counter / rootChildCount) == nextStep) {
            
            NSLog(@"%d percent done...", nextStep);
            
            nextStep += stepWidth;
        }
        
        ++counter;
    }
    
    NSLog(@"SearchIndex: done serializing.");
    
    return [resultArray componentsJoinedByString:@","];
}


- (NSString*) randomString {
    
    uint index = arc4random() % _rootNode.childNodes.count;
    
    return [_rootNode.childNodes.allKeys objectAtIndex:index];
}

@end























