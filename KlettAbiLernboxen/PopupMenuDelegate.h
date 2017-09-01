//
//  PopupMenuDelegate.h
//  KlettAbiLernboxen
//
//  Created by Wang on 21.11.12.
//
//

#import <Foundation/Foundation.h>

@protocol PopupMenuDelegate <NSObject>

- (void) popupMenuFavoriteButtonWasTouchedSelected:(BOOL) selected;
- (void) popupMenuCheckButtonWasTouchedSelected:(BOOL) selected;
- (void) popupMenuCrossButtonWasTouchedSelected:(BOOL) selected;
- (void) popupMenuShowNotesButtonWasTouchedSelected:(BOOL) selected;
- (void) popupMenuAddNoteButtonWasTouchedSelected:(BOOL) selected;
- (void) popupMenuFullscreenButtonWasTouchedSelected:(BOOL) selected;

@end
