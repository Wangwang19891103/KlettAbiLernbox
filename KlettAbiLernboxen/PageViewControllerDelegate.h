//
//  PageViewControllerDelegate.h
//  KlettAbiLernboxen
//
//  Created by Wang on 22.11.12.
//
//

#import <Foundation/Foundation.h>

@class PageViewController;


@protocol PageViewControllerDelegate

- (BOOL) pageViewControllerShouldCreateNote:(PageViewController*) controller;

- (void) pageViewControllerDidCreateNote:(PageViewController*) controller;

- (BOOL) pageViewControllerShouldShowNotes:(PageViewController*) controller;

- (void) noteScrollViewControllerDidBeginEditMode:(NoteScrollViewController*) controller;

- (void) noteScrollViewControllerWillEndEditMode:(NoteScrollViewController*) controller;

- (CGFloat) bottomHeight;


@end
