//
//  OCDView.h
//  OCDView
//
//  Created by Patrick Gibson on 2/15/13.
//

#import <UIKit/UIKit.h>

#import "OCDSelection.h"
#import "OCDNode.h"

/**
 An OCDView plays host to all OCD content. Using an OCDView you can
 
 - Append new nodes (optionally with animations)
 - Remove existing nodes
 - Create selections
 */

@interface OCDView : UIView

/**
 The primary way you'll want to interact with OCDView objects. Getting a seleciton allows you to join data to it in order to create, update and delete OCDNode objects.
 
 @param identifier The identifier of the node(s) you would like to be selected.
 @return An OCDSelection object representing the selection.
 */

- (OCDSelection *)selectAllWithIdentifier:(NSString *)identifier;

/**
 Allows you to manually add nodes to an OCDView. Note that you could call -updateAttributes on the node itself before adding it, to ensure its values have been applied to the underlying layer.
 
 @param node The node to add.
 */

- (void)appendNode:(OCDNode *)node;

/**
 Allows you to manually add nodes to an OCDView with a given animation and completion block. Note that you could call -updateAttributes on the node itself before adding it, to ensure its values have been applied to the underlying layer.
 
 @param node The node to add.
 @param transition The animation block.
 @param completion The compelition block.
 */

- (void)appendNode:(OCDNode *)node
    withTransition:(OCDNodeAnimationBlock)transition
        completion:(OCDNodeAnimationCompletionBlock)completion;


/**
 Allows you to manually remove a node from an OCDView.
 
 @param node The node to remove from the view.
 */
- (void)remove:(OCDNode *)node;

@end
