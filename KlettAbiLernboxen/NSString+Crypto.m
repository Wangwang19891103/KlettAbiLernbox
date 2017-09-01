//
//  NSString+Crypto.m
//  KlettAbiLernboxen
//
//  Created by Stefan Ueter on 06.07.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+Crypto.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (Crypto)

- (NSString *)sha1 {
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end
