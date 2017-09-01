//
//  ResourceManager.m
//  KlettAbiLernboxen
//
//  Created by Wang on 09.11.12.
//
//

#import "ResourceManager.h"
#import "UIColor+Extensions.h"



@implementation ResourceManager

- (id) init {
    
    if (self = [super init]) {
        
        _resourceDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"resources" ofType:@"plist"]];
    }
    
    return self;
}


+ (ResourceManager*) instance {
    
    static ResourceManager* _instance;
    
    @synchronized(self) {
        
        if (!_instance) {
            
            _instance = [[ResourceManager alloc] init];
        }
    }
    
    return _instance;
}


- (id) resourceForKeyPath:(NSString *)keyPath {
 
    NSString* pathType = [[keyPath componentsSeparatedByString:@"."] objectAtIndex:0];
    id value = [_resourceDict valueForKeyPath:keyPath];

    if (value) {
    
        /* Images (UIImage) */
        if ([pathType isEqualToString:@"Images"]) {
            
            NSString* fileName = (NSString*)value;
            
            [self checkFileName:fileName];
            
            return [UIImage imageNamed:fileName];
        }
        /* Fonts (UIFont) */
        else if ([pathType isEqualToString:@"Fonts"]) {
            
            NSString* suffixType = [[keyPath componentsSeparatedByString:@"."] lastObject];
            
            if ([suffixType isEqualToString:@"Font"]) {

                NSDictionary* dict = (NSDictionary*)value;
                NSString* fontName = [dict objectForKey:@"fontname"];
                NSNumber* fontSize = [dict objectForKey:@"fontsize"];
                NSNumber* scaleFactor = [dict objectForKey:@"scalefactor"];
                if (!scaleFactor) scaleFactor = [NSNumber numberWithInt:1];
                
                NSLog(@"scalefactor: %@", scaleFactor);
                
                float size = (is_ipad) ? [scaleFactor floatValue] * [fontSize floatValue] : [fontSize floatValue];
                
                return [UIFont fontWithName:fontName size:size];
            }
            else if (([suffixType isEqualToString:@"Color"])) {

                NSString* colorString = (NSString*)value;
                
                return [UIColor colorFromString:colorString];
            }
            else {

                alert(@"[ResourceManager] Resource not found: %@", value);
                
                return nil;
            }
        }
        else if ([pathType isEqualToString:@"Arrays"]) {
            
            NSArray* array = (NSArray*)value;
            
            return array;
        }
        else if ([pathType isEqualToString:@"Dictionaries"]) {
            
            NSDictionary* dict = (NSDictionary*)value;
            
            return dict;
        }
        else {
            
            alert(@"[ResourceManager] Resource not found: %@", value);
            
            return nil;
        }
    }
    else {

        alert(@"[ResourceManager] KeyPath not found: %@", keyPath);
    
        return nil;
    }
}


- (void) checkFileName:(NSString*) fileName {
    
    if (!fileName || ![[NSFileManager defaultManager] fileExistsAtPath:[[NSBundle mainBundle] pathForResource:fileName ofType:nil]]) {
        
        alert(@"[ResourceManager] File not found: %@", fileName);
    }
}

@end
