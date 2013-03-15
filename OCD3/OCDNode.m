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
        case OCDNodeTypeCircle: {
            CGPathRef path = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, 20, 20), NULL);
            self.shapeLayer.path = path;
            CGPathRelease(path);
            self.shapeLayer.bounds = CGRectMake(0, 0, 20, 20);
            break;
        }
        case OCDNodeTypeLine:{
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, 0, 0);
            CGPathAddLineToPoint(path, NULL, 0, 10);
            self.shapeLayer.path = path;
            self.shapeLayer.strokeColor = [UIColor blackColor].CGColor;
            self.shapeLayer.lineWidth = 1.f;
            CGPathRelease(path);
            break;
        }
            
        case OCDNodeTypeRectangle: {
            CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, 20, 20), NULL);
            self.shapeLayer.path = path;
            CGPathRelease(path);
            _previousHeight = 20;
            _previousWidth = 20;
            self.shapeLayer.bounds = CGRectMake(0, 0, 20, 20);
            self.shapeLayer.anchorPoint = CGPointMake(0, 0);
            break;
        }
        case OCDNodeTypeArc: {
            CGPathRef path = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, 20, 20), NULL);
            self.shapeLayer.path = path;
            CGPathRelease(path);
            self.shapeLayer.bounds = CGRectMake(0, 0, 20, 20);
            _innerRadius = 0.0f;
            _outerRadius = 0.0f;
            break;
        }
            
        default:
            break;
    }
}

- (void)setText:(NSString *)text
{
    if (![_text isEqualToString:text]) {
        _text = text;
        
        if (!self.textLayer) {
            self.textLayer = [CATextLayer layer];
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

// Internal method which applies the values to the given paths.
- (void)_setValue:(id)value forAttributePath:(NSString *)path
{    
    NSArray *array = [path componentsSeparatedByString:@"."];
    if ([[array objectAtIndex:0] isEqualToString:@"shape"]) {

        if ([array count] < 2) {
            NSLog(@"ERROR: Attribute Path incompelete.");
            return;
        }
        NSString *attribute = [array objectAtIndex:1];
        
        CGPathRef newPath = nil;
        
        // TODO: These should be broken out into subclasses as some point.
        switch (self.nodeType) {
            case OCDNodeTypeCircle: {
                if ([attribute isEqualToString:@"r"]) {
                    _radius = [value floatValue];
                    newPath = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, _radius, _radius), NULL);
                }
                self.shapeLayer.bounds = CGRectMake(0, 0, _radius*2, _radius*2);
                break;
            }
            case OCDNodeTypeLine:{
                if ([attribute isEqualToString:@"startPoint"]) {
                    CGPoint startPoint = [value CGPointValue];
                    newPath = (CGPathRef) CGPathCreateMutable();
                    CGPathMoveToPoint((CGMutablePathRef)newPath, NULL, startPoint.x, startPoint.y);
                    CGPathAddLineToPoint((CGMutablePathRef) newPath, NULL, _previousEndPoint.x, _previousEndPoint.y);
                    _previousStartPoint = startPoint;
                } else if ([attribute isEqualToString:@"endPoint"]) {
                    CGPoint endPoint = [value CGPointValue];
                    newPath = (CGPathRef) CGPathCreateMutable();
                    CGPathMoveToPoint((CGMutablePathRef)newPath, NULL, _previousStartPoint.x, _previousStartPoint.y);
                    CGPathAddLineToPoint((CGMutablePathRef) newPath, NULL, endPoint.x, endPoint.y);
                    _previousEndPoint = endPoint;
                }
                break;
            }
                
            case OCDNodeTypeRectangle: {
                if ([attribute isEqualToString:@"width"]) {
                    float width = [value floatValue];
                    newPath = CGPathCreateWithRect(CGRectMake(0, 0, width, _previousHeight), NULL);
                    _previousWidth = width;
                    self.shapeLayer.bounds = CGRectMake(0, 0, width, _previousHeight);
                } else if ([attribute isEqualToString:@"height"]) {
                    float height = [value floatValue];
                    newPath = CGPathCreateWithRect(CGRectMake(0, 0, _previousWidth, height), NULL);
                    _previousHeight = height;
                    self.shapeLayer.bounds = CGRectMake(0, 0, _previousWidth, height);
                }
                break;
            }
                
            case OCDNodeTypeArc: {
                if ([attribute isEqualToString:@"startAngle"]) {
                    float angle = [value floatValue];
                    _startAngle = angle;
                } else if ([attribute isEqualToString:@"endAngle"]) {
                    float angle = [value floatValue];
                    _endAngle = angle;
                } else if ([attribute isEqualToString:@"outerRadius"]) {
                    float radius = [value floatValue];
                    _outerRadius = radius;
                } else if ([attribute isEqualToString:@"innerRadius"]) {
                    float radius = [value floatValue];
                    _innerRadius = radius;
                }
                
                newPath = [self generateArcPath];
                
                self.shapeLayer.bounds = CGRectMake(0, 0, _outerRadius*2, _outerRadius*2);
                break;
            }
                
            default:
                break;
        }
        
        self.shapeLayer.path = newPath;
        CGPathRelease(newPath);
        
    } else {
        [self.shapeLayer setValue:value forKeyPath:path];
    }
}

- (CGPathRef)generateArcPath
{
    float center = _outerRadius;
    CGMutablePathRef path = CGPathCreateMutable();    
    CGPathMoveToPoint(path, NULL, center, center);
    
    CGPoint arcStartPointOuter = CGPointMake(center + _outerRadius * cosf(_startAngle), center + _outerRadius * sinf(_startAngle));    
    
    // Some basic trig at play here: http://en.wikipedia.org/wiki/Circle#Equations
    if (_innerRadius != 0) {
        CGPoint arcStartPointInner = CGPointMake(center + _innerRadius * cosf(_startAngle), center + _innerRadius * sinf(_startAngle));
        CGPathMoveToPoint(path, NULL, arcStartPointInner.x, arcStartPointInner.y);
    }
    CGPathAddLineToPoint(path, NULL, arcStartPointOuter.x, arcStartPointOuter.y);
    CGPathAddArc(path, NULL, center, center, _outerRadius, _startAngle, _endAngle, 0);
    if (_innerRadius != 0) {
        CGPoint arcEndPointInner = CGPointMake(center + _innerRadius * cosf(_endAngle), center + _innerRadius * sinf(_endAngle));
        CGPathAddLineToPoint(path, NULL, arcEndPointInner.x, arcEndPointInner.y);
        CGPathAddArc(path, NULL, center, center, _innerRadius, _endAngle, _startAngle, 1);
    } else {
        CGPathAddLineToPoint(path, NULL, center, center);
    }
    CGPathCloseSubpath(path);
    
        
    return path;
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

- (void)setTransition:(OCDNodeAnimationBlock)animationBlock completion:(OCDNodeAnimationCompletionBlock)completion;
{
    _transition = animationBlock;
    _completion = completion;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"OCDNode: %p - nodeType: %d - shapeLayer: %@", self, self.nodeType, self.shapeLayer];
}


@end
