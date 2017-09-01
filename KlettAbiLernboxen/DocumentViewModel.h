//
//  DocumentViewModel.h
//  KlettAbiLernboxen
//
//  Created by Wang on 17.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PageViewModel.h"


@class DocumentViewModel;


@protocol DocumentViewModelDelegate

- (void) documentViewModelDidFinishLoading:(DocumentViewModel*) model;

@end


@interface DocumentViewModel : NSObject

@property (nonatomic, assign) id<DocumentViewModelDelegate> delegate;

@property (nonatomic, copy) NSString* category;

@property (nonatomic, assign) NSRange pageRange;

//@property (nonatomic, strong) NSArray* titles;

@property (nonatomic, strong) NSDictionary* pages;

@property (nonatomic, strong) NSArray* thumbnails;

//@property (nonatomic, strong) NSDictionary* notes;
//
//@property (nonatomic, strong) NSSet* favorites;
//
//@property (nonatomic, strong) NSArray* learnStatus;

- (id) initWithCategory:(NSString*) categoryName;

- (void) initialize;

- (PageViewModel*) pageViewModelForPageNumber:(uint) number;


- (BOOL) isFavoriteForRelativePageNumber:(uint) pageNumber;

- (uint) learnStatusForRelativePageNumber:(uint) pageNumber;


@end
