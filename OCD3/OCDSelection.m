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
// Old
@property (nonatomic, strong) NSArray *enteringDataArray;
@property (nonatomic, strong) NSArray *updatedDataArray;
@property (nonatomic, strong) NSMutableArray *exitingNodeArray;

// New
@property (nonatomic, strong) NSMutableArray *enteringNodeArray;
@property (nonatomic, strong) NSMutableArray *updatedNodeArray;


@property (nonatomic, strong) OCDView *view;
@end

@implementation OCDSelection

- (OCDSelection *)setData:(NSArray *)dataArray;
{
    // Shortcut: If this is the first time we're being set, we can just set the appropriate values.
    if ([self.dataArray count] == 0) {
        self.dataArray = dataArray;
        self.enteringDataArray = dataArray;
        return self;
    }
    
    NSMutableArray *dataToAdd = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *dataToRemove = [NSMutableArray arrayWithCapacity:10];
    NSMutableArray *dataToUpdate = [NSMutableArray arrayWithCapacity:10];

    // Find our enter set
    const int previousDataCount = [self.dataArray count];
    const int newDataCount = [dataArray count];
    if (newDataCount > previousDataCount) {
        
        for (int i = (previousDataCount - 1); i < newDataCount; i++) {
            id newData = [dataArray objectAtIndex:i];
            [dataToAdd addObject:newData];
        }
    }
    
    // Find our updated set
    for (int i = 0; i < previousDataCount; i++) {
        if (i >= newDataCount) {
            break;
        }
        
        id oldData = [self.dataArray objectAtIndex:i];
        id newData = [dataArray objectAtIndex:i];
        if (![oldData isEqual:newData]) {
            [dataToUpdate addObject:oldData];
        } 
    }
    
    // Find our exit set
    // Not sure if this is useful.
    if (newDataCount < previousDataCount) {
        for (int i = newDataCount; i < previousDataCount; i++) {
            id oldDeletedData = [self.dataArray objectAtIndex:i];
            [dataToRemove addObject:oldDeletedData];
        }
    }

    self.enteringDataArray = dataToAdd;
    self.updatedDataArray = dataToUpdate;
    self.dataArray = dataArray;
    
    
    // This should be moved out into an update / transition method
    if (self.selectedNodes) {
        for (int i = 0; i < newDataCount; i++) {
            OCDNode *node = [self.selectedNodes objectAtIndex:i];
            [node setData:[self.dataArray objectAtIndex:i]];
        }
    }
    
    self.exitingNodeArray = [NSMutableArray arrayWithCapacity:10];
    if ([dataToRemove count] > 0) {
        
        NSMutableArray *newSelected = [self.selectedNodes mutableCopy];
        for (int i = 0; i < [dataToRemove count]; i++) {
            int indexToRemove = [self.selectedNodes count] - [dataToRemove count];
            OCDNode *nodeToRemoveFromSelection = [newSelected objectAtIndex:indexToRemove];
            [self.exitingNodeArray addObject:nodeToRemoveFromSelection];
            [newSelected removeObjectAtIndex:indexToRemove];
        }
        self.selectedNodes = newSelected;
    }
    
    return self;
}

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
    
    int index = 0;
    if (key) {
        for (id data in dataArray) {
            id lookupValue = [data objectForKey:key];
            BOOL updated = NO;
            
            NSLog(@"Looking up by value %@", lookupValue);
            
            // See if we have an existing node for this key/value. If we do, updated it.
            for (OCDNode *existingNode in self.selectedNodes) {
                NSLog(@"Existing value: %@", [existingNode.data objectForKey:key]);
                if ([[existingNode.data objectForKey:key] isEqual:lookupValue]) {
                    existingNode.data = data;
                    existingNode.index = index;
                    [self.updatedNodeArray addObject:existingNode];
                    updated = YES;
                    NSLog(@"updating object with data: %@", data);
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
                NSLog(@"creating new object with data: %@", data);
            }
            
            index++;
        } // end looping through dataArray
        
        // Remove nodes
        for (OCDNode *oldNode in self.selectedNodes) {
            if ([self.updatedNodeArray containsObject:oldNode] || [self.enteringNodeArray containsObject:oldNode]) {
                continue;
            }
            [self.exitingNodeArray addObject:oldNode];
        }
        
        self.selectedNodes = [self.updatedNodeArray arrayByAddingObjectsFromArray:self.enteringNodeArray];
        
        self.dataArray = dataArray;
    } // End if key
    
    return self;
}


- (OCDSelection *)setEnter:(OCDSelectionBlock)enterBlock;
{
    for (OCDNode *node in self.enteringNodeArray) {        
        [CATransaction begin];
        enterBlock(node); // the block is responsible for appending it to the view.
        [CATransaction commit];
        
        [node updateAttributes];
    }
    return self;
}

- (OCDSelection *)setTransition:(OCDSelectionAnimationBlock)animationBlock withDuration:(NSUInteger)duration;
{
    for (OCDNode *node in self.updatedNodeArray) {
        [node updateAttributes];
    }
    
    
//    for (OCDNode *node in self.updatedNodeArray) {
//        [CATransaction begin];
//        CABasicAnimation *animation = [CABasicAnimation animation];
//        
//        animationBlock(animation); // the block is responsible for removing it from the view.
//        [node.shapeLayer addAnimation:animation forKey:@"updatingAnimation"];
//        [CATransaction commit];
//    }
    
    return self;
}

- (OCDSelection *)setExit:(OCDSelectionBlock)exitBlock;
{
    for (OCDNode *node in self.exitingNodeArray) {
        [CATransaction begin];
        exitBlock(node); // the block is responsible for removing it from the view.
        [CATransaction commit];
    }
    
    return self;
}

- (OCDSelection *)setValue:(id)value forAttributePath:(NSString *)path;
{
    int index = 0;
    for (OCDNode *node in self.selectedNodes) {
        [node setIndex:index];
        [node setValue:value forAttributePath:path];
        [node updateAttributes];
        index++;
    }
    
    return self;
}

@end
