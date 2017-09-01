//
//  AnimationLayer.m
//  KlettAbiLernboxen
//
//  Created by Wang on 11.10.12.
//
//

#import "AnimationLayer.h"


@implementation AnimationLayer

@synthesize progress;
@synthesize imageBuffer;
@synthesize bufferedFrameIndex;
@synthesize numberOfFrames;


- (id) initWithFrame:(CGRect) theFrame {
    
    if (self = [super init]) {
        
        self.frame = theFrame;
        self.progress = [NSNumber numberWithFloat:0.0f];
        self.bufferedFrameIndex = -1;
        self.numberOfFrames = 0;
    }
    
    return self;
}


- (id) initWithLayer:(id)layer {
    
    if (self = [super initWithLayer:layer]) {
        
        self.numberOfFrames = ((AnimationLayer*)layer).numberOfFrames;
    }
    
    return self;
}


- (void) animateWithDuration:(float)duration {
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"progress"];
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat:1.0f];
    animation.duration = duration;
    animation.removedOnCompletion = TRUE;
    animation.autoreverses = self.autoreverses;
    animation.repeatCount = self.repeatCount;
    
    [self addAnimation:animation forKey:@"progress"];
}


- (void) setProgress:(NSNumber *)theProgress {
    
    progress = theProgress;
    
    if ([self modelLayer] && [self modelLayer] != self) {

        ((AnimationLayer*)[self modelLayer]).progress = theProgress;
    }
}


+ (BOOL) needsDisplayForKey:(NSString *)key {
    
    if ([key isEqualToString:@"progress"])
        return TRUE;
    
    else
        return [super needsDisplayForKey:key];
}


- (void) drawInContext:(CGContextRef)context {
    
    AnimationLayer* modelLayer = ([self modelLayer]) ? [self modelLayer] : self;
    
    int currentFrameIndex = floor((modelLayer.numberOfFrames + 1) * [modelLayer.progress floatValue]);
    /* numberOfFrames + 1 so that the last frame index will be reached */
    
//    NSLog(@"currentFrameIndex: %d (numberOfFrames: %d)", currentFrameIndex, modelLayer.numberOfFrames);
    
    if (currentFrameIndex != modelLayer.bufferedFrameIndex) {
        
        modelLayer.bufferedFrameIndex = currentFrameIndex;
        
        if (modelLayer.imageBuffer) {
            CGImageRelease(modelLayer.imageBuffer);
        }
        
        modelLayer.imageBuffer = [self renderFrame:currentFrameIndex];
    }
    
    CGContextSaveGState(context);
    
    CGContextDrawImage(context, self.bounds, modelLayer.imageBuffer);
    
    CGContextRestoreGState(context);
    
}


- (CGImageRef) renderFrame:(uint) frame {
    
    uint width = self.bounds.size.width;
    uint height = self.bounds.size.height;
    uint numberOfComponents = 4;
    uint bitsPerComponent = 8;
    uint bitsPerPixel = bitsPerComponent * numberOfComponents;
    uint bytesPerRow = (width * bitsPerComponent * numberOfComponents * bitsPerPixel + 7) / 8;
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    
    uint dataSize = bytesPerRow * height;
    unsigned char *data = malloc(dataSize);
    memset(data, 0, dataSize);
    
    CGContextRef context = CGBitmapContextCreate(data, width, height, bitsPerComponent, bytesPerRow, CGColorSpaceCreateDeviceRGB(), bitmapInfo);

    [self drawInContext:context forFrame:frame];

    CGImageRef image = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    free(data);
    
    return image;
}


- (void) drawInContext:(CGContextRef)context forFrame:(uint)frame {
    
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


#pragma mark - Dealloc

- (void) dealloc {
    
    if (imageBuffer) {
        CGImageRelease(imageBuffer);
    }
}


@end

