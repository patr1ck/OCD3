//
//  PieAndBar.m
//  OCD3
//
//  Created by Patrick B. Gibson on 3/27/13.
//  Copyright (c) 2013 Patrick B. Gibson. All rights reserved.
//

#import "PieAndBar.h"
#import "OCD3.h"

#define kBarPaddingWidth 5.0f
#define kBarMaxHeight 200.0f

@interface PieAndBar () {
    BOOL _isPie;
}
@property (nonatomic, weak) OCDView *view;
@property (nonatomic, strong) OCDPieLayout *pieLayout;
@property (nonatomic, strong) OCDNodeFormatter *arcFormatter;
@property (nonatomic, strong) NSArray *data;
@end

@implementation PieAndBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        OCDView *newView = [[OCDView alloc] initWithFrame:self.bounds];
        [self addSubview:newView];
        self.view = newView;
        
        _isPie = YES;
        
        self.data = @[ @{@"Browser": @"Chrome",             @"Percent": @42},
                       @{@"Browser": @"Safari",             @"Percent": @32},
                       @{@"Browser": @"Internet Explorer",  @"Percent": @11},
                       @{@"Browser": @"Firefox",            @"Percent": @10},
                       @{@"Browser": @"Other",              @"Percent": @5} ];
        
    
        self.arcFormatter = [OCDNodeFormatter arcNodeFormatterWithInnerRadius:100.0f
                                                                  outerRadius:(self.bounds.size.width/2.0f)];
        self.pieLayout = [OCDPieLayout layoutForDataArray:self.data usingKey:@"Percent"];
        self.pieLayout.startAngle = M_PI_2;
        self.pieLayout.endAngle = (2 * M_PI) + M_PI_2;
        OCDSelection *browsers = [[self.view selectAllWithIdentifier:@"browsers"] setData:[self.pieLayout layoutData]
                                                                                 usingKey:@"Browser"];
        
        [browsers setEnter:^(OCDNode *node) {
            [self.arcFormatter formatNode:node];
            
            double hue = (double) arc4random() / 0x100000000;
            [node setValue:(id)[UIColor colorWithHue:hue saturation:0.95f brightness:0.95f alpha:1.0f].CGColor forAttributePath:@"fillColor"];
            
//            [node setValue:(id)[UIColor lightGrayColor].CGColor forAttributePath:@"backgroundColor"];
            
            [self.view appendNode:node];
        }];
        
        UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [toggleButton setTitle:@"Toggle Bar/Pie" forState:UIControlStateNormal];
        [toggleButton addTarget:self action:@selector(togglePressed:) forControlEvents:UIControlEventTouchUpInside];
        [toggleButton sizeToFit];
        toggleButton.frame = CGRectMake(self.bounds.size.width/2 - toggleButton.bounds.size.width/2,
                                        400, toggleButton.bounds.size.width, toggleButton.bounds.size.height);
        [self addSubview:toggleButton];
    }
    return self;
}

- (void)togglePressed:(id)sender;
{
    if (_isPie) {
        // Change to bar
        
        CGFloat barWidth = (self.bounds.size.width - kBarPaddingWidth * ([self.data count] - 1) ) / [self.data count];
        OCDSelection *browsers = [[self.view selectAllWithIdentifier:@"browsers"] setData:self.data
                                                                                 usingKey:@"Browser"];
        
        [browsers setUpdate:^(OCDNode *node) {
            
            NSValue *oldBounds = [node valueForAttributePath:@"bounds"];
            [node setValue:[NSValue valueWithCGPoint:CGPointMake(0, 0)] forAttributePath:@"anchorPoint"];
            [node setValue:[NSValue valueWithCGRect:CGRectMake(0, 0, barWidth, kBarMaxHeight)] forAttributePath:@"bounds"];
            
    
            CGPoint oldPos = [[node valueForAttributePath:@"position"] CGPointValue];

            [node setValue:^(id data, NSUInteger index){
                CGFloat dataValue = [[data objectForKey:@"Percent"] floatValue];
                CGPoint pos = CGPointMake(index * (barWidth + kBarPaddingWidth), kBarMaxHeight - dataValue);
                NSLog(@"New position: %@", NSStringFromCGPoint(pos));
                return [NSValue valueWithCGPoint:pos];
            } forAttributePath:@"position"];
            
            CGPathRef oldPath = (__bridge CGPathRef) [node valueForAttributePath:@"path"];
            CGPathRef fullBar = [OCDPath rectangleWithWidth:barWidth
                                                     height:[[node.data objectForKey:@"Percent"] floatValue]];
            [node setValue:(__bridge id)fullBar forAttributePath:@"path"];

            
            [node setTransition:^(CAAnimationGroup *animationGroup, id data, NSUInteger index) {
                CABasicAnimation *shapeChange = [CABasicAnimation animationWithKeyPath:@"path"];
                shapeChange.fromValue = (__bridge id)oldPath;
                shapeChange.toValue = (__bridge_transfer id)fullBar;
                
                CABasicAnimation *positionChange = [CABasicAnimation animationWithKeyPath:@"position"];
                positionChange.fromValue = [NSValue valueWithCGPoint:oldPos];
                CGFloat dataValue = [[data objectForKey:@"Percent"] floatValue];
                positionChange.toValue = [NSValue valueWithCGPoint:CGPointMake(index * (barWidth + kBarPaddingWidth),
                                                                            kBarMaxHeight - dataValue)];
                
                CABasicAnimation *anchorChange = [CABasicAnimation animationWithKeyPath:@"anchorPoint"];
                anchorChange.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)];
                anchorChange.toValue = [NSValue valueWithCGPoint:CGPointMake(0, 0)];
                
                CABasicAnimation *boundsChange = [CABasicAnimation animationWithKeyPath:@"bounds"];
                boundsChange.fromValue = oldBounds;
                boundsChange.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, barWidth, kBarMaxHeight)];
                
                
                animationGroup.duration = 1;
                [animationGroup setAnimations:@[positionChange, shapeChange, anchorChange, boundsChange]];
            } completion:nil];
        }];
        
    } else {        
        // Change to pie
        OCDSelection *browsers = [[self.view selectAllWithIdentifier:@"browsers"] setData:[self.pieLayout layoutData]
                                                                                 usingKey:@"Browser"];
        
        [browsers setUpdate:^(OCDNode *node) {
            [self.arcFormatter formatNode:node];
                        NSLog(@"setting update on node: %@", node);
            double hue = (double) arc4random() / 0x100000000;
            [node setValue:(id)[UIColor colorWithHue:hue saturation:0.95f brightness:0.95f alpha:1.0f].CGColor forAttributePath:@"fillColor"];
            [self.view appendNode:node withTransition:^(CAAnimationGroup *animationGroup, id data, NSUInteger index) {
                
            } completion:nil];
        }];
    }
    
    _isPie = !_isPie;
}

@end
