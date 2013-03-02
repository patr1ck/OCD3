//
//  OCDNode_Private.h
//  OCDView
//
//  Created by Patrick B. Gibson on 2/19/13.
//

#import "OCDNode.h"

@class OCDView;

@interface OCDNode ()

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, weak) OCDView *view;
@property (nonatomic, strong) id data;
@property (nonatomic, strong) id key;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) OCDNodeAnimationBlock animationBlock;

- (void)instantiateLayer;
- (void)updateAttributes;

@end
