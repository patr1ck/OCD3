//
//  OMGParticles.m
//  OCD3
//
//  Created by Patrick B. Gibson on 3/12/13.
//  Copyright (c) 2013 Patrick B. Gibson. All rights reserved.
//

#import "OMGParticles.h"

@interface OMGParticles () {
    CADisplayLink *_displayLink;
    CGPoint _previousTouchedPoint;
    CGPoint _touchedPoint;
}
@property (nonatomic, weak) OCDView *particlesView;
@end

@implementation OMGParticles

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        OCDView *particlesView = [[OCDView alloc] initWithFrame:frame];
        [self addSubview:particlesView];
        self.particlesView = particlesView;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [particlesView addGestureRecognizer:pan];
    }
    return self;
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    switch ([gesture state]) {
        case UIGestureRecognizerStateBegan:
            if (!_displayLink) {
                _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick)];
                [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            }
            _touchedPoint = [gesture locationInView:self];
            break;
            
        case UIGestureRecognizerStateChanged:
            _touchedPoint = [gesture locationInView:self];
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [_displayLink invalidate];
            _displayLink = nil;
            
        default:
            break;
    }
}

- (void)tick
{
    NSLog(@"Ticking");
    
    if (! CGPointEqualToPoint(_touchedPoint, _previousTouchedPoint)) {
        OCDNode *node = [OCDNode nodeWithIdentifier:@"circle"];
        node.nodeType = OCDNodeTypeCircle;
        [node setValue:[NSValue valueWithCGPoint:_touchedPoint] forAttributePath:@"shape.center"];
        
        [self.particlesView appendNode:node
                        withTransition:^(CAAnimationGroup *animationGroup, id data, NSUInteger index) {
                            
                        }
                            completion:^(BOOL finished) {
                                [self.particlesView remove:node];
                            }];
    }
}

@end
