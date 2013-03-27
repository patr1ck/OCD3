//
//  OCDPath.m
//  OCD3
//
//  Created by Patrick B. Gibson on 3/26/13.
//  Copyright (c) 2013 Patrick B. Gibson. All rights reserved.
//

#import "OCDPath.h"

@implementation OCDPath

+ (CGPathRef)rectangleWithWidth:(CGFloat)width
                         height:(CGFloat)height;
{
    return CGPathCreateWithRect(CGRectMake(0, 0, width, height), NULL);
}

+ (CGPathRef)circleWithRadius:(CGFloat)radius;
{
    return CGPathCreateWithEllipseInRect(CGRectMake(0, 0, radius, radius), NULL);
}

+ (CGPathRef)lineWithStartPoint:(CGPoint)startPoint
                       endPoint:(CGPoint)endPoint;
{
    CGMutablePathRef newPath = CGPathCreateMutable();
    CGPathMoveToPoint(newPath, NULL, startPoint.x, startPoint.y);
    CGPathAddLineToPoint(newPath, NULL, endPoint.x, endPoint.y);
    return newPath;
}

+ (CGPathRef)arcWithInnerRadius:(CGFloat)innerRadius
                     outerRadus:(CGFloat)outerRadius
                     startAngle:(CGFloat)startAngle
                       endAngle:(CGFloat)endAngle;
{
    float center = outerRadius;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, center, center);
    
    CGPoint arcStartPointOuter = CGPointMake(center + outerRadius * cosf(startAngle), center + outerRadius * sinf(startAngle));
    
    // Some basic trig at play here: http://en.wikipedia.org/wiki/Circle#Equations
    if (innerRadius != 0) {
        CGPoint arcStartPointInner = CGPointMake(center + innerRadius * cosf(startAngle), center + innerRadius * sinf(startAngle));
        CGPathMoveToPoint(path, NULL, arcStartPointInner.x, arcStartPointInner.y);
    }
    
    CGPathAddLineToPoint(path, NULL, arcStartPointOuter.x, arcStartPointOuter.y);
    CGPathAddArc(path, NULL, center, center, outerRadius, startAngle, endAngle, 0);
    
    if (innerRadius != 0) {
        CGPoint arcEndPointInner = CGPointMake(center + innerRadius * cosf(endAngle), center + innerRadius * sinf(endAngle));
        CGPathAddLineToPoint(path, NULL, arcEndPointInner.x, arcEndPointInner.y);
        CGPathAddArc(path, NULL, center, center, innerRadius, endAngle, startAngle, 1);
    } else {
        CGPathAddLineToPoint(path, NULL, center, center);
    }
    
    return path;
}

@end
