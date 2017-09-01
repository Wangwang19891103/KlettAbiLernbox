//
//  PopupMenu.m
//  KlettAbiLernboxen
//
//  Created by Wang on 21.11.12.
//
//

#import "PopupMenu.h"
#import "UIColor+Extensions.h"



#define Button_Size CGSizeMake(40,40)


@implementation PopupMenu

@synthesize delegate;
@synthesize favoriteButton;
@synthesize checkButton;
@synthesize crossButton;
@synthesize showNotesButton;
@synthesize addNoteButton;
@synthesize fullscreenButton;


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        
        favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [favoriteButton setImage:resource(@"Images.DocumentView.PopupMenu.Buttons.FavoriteNormal") forState:UIControlStateNormal];
        [favoriteButton setImage:resource(@"Images.DocumentView.PopupMenu.Buttons.FavoriteSelected") forState:UIControlStateSelected];
        [favoriteButton addTarget:self action:@selector(handleButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:favoriteButton];
        
        
        checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [checkButton setImage:resource(@"Images.DocumentView.PopupMenu.Buttons.CheckNormal") forState:UIControlStateNormal];
        [checkButton setImage:resource(@"Images.DocumentView.PopupMenu.Buttons.CheckSelected") forState:UIControlStateSelected];
        [checkButton addTarget:self action:@selector(handleButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:checkButton];

        
        crossButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [crossButton setImage:resource(@"Images.DocumentView.PopupMenu.Buttons.CrossNormal") forState:UIControlStateNormal];
        [crossButton setImage:resource(@"Images.DocumentView.PopupMenu.Buttons.CrossSelected") forState:UIControlStateSelected];
        [crossButton addTarget:self action:@selector(handleButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:crossButton];

        
        showNotesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [showNotesButton setImage:resource(@"Images.DocumentView.PopupMenu.Buttons.ShowNotesNormal") forState:UIControlStateNormal];
        [showNotesButton setImage:resource(@"Images.DocumentView.PopupMenu.Buttons.ShowNotesSelected") forState:UIControlStateSelected];
        [showNotesButton addTarget:self action:@selector(handleButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:showNotesButton];

        
        addNoteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addNoteButton setImage:resource(@"Images.DocumentView.PopupMenu.Buttons.AddNoteNormal") forState:UIControlStateNormal];
        [addNoteButton setImage:resource(@"Images.DocumentView.PopupMenu.Buttons.AddNoteSelected") forState:UIControlStateSelected];
        [addNoteButton addTarget:self action:@selector(handleButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:addNoteButton];
        
        
        fullscreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [fullscreenButton setImage:resource(@"Images.DocumentView.PopupMenu.Buttons.FullscreenNormal") forState:UIControlStateNormal];
        [fullscreenButton setImage:resource(@"Images.DocumentView.PopupMenu.Buttons.FullscreenSelected") forState:UIControlStateSelected];
        [fullscreenButton addTarget:self action:@selector(handleButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:fullscreenButton];

        
        UIColor* barColor = [[ModuleManager manager] colorForModule:[PDFManager manager].moduleName];
        barColor = [barColor colorWithSaturationFactor:PBintVarValue(@"popupmenu saturation") * 0.01];

        self.backgroundColor = barColor;
        
        PBaddObserver(self);
    }
    
    return self;
}


- (void) didMoveToSuperview {
    
    if (self.superview) {
        
        [self layout];
    }
}


- (void) variableValueChangedForName:(NSString *)name {
    
    if ([name isEqualToString:@"popupmenu saturation"]) {
        
        UIColor* barColor = [[ModuleManager manager] colorForModule:[PDFManager manager].moduleName];
        barColor = [barColor colorWithSaturationFactor:PBintVarValue(@"popupmenu saturation") * 0.01];
        
        self.backgroundColor = barColor;
    }
    else if ([name isEqualToString:@"popupmenu marginLeft"]

             || [name isEqualToString:@"popupmenu marginTop"]
             || [name isEqualToString:@"popupmenu padding"]) {
        
        [self layout];
    }
}


- (void) layout {
    
    // layout will try to center button group but respect a minimum right margin
    
//    uint globalOffset = (self.bounds.size.width - 320) * 0.5;
    
    uint marginLeft = PBintVarValue(@"popupmenu marginLeft");  // treated as minimum right margin
    uint marginTop = PBintVarValue(@"popupmenu marginTop");
    uint padding = PBintVarValue(@"popupmenu padding");

    uint numberOfButtons = 6;
    uint totalWidth = (Button_Size.width * numberOfButtons) + (padding * (numberOfButtons - 1));
    uint offsetX = (self.bounds.size.width - totalWidth) * 0.5;  // offsetX is left AND right
    
    if (offsetX < marginLeft) {
        
        offsetX = self.bounds.size.width - totalWidth - marginLeft;
    }
    
    uint posX = offsetX;
    
    [favoriteButton setFrame:CGRectMake(posX, marginTop, Button_Size.width, Button_Size.height)];
    
    
    posX += padding + Button_Size.width;

    [checkButton setFrame:CGRectMake(posX, marginTop, Button_Size.width, Button_Size.height)];

    
    posX += padding + Button_Size.width;
    
    [crossButton setFrame:CGRectMake(posX, marginTop, Button_Size.width, Button_Size.height)];

    
    posX += padding + Button_Size.width;
    
    [showNotesButton setFrame:CGRectMake(posX, marginTop, Button_Size.width, Button_Size.height)];

    
    posX += padding + Button_Size.width;
    
    [addNoteButton setFrame:CGRectMake(posX, marginTop, Button_Size.width, Button_Size.height)];

    
    posX += padding + Button_Size.width;
    
    [fullscreenButton setFrame:CGRectMake(posX, marginTop, Button_Size.width, Button_Size.height)];
 
    
    [self setNeedsDisplay];
}


- (void) handleButtonTouched:(id)sender {

    UIButton* button = (UIButton*)sender;

    // visual selection being controlled by delegate
//    [button setSelected:!button.selected];
    
    
    /* which button */
    
    if (button == favoriteButton) {
        
        [delegate popupMenuFavoriteButtonWasTouchedSelected:button.selected];
    }
    else if (button == checkButton) {
        
        [delegate popupMenuCheckButtonWasTouchedSelected:button.selected];
    }
    else if (button == crossButton) {
        
        [delegate popupMenuCrossButtonWasTouchedSelected:button.selected];
    }
    else if (button == showNotesButton) {
        
        [delegate popupMenuShowNotesButtonWasTouchedSelected:button.selected];
    }
    else if (button == addNoteButton) {
        
        [delegate popupMenuAddNoteButtonWasTouchedSelected:button.selected];
    }
    else if (button == fullscreenButton) {
        
        [delegate popupMenuFullscreenButtonWasTouchedSelected:button.selected];
    }

}



@end













