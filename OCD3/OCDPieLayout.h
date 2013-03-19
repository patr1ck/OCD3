//
//  OCDPieLayout.h
//  OCD3
//
//  Created by Patrick B. Gibson on 3/7/13.
//  Copyright (c) 2013 Patrick B. Gibson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCDPieLayout : NSObject

@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat endAngle;

+ (id)layoutForDataArray:(NSArray *)data usingKey:(NSString *)key;
- (NSArray *)layoutData;

@end
