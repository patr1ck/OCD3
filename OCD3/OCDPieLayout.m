//
//  OCDPieLayout.m
//  OCD3
//
//  Created by Patrick B. Gibson on 3/7/13.
//  Copyright (c) 2013 Patrick B. Gibson. All rights reserved.
//

#import "OCDPieLayout.h"

@interface OCDPieLayout ()
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSString *key;
@end

@implementation OCDPieLayout

- (id)init
{
    self = [super init];
    if (self) {
        _startAngle = 0;
        _endAngle = (M_PI * 2);
    }
    return self;
}

+ (id)layoutForDataArray:(NSArray *)data
                usingKey:(NSString *)key;
{
    OCDPieLayout *pieLayout = [[OCDPieLayout alloc] init];
    pieLayout.dataArray = data;
    pieLayout.key = key;

    return pieLayout;
}

- (NSArray *)layoutData;
{
    // find the total, we need it to scale the individual values below
    float valuesTotal = 0;
    for (id value in self.dataArray) {
        id extractedValue = value;
        if (self.key) {
            extractedValue = [value valueForKey:self.key];
        }
        if ([extractedValue isKindOfClass:[NSNumber class]]) {
            valuesTotal += [(NSNumber *)extractedValue floatValue];
        }
    }
    
    float a = _startAngle;
    float k = (_endAngle - _startAngle) / valuesTotal;
    
    NSMutableArray *layout = [[NSMutableArray alloc] initWithCapacity:10];
    for (id value in self.dataArray) {
        id extractedValue = value;
        if (self.key) {
            extractedValue = [value valueForKey:self.key];
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
