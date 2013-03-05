//
//  OCDNode.m
//  OCDView
//
//  Created by Patrick Gibson on 2/15/13.
//

#import <QuartzCore/QuartzCore.h>

#import "OCDNode.h"
#import "OCDNode_Private.h"
#import "OCDView.h"
#import "OCDScale.h"

@interface OCDNode () {
    CGFloat _previousHeight;
    CGFloat _previousWidth;
}
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSMutableDictionary *attributesDictionary;
@end

@implementation OCDNode

+ (id)nodeWithIdentifier:(NSString *)identifier;
{
    OCDNode *node = [[OCDNode alloc] init];
    node.identifier = identifier;
    node.attributesDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    return node;
}

- (void)setNodeType:(OCDNodeType)nodeType
{
    _nodeType = nodeType;
    if (!self.shapeLayer) {
        [self instantiateLayer];
    }
}

- (void)instantiateLayer;
{
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.fillColor = [UIColor blueColor].CGColor;
    self.shouldFireExit = NO;
    
    switch (self.nodeType) {
        case OCDNodeTypeCircle:
            self.shapeLayer.path = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, 20, 20), NULL);
            break;
        case OCDNodeTypeLine:
            
            break;
        case OCDNodeTypeRectangle:
            self.shapeLayer.path = CGPathCreateWithRect(CGRectMake(0, 0, 20, 20), NULL);
            _previousHeight = 20;
            _previousWidth = 20;
            break;
            
        default:
            break;
    }
}

// Internal method which applies the values to the given paths.
- (void)_setValue:(id)value forAttributePath:(NSString *)path
{    
    NSArray *array = [path componentsSeparatedByString:@"."];
    if ([[array objectAtIndex:0] isEqualToString:@"shape"]) {
        
//        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
//        [animation setFromValue:(id)self.shapeLayer.path];

        CGPathRef endPath = nil;
        
        if ([[array objectAtIndex:1] isEqualToString:@"r"]) {
            float radius = [value floatValue];
            self.shapeLayer.path = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, radius, radius), NULL);
            endPath = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, radius, radius), NULL);
        } else if ([[array objectAtIndex:1] isEqualToString:@"width"]) {
            float width = [value floatValue];
            self.shapeLayer.path = CGPathCreateWithRect(CGRectMake(0, 0, width, _previousHeight), NULL);
            endPath = CGPathCreateWithRect(CGRectMake(0, 0, width, _previousHeight), NULL);
            _previousWidth = width;
        } else if ([[array objectAtIndex:1] isEqualToString:@"height"]) {
            float height = [value floatValue];
            self.shapeLayer.path = CGPathCreateWithRect(CGRectMake(0, 0, _previousWidth, height), NULL);
            endPath = CGPathCreateWithRect(CGRectMake(0, 0, _previousWidth, height), NULL);
            _previousHeight = height;
        }
//        [animation setToValue:(__bridge id)endPath];
//        animation.duration = .5f;
//        [animation setRemovedOnCompletion:NO];
//        [animation setFillMode:kCAFillModeForwards]; ;
//        
//        [self.shapeLayer addAnimation:animation forKey:@"wat"];
    } else {
        [self.shapeLayer setValue:value forKeyPath:path];
    }
}

- (void)runAnimations;
{
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 2.f;
    animationGroup.delegate = self;
    if (self.animationBlock) {
        self.animationBlock(animationGroup, self.data, self.index);
    }
    [self.shapeLayer addAnimation:animationGroup forKey:@"runningAnimations"];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if (self.shouldFireExit) {
        [self fireExitBlock];
    }
}

- (void)fireExitBlock;
{
    self.exitBlock(self);
}

- (void)setValue:(id)value forAttributePath:(NSString *)path
{
    [self.attributesDictionary setValue:value forKey:path];
}

- (id)interpolateValueAtPath:(NSString *)path
{
    id value = [self.attributesDictionary objectForKey:path];
    
    if ([value isKindOfClass:NSClassFromString(@"NSBlock")]) {
        
        // If the value is a block, evalute it before passing it through.
        
        OCDSelectionValueBlock block = (OCDSelectionValueBlock)value;
        NSValue *newValue = block(self.data, self.index);
        return newValue;
    } else if ([value isKindOfClass:[OCDNodeData class]]) {
        
        // If the value is a special "OCDNodeData" type, pull the data for the node and pass it through.
        
        NSValue *newValue = self.data;
        return newValue;
    } else if ([value isKindOfClass:[OCDScale class]]) {
        
        // If the value is a scale, scale the data
        
        OCDScale *scale = (OCDScale *)value;
        CGFloat scaleValue = [[scale scaleValue:[NSNumber numberWithInt:self.index]] floatValue];
        CGFloat scaledDataValue = [(NSNumber *)self.data floatValue] * scaleValue;
        return [NSNumber numberWithFloat:scaledDataValue];
    } else {
        // Pass it through
        return value;
    }
    
}

- (void)updateAttributes
{
    for (NSString *path in [self.attributesDictionary allKeys]) {
        [self _setValue:[self interpolateValueAtPath:path] forAttributePath:path];
    }
}

- (void)setData:(NSValue *)data
{
    if (![data isEqual:_data]) {
        _data = data;
    }
}

- (void)setTransition:(OCDNodeAnimationBlock)animationBlock;
{
    self.animationBlock = animationBlock;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"OCDNode: %p - nodeType: %d - shapeLayer: %@", self, self.nodeType, self.shapeLayer];
}


@end
