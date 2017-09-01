//
//  PDFView.h
//  KlettAbiLernboxen
//
//  Created by Wang on 04.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PropertyBoardChangeObserver.h"


@interface PDFView : UIView <PropertyBoardChangeObserver> {
    
    UIImage* _backgroundImage;
    CGColorRef _patternColor;
}

@property (nonatomic, assign) CGPDFPageRef pageRef;

@property (nonatomic, assign) uint documentType;

@property (nonatomic, assign) uint pageNumber; // 1-based

@property (nonatomic, copy) NSArray* keywords;

@property (nonatomic, strong) NSMutableArray* selections;


- (id) initWithPage:(CGPDFPageRef) pageRef;



@end
