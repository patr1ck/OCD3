//
//  RisingBarChart.m
//  OCD3
//
//  Created by Patrick B. Gibson on 3/25/13.
//  Copyright (c) 2013 Patrick B. Gibson. All rights reserved.
//

#import "OCD3.h"
#import "RisingBarChart.h"

#define kBarPaddingWidth 5.0f
#define kBarMaxHeight 200.0f

@implementation RisingBarChart

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
        
        CGFloat barWidth = (self.bounds.size.width - kBarPaddingWidth * ([data count] - 1) ) / [data count];

        OCDSelection *bars = [[view selectAllWithIdentifier:@"bar"] setData:data
                                                                   usingKey:@"Percent"];
        
        [bars setEnter:^(OCDNode *node) {
            
            [node setNodeType:OCDNodeTypeRectangle];
            [node setValue:[NSNumber numberWithFloat:barWidth] forAttributePath:@"shape.width"];
            [node setValue:[OCDNodeData data] forAttributePath:@"shape.height"];
            
            [node setValue:^(id data, NSUInteger index){
                return [NSNumber numberWithFloat:index * (barWidth + kBarPaddingWidth)];
            } forAttributePath:@"position.x"];

            [node setValue:^(id data, NSUInteger index){
                CGFloat dataValue = [[data objectForKey:@"Percent"] floatValue];
                return [NSNumber numberWithFloat:kBarMaxHeight - dataValue];
            } forAttributePath:@"position.y"];
            
            
            [node setValue:(id)[UIColor blueColor].CGColor forAttributePath:@"fillColor"];
            
            [view appendNode:node withTransition:^(CAAnimationGroup *animationGroup, id data, NSUInteger index) {
                CABasicAnimation *grow = [CABasicAnimation animationWithKeyPath:@"shape.height"];
                grow.fromValue = @0;
                grow.toValue = [data objectForKey:@"Percent"];
                grow.duration = 2;
                
                animationGroup.duration = 2;
                [animationGroup setAnimations:@[grow]];
            } completion:nil];
        }];
        
    }
    return self;
}


@end
