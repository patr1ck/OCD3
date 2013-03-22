//
//  OCDScale.m
//  OCDView
//
//  Created by Patrick B. Gibson on 2/21/13.
//

#import "OCDScale.h"

typedef enum {
    OCDScaleTypeLinear
} OCDScaleType;

@interface OCDScale () {
    CGFloat _domainStart;
    CGFloat _domainEnd;
    CGFloat _rangeStart;
    CGFloat _rangeEnd;
}

@property (nonatomic, strong) NSArray *data;
@property (nonatomic, assign) OCDScaleType scaleType;

@end

@implementation OCDScale

+ (id)linearScaleWithDomainStart:(CGFloat)startNum
                       domainEnd:(CGFloat)endNum
                      rangeStart:(CGFloat)startIndex
                        rangeEnd:(CGFloat)endIndex;
{
    OCDScale *scale = [[OCDScale alloc] initWithDomainStart:startNum
                                                domainEnd:endNum
                                               rangeStart:startIndex
                                                 rangeEnd:endIndex];
    return scale;
}

- (id)initWithDomainStart:(CGFloat)domainStart domainEnd:(CGFloat)domainEnd rangeStart:(CGFloat)rangeStart rangeEnd:(CGFloat)rangeEnd;
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

- (CGFloat)scaleValue:(CGFloat)value;
{    
    switch (self.scaleType) {
        case OCDScaleTypeLinear: {
            // Shift the domain and range to be zero based
            CGFloat shiftedDomainEnd = (float) _domainEnd - _domainStart;
            CGFloat shiftedRangeEnd = (float) _rangeEnd - _rangeStart;
            
            // scale the number
            CGFloat scaled = (float) ( (float) (shiftedRangeEnd * (value - _domainStart)) / shiftedDomainEnd ) + _rangeStart;
            return scaled;
            break;
        }

            
        default:
            break;
    }
    
    return 0;
}

@end
