//
//  UIView+Extensions.h
//  Sprachenraetsel
//
//  Created by Stefan Ueter on 15.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (Frame_Setters) 

// Setters

- (void) setFrameX:(float) theX;
- (void) setFrameY:(float) theY;
- (void) setFrameWidth:(float) theWidth;
- (void) setFrameHeight:(float) theHeight;

- (void) setFrameSize:(CGSize) theSize;
- (void) setFrameOrigin:(CGPoint) theOrigin;

// Center Methods

- (void) centerXInSuperview;
- (void) centerYInSuperview;
- (void) centerOverPoint:(CGPoint) point;

// Scaling Methods

- (void) scaleToWidth:(int) theWidth withUpScale:(BOOL) upScale;
- (void) scaleToHeight:(int) theHeight withUpScale:(BOOL) upScale;
- (void) scaleToSize:(CGSize) theSize withUpScale:(BOOL) upScale;

// Misc Methods

- (UIView*) parentViewOfClass:(Class) theClass;
- (UIImage*) captureImage;

//+ (void) replaceView:(UIView**) oldView inSuperviewWithView:(UIView*) newView centering:(BOOL) centering withStrongReference:(BOOL) strong;

@end
