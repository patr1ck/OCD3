//
//  OCDViewController.m
//  OCD3
//
//  Created by Patrick B. Gibson on 2/22/13.
//  Copyright (c) 2013 Patrick B. Gibson. All rights reserved.
//

#import "OCDViewController.h"
#import "OCD3.h"

@interface OCDViewController ()
@property (nonatomic, weak) OCDView *OCDView;
@end

@implementation OCDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    OCDView *view = [[OCDView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:view];
    self.OCDView = view;
    
    [self performSelector:@selector(drawBarChart) withObject:nil afterDelay:1];
}

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
    [bars setValue:^(NSValue *value, NSUInteger index){
        return [NSNumber numberWithFloat:(index * 20) + (index * 1)];
    } forAttributePath:@"position.y"];
    [bars setValue:xScale forAttributePath:@"shape.width"];
    [bars setValue:@20 forAttributePath:@"shape.height"];
    
    [self performSelector:@selector(drawBarChartStep2) withObject:nil afterDelay:1];
}

- (void)drawBarChartStep2
{
    NSLog(@"Firing step 2");

    NSArray *data =  @[@8, @15, @16, @23, @42, @32];
    [[self.OCDView selectAllWithIdentifier:@"bar"] setData:data];
}

@end
