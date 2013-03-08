//
//  OCDPieLayout.m
//  OCD3
//
//  Created by Patrick B. Gibson on 3/7/13.
//  Copyright (c) 2013 Patrick B. Gibson. All rights reserved.
//

#import "OCDPieLayout.h"

@implementation OCDPieLayout

+ (NSArray *)layoutForDataArray:(NSArray *)data usingKey:(NSString *)key;
{
    // These should be use configurable
    float startAngle = 0;
    float endAngle = M_PI * 2;
    
    // find the total, we need it to scale the individual values below
    float valuesTotal = 0;
    for (id value in data) {
        id extractedValue = value;
        if (key) {
            extractedValue = [value valueForKey:key];
        }
        if ([extractedValue isKindOfClass:[NSNumber class]]) {
            valuesTotal += [(NSNumber *)extractedValue floatValue];
        }
    }
    
    float a = startAngle;
    float k = (endAngle - startAngle) / valuesTotal;
    
    NSMutableArray *layout = [[NSMutableArray alloc] initWithCapacity:10];
    for (id value in data) {
        id extractedValue = value;
        if (key) {
            extractedValue = [value valueForKey:key];
        }
        if ([extractedValue isKindOfClass:[NSNumber class]]) {
            float floatValue = [(NSNumber *)extractedValue floatValue];
            float start = a;
            float end = a + floatValue * k;
            NSDictionary *angleData = @{@"data": value,
                                        @"value": extractedValue,
                                        @"startAngle": [NSNumber numberWithFloat:start],
                                        @"endAngle": [NSNumber numberWithFloat:end]
                                        };
            [layout addObject:angleData];
            
            a = end;
        }
    }
    
    return layout;
}

@end
