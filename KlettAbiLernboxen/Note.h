//
//  Note.h
//  KlettAbiLernboxen
//
//  Created by Wang on 21.09.12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Page;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSNumber * documentType;
@property (nonatomic, retain) NSNumber * isOpen;
@property (nonatomic, retain) NSNumber * positionX;
@property (nonatomic, retain) NSNumber * positionY;
@property (nonatomic, retain) NSNumber * scale;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Page *page;

@end
