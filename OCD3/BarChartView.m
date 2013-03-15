//
//  BarChartView.m
//  OCD3
//
//  Created by Patrick B. Gibson on 3/6/13.
//  Copyright (c) 2013 Patrick B. Gibson. All rights reserved.
//


/*
 
 Similar to the code of the D3.js "A Simple Bar Chart, Part 2":
 
 var x = d3.scale.linear()
   .domain([0, 1])
   .range([0, w]);
 
 var y = d3.scale.linear()
   .domain([0, 100])
   .rangeRound([0, h]);
 
 var rect = chart.selectAll("rect")
   .data(data, function(d) { return d.time; });
 
rect.enter().insert("rect", "line")
  .attr("x", function(d, i) { return x(i + 1) - .5; })
  .attr("y", function(d) { return h - y(d.value) - .5; })
  .attr("width", w)
  .attr("height", function(d) { return y(d.value); })
  .transition()
    .duration(1000)
    .attr("x", function(d, i) { return x(i) - .5; });
 
rect.transition()
  .duration(1000)
  .attr("x", function(d, i) { return x(i) - .5; });
 
rect.exit().transition()
  .duration(1000)
  .attr("x", function(d, i) { return x(i - 1) - .5; })
  .remove();
 
 */

#import "BarChartView.h"
#import "OCD3.h"

#define kMinBar 20
#define kMaxBar 80
#define kBarWidth 20
#define kBarHeight 80
#define ARC4RANDOM_MAX      0x100000000

@interface BarChartView () {
    NSUInteger _vector;
    NSUInteger _count;
}
@property (nonatomic, weak) OCDView *movingBarView;
@property (nonatomic, strong) NSMutableArray *randomWalkData;
@end

@implementation BarChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Moving Bar
        OCDView *movingBarView = [[OCDView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, kMaxBar)];
        [self addSubview:movingBarView];
        self.movingBarView = movingBarView;
        _vector = (kMaxBar + kMinBar)/2;
        _count = 0;
        
        // Create the line on the bottom and add it.
        OCDNode *line = [OCDNode nodeWithIdentifier:@"line"];
        line.nodeType = OCDNodeTypeLine;
        [line setValue:[NSValue valueWithCGPoint:CGPointMake(0, kBarHeight)]
      forAttributePath:@"shape.startPoint"];
        [line setValue:[NSValue valueWithCGPoint:CGPointMake(self.bounds.size.width, kBarHeight)]
      forAttributePath:@"shape.endPoint"];
        [line setValue:[NSNumber numberWithInt:100] forAttributePath:@"zPosition"];
        [line updateAttributes]; // This is automatically called on entering nodes, but since this is being created outside of a data join, we'll just call it manually.
        [self.movingBarView appendNode:line];
        
        self.randomWalkData = [NSMutableArray arrayWithCapacity:10];
        for (int i = 0; i < 15; i++) {
            [self.randomWalkData addObject:[self nextData]];
        }
        
        NSTimer *timer = [NSTimer timerWithTimeInterval:2
                                                 target:self
                                               selector:@selector(stepUp)
                                               userInfo:nil
                                                repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)stepUp
{
    [self.randomWalkData removeObjectAtIndex:0];
    [self.randomWalkData addObject:[self nextData]];
    [self redrawChart];
}

- (NSDictionary *)nextData
{
    int value = MAX(kMinBar, MIN(kMaxBar, abs(_vector + kMinBar * ( (((double)arc4random() / ARC4RANDOM_MAX)) - 0.5) )));
    _vector = value;
    return @{ @"value": [NSNumber numberWithInt:value], @"time": [NSNumber numberWithInt:_count++] };
}

- (void)redrawChart
{
    OCDScale *xScale = [OCDScale linearScaleWithDomainStart:@0 domainEnd:@1
                                                 rangeStart:0 rangeEnd:kBarWidth];
    OCDScale *yScale = [OCDScale linearScaleWithDomainStart:@0 domainEnd:@100
                                                 rangeStart:0 rangeEnd:kBarHeight];
    
    OCDSelection *bars = [self.movingBarView selectAllWithIdentifier:@"rects"];
    [bars setData:self.randomWalkData usingKey:@"time"];
    
    [bars setEnter:^(OCDNode *node) {
        [node setNodeType:OCDNodeTypeRectangle];
        
        [node setValue:^(id data, NSUInteger index){
            CGFloat scaledValue = [[xScale scaleValue:[NSNumber numberWithInt:index]] floatValue];
            return [NSNumber numberWithFloat:scaledValue + index];
        } forAttributePath:@"position.x"];
        
        [node setValue:^(id data, NSUInteger index){
            CGFloat computed = kBarHeight - [[yScale scaleValue:[data objectForKey:@"value"]] floatValue];
            return [NSNumber numberWithFloat:computed];
        } forAttributePath:@"frame.origin.y"];
        
        [node setValue:@20 forAttributePath:@"shape.width"];
        [node setValue:^(id data, NSUInteger index){
            return [yScale scaleValue:[data objectForKey:@"value"]];
        } forAttributePath:@"shape.height"];
        
        double hue = (double) arc4random() / 0x100000000;
        [node setValue:(id)[UIColor colorWithHue:hue saturation:0.95f brightness:0.95f alpha:1.0f].CGColor forAttributePath:@"fillColor"];
        
        [node setText:[NSString stringWithFormat:@"%.0f", [[node.data objectForKey:@"value"] floatValue]]];
        
        
        [node setTransition:^(CAAnimationGroup *animationGroup, id data, NSUInteger index) {
            CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position.x"];
            CGFloat scaledValueFrom = [[xScale scaleValue:[NSNumber numberWithInt:index+1]] floatValue];
            CGFloat scaledValueTo = [[xScale scaleValue:[NSNumber numberWithInt:index]] floatValue];
            move.fromValue = [NSNumber numberWithFloat:scaledValueFrom + index];
            move.toValue = [NSNumber numberWithFloat:scaledValueTo + index];
            move.duration = 1.0f;
            [animationGroup setAnimations:@[move]];
        } completion:^(BOOL finished) {
            
        }];
        
        [self.movingBarView appendNode:node];
    }];
    
    [bars setUpdate:^(OCDNode *node) {
        // We don't need to do much here since our update transition remains the same as above.
        // Just update the text of the nodes.
        [node setText:[NSString stringWithFormat:@"%.0f", [[node.data objectForKey:@"value"] floatValue]]];
    }];
    
    [bars setExit:^(OCDNode *node) {
        __weak OCDNode *blockNode = node;
        [node setTransition:^(CAAnimationGroup *animationGroup, id data, NSUInteger index) {
            CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position.x"];
            // Index will be Zero
            CGFloat scaledValueFrom = [[xScale scaleValue:[NSNumber numberWithInt:index]] floatValue];
            CGFloat scaledValueTo = [[xScale scaleValue:[NSNumber numberWithInt:index-1]] floatValue];
            move.fromValue = [NSNumber numberWithFloat:scaledValueFrom - 1.f]; // Keep the 1px spacing.
            move.toValue = [NSNumber numberWithFloat:scaledValueTo - 1.f]; // Keep the 1px spacing.
            move.fillMode = kCAFillModeForwards;
            move.removedOnCompletion = NO;
            [animationGroup setAnimations:@[move]];
        } completion:^(BOOL finished) {
            [self.movingBarView remove:blockNode];
        }];
    }];
    
}

@end
