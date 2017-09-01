//
//  PropertyBoardIntegerViewController.h
//  KlettAbiLernboxen
//
//  Created by Wang on 15.10.12.
//
//

#import <Foundation/Foundation.h>
#import "PropertyBoardChangeObserver.h"


@class PropertyBoardDraggableView;


@interface PropertyBoardIntegerViewController : UIViewController {
    
    NSIndexPath* _indexPath;
}

@property (nonatomic, strong) IBOutlet PropertyBoardDraggableView* contentView;


- (id) initWithPropertyIndexPath:(NSIndexPath*) indexPath;

- (IBAction) actionBack;




@end



@interface PropertyBoardDraggableView : UIView <PropertyBoardChangeObserver> {
    
    BOOL _isDragging;
}

@property (nonatomic, strong) IBOutlet UILabel* nameLabel;

@property (nonatomic, strong) IBOutlet UILabel* typeLabel;

@property (nonatomic, strong) IBOutlet UILabel* valueLabel;

@property (nonatomic, strong) IBOutlet UISlider* slider;

@property (nonatomic, strong) IBOutlet UIView* dragView;

//@property (nonatomic, weak) id object;
//
//@property (nonatomic, copy) NSString* keyPath;

@property (nonatomic, copy) NSString*variableName;


- (IBAction) handlePan:(UIGestureRecognizer*) recognizer;

- (IBAction) handleSliderValueChanged:(UISlider*) slider;

- (IBAction) increase;
- (IBAction) decrease;

- (IBAction) editingChanged;
- (IBAction) editingStarted;
- (IBAction) editingEnded;

@end
