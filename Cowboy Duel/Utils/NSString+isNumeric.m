//
//  NSString+isNumeric.m
//  Bounty Hunter 1
//
//  Created by Taras on 07.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+isNumeric.h"

@implementation NSString (usefull_stuff)

- (BOOL) isAllDigits
{
    NSCharacterSet* nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [self rangeOfCharacterFromSet: nonNumbers];
    return r.location == NSNotFound;
}

@end
