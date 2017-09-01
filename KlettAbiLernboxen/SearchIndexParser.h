//
//  SearchIndexParser.h
//  KlettAbiLernboxen
//
//  Created by Wang on 04.09.12.
//
//

#import <Foundation/Foundation.h>
#import "SearchIndexNode.h"


@interface SearchIndexParser : NSObject  {
    
    NSString* __strong _string;
    uint _cursor;
//    NSString* _currentToken;
    
    NSMutableData* _data;
    
    unsigned char* _buffer;
    uint _bufferLength;
    unsigned char _currentToken;
    BOOL _shouldRun;
    SearchIndexNode* _rootNode;
//    NSFileHandle* __strong _fileHandle;
}


//- (id) initWithString:(NSString*) theString;

//- (id) initWithPath:(NSString*) path;

- (id) initWithData:(NSData*) data;

- (SearchIndexNode*) rootNodeFromSerializedString:(NSString*) theString;

- (SearchIndexNode*) rootNode;

@end
