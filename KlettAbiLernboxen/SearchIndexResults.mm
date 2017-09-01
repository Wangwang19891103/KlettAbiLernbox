//
//  SearchIndexResult.m
//  KlettAbiLernboxen
//
//  Created by Wang on 04.09.12.
//
//

#import "SearchIndexResults.h"
#import "NSArray+Extensions.h"

#include <ext/hash_map>



typedef __gnu_cxx::hash_map<int,int> HashMap;



@implementation SearchIndexResults


#pragma mark - Initializers

- (id) init {
    
    if (self = [super init]) {
        
        _strings = [NSMutableSet set];
        _pageDict = nil;
    }
    
    return self;
}



#pragma mark - Public Methods

- (void) addNodeArray:(NSArray*)nodeArray includeChildNodes:(BOOL)includeChildNodes {

    HashMap map;

    for (SearchIndexNode* node in nodeArray) {
    
        /* check if string is already in results */
        if ([_strings containsObject:node.string]) {
            
            return;
        }
        
//        NSLog(@"SearchIndexResults addNode string=%@", node.string);
        
        /* add string to strings set */
        [_strings addObject:node.string];
        
        
        /* union pages in page array of node with child nodes */
        
        [self unionPageDictsForNode:node intoHashMap:&map includeChildNodes:includeChildNodes];
    }

    NSMutableDictionary* unionedPageDict = [NSMutableDictionary dictionary];
    
    for (HashMap::iterator it = map.begin(); it != map.end(); it++) {
        
//        NSLog(@"key=%d, value=%d", it->first, it->second);
        
        [unionedPageDict setObject:[NSNumber numberWithInt:it->second] forKey:[NSNumber numberWithInt:it->first]];
    }

//    NSLog(@"unionedPageDict: %@", unionedPageDict);
    
    
    /* intersect union'ed node page dict with results page dict */
    _pageDict = [self intersectBaseDictionary:_pageDict withDictionary:unionedPageDict];
    
//    NSLog(@"pageDict: %@", _pageDict);
}


- (NSArray*) strings {

    return _strings.allObjects;
}


- (NSArray*) pageNumbersForAllStrings {
    
    return [_pageDict allKeys];
}


- (uint) hitCountForPageNumber:(NSNumber *)thePageNumber {
    
    return [[_pageDict objectForKey:thePageNumber] intValue];
}


- (NSDictionary*) pageDict {
    
    return _pageDict;
}



#pragma mark - Private Methods

- (void) unionPageDictsForNode:(SearchIndexNode*) node intoHashMap:(HashMap*) map includeChildNodes:(BOOL) includeChildNodes {

//    NSLog(@"unionPageDictsForNode string=%@", node.string);
    
//    /* check if string is already in results */
//    if ([_strings containsObject:node.string]) {
//        
//        return;
//    }
    
    /* add string to strings set */
    [_strings addObject:node.string];

    
    
    for (NSNumber* key in node.pageDict.allKeys) {

//        NSLog(@"key=%@, value=%@", key, [node.pageDict objectForKey:key]);
        
        (*map)[[key intValue]] += [[node.pageDict objectForKey:key] intValue];
    }
    
    if (includeChildNodes && [node.childNodes count] != 0) {

        for (NSString* childKey in node.childNodes.allKeys) {
            
            SearchIndexNode* childNode = [node.childNodes objectForKey:childKey];
            
//            NSLog(@"childkey: %@", childKey);
            
            if ([_strings containsObject:childNode]) {
                continue;
            }
            
            [self unionPageDictsForNode:childNode intoHashMap:map includeChildNodes:includeChildNodes];
        }
    }
    
    for (HashMap::iterator it = map->begin(); it != map->end(); ++it) {
        
//        NSLog(@"lala key=%d", it->first);
    }
}


- (NSDictionary*) intersectBaseDictionary:(NSDictionary*) dict1 withDictionary:(NSDictionary*) dict2 {

    if (!dict1) {
        
        return dict2;
    }
    
    NSMutableDictionary* resultDict = [NSMutableDictionary dictionary];
    
    for (NSNumber* key in dict1) {

        NSNumber* hitCount2 = [dict2 objectForKey:key];
        
        if (hitCount2) {
            
            NSNumber* hitCount1 = [dict1 objectForKey:key];
            [resultDict setObject:[NSNumber numberWithInt:([hitCount1 intValue] + [hitCount2 intValue])] forKey:key];
        }
    }
    
    return resultDict;
}


@end
