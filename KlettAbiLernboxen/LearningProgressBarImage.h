//
//  LearningProgressBarImage.h
//  KlettAbiLernboxen
//
//  Created by Wang on 14.11.12.
//
//

#import <Foundation/Foundation.h>

@interface LearningProgressBarImage : NSObject

+ (UIImage*) imageWithProgress:(float) progress size:(CGSize) size;

+ (UIImage*) imageWithProgressNumber:(float) progress totalNumber:(float) total size:(CGSize) size;

+ (UIImage*) imageWithProgressNumber:(float) progress progress2:(float) progress2 totalNumber:(float) total size:(CGSize) size;

@end
