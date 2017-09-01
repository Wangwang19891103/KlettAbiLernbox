//
//  NSObject+ObjectName.m
//  KlettAbiLernboxen
//
//  Created by Stefan Ueter on 29.10.14.
//
//

#import "NSObject+ObjectName.h"
#import <objc/runtime.h>


@implementation NSObject (ObjectName)

@dynamic objectName;

NSString const *objectNameKey = @"NSObject.ObjectName.objectName";  // any unique key


- (void) setObjectName:(NSString *)p_objectName {
    
    objc_setAssociatedObject(self, &objectNameKey, p_objectName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


- (NSString*) objectName {
    
    return objc_getAssociatedObject(self, &objectNameKey);
}

@end
