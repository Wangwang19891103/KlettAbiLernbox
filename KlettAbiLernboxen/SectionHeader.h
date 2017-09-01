//
//  SectionHeader.h
//  KlettAbiLernboxen
//
//  Created by Wang on 12.11.12.
//
//

#import <Foundation/Foundation.h>

@interface SectionHeader : UIView <NSCopying>

@property (nonatomic, strong) IBOutlet UIImageView* backgroundImage;

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, strong) IBOutlet UIImageView* zigzagImage;

@end
