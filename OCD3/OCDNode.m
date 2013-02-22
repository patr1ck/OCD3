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

@interface OCDNode () {
    CGFloat _previousHeight;
    CGFloat _previousWidth;
}
@property (nonatomic, strong) NSString *identifier;
@end

@implementation OCDNode

+ (id)nodeWithIdentifier:(NSString *)identifier;
{
    OCDNode *node = [[OCDNode alloc] init];
    node.identifier = identifier;
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
    self.shapeLayer.fillColor = [UIColor greenColor].CGColor;
    
    switch (self.nodeType) {
        case OCDNodeTypeCircle:
            self.shapeLayer.path = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, 20, 20), NULL);
            break;
        case OCDNodeTypeSquare:
            
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

- (void)setValue:(id)value forAttributePath:(NSString *)path;
{
    NSArray *array = [path componentsSeparatedByString:@"."];
    if ([[array objectAtIndex:0] isEqualToString:@"shape"]) {
        if ([[array objectAtIndex:1] isEqualToString:@"r"]) {
            float radius = [value floatValue];
            self.shapeLayer.path = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, radius, radius), NULL);
        } else if ([[array objectAtIndex:1] isEqualToString:@"width"]) {
            float width = [value floatValue];
            self.shapeLayer.path = CGPathCreateWithRect(CGRectMake(0, 0, width, _previousHeight), NULL);
            _previousWidth = width;
        } else if ([[array objectAtIndex:1] isEqualToString:@"height"]) {
            float height = [value floatValue];
            self.shapeLayer.path = CGPathCreateWithRect(CGRectMake(0, 0, _previousWidth, height), NULL);
            _previousHeight = height;
        }
    } else {
          [self.shapeLayer setValue:value forKeyPath:path];
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"OCDNode: %p - nodeType: %d - shapeLayer: %@", self, self.nodeType, self.shapeLayer];
}


@end
