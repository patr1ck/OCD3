//
//  OCDNode.h
//  OCDView
//
//  Created by Patrick Gibson on 2/15/13.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {
    OCDNodeTypeCircle,
    OCDNodeTypeLine,
    OCDNodeTypeRectangle,
    OCDNodeTypeArc
} OCDNodeType;

typedef void (^OCDNodeAnimationBlock)(CAAnimationGroup *animationGroup, id data, NSUInteger index);
typedef void (^OCDNodeAnimationCompletionBlock)(BOOL finished);

/**
 OCDNode objects are somewhat analogous to DOM nodes. They represent the data they are joined with via an underlying CAShapeLayer which can be configured easily through the OCDNode API.
 */
@interface OCDNode : NSObject

/**
 All nodes have an identifier which is set by the user, either through selection creation or direct (manual) creation.
 It can be used to later select the node.
 */
@property (nonatomic, readonly) NSString *identifier;

/**
 nodeType defines the shape the node takes. Current options are:
 
 - OCDNodeTypeCircle
 - OCDNodeTypeLine
 - OCDNodeTypeRectangle
 - OCDNodeTypeArc
 
 Different types have different properties which can be modified, but all are CAShapeLayers.
 */
@property (nonatomic, assign) OCDNodeType nodeType;

/**
 The data this node represents.
 */
@property (nonatomic, readonly) id data;

/**
 The (optional) key to read data from (if the data is a property)
 */
@property (nonatomic, readonly) id key;

/**
 A text label that can be added to the shape.
 */
@property (nonatomic, strong) NSString *text;

/**
 Creates a node with a given identifier.
 
 @param identifier The identifier string.
 @return a new OCDNode object.
 */
+ (id)nodeWithIdentifier:(NSString *)identifier;

/**
 Creates a node with a given identifier.
 
 @param identifier The identifier string.
 */
- (void)setValue:(id)value forAttributePath:(NSString *)path;

/**
 Creates a node with a given identifier.
 
 @param animationBlock A block which creates appropriate animations and adds them to the group animation.
 @param completion 
 */
- (void)setTransition:(OCDNodeAnimationBlock)animationBlock completion:(OCDNodeAnimationCompletionBlock)completion;

/**
 Force a node to apply its attribute settings immediately. 
 */
- (void)updateAttributes;

@end
