//
//  Thumbnail.h
//  KlettAbiLernboxen
//
//  Created by Wang on 20.11.12.
//
//

#import <UIKit/UIKit.h>

@interface Thumbnail : UIView {
    
    UIImage* __strong _image;
    UIColor* __strong _blendColor;
}

@property (nonatomic, assign) uint position;
@property (nonatomic, assign) int leftX;
@property (nonatomic, assign) int middleX;
@property (nonatomic, assign) int rightX;
@property (nonatomic, assign) BOOL selected;

- (id) initWithImage:(UIImage*) image blendColor:(UIColor*) color;

@end
