//
//  PropertyBoardIntegerViewController.m
//  KlettAbiLernboxen
//
//  Created by Wang on 15.10.12.
//
//

#import "PropertyBoardIntegerViewController.h"
#import "PropertyBoard.h"
#import <QuartzCore/QuartzCore.h>


@implementation PropertyBoardIntegerViewController

@synthesize contentView;


- (id) initWithPropertyIndexPath:(NSIndexPath *)indexPath {
    
    if (self = [super initWithNibName:@"PropertyBoardIntegerViewController" bundle:[NSBundle mainBundle]]) {
        
        _indexPath = indexPath;
    }
    
    return self;
}


- (void) viewDidLoad {
    
    NSLog(@"PropertyBoardIntegerViewController -viewDidLoad");
    
    [super viewDidLoad];
//    
//    NSValue* objectPointer = [[PropertyBoard instance].properties.allKeys objectAtIndex:_indexPath.section - 1];
//    NSDictionary* propertyDict = [[[PropertyBoard instance].properties objectForKey:objectPointer] objectAtIndex:_indexPath.row];
//    NSNumber* type = [propertyDict objectForKey:@"type"];
//    NSString* typeString = [[PropertyBoard instance] stringForType:type];
//    id object = [objectPointer pointerValue];
//    NSString* class = NSStringFromClass([object class]);
//    NSString* propertyKey = [propertyDict objectForKey:@"key"];
//    int value = [[object valueForKey:propertyKey] intValue];

    NSString* variableName = [[PropertyBoard instance] variableNameAtIndex:_indexPath.row];
    NSNumber* type = [[PropertyBoard instance] typeForVariableNamed:variableName];
    NSString* typeString = [[PropertyBoard instance] stringForType:type];
    int value = [[[PropertyBoard instance] valueForVariableNamed:variableName] intValue];
    int minValue = [[[PropertyBoard instance] minValueForVariableNamed:variableName] intValue];
    int maxValue = [[[PropertyBoard instance] maxValueForVariableNamed:variableName] intValue];
    
    self.contentView.nameLabel.text = variableName;
    self.contentView.typeLabel.text = typeString;
    self.contentView.valueLabel.text = [NSString stringWithFormat:@"%d", value];
    
    self.contentView.slider.minimumValue = minValue;
    self.contentView.slider.maximumValue = maxValue;
    self.contentView.slider.value = value;
    
    self.contentView.variableName = variableName;
}

- (IBAction) actionBack {
    
    [[PropertyBoard instance] navigateBack];
}




#pragma mark Motion Events

- (BOOL) canBecomeFirstResponder {
    
    return TRUE;
}


- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    [[PropertyBoard instance] toggleView];
}



@end







@implementation PropertyBoardDraggableView

@synthesize nameLabel;
@synthesize typeLabel;
@synthesize valueLabel;
@synthesize slider;
//@synthesize object;
//@synthesize keyPath;
@synthesize dragView;
@synthesize variableName;


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        
        [[PropertyBoard instance] addChangeObserver:self];
        
        self.layer.shadowOffset = CGSizeMake(5,5);
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.5;
        
        _isDragging = FALSE;
    }
    
    return self;
}


- (void) handlePan:(UIGestureRecognizer *)recognizer {

    static float offsetY;

    CGPoint point = [recognizer locationInView:self.superview];
    CGPoint point2 = [recognizer locationInView:self];

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        offsetY = point2.y;
    }
    else {
    
        float posY = point.y - offsetY;
        
        if (posY < 0)
            posY = 0;
        else if (posY + self.frame.size.height > self.superview.frame.size.height)
            posY = self.superview.frame.size.height - self.frame.size.height;
        
        [self setFrameY:posY];
    }
}


- (void) handleSliderValueChanged:(UISlider *)theSlider {
    
    int roundedValue = round(theSlider.value);
    theSlider.value = roundedValue;
    
    NSLog(@"value: %f", theSlider.value);
    
//    [object setValue:[NSNumber numberWithInt:roundedValue] forKey:keyPath];
    
    [[PropertyBoard instance] setValue:[NSNumber numberWithInt:roundedValue] forVariableNamed:variableName];
}


- (IBAction) increase {
    
    int newValue = slider.value + 1;
    int maxValue = [[[PropertyBoard instance] maxValueForVariableNamed:variableName] intValue];
    
    if (newValue <= maxValue) {
        
        [[PropertyBoard instance] setValue:[NSNumber numberWithInt:newValue] forVariableNamed:variableName];
    }
}


- (IBAction) decrease {

    int newValue = slider.value - 1;
    int minValue = [[[PropertyBoard instance] minValueForVariableNamed:variableName] intValue];
    
    if (newValue >= minValue) {
        
        [[PropertyBoard instance] setValue:[NSNumber numberWithInt:newValue] forVariableNamed:variableName];
    }
}


- (IBAction) editingChanged {
    
    int roundedValue = round(slider.value);
    
    NSLog(@"editing changed: %d", roundedValue);
    
    slider.value = roundedValue;
    valueLabel.text = [NSString stringWithFormat:@"%d", roundedValue];
}


- (IBAction) editingStarted {
    
    NSLog(@"editing started");
    
    _isDragging = TRUE;
    valueLabel.textColor = [UIColor redColor];
}


- (IBAction) editingEnded {
    
    NSLog(@"editing ended");
    
    _isDragging = FALSE;
    valueLabel.textColor = [UIColor blackColor];
}


//- (void) propertyChangedForObject:(id)theObject withKeyPath:(NSString *)theKeyPath {
//    
//    if (theObject == self.object && [theKeyPath isEqualToString:self.keyPath]) {
//        
//        int value = [[theObject valueForKey:theKeyPath] intValue];
//
//        NSLog(@"my value changed to: %d", value);
//        
//        slider.value = value;
//        valueLabel.text = [NSString stringWithFormat:@"%d", value];
//    }
//}


- (void) variableValueChangedForName:(NSString *)name {
    
    if ([name isEqualToString:variableName]) {
        
        int value = [[[PropertyBoard instance] valueForVariableNamed:name] intValue];
        
        NSLog(@"my value changed to: %d", value);
        
        slider.value = value;
        valueLabel.text = [NSString stringWithFormat:@"%d", value];
    }
}


- (void) dealloc {
    
    [[PropertyBoard instance] removeChangeObserver:self];
}

@end
