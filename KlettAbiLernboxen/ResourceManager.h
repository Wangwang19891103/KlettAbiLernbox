//
//  ResourceManager.h
//  KlettAbiLernboxen
//
//  Created by Wang on 09.11.12.
//
//

#import <Foundation/Foundation.h>


#define resource(keyPath) [[ResourceManager instance] resourceForKeyPath:keyPath]


@interface ResourceManager : NSObject {
    
    NSDictionary* __strong _resourceDict;
}

+ (ResourceManager*) instance;

- (id) resourceForKeyPath:(NSString*) keyPath;

@end
