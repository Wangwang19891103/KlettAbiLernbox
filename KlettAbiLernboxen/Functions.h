//
//  Functions.h
//  Sprachenraetsel
//
//  Created by Stefan Ueter on 13.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



NSString* stringSwitchCaseString(NSString* string, NSString* firstKey, ...);

int intSwitchCaseString(NSString* string, id firstKey, ...);

NSString* stringSwitchCaseInt(uint theInt, id firstKey, ...);

uint randomIntegerFromTo(uint from, uint to);

float roundFDigits(float f, uint digits);