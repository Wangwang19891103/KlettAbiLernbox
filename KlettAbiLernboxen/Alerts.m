//
//  Alerts.m
//  KlettAbiLernboxen
//
//  Created by Stefan Ueter on 16.08.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Alerts.h"


void alert(NSString* text, ...) {

    return;
    
    va_list args;
    va_start(args, text);

//    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[[UIAlertView alloc] initWithTitle:@"alert" message:[[NSString alloc] initWithFormat:text arguments:args] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
//    });
}


void alerterror(NSError* error) {
    
    alert(error.localizedDescription);
}