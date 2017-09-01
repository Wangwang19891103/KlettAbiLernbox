//
//  ThumbnailBarDelegate.h
//  KlettAbiLernboxen
//
//  Created by Wang on 20.11.12.
//
//

#import <Foundation/Foundation.h>

@protocol ThumbnailBarDelegate

- (void) thumbnailWasSelectedForPage:(uint) page;

- (void) thumbnailWillBeginDragging;
- (void) thumbnailDidEndDragging;
- (void) thumbnailDidHitPageNumber:(uint) pageNumber;

@end
