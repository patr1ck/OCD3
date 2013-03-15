//
//  OCDNode_Private.h
//  OCDView
//
//  Created by Patrick B. Gibson on 2/19/13.
//

#import "OCDNode.h"
#import "OCDSelection.h"

@class OCDView;

@interface OCDNode ()

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CATextLayer *textLayer;
@property (nonatomic, weak) OCDView *view;
@property (nonatomic, strong) id data;
@property (nonatomic, strong) id key;
@property (nonatomic, assign) NSUInteger index;

@property (nonatomic, assign) BOOL shouldFireExit;
@property (nonatomic, strong) OCDNodeAnimationBlock transition;
@property (nonatomic, strong) OCDNodeAnimationCompletionBlock completion;

- (void)instantiateLayer;
- (void)runAnimations;

@end
