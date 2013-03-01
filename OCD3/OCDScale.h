//
//  OCDScale.h
//  OCDView
//
//  Created by Patrick B. Gibson on 2/21/13.
//

#import <Foundation/Foundation.h>

@interface OCDScale : NSObject

+ (id)ordinalScaleWithData:(NSArray *)data
                rangeStart:(NSUInteger)startIndex
                  rangeEnd:(NSUInteger)endIndex;

+ (id)linearScaleWithDomainStart:(NSNumber *)startNum
                       domainEnd:(NSNumber *)endNum
                      rangeStart:(NSUInteger)startIndex
                        rangeEnd:(NSUInteger)endIndex;

- (id)scaleValue:(NSNumber *)value;

@end
