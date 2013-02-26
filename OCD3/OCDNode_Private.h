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
@property (nonatomic, strong) NSValue *data;
@property (nonatomic, assign) NSUInteger index;

- (void)instantiateLayer;
- (void)updateAttributes;
- (void)saveValue:(id)value forAttributePath:(NSString *)path;

@end
