//
//  OCDNodeGenerator.h
//  OCD3
//
//  Created by Patrick B. Gibson on 3/6/13.
//  Copyright (c) 2013 Patrick B. Gibson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OCDNode;


/**
 OCDNodeFormatters can be used to simplify setting multiple properties on a node to achieve a specific shape or look. Currently, the only implemented formatter is the Arc node formatter, which allows you to set inner and outer radiuses, and uses the node data to draw an arc (or pie-like) shape.
 */

@interface OCDNodeFormatter : NSObject

/**
 Creates an arc node formatter with the provider 
 
 @param innerRadius The desired inner radius of the arc. 0 for a pie like shape.
 @param outerRadius The desired outer radius of the arc.
 @return A new arc formatter.
 */
+ (id)arcNodeFormatterWithInnerRadius:(CGFloat)innerRadius
                          outerRadius:(CGFloat)outerRadius;

/**
 Sets multiple values on multiples paths of a given node, formatting in a predefinied way.
 
 @param node The node to be formatted.
 */
- (void)formatNode:(OCDNode *)node;

@end
