//
//  OCDViewController.m
//  OCD3
//
//  Created by Patrick B. Gibson on 2/22/13.
//  Copyright (c) 2013 Patrick B. Gibson. All rights reserved.
//

#import "OCDViewController.h"
#import "OCD3.h"

#define kMinBar 20
#define kMaxBar 80
#define ARC4RANDOM_MAX      0x100000000

@interface OCDViewController () {
    NSUInteger _vector;
}
@property (nonatomic, weak) OCDView *OCDView;
@property (nonatomic, strong) NSMutableArray *randomWalkData;
@end

@implementation OCDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    OCDView *view = [[OCDView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:view];
    self.OCDView = view;
    _vector = (kMaxBar + kMinBar)/2;
    
    self.randomWalkData = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < 15; i++) {
        [self.randomWalkData addObject:[self nextRandomWalk]];
    }
    
    [self performSelector:@selector(redrawChart) withObject:nil afterDelay:1];
}

- (NSNumber *)nextRandomWalk
{
    int value = MAX(kMinBar, MIN(kMaxBar, abs(_vector + kMinBar * ( (((double)arc4random() / ARC4RANDOM_MAX)) - 0.5) )));
    _vector = value;
    return [NSNumber numberWithInt:value];
}

- (void)redrawChart
{
    int w = 20;
    int h = 80;
    
    /* 
     Similar to the code of the D3.js "A Simple Bar Chart, Part 2":
     
     var x = d3.scale.linear()
          .domain([0, 1])
          .range([0, w]);
     
     var y = d3.scale.linear()
          .domain([0, 100])
          .rangeRound([0, h]);
     
    chart.selectAll("rect")
         .data(data)
       .enter().append("rect")
         .attr("x", function(d, i) { return x(i) - .5; })
         .attr("y", function(d) { return h - y(d.value) - .5; })
         .attr("width", w)
         .attr("height", function(d) { return y(d.value); });
     */
    
    OCDScale *xScale = [OCDScale linearScaleWithDomainStart:@0 domainEnd:@1
                                                 rangeStart:0 rangeEnd:w];
    OCDScale *yScale = [OCDScale linearScaleWithDomainStart:@0 domainEnd:@100
                                                 rangeStart:0 rangeEnd:h];
    
        
    OCDSelection *bars = [[self.OCDView selectAllWithIdentifier:@"rects"]
                             setData:self.randomWalkData];
    [bars setEnter:^(OCDNode *node) {
        [node setNodeType:OCDNodeTypeRectangle];
        
        [node setValue:^(id data, NSUInteger index){
            CGFloat scaledValue = [[xScale scaleValue:[NSNumber numberWithInt:index]] floatValue];
            return [NSNumber numberWithFloat:scaledValue + index];
        } forAttributePath:@"frame.origin.x"];
        [node setValue:^(id data, NSUInteger index){
            CGFloat computed = h - [[yScale scaleValue:data] floatValue];
            return [NSNumber numberWithFloat:computed];
        } forAttributePath:@"frame.origin.y"];
        [node setValue:@20 forAttributePath:@"shape.width"];
        [node setValue:^(id data, NSUInteger index){
            return [yScale scaleValue:data];
        } forAttributePath:@"shape.height"];
        
        [self.OCDView append:node];
    }];
    
}



/*
- (void)drawCircles
{
    OCDSelection *circles = [[[self.OCDView selectAllWithIdentifier:@"circle"]
                             setData:@[@32, @57, @112, @293]]
                            setEnter:^(OCDNode *node) {
                                [node setNodeType:OCDNodeTypeCircle];
                                [self.OCDView append:node];
                            }];
    [circles setValue:[OCDNodeData data] forAttributePath:@"position.y"];
    [circles setValue:@90 forAttributePath:@"position.x"];
    [circles setValue:^(NSValue *value, NSUInteger index){
        float valuef = [(NSNumber *)value floatValue];
        return [NSNumber numberWithFloat:sqrtf(valuef)];
    } forAttributePath:@"shape.r"];
}

- (void)drawBarChart
{
    NSArray *data = @[@4, @8, @15, @16, @23, @42];
    
    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    NSNumber *max = [[data sortedArrayUsingDescriptors:@[sorter]] objectAtIndex:0];
    
    OCDScale *xScale = [OCDScale linearScaleWithDomainStart:@0
                                                  domainEnd:max
                                                 rangeStart:0
                                                   rangeEnd:300];
    
    OCDSelection *bars = [[[self.OCDView selectAllWithIdentifier:@"bar"]
                          setData:data]
                         setEnter:^(OCDNode *node) {
                             [node setNodeType:OCDNodeTypeRectangle];
                             [self.OCDView append:node];
                         }];
//    [bars trans]
    [bars setValue:^(NSValue *value, NSUInteger index){
        return [NSNumber numberWithFloat:(index * 20) + (index * 1)];
    } forAttributePath:@"position.y"];
    [bars setValue:xScale forAttributePath:@"shape.width"];
    [bars setValue:@20 forAttributePath:@"shape.height"];
    
    [self performSelector:@selector(drawBarChartStep2) withObject:nil afterDelay:2];
}

- (void)drawBarChartStep2
{
    NSLog(@"Firing step 2");

    NSArray *data =  @[@8, @15, @16, @23, @42, @32];
    OCDSelection *selection = [[self.OCDView selectAllWithIdentifier:@"bar"] setData:data];
//    [selection transitionWithBlock:]
    
    [self performSelector:@selector(drawBarChartStep3) withObject:nil afterDelay:2];
}

- (void)drawBarChartStep3
{
    NSLog(@"Firing step 3");
    
    NSArray *data =  @[@8, @15, @16, @2];
    [[[self.OCDView selectAllWithIdentifier:@"bar"] setData:data] setExit:^(OCDNode *node) {
        [self.OCDView remove:node];
    }];
}
*/


@end
