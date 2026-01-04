//
//  CDStringFormatting.m
//  ClassDump
//
//  Created by Leptos on 1/3/26.
//  Copyright © 2026 Leptos. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *NSStringFromNSUInteger(NSUInteger value) {
    // fast path
    switch (value) {
        case 0:
            return @"0";
        case 1:
            return @"1";
        case 2:
            return @"2";
        case 3:
            return @"3";
        case 4:
            return @"4";
        case 5:
            return @"5";
        case 6:
            return @"6";
        case 7:
            return @"7";
        case 8:
            return @"8";
        case 9:
            return @"9";
    }
    
    NSUInteger place = 1;
    size_t digits = 1;
    while ((value / place) >= 10) {
        place *= 10;
        digits += 1;
    }
    
    char buff[digits];
    char *tail = buff + digits;
    while (tail > buff) {
        NSUInteger const trailingDigit = value % 10;
        value /= 10;
        
        tail--;
        *tail = (trailingDigit + '0');
    }
    
    return [[NSString alloc] initWithBytes:buff length:digits encoding:NSASCIIStringEncoding];
}
