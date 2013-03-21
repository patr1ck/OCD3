//
//  OCDPieLayout.h
//  OCD3
//
//  Created by Patrick B. Gibson on 3/7/13.
//  Copyright (c) 2013 Patrick B. Gibson. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 OCDPieLayout is the first of hopefully many OCDLayout classes which aid in laying out data in familiar forms. Obviously, the OCDPieLayout helps create a pie chart. It does this by converting your original data array (with optional key) into a new data array with keys and values that are needed for the expected node types.
 */
@interface OCDPieLayout : NSObject

/**
 The angle at which the first pie slice begins (in radians).
 */
@property (nonatomic, assign) CGFloat startAngle;

/**
 The angle at which the last pie slice ends (in radians).
 */
@property (nonatomic, assign) CGFloat endAngle;

/**
 Creates a new OCDPieLayout
 
 @param data The data to be formatted.
 @param key The key of the data.
 @return A new OCDPieLayout object.
 */
+ (id)layoutForDataArray:(NSArray *)data usingKey:(NSString *)key;

/**
 Returns a data array based on the layout attributes that can be passed to an OCDSelection.
 */
- (NSArray *)layoutData;

@end
