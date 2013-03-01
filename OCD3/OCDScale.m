//
//  OCDScale.m
//  OCDView
//
//  Created by Patrick B. Gibson on 2/21/13.
//

#import "OCDScale.h"

typedef enum {
    OCDScaleTypeLinear,
    OCDScaleTypeOrdinal
} OCDScaleType;

@interface OCDScale () {
    NSUInteger _domainStart;
    NSUInteger _domainEnd;
    NSUInteger _rangeStart;
    NSUInteger _rangeEnd;
}

@property (nonatomic, strong) NSArray *data;
@property (nonatomic, assign) OCDScaleType scaleType;

@end

@implementation OCDScale

+ (id)ordinalScaleWithData:(NSArray *)data rangeStart:(NSUInteger)startIndex rangeEnd:(NSUInteger)endIndex;
{
    return nil;
}

+ (id)linearScaleWithDomainStart:(NSNumber *)startNum
                       domainEnd:(NSNumber *)endNum
                      rangeStart:(NSUInteger)startIndex
                        rangeEnd:(NSUInteger)endIndex;
{
    OCDScale *scale = [[OCDScale alloc] initWithDomainStart:[startNum floatValue]
                                                domainEnd:[endNum floatValue]
                                               rangeStart:startIndex
                                                 rangeEnd:endIndex];
    return scale;
}

- (id)initWithDomainStart:(CGFloat)domainStart domainEnd:(CGFloat)domainEnd rangeStart:(NSUInteger)rangeStart rangeEnd:(NSUInteger)rangeEnd;
{
    self = [super init];
    if (self) {
        _domainStart = domainStart;
        _domainEnd = domainEnd;
        _rangeStart = rangeStart;
        _rangeEnd = rangeEnd;
        self.scaleType = OCDScaleTypeLinear;
    }
    return self;
}

- (id)scaleValue:(NSNumber *)value;
{
    CGFloat valuef = [value floatValue];
    
    switch (self.scaleType) {
        case OCDScaleTypeLinear: {
            // Shift the domain and range to be zero based
            CGFloat shiftedDomainEnd = (float) _domainEnd - _domainStart;
            CGFloat shiftedRangeEnd = (float) _rangeEnd - _rangeStart;
            
            // scale the number
            CGFloat scaled = (float) ( (float) (shiftedRangeEnd * (valuef - _domainStart)) / shiftedDomainEnd ) + _rangeStart;
            return [NSNumber numberWithFloat:scaled];
            break;
        }
            
        case OCDScaleTypeOrdinal:
            
            break;
            
        default:
            break;
    }
    
    return nil;
}

@end
