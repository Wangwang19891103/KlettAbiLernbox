//
//  TableCells.h
//  KlettAbiLernboxen
//
//  Created by Wang on 20.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserDataManager.h"


@interface CardCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView* cardImageView;

@property (nonatomic, strong) IBOutlet UILabel* pageNumberLabel;

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, strong) IBOutlet UIImageView* learnStatusImageView;

@property (nonatomic, strong) IBOutlet UIImageView* backgroundImageView;


@property (nonatomic, copy) NSString* title;
@property (nonatomic, assign) uint pageNumber;
@property (nonatomic, assign) BOOL isFavorite;
@property (nonatomic, assign) uint learnStatus;


//- (id) initWithLearnStatus:(PageLearnStatus) learnStatus isFavorite:(BOOL) isFavorite;

- (void) setCellSelected:(BOOL)selected;

@end


@interface CardResultCell : CardCell

@property (nonatomic, strong) IBOutlet UILabel* hitsLabel;

@property (nonatomic, assign) uint hits;

@end



@interface CardCell2 : UITableViewCell

@property (nonatomic, assign) BOOL isFavorite;

@property (nonatomic, assign) PageLearnStatus learnStatus;

@property (nonatomic, assign) uint pageNumber;

@property (nonatomic, copy) NSString* title;

@end


@interface CategoryCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, strong) IBOutlet UILabel* countLabel;

@property (nonatomic, strong) IBOutlet UIImageView* backgroundImageView;

@property (nonatomic, strong) IBOutlet UIImageView* learningProgressBarImageView;

@property (nonatomic, strong) IBOutlet UILabel* learningProgressLabel;


- (void) setCellSelected:(BOOL)selected;

@end


@interface CategoryResultCell : CategoryCell

@property (nonatomic, strong) IBOutlet UILabel* hitsLabel;
@property (nonatomic, strong) IBOutlet UILabel* pageHitsLabel;

@end


@interface NoteCell : CardCell

@property (nonatomic, strong) IBOutlet UILabel* noteTextLabel;

@property (nonatomic, copy) NSString* noteText;

@end



@interface InfoCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, strong) IBOutlet UIImageView* backgroundImageView;


@property (nonatomic, copy) NSString* title;

@end
