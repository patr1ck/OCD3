//
//  OCDSelection.h
//  OCDView
//
//  Created by Patrick Gibson on 2/15/13.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class OCDSelection;
@class OCDView;
@class OCDNode;

/**
 The selection block is used by the enter/update/exit methods to define the nodes presentaion.
 */
typedef void (^OCDSelectionBlock)(OCDNode *node);


/**
 The selection value block can be used as a value passed to setValue:forAttributePath: which is evaluated at run time.
 */
typedef NSValue * (^OCDSelectionValueBlock)(id data, NSUInteger index);



@interface OCDNodeData : NSObject
+ (id)data;
@end



/**
 Selections allow you to join data to them and define the behavior of entering nodes, updated nodes, and exciting nodes. All selections have an identifier which is defined by the user when created via the OCDView.
 */
@interface OCDSelection : NSObject

@property (nonatomic, readonly) NSString *identifier;

/**
 Joins a data array with OCDNode objects. Nodes which don't already exist are created and put into an "enter" state which can then be appended within the block passed to setEnter: method. Data with existing nodes are put into an updated state and can be modified in the block passed to the setUpdate: method. Nodes with removed data are moved to the "exit" state and can modified in the block passed to setExit before they are removed frome the view.
 
 @param dataArray An array of objects which will be joined with OCDNodes.
 @param key An object which acts as a primary key for the data. Can be nil.
 @return The selection that was messaged.
 */
- (OCDSelection *)setData:(NSArray *)dataArray usingKey:(id)key;

/**
 Sets the block which will be executed on selected nodes that are entering the view.
 
 @param enterBlock An array of objects which will be joined with OCDNodes.
 @return The selection that was messaged.
 */
- (OCDSelection *)setEnter:(OCDSelectionBlock)enterBlock;

/**
 Sets the block which will be executed on selected nodes that are remaining in the view and being updated.
 
 @param updateBlock An array of objects which will be joined with OCDNodes.
 @return The selection that was messaged.
 */
- (OCDSelection *)setUpdate:(OCDSelectionBlock)updateBlock;

/**
 Sets the block which will be executed on selected nodes that are exiting the view.
 
 @param exitBlock An array of objects which will be joined with OCDNodes.
 @return The selection that was messaged.
 */
- (OCDSelection *)setExit:(OCDSelectionBlock)exitBlock;

@end
