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

typedef void (^OCDSelectionBlock)(OCDNode *node);
typedef NSValue * (^OCDSelectionValueBlock)(id data, NSUInteger index);
typedef NSValue * (^OCDSelectionAnimationBlock)(CABasicAnimation *animation);

@interface OCDNodeData : NSObject
+ (id)data;
@end

@interface OCDSelection : NSObject

@property (nonatomic, readonly) NSString *identifier;

- (OCDSelection *)setData:(NSArray *)dataArray;
- (OCDSelection *)setData:(NSArray *)dataArray usingKey:(id)key;
- (OCDSelection *)setEnter:(OCDSelectionBlock)enterBlock;
- (OCDSelection *)setTransition:(OCDSelectionAnimationBlock)animationBlock withDuration:(NSUInteger)duration;
- (OCDSelection *)setExit:(OCDSelectionBlock)exitBlock;

@end
