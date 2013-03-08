//
//  OCDNode.h
//  OCDView
//
//  Created by Patrick Gibson on 2/15/13.
//

#import <Foundation/Foundation.h>

typedef enum {
    OCDNodeTypeCircle,
    OCDNodeTypeLine,
    OCDNodeTypeRectangle,
    OCDNodeTypeArc
} OCDNodeType;

typedef void (^OCDNodeAnimationBlock)(CAAnimationGroup *animationGroup, id data, NSUInteger index);

@interface OCDNode : NSObject

@property (nonatomic, assign) OCDNodeType nodeType;
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) id data;
@property (nonatomic, readonly) id key;
@property (nonatomic, strong) NSString *text;

+ (id)nodeWithIdentifier:(NSString *)identifier;
- (void)setValue:(id)value forAttributePath:(NSString *)path;

- (void)setTransition:(OCDNodeAnimationBlock)animationBlock;
- (void)setExitTransition:(OCDNodeAnimationBlock)animationBlock;

- (void)updateAttributes;

@end
