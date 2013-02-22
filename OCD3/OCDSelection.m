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

@implementation OCDNodeData

+ (id)data;
{
    return [[self alloc] init];
}

@end

@interface OCDSelection ()
@property (nonatomic, strong) NSArray *previousDataArray;
@property (nonatomic, strong) NSArray *enteringDataArray;
@property (nonatomic, strong) NSArray *exitingDataArray;
@property (nonatomic, strong) OCDSelectionEnterBlock enterBlock;
@property (nonatomic, strong) OCDView *view;
@end

@implementation OCDSelection

- (OCDSelection *)setData:(NSArray *)dataArray;
{
//    NSMutableArray *newData = [NSMutableArray arrayWithCapacity:10];
//    NSMutableArray *dataToRemove = [NSMutableArray arrayWithCapacity:10];
    
    // Shortcut: If this is the first time we're being set, we can just set the appropriate values.
    if (self.previousDataArray == nil) {
        self.previousDataArray = dataArray;
        self.enteringDataArray = dataArray;
        return self;
    }
    
//    // Find our entering set
//    for (NSValue *value in dataArray) {
//        if ( ![self.previousDataArray containsObject:value]) {
//            [newData addObject:value];
//        }
//    }
//    self.enteringDataArray = newData;
//    
//    // Find our exiting data
//    for (NSValue *value in dataArray) {
//        if ([self.previousDataArray containsObject:value]) {
//            [dataToRemove addObject:value];
//        }
//    }
//    self.exitingDataArray = dataToRemove;
//    
//    self.previousDataArray = dataArray;
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
        enterBlock(node);
        [CATransaction commit];
    }
    
#warning self.selectedNodes may already be set if nodes already exist
    self.selectedNodes = selectedNodes;
    return self;
}

- (OCDSelection *)setValue:(id)value forAttributePath:(NSString *)path;
{
    NSLog(@"Selection: %@", self.selectedNodes);
    NSLog(@"Setting value: %@ for path: %@", value, path);
    int index = 0;
    for (OCDNode *node in self.selectedNodes) {
        NSLog(@"Node: %@", node);
        
        if ([value isKindOfClass:NSClassFromString(@"NSBlock")]) {
            // If the value is a block, evalute it before passing it through.
            
            OCDSelectionValueBlock block = (OCDSelectionValueBlock)value;
            NSValue *newValue = block(node.data, index);
            [node setValue:newValue forAttributePath:path];
        } else if ([value isKindOfClass:[OCDNodeData class]]) {
            // If the value is a special "OCDNodeData" type, pull the data for the node and pass it through.
            
            NSValue *newValue = node.data;
            NSLog(@"relpacing value of OCDNodeData with %@", newValue);
            [node setValue:newValue forAttributePath:path];
        } else if ([value isKindOfClass:[OCDScale class]]) {
            // If the value is a scale, scale the data
            
            OCDScale *scale = (OCDScale *)value;
            CGFloat scaleValue = [[scale valueAtIndex:index] floatValue];
            CGFloat scaledDataValue = [(NSNumber *)node.data floatValue] * scaleValue;
            [node setValue:[NSNumber numberWithFloat:scaledDataValue] forAttributePath:path];
        } else {
            // Pass it through
            [node setValue:value forAttributePath:path];
        }

        index++;
    }
    
    return self;
}

@end
