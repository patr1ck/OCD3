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
    
    // OCDNodeTypeRectangle
    CGFloat _previousHeight;
    CGFloat _previousWidth;
    
    // OCDNodeTypeLine
    CGPoint _previousStartPoint;
    CGPoint _previousEndPoint;
    
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
            self.textLayer.foregroundColor = [UIColor blackColor].CGColor;
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
        
        switch (self.nodeType) {
            case OCDNodeTypeCircle: {
                if ([attribute isEqualToString:@"r"]) {
                    float radius = [value floatValue];
                    newPath = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, radius, radius), NULL);
                }
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
                
                break;
            case OCDNodeTypeRectangle: {
                if ([attribute isEqualToString:@"width"]) {
                    float width = [value floatValue];
                    newPath = CGPathCreateWithRect(CGRectMake(0, 0, width, _previousHeight), NULL);
                    _previousWidth = width;
                } else if ([attribute isEqualToString:@"height"]) {
                    float height = [value floatValue];
                    newPath = CGPathCreateWithRect(CGRectMake(0, 0, _previousWidth, height), NULL);
                    _previousHeight = height;
                }
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

- (void)runExitAnimations;
{
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 1.f;
    animationGroup.delegate = self;
    if (self.exitTransition) {
        self.exitTransition(animationGroup, self.data, self.index);
    }
    [self.shapeLayer addAnimation:animationGroup forKey:@"runningExitAnimations"];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if (self.shouldFireExit) {
        [self fireExitBlock];
    }
}

- (void)fireExitBlock;
{
    [self.view remove:self];
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
    _transition = animationBlock;
}

- (void)setExitTransition:(OCDNodeAnimationBlock)animationBlock;
{
    _exitTransition = animationBlock;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"OCDNode: %p - nodeType: %d - shapeLayer: %@", self, self.nodeType, self.shapeLayer];
}


@end
