//
//  StatisticsViewController.h
//  KlettAbiLernboxen
//
//  Created by Wang on 16.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol TickerDelegate

- (void) tickerDidTickWithTickNumber:(uint) tickNumber;

@end


@class Ticker;


@interface StatisticsViewController : UIViewController  <TickerDelegate> {
    
    NSMutableArray* __strong _images;
}

- (void) resetImages;

@end





@interface StatisticsImage : UIView{
    
    NSString* __strong _title;
    float _greenDegrees;
    float _whiteDegrees;
    float _redDegrees;
    CGSize _size;
}

@property (nonatomic, assign) uint progressDegrees;
@property (nonatomic, assign) uint progressDistance;


- (id) initWithTitle:(NSString*) title red:(float) red green:(float) green size:(CGSize) size;

+ (UIImage*) createImageWithGreen:(float) green red:(float) red size:(CGSize) size;



@end






@interface Ticker : NSObject {
    
    uint _numberOfTicks;
    float _intervalLength;
    NSTimer* __strong _timer;
    uint _tickNumber;
}

@property (nonatomic, assign) id<TickerDelegate> delegate;

- (id) initWithTicks:(uint) ticks intervalLength:(float) intervalLength;

- (void) start;

- (void) tick;

- (void) stop;

@end
