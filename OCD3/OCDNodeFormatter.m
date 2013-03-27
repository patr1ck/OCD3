//
//  OCDNodeGenerator.m
//  OCD3
//
//  Created by Patrick B. Gibson on 3/6/13.
//  Copyright (c) 2013 Patrick B. Gibson. All rights reserved.
//

#import "OCDNodeFormatter.h"
#import "OCDNode.h"
#import "OCDPath.h"

typedef enum {
    OCDNodeFormatterTypeArc
} OCDNodeFormatterType ;

@interface OCDNodeFormatter ()
@property (nonatomic, assign) OCDNodeFormatterType formatterType;
@property (nonatomic, strong) NSDictionary *attributeDictionary;
@property (nonatomic, assign) CGFloat innerRadius;
@property (nonatomic, assign) CGFloat outerRadius;
@end

@implementation OCDNodeFormatter

+ (id)arcNodeFormatterWithInnerRadius:(CGFloat)innerRadius outerRadius:(CGFloat)outerRadius;
{
    OCDNodeFormatter *arcFormatter = [[OCDNodeFormatter alloc] init];
    arcFormatter.formatterType = OCDNodeFormatterTypeArc;
    
    arcFormatter.innerRadius = innerRadius;
    arcFormatter.outerRadius = outerRadius;
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
    for (NSString *key in [self.attributeDictionary keyEnumerator]) {
        [node setValue:[self.attributeDictionary valueForKey:key] forAttributePath:key];
    }
    
    switch (self.formatterType) {
        case OCDNodeFormatterTypeArc: {
            NSDictionary *dataDictionary = (NSDictionary *)node.data;
            [node setValue:[NSValue valueWithCGRect:CGRectMake(0, 0, self.outerRadius*2, self.outerRadius*2)] forAttributePath:@"bounds"];
            
            CGPathRef path = [OCDPath arcWithInnerRadius:self.innerRadius
                                              outerRadus:self.outerRadius
                                              startAngle:[[dataDictionary objectForKey:@"startAngle"] floatValue]
                                                endAngle:[[dataDictionary objectForKey:@"endAngle"] floatValue]];
            
            [node setValue:(__bridge_transfer id)path forAttributePath:@"path"];
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
