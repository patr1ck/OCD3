//
//  OCDNodeGenerator.h
//  OCD3
//
//  Created by Patrick B. Gibson on 3/6/13.
//  Copyright (c) 2013 Patrick B. Gibson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OCDNode;
@interface OCDNodeFormatter : NSObject

+ (id)arcNodeFormatterWithInnerRadius:(CGFloat)innerRadius outerRadius:(CGFloat)outerRadius;
- (void)formatNode:(OCDNode *)node;

@end
