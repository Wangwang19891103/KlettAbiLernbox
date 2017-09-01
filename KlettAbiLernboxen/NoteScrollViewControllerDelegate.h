//
//  NoteScrollViewControllerDelegate.h
//  KlettAbiLernboxen
//
//  Created by Wang on 22.11.12.
//
//

#import <Foundation/Foundation.h>


@class NoteScrollViewController;


@protocol NoteScrollViewControllerDelegate <NSObject>

- (BOOL) noteScrollViewControllerShouldCreateNote:(NoteScrollViewController*) controller;

- (void) NoteScrollViewControllerDidCreateNote:(NoteScrollViewController*) controller;

- (BOOL) NoteScrollViewControllerShouldShowNotes:(NoteScrollViewController*) controller;

- (void) noteScrollViewControllerDidBeginEditMode:(NoteScrollViewController*) controller;

- (void) noteScrollViewControllerWillEndEditMode:(NoteScrollViewController*) controller;

@end
