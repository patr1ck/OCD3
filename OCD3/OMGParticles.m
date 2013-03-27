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
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
        label.text = @"touch me";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor lightGrayColor];
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        label.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) - 20);
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
    OCDNode *node = [OCDNode nodeWithIdentifier:@"circle"];
    
    CGPathRef circlePath = [OCDPath circleWithRadius:10];
    [node setValue:(__bridge_transfer id)circlePath forAttributePath:@"path"];
    [node setValue:[NSValue valueWithCGRect:CGRectMake(0, 0, 10, 10)] forAttributePath:@"bounds"];

    [node setValue:[NSValue valueWithCGPoint:_touchedPoint] forAttributePath:@"position"];
    double hue = (double) arc4random() / 0x100000000;
    [node setValue:(id)[UIColor colorWithHue:hue saturation:0.95f brightness:0.95f alpha:1.0f].CGColor forAttributePath:@"strokeColor"];
    [node setValue:(id)[UIColor clearColor].CGColor forAttributePath:@"fillColor"];
    
    [self.particlesView appendNode:node
                    withTransition:^(CAAnimationGroup *animationGroup, id data, NSUInteger index) {
                        CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
                        fade.toValue = @0.0;
                        
                        CABasicAnimation *growBounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
                        growBounds.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 100, 100)];
                        
                        CABasicAnimation *growShape = [CABasicAnimation animationWithKeyPath:@"path"];
                        CGPathRef circlePathBig = [OCDPath circleWithRadius:100];
                        growShape.toValue = (__bridge_transfer id)circlePathBig;
                        
                        animationGroup.removedOnCompletion = NO;
                        animationGroup.fillMode = kCAFillModeForwards;
                        [animationGroup setAnimations:@[fade, growBounds, growShape]];
                    }
                        completion:^(BOOL finished) {
                            [self.particlesView remove:node];
                        }];
}

@end
