//
//  OCDNode.h
//  OCDView
//
//  Created by Patrick Gibson on 2/15/13.
//

#import <Foundation/Foundation.h>

typedef enum {
    OCDNodeTypeCircle,
    OCDNodeTypeSquare,
    OCDNodeTypeRectangle
} OCDNodeType;

@interface OCDNode : NSObject

@property (nonatomic, assign) OCDNodeType nodeType;
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSValue *data;

+ (id)nodeWithIdentifier:(NSString *)identifier;
- (void)setValue:(id)value forAttributePath:(NSString *)path;

@end
