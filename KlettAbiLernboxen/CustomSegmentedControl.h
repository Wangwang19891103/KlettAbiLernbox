//
//  CustomSegmentedControl.h
//  KlettAbiLernboxen
//
//  Created by Wang on 18.11.12.
//
//

#import <UIKit/UIKit.h>
#import "PropertyBoard.h"


@interface CustomSegmentedControl : UIView <PropertyBoardChangeObserver> {
    
    id _valueChangedTarget;
    SEL _valueChangedSelector;
}

@property (nonatomic, assign) uint selectedIndex;

@property (nonatomic, strong) NSArray* titles;

- (void) setValueChangedSelector:(SEL) selector onTarget:(id) target;

- (void) handleTap:(UIGestureRecognizer*) recognizer;

@end
