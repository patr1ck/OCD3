//
//  PieChartView.m
//  OCD3
//
//  Created by Patrick B. Gibson on 3/6/13.
//  Copyright (c) 2013 Patrick B. Gibson. All rights reserved.
//

#import "PieChartView.h"

@implementation PieChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        OCDView *view = [[OCDView alloc] initWithFrame:self.bounds];
        [self addSubview:view];
        
        NSArray *data = @[ @{@"Browser": @"Chrome",             @"Percent": @42},
                           @{@"Browser": @"Safari",             @"Percent": @32},
                           @{@"Browser": @"Internet Explorer",  @"Percent": @11},
                           @{@"Browser": @"Firefox",            @"Percent": @10},
                           @{@"Browser": @"Other",              @"Percent": @5} ];
        
        OCDNodeFormatter *arcFormatter = [OCDNodeFormatter arcNodeFormatterWithInnerRadius:100
                                                                               outerRadius:(self.bounds.size.width/2)];
        OCDSelection *arcs = [[view selectAllWithIdentifier:@"arcs"] setData:[OCDPieLayout layoutForDataArray:data usingKey:@"Percent"]
                                                                    usingKey:nil];
        
        [arcs setEnter:^(OCDNode *node) {
            [arcFormatter formatNode:node];
            
            double hue = (double) arc4random() / 0x100000000;
            [node setValue:(id)[UIColor colorWithHue:hue saturation:0.95f brightness:0.95f alpha:1.0f].CGColor forAttributePath:@"fillColor"];
            
            [view append:node];
        }];
        
    }
    return self;
}

@end
