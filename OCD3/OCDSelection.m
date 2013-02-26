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
@property (nonatomic, strong) NSArray *enteringDataArray;
@property (nonatomic, strong) NSArray *updatedDataArray;
@property (nonatomic, strong) NSArray *exitingDataArray;
@property (nonatomic, strong) OCDSelectionEnterBlock enterBlock;
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
        id oldData = [self.dataArray objectAtIndex:i];
        id newData = [dataArray objectAtIndex:i];
        if (![oldData isEqual:newData]) {
            [dataToUpdate addObject:oldData];
        } 
    }
    
    // Find our exit set
    if (newDataCount < previousDataCount) {
        for (int i = (newDataCount - 1); i < previousDataCount; i++) {
            id oldDeletedData = [self.dataArray objectAtIndex:i];
            [dataToRemove addObject:oldDeletedData];
        }
    }

    self.enteringDataArray = dataToAdd;
    self.updatedDataArray = dataToUpdate;
    self.exitingDataArray = dataToRemove;
    self.dataArray = dataArray;
    
//    [CATransaction begin];
    if (self.selectedNodes) {
        for (int i = 0; i < previousDataCount; i++) {
            OCDNode *node = [self.selectedNodes objectAtIndex:i];
            [node setData:[self.dataArray objectAtIndex:i]];
        }
    }
//    [CATransaction commit];
    
    return self;
}

- (OCDSelection *)setEnter:(OCDSelectionEnterBlock)enterBlock;
{
    NSMutableArray *selectedNodes = [NSMutableArray arrayWithCapacity:10];
    
    for (NSValue *value in self.enteringDataArray) {
        OCDNode *node = [OCDNode nodeWithIdentifier:self.identifier];
        node.view = self.view;
        node.data = value;
        [selectedNodes addObject:node];
        [CATransaction begin];
        enterBlock(node); // the block is responsible for appending it to the view.
        [CATransaction commit];
    }
    
    [selectedNodes addObjectsFromArray:self.selectedNodes];
    self.selectedNodes = selectedNodes;
    return self;
}

- (OCDSelection *)setExit:(OCDSelectionEnterBlock)exitBlock;
{    
    for (NSValue *value in self.exitingDataArray) {
        [CATransaction begin];
#warning how do we get this node?
//        exitBlock(node);
        [CATransaction commit];
    }
    
    return self;
}

- (OCDSelection *)setValue:(id)value forAttributePath:(NSString *)path;
{
    int index = 0;
    for (OCDNode *node in self.selectedNodes) {
        [node setIndex:index];
        [node saveValue:value forAttributePath:path];
        [node updateAttributes];
        index++;
    }
    
    return self;
}

@end
