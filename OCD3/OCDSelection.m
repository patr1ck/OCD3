//
//  OCDSelection.m
//  OCDView
//
//  Created by Patrick Gibson on 2/15/13.
//

#import <QuartzCore/QuartzCore.h>

#import "OCDSelection.h"
#import "OCDSelection_Private.h"
#import "OCDNode.h"
#import "OCDNode_Private.h"
#import "OCDScale.h"
#import "OCDView_Private.h"

@implementation OCDNodeData

+ (id)data;
{
    return [[self alloc] init];
}

@end

@interface OCDSelection ()

// New
@property (nonatomic, strong) NSMutableArray *enteringNodeArray;
@property (nonatomic, strong) NSMutableArray *updatedNodeArray;
@property (nonatomic, strong) NSMutableArray *exitingNodeArray;


@property (nonatomic, strong) OCDView *view;
@end

@implementation OCDSelection


- (OCDSelection *)setData:(NSArray *)dataArray usingKey:(id)key;
{
    self.enteringNodeArray = [NSMutableArray arrayWithCapacity:10];
    self.updatedNodeArray = [NSMutableArray arrayWithCapacity:10];
    self.exitingNodeArray = [NSMutableArray arrayWithCapacity:10];
    
    // Shortcut for a new selection
    if ([self.dataArray count] == 0) {
        
        int index = 0;
        for (id value in dataArray) {
            OCDNode *node = [OCDNode nodeWithIdentifier:self.identifier];
            node.data = value;
            node.index = index++;
            node.key = key;
            [self.enteringNodeArray addObject:node];
        }
        
        self.dataArray = dataArray;
        return self;
    }
    
    // We already have data, so we want to do a data join.
    
    // Our sentinal value to track how far we have gone through dataArray
    int index = 0;
    
    // If we have a key, we will want to look for existing nodes with the same one.
    if (key) {
        for (id data in dataArray) {
            id lookupValue = [data objectForKey:key];
            BOOL updated = NO;
            
            
            // See if we have an existing node for this key/value. If we do, updated it.
            for (OCDNode *existingNode in self.selectedNodes) {
                id originalData = [existingNode.data objectForKey:key];
                
                // Extract the embedded data, if one exists
                NSDictionary *embeddedData = [existingNode.data objectForKey:@"data"];
                if (embeddedData) {
                    originalData = [embeddedData objectForKey:key];
                }
                
                if ([originalData isEqual:lookupValue]) {
                    existingNode.data = data;
                    existingNode.index = index;
                    [self.updatedNodeArray addObject:existingNode];
                    updated = YES;
                    break;
                }
            }
            
            // If we don't have an existing node, create a new one.
            if (!updated) {
                OCDNode *node = [OCDNode nodeWithIdentifier:self.identifier];
                node.data = data;
                node.index = index;
                node.key = key;
                [self.enteringNodeArray addObject:node];
            }
            
            index++;
        } // end looping through dataArray
        
    } else {
        // If we do NOT have a key, we should simply replace/update elements based on index.
        for (id data in dataArray) {

            // Check for updated values
            if (index < [self.selectedNodes count]) {
                OCDNode *existingNode = [self.selectedNodes objectAtIndex:index];
                if (![existingNode.data isEqual:data]) {
                    existingNode.data = data;
                    [self.updatedNodeArray addObject:existingNode];
                }
            }
            
            // Check for new values
            if (index >= [self.selectedNodes count]) {
                OCDNode *node = [OCDNode nodeWithIdentifier:self.identifier];
                node.data = data;
                node.index = index;
                node.key = key;
                [self.enteringNodeArray addObject:node];
            }
            
            index++;
        } // end looping through dataArray
    }
    
    // Remove old nodes
    for (OCDNode *oldNode in self.selectedNodes) {
        if ([self.updatedNodeArray containsObject:oldNode] || [self.enteringNodeArray containsObject:oldNode]) {
            continue;
        }
        [self.exitingNodeArray addObject:oldNode];
    }
    
    self.selectedNodes = [self.updatedNodeArray arrayByAddingObjectsFromArray:self.enteringNodeArray];
    self.dataArray = dataArray;
    
    return self;
}


- (OCDSelection *)setEnter:(OCDSelectionBlock)enterBlock;
{
    for (OCDNode *node in self.enteringNodeArray) {
        
        if (enterBlock != nil) {
            enterBlock(node); // the block is responsible for appending it to the view.
        }
        [node updateAttributes];
        
        if (node.transition) {
            [CATransaction begin];
            [node runAnimations];
            [CATransaction commit];
        }
    }
    return self;
}

- (OCDSelection *)setUpdate:(OCDSelectionBlock)updateBlock;
{
    for (OCDNode *node in self.updatedNodeArray) {
        
        if (updateBlock != nil) {
            updateBlock(node);
        }
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        
        [node updateAttributes];
        
        [CATransaction commit];
        
        if (node.transition) {
            [CATransaction begin];
            [node runAnimations];
            [CATransaction commit];
        }
    }
    
    return self;
}

- (OCDSelection *)setExit:(OCDSelectionBlock)exitBlock;
{
    for (OCDNode *node in self.exitingNodeArray) {
        [node updateAttributes];
        
        if (exitBlock != nil) {
            exitBlock(node);
        }

        if (node.transition) {
            [CATransaction begin];
            [node runAnimations];
            [CATransaction commit];
        }
    }
    
    return self;
}

@end
