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
    
    // OCDNodeTypeCircle
    CGPoint _center;
    CGFloat _radius;
    
    // OCDNodeTypeRectangle
    CGFloat _previousHeight;
    CGFloat _previousWidth;
    
    // OCDNodeTypeLine
    CGPoint _previousStartPoint;
    CGPoint _previousEndPoint;
    
    // OCDNodeTypeArc
    CGFloat _innerRadius;
    CGFloat _outerRadius;
    CGFloat _startAngle;
    CGFloat _endAngle;
    
}
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSMutableDictionary *attributesDictionary;
@end

@implementation OCDNode

@synthesize data = _data;

+ (id)nodeWithIdentifier:(NSString *)identifier;
{
    OCDNode *node = [[OCDNode alloc] init];
    node.identifier = identifier;
    node.attributesDictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    [node instantiateLayer];
    
    return node;
}

- (void)instantiateLayer;
{
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.fillColor = [UIColor blueColor].CGColor;
    self.shouldFireExit = NO;
}

- (void)setText:(NSString *)text
{
    if (![_text isEqualToString:text]) {
        _text = text;
        
        if (!self.textLayer) {
            self.textLayer = [CATextLayer layer];
            self.textLayer.contentsScale = [[UIScreen mainScreen] scale];
            NSAttributedString *string = [[NSAttributedString alloc] initWithString:text
                                                                         attributes:@{
                                        NSFontAttributeName: [UIFont systemFontOfSize:2.f]
                                          
                                          }];

            self.textLayer.string = string;
            self.textLayer.foregroundColor = [UIColor blackColor].CGColor;
            self.textLayer.bounds = self.shapeLayer.bounds;
            self.textLayer.backgroundColor = [UIColor clearColor].CGColor;
            self.textLayer.anchorPoint = CGPointMake(0, 0);
            self.textLayer.fontSize = 12.f;
            self.textLayer.alignmentMode = kCAAlignmentCenter;
            [self.shapeLayer addSublayer:self.textLayer];
        }
        [self.textLayer setString:_text];
    }
}

- (void)runAnimations;
{
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 1.f;
    animationGroup.delegate = self;
    if (self.transition) {
        self.transition(animationGroup, self.data, self.index);
    }
    [self.shapeLayer addAnimation:animationGroup forKey:@"runningAnimations"];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if (self.completion) {
        self.completion(flag);
    }
}

- (void)setValue:(id)value forAttributePath:(NSString *)path
{
    [self.attributesDictionary setValue:value forKey:path];
}

- (id)valueForAttributePath:(NSString *)path;
{
    id value = [self.attributesDictionary objectForKey:path];
    if (!value) {
        value = [self.shapeLayer valueForKeyPath:path];
    }
    return value;
}

- (id)keyedData
{
    if (self.key) {
        return [_data objectForKey:self.key];
    }
    
    return _data;
}

- (id)interpolateValueAtPath:(NSString *)path
{
    id value = [self.attributesDictionary objectForKey:path];
    
    if ([value isKindOfClass:NSClassFromString(@"NSBlock")]) {
        
        // If the value is a block, evalute it before passing it through.
        
        OCDSelectionValueBlock block = (OCDSelectionValueBlock)value;
        return block(self.data, self.index);
        
    } else if ([value isKindOfClass:[OCDNodeData class]]) {
        
        // If the value is a special "OCDNodeData" type, pull the data for the node and pass it through.
        
        NSValue *newValue = [self keyedData];
        return newValue;
        
    } else if ([value isKindOfClass:[OCDScale class]]) {
        
        // If the value is a scale, scale the data
        
        OCDScale *scale = (OCDScale *)value;
        CGFloat scaleValue = [scale scaleValue:self.index];
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
        [self.shapeLayer setValue:[self interpolateValueAtPath:path] forKeyPath:path];
    }
}

- (void)setData:(NSValue *)data
{
    if (![data isEqual:_data]) {
        _data = data;
    }
}

- (void)setTransition:(OCDNodeAnimationBlock)animationBlock completion:(OCDNodeAnimationCompletionBlock)completion;
{
    _transition = animationBlock;
    _completion = completion;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"OCDNode: %p - shapeLayer: %@", self, self.shapeLayer];
}


@end
