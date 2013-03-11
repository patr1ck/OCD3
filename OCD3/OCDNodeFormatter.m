//
//  OCDNodeGenerator.m
//  OCD3
//
//  Created by Patrick B. Gibson on 3/6/13.
//  Copyright (c) 2013 Patrick B. Gibson. All rights reserved.
//

#import "OCDNodeFormatter.h"
#import "OCDNode.h"

typedef enum {
    OCDNodeFormatterTypeArc
} OCDNodeFormatterType ;

@interface OCDNodeFormatter ()
@property (nonatomic, assign) OCDNodeFormatterType formatterType;
@property (nonatomic, strong) NSDictionary *attributeDictionary;
@end

@implementation OCDNodeFormatter

+ (id)arcNodeFormatterWithInnerRadius:(CGFloat)innerRadius outerRadius:(CGFloat)outerRadius;
{
    OCDNodeFormatter *arcFormatter = [[OCDNodeFormatter alloc] init];
    arcFormatter.formatterType = OCDNodeFormatterTypeArc;
    
    [arcFormatter setValue:[NSNumber numberWithFloat:innerRadius] forAttributePath:@"shape.innerRadius"];
    [arcFormatter setValue:[NSNumber numberWithFloat:outerRadius] forAttributePath:@"shape.outerRadius"];
    [arcFormatter setValue:[NSNumber numberWithFloat:outerRadius] forAttributePath:@"position.x"];
    [arcFormatter setValue:[NSNumber numberWithFloat:outerRadius] forAttributePath:@"position.y"];
    
    return arcFormatter;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.attributeDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return self;
}

- (void)formatNode:(OCDNode *)node;
{
    node.nodeType = OCDNodeTypeArc;
    
    for (NSString *key in [self.attributeDictionary keyEnumerator]) {
        [node setValue:[self.attributeDictionary valueForKey:key] forAttributePath:key];
    }
    
    switch (self.formatterType) {
        case OCDNodeFormatterTypeArc: {
            NSDictionary *dataDictionary = (NSDictionary *)node.data;
            [node setValue:[dataDictionary objectForKey:@"startAngle"] forAttributePath:@"shape.startAngle"];
            [node setValue:[dataDictionary objectForKey:@"endAngle"] forAttributePath:@"shape.endAngle"];
            break;
        }
            
        default:
            break;
    }
}

- (void)setValue:(id)value forAttributePath:(NSString *)path
{
    [self.attributeDictionary setValue:value forKey:path];
}

@end
