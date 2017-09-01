//
//  DownloadButton.h
//  KlettAbiLernboxen
//
//  Created by Wang on 14.11.12.
//
//

#import <Foundation/Foundation.h>

@interface DownloadButtonImage : NSObject

+ (UIImage*) imageWithProgress:(float) progress  buttonName:(NSString*) buttonName;

+ (UIImage*) shopImageWithProgress:(float) progress  buttonName:(NSString*) buttonName;

@end
