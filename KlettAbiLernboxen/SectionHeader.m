//
//  SectionHeader.m
//  KlettAbiLernboxen
//
//  Created by Wang on 12.11.12.
//
//

#import "SectionHeader.h"

@implementation SectionHeader

@synthesize backgroundImage;
@synthesize titleLabel;
@synthesize zigzagImage;
- (id) init {
    
    if ((self = [[[NSBundle mainBundle] loadNibNamed:@"SectionHeader" owner:nil options:nil] objectAtIndex:0])) {
        
    }
    
    return self;
}


- (id) copyWithZone:(NSZone *)zone {
    
    SectionHeader* newHeader = [[SectionHeader alloc] init];
    newHeader.backgroundImage.image = self.backgroundImage.image;
    newHeader.titleLabel.text = [self.titleLabel.text copy];
    newHeader.zigzagImage.image = self.zigzagImage.image;
    
    return newHeader;
}

@end
