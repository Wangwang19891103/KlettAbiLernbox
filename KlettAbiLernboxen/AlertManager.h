//
//  AlertManager.h
//  KlettAbiLernboxen
//
//  Created by Wang on 12.02.13.
//
//

#import <Foundation/Foundation.h>


typedef void (^AlertManagerBlock)();


@interface AlertManager : NSObject  <UIAlertViewDelegate> {
    
    NSMutableDictionary* _blocks;
    
}


+ (AlertManager*) instance;

- (void) yesNoAlertWithTitle:(NSString*) title message:(NSString*) message yesBlock:(AlertManagerBlock) block;

- (void) okAlertWithTitle:(NSString*) title message:(NSString*) message okBlock:(AlertManagerBlock) block;

- (void) okAlertWithTitle:(NSString*) title message:(NSString*) message;

@end
