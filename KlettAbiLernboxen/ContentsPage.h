//
//  ContentsPage.h
//  KlettAbiLernboxen
//
//  Created by Wang on 21.09.12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ContentsCategory, ContentsSubcategory;

@interface ContentsPage : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSNumber * actualPageNumber;
@property (nonatomic, retain) ContentsCategory *category;
@property (nonatomic, retain) ContentsSubcategory *subcategory;

@end
