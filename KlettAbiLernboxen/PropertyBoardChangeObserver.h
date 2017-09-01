//
//  PropertyBoardChangeObserver.h
//  KlettAbiLernboxen
//
//  Created by Wang on 15.10.12.
//
//

#import <Foundation/Foundation.h>


@protocol PropertyBoardChangeObserver

@optional

- (void) propertyChangedForObject:(id) object withKeyPath:(NSString*) keyPath;

- (void) propertyDictionaryDidChange;

- (void) variableValueChangedForName:(NSString*) name;

- (void) variableDictionaryDidChange;

@end
