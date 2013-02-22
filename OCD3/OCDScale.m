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

- (id)valueAtIndex:(NSUInteger)index
{    
    switch (self.scaleType) {
        case OCDScaleTypeLinear: {
            CGFloat scaleFactor = (float) _rangeEnd / _domainEnd;
            return [NSNumber numberWithFloat:scaleFactor];
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
