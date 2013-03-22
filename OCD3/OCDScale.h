//
//  OCDScale.h
//  OCDView
//
//  Created by Patrick B. Gibson on 2/21/13.
//

#import <Foundation/Foundation.h>

@interface OCDScale : NSObject

+ (id)linearScaleWithDomainStart:(CGFloat)startNum
                       domainEnd:(CGFloat)endNum
                      rangeStart:(CGFloat)startIndex
                        rangeEnd:(CGFloat)endIndex;

- (CGFloat)scaleValue:(CGFloat)value;

@end
