//
//  BarChartView.m
//  OCD3
//
//  Created by Patrick B. Gibson on 3/6/13.
//  Copyright (c) 2013 Patrick B. Gibson. All rights reserved.
//


// Similar to the code of the D3.js "A Simple Bar Chart, Part 2":
// http://mbostock.github.com/d3/tutorial/bar-2.html

#import "BarChartView.h"
#import "OCD3.h"

#define kBarDataPerScreen 15
#define kBarMaxHeight 80
#define kBarMinHeight 20
#define ARC4RANDOM_MAX 0x100000000

@interface BarChartView () {
    NSUInteger _vector;
    NSUInteger _time;
    CGFloat _barWidth;
}
@property (nonatomic, weak) OCDView *movingBarView;
@property (nonatomic, strong) NSMutableArray *randomWalkData;
@end

@implementation BarChartView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Create our containing view and set up some details
        OCDView *movingBarView = [[OCDView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, kBarMaxHeight)];
        [self addSubview:movingBarView];
        self.movingBarView = movingBarView;
        _vector = (kBarMinHeight + kBarMaxHeight)/2;
        _time = 0;
        _barWidth = (self.bounds.size.width - kBarDataPerScreen + 1) / kBarDataPerScreen;

        // Initialize our data set
        self.randomWalkData = [NSMutableArray arrayWithCapacity:10];
        for (int i = 0; i < kBarDataPerScreen; i++) {
            [self.randomWalkData addObject:[self nextData]];
        }
        
        // Create the line on the bottom and add it.
        OCDNode *line = [OCDNode nodeWithIdentifier:@"line"];
        line.nodeType = OCDNodeTypeLine;
        [line setValue:[NSValue valueWithCGPoint:CGPointMake(0, kBarMaxHeight - 0.5)]
      forAttributePath:@"shape.startPoint"];
        [line setValue:[NSValue valueWithCGPoint:CGPointMake(movingBarView.bounds.size.width, kBarMaxHeight - 0.5)]
      forAttributePath:@"shape.endPoint"];
        [line setValue:[NSNumber numberWithInt:100] forAttributePath:@"zPosition"]; // ensure it's in front
        [line updateAttributes]; // This is automatically called on entering nodes, but since this is being created outside of a data join, we'll just call it manually.
        [self.movingBarView appendNode:line];
        
        
        // Setup a timer to redraw every few seconds
        NSTimer *timer = [NSTimer timerWithTimeInterval:2
                                                 target:self
                                               selector:@selector(stepData)
                                               userInfo:nil
                                                repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [self redrawChart];
    }
    return self;
}

- (void)stepData
{
    [self.randomWalkData removeObjectAtIndex:0];
    [self.randomWalkData addObject:[self nextData]];
    [self redrawChart];
}

- (NSDictionary *)nextData
{
    int value = MAX(kBarMinHeight, MIN(kBarMaxHeight, abs(_vector + kBarMinHeight * ( (((double)arc4random() / ARC4RANDOM_MAX)) - 0.5) )));
    _vector = value;
    return @{ @"value": [NSNumber numberWithInt:value], @"time": [NSNumber numberWithInt:_time++] };
}

- (void)redrawChart
{
    OCDScale *xScale = [OCDScale linearScaleWithDomainStart:0 domainEnd:1
                                                 rangeStart:0 rangeEnd:_barWidth];
    OCDScale *yScale = [OCDScale linearScaleWithDomainStart:0 domainEnd:100
                                                 rangeStart:0 rangeEnd:kBarMaxHeight];
    
    OCDSelection *bars = [self.movingBarView selectAllWithIdentifier:@"rects"];
    [bars setData:self.randomWalkData usingKey:@"time"];
    
    [bars setEnter:^(OCDNode *node) {
        
        // We want to represent our data as a bar chart, so each data point will be a rectangle
        [node setNodeType:OCDNodeTypeRectangle];
        
        // The x position depends on which peice of data we're looking at, so we use our scale to set it
        // We add the index value again to give it a 1px space from the previous bar.
        [node setValue:^(id data, NSUInteger index){
            CGFloat scaledValue = [xScale scaleValue:index];
            return [NSNumber numberWithFloat:scaledValue + index];
        } forAttributePath:@"position.x"];
        
        
        // Likewise, we set the y position to be the max bar height minus our real height,
        // in order to align them to the bottom of the frame
        [node setValue:^(id data, NSUInteger index){
            CGFloat computed = kBarMaxHeight - [yScale scaleValue:[[data objectForKey:@"value"] floatValue]];
            return [NSNumber numberWithFloat:computed];
        } forAttributePath:@"position.y"];
        
        
        // Set the width and height of the bars. Here, the height is a function: the scaled data.
        [node setValue:[NSNumber numberWithFloat:_barWidth] forAttributePath:@"shape.width"];
        [node setValue:^(id data, NSUInteger index){
            CGFloat computed = [yScale scaleValue:[[data objectForKey:@"value"] floatValue]];
            return [NSNumber numberWithFloat:computed];
        } forAttributePath:@"shape.height"];
        
        
        // Set a random color for the bar
        double hue = (double) arc4random() / ARC4RANDOM_MAX;
        [node setValue:(id)[UIColor colorWithHue:hue saturation:0.95f brightness:0.95f alpha:1.0f].CGColor forAttributePath:@"fillColor"];
        
        
        // Put the value inside the bar
        [node setText:[NSString stringWithFormat:@"%.0f", [[node.data objectForKey:@"value"] floatValue]]];
        
        
        // Have the bar move from +1 of it's normal x position into where it should be.
        [node setTransition:^(CAAnimationGroup *animationGroup, id data, NSUInteger index) {
            CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position.x"];
            CGFloat scaledValueFrom = [xScale scaleValue:index+1];
            CGFloat scaledValueTo = [xScale scaleValue:index];
            
            // We add the index again to leave a 1px space between the bars
            move.fromValue = [NSNumber numberWithFloat:scaledValueFrom + index];
            move.toValue = [NSNumber numberWithFloat:scaledValueTo + index];
            
            move.duration = 1.0f;
            [animationGroup setAnimations:@[move]];
        } completion:nil];
        
        
        // Add the node to the view.
        [self.movingBarView appendNode:node];
    }];
    
    // We don't need to do anything here since our update transition remains the same as above.
    [bars setUpdate:nil];
    
    [bars setExit:^(OCDNode *node) {
        
        // We're going to reference the given node in a completion block below, so we should mark
        // it as weak so we don't cause a memory leak.
        __weak OCDNode *blockNode = node;
        
        [node setTransition:^(CAAnimationGroup *animationGroup, id data, NSUInteger index) {
            CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position.x"];
            CGFloat scaledValueFrom = [xScale scaleValue:index];
            CGFloat scaledValueTo = [xScale scaleValue:index - 1.0f];
            
            move.fromValue = [NSNumber numberWithFloat:scaledValueFrom - 1.f]; // Keep the 1px spacing.
            move.toValue = [NSNumber numberWithFloat:scaledValueTo - 1.f]; // Keep the 1px spacing.
            
            // We want the animation to hold in position at the end, (for the split second before
            // it is removed) so the user doesn't see any flickering.
            animationGroup.fillMode = kCAFillModeForwards;
            animationGroup.removedOnCompletion = NO;
            [animationGroup setAnimations:@[move]];
        } completion:^(BOOL finished) {
            [self.movingBarView remove:blockNode];
        }];
    }];
    
}

@end
