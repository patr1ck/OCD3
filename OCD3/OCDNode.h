//
//  OCDNode.h
//  OCDView
//
//  Created by Patrick Gibson on 2/15/13.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

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
 Allows you to set values on the node.
 
 This can be used to set values on the underlying CAShapeLayer that OCDNode represents. Any CAShapeLayer property you can set with setValue:forKey: will also work here.
 
 There are several kinds of values you can pass:

- A normal value, like an NSString or NSNumber.
- An OCDNodeData object, which will substitute for the joined data's value at run time.
- An OCDSelectionValueBlock, which will be evaluated using the data's value and its index at run time.
 
 The latter two options allow the attributes to easily be defined by the data being represented.
 
 @param value The identifier string.
 @param path The path of the attribute you are trying to set. Can be things like "position.y", "opacity", or "transform.scale.x"
 */
- (void)setValue:(id)value forAttributePath:(NSString *)path;


/**
 Allows you to get values from the node.
 
 This can be used to get values from the underlying CAShapeLayer that OCDNode represents. It could also return a block, if it was set.
 
 @param path The path of the attribute you are trying to retrieve. Can be things like "position.y", "opacity", or "transform.scale.x"
 @return The object for the attribute at the given path.
 */
- (id)valueForAttributePath:(NSString *)path;


/**
 Allows animation(s) to be set on the node. These animations are run after the node has been updated with the latest attributes.

 @param animationBlock A block which creates appropriate animations and adds them to the group animation.
 @param completion A block of code which will be run when the animation completes or is cancelled.
 */
- (void)setTransition:(OCDNodeAnimationBlock)animationBlock completion:(OCDNodeAnimationCompletionBlock)completion;

/**
 Force a node to apply its attribute settings immediately. 
 */
- (void)updateAttributes;

@end
