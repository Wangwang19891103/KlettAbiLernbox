//
//  IndexedPage.h
//  KlettAbiLernboxen
//
//  Created by Wang on 28.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface IndexedPage : NSManagedObject

@property (nonatomic, retain) NSString * moduleName;
@property (nonatomic, retain) NSNumber * documentType;
@property (nonatomic, retain) NSNumber * pageNumber;
@property (nonatomic, retain) NSString * text;

@end
