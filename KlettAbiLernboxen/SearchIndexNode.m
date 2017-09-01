//
//  SearchIndexNode.m
//  KlettAbiLernboxen
//
//  Created by Wang on 04.09.12.
//
//

#import "SearchIndexNode.h"
#import "NSArray+Extensions.h"
#import "SearchIndexResults.h"


@implementation SearchIndexNode

@synthesize string;
@synthesize childNodes;
@synthesize pageDict;


- (id) init {
    
    if (self = [super init]) {
        
        string = nil;
        childNodes = [NSMutableDictionary dictionary];
        pageDict = nil;
    }
    
    return self;
}


- (id) initWithString:(NSString *)theString pages:(NSDictionary *)thePageDict {
    
    if (self = [super init]) {
        
        string = theString;
        pageDict = thePageDict;
        childNodes = nil;
    }
    
    return self;
}


- (SearchIndexNode*) nextNodeForString:(NSString *)theString {
    
    //    NSLog(@"\"%@\" nextNodeForString", self.string);
    
    // find the key that shares x beginning characters with theString
    
    for (int i = string.length + 1; i <= theString.length; ++i) {
        
        NSString* substring = [theString substringToIndex:i];
        
        //        NSLog(@"testing substring: %@", substring);
        
        if ([childNodes.allKeys containsObject:substring]) {
            
            return [childNodes objectForKey:substring];
        }
    }
    
    return nil;
}


- (void) addNodeWithString:(NSString *)theString pageDict:(NSDictionary *)thePageDict {
    
    // find all keys in childNotes that begin with theString
    
    NSMutableArray* relevantChildNotes = [NSMutableArray array];
    
    for (NSString* key in childNodes.allKeys) {
        
        if (key.length >= theString.length && [[key substringToIndex:theString.length] isEqualToString:theString]) {
            
            [relevantChildNotes addObject:[childNodes objectForKey:key]];
        }
    }
    
    SearchIndexNode* newNode = [[SearchIndexNode alloc] initWithString:theString pages:thePageDict];
    
    // insert relevant childNodes into new child node and remove them from own node
    
    [newNode addChildNodes:relevantChildNotes];
    
    for (SearchIndexNode* node in relevantChildNotes) {
        
//        [newNode.childNodes setObject:node forKey:node.string];
        [childNodes removeObjectForKey:node.string];
    }
    
    [childNodes setObject:newNode forKey:theString];
}


- (void) addChildNodes:(NSArray *)theChildNodes {
    
    if (!childNodes) {
        
        childNodes = [NSMutableDictionary dictionary];
    }
    
    for (SearchIndexNode* node in theChildNodes) {
        
        [childNodes setObject:node forKey:node.string];
    }
}


//- (void) addNodeAndChildNodesToArray:(NSMutableArray *)theArray {
//    
//    SearchIndexResults* result = [[SearchIndexResults alloc] initWithString:string pages:pageDict];
//    
//    [theArray addObject:result];
//    
//    for (SearchIndexNode* node in childNodes.objectEnumerator) {
//        
//        [node addNodeAndChildNodesToArray:theArray];
//    }
//}


- (NSString*) description {
    
//    NSMutableArray* resultArray = [NSMutableArray array];
    
    NSString* nodeString = [NSString stringWithFormat:@"SearchIndexNode (string = %@,"
                            "pageDict = %@"
                            ")", string, [pageDict serializeToString]];
    
//    [resultArray addObject:nodeString];
//    
//    for (SearchIndexNode* childNode in childNodes.objectEnumerator) {
//        
//        nodeString = [NSString stringWithFormat:@"SearchIndexNode (string = %@,"
//                                "pageDict = %@"
//                                ")", string, [pageDict serializeToString]];
//        
//        [resultArray addObject:nodeString];
//    }
    
//     "\tchildNodes = [\n", string, [pageDict serializeToString]];
//    
//    for (SearchIndexNode* node in childNodes.objectEnumerator) {
//        
//        nodeString = [nodeString stringByAppendingString:[node description]];
//    }
//    
//    nodeString = [nodeString stringByAppendingString:@"])\n"];
    
                            
    return nodeString;
}


- (NSString*) serializeToString {
    
    NSString* pageDictString = [pageDict serializeToString];
        
    
    if (childNodes && childNodes.count != 0) {
        
        NSString* childNodeString = [childNodes.allValues serializeToString];
        return [NSString stringWithFormat:@"[\"%@\",%@,%@]", string, pageDictString, childNodeString];
    }
    else {
        
        return [NSString stringWithFormat:@"[\"%@\",%@]", string, pageDictString];
    }
}


@end






@implementation NSDictionary (serializeToString)


- (NSString*) serializeToString {
    
    NSMutableArray* resultArray = [NSMutableArray arrayWithCapacity:self.count];
    
    for (NSNumber* key in self.allKeys) {
        
        [resultArray addObject:[NSString stringWithFormat:@"[%d=%d]", [key intValue], [[self objectForKey:key] intValue]]];
    }
    
    return [NSString stringWithFormat:@"[%@]", [resultArray componentsJoinedByString:@","]];
}

@end
