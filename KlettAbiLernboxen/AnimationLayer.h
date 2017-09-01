//
//  AnimationLayer.h
//  KlettAbiLernboxen
//
//  Created by Wang on 11.10.12.
//
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@interface AnimationLayer : CALayer

@property (nonatomic, strong) NSNumber* progress;

@property (nonatomic, assign) CGImageRef imageBuffer;

@property (nonatomic, assign) int bufferedFrameIndex;

@property (nonatomic, assign) uint numberOfFrames;


- (id) initWithFrame:(CGRect) theFrame;

- (void) animateWithDuration:(float) duration;

- (void) drawInContext:(CGContextRef) context forFrame:(uint) frame;


@end
