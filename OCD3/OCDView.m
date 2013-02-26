//
//  OCDView.m
//  OCDView
//
//  Created by Patrick Gibson on 2/15/13.
//

#import <QuartzCore/QuartzCore.h>

#import "OCDView.h"
#import "OCDView_Private.h"

#import "OCDNode.h"
#import "OCDSelection_Private.h"
#import "OCDNode_Private.h"

@interface OCDView ()

@end

@implementation OCDView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.nodes = [[NSMutableArray alloc] initWithCapacity:10];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (OCDSelection *)selectAllWithIdentifier:(NSString *)identifier;
{
    OCDSelection *selection = [[OCDSelection alloc] init];
    selection.identifier = identifier;
    
    // Search view for existing nodes with given identifier.
    NSMutableArray *existingNodes = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray *existingData = [[NSMutableArray alloc] initWithCapacity:10];
    for (OCDNode *node in self.nodes) {
        if ([node.identifier isEqualToString:identifier]) {
            [existingNodes addObject:node];
            [existingData addObject:node.data];
        }
    }
    
    // Attache the selection to the nodes.
    selection.selectedNodes = existingNodes;
    selection.dataArray = existingData;
    
    return selection;
}

- (void)append:(OCDNode *)node;
{
    // Ensure the node doesn't already exist in the view
    for (OCDNode *existingNode in self.nodes) {
        if ([existingNode isEqual:node]) {
            return;
        }
    }
    
    // Add the sublayer
    [self.layer addSublayer:node.shapeLayer];
    [self.nodes addObject:node];
}

@end
