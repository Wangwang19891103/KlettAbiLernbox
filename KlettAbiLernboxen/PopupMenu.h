//
//  PopupMenu.h
//  KlettAbiLernboxen
//
//  Created by Wang on 21.11.12.
//
//

#import <UIKit/UIKit.h>
#import "PopupMenuDelegate.h"


@interface PopupMenu : UIView <PropertyBoardChangeObserver> {
    
}

@property (nonatomic, assign) id<PopupMenuDelegate> delegate;

@property (nonatomic, strong) UIButton* favoriteButton;

@property (nonatomic, strong) UIButton*  checkButton;

@property (nonatomic, strong) UIButton*  crossButton;

@property (nonatomic, strong) UIButton*  showNotesButton;

@property (nonatomic, strong) UIButton*  addNoteButton;

@property (nonatomic, strong) UIButton* fullscreenButton;


- (void) handleButtonTouched:(id) sender;

- (void) layout;

- (void) setFavorite:(BOOL) isFavorite;

@end
