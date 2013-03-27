//
//  OCDPath.h
//  OCD3
//
//  Created by Patrick B. Gibson on 3/26/13.
//  Copyright (c) 2013 Patrick B. Gibson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCDPath : NSObject

/** 
 Creates a path for a rectangle.
 
 @param width The rectangle's width.
 @param height The rectangle's width.
 @return A path with a recangle 
 */

+ (CGPathRef)rectangleWithWidth:(CGFloat)width
                         height:(CGFloat)height;

/**
 Creates a path for a circle.
 
 @param radius The circle's radius.
 @return A path with for a circles with specified radius
 */

+ (CGPathRef)circleWithRadius:(CGFloat)radius;

/**
 Creates a path for a line.
 
 @param startPoint The start point of the line
 @param endPoint The end point of the line
 @return A path with for a line with the specified start and end points
 */

+ (CGPathRef)lineWithStartPoint:(CGPoint)startPoint
                       endPoint:(CGPoint)endPoint;

/**
 Creates a path for an arc.
 
 @param innerRadius The start point of the line
 @param outerRadius The end point of the line
 @param startAngle The start point of the line
 @param endAngle The end point of the line
 @return A path with for a line with the specified start and end points
 */

+ (CGPathRef)arcWithInnerRadius:(CGFloat)innerRadius
                     outerRadus:(CGFloat)outerRadius
                     startAngle:(CGFloat)startAngle
                       endAngle:(CGFloat)endAngle;


@end
