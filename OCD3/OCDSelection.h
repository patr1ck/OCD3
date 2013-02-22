//
//  OCDSelection.h
//  OCDView
//
//  Created by Patrick Gibson on 2/15/13.
//

#import <Foundation/Foundation.h>

@class OCDSelection;
@class OCDView;
@class OCDNode;

typedef void (^OCDSelectionEnterBlock)(OCDNode *node);
typedef NSValue * (^OCDSelectionValueBlock)(NSValue *data, NSUInteger index);

@interface OCDNodeData : NSObject
+ (id)data;
@end

@interface OCDSelection : NSObject

@property (nonatomic, readonly) NSString *identifier;

- (OCDSelection *)setData:(NSArray *)dataArray;
- (OCDSelection *)setEnter:(OCDSelectionEnterBlock)enterBlock;
- (OCDSelection *)setValue:(id)value forAttributePath:(NSString *)path;

@end
