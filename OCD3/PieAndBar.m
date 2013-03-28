//
//  PieAndBar.m
//  OCD3
//
//  Created by Patrick B. Gibson on 3/27/13.
//  Copyright (c) 2013 Patrick B. Gibson. All rights reserved.
//

#import "PieAndBar.h"
#import "OCD3.h"

#define kBarPaddingWidth 5.0f
#define kBarMaxHeight 200.0f

@interface PieAndBar () {
    BOOL _isPie;
}
@property (nonatomic, weak) OCDView *view;
@property (nonatomic, strong) OCDPieLayout *pieLayout;
@property (nonatomic, strong) OCDNodeFormatter *arcFormatter;
@property (nonatomic, strong) NSArray *data;
@end

@implementation PieAndBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        OCDView *newView = [[OCDView alloc] initWithFrame:self.bounds];
        [self addSubview:self.view];
        self.view = newView;
        
        _isPie = YES;
        
        self.data = @[ @{@"Browser": @"Chrome",             @"Percent": @42},
                    @{@"Browser": @"Safari",             @"Percent": @32},
                    @{@"Browser": @"Internet Explorer",  @"Percent": @11},
                    @{@"Browser": @"Firefox",            @"Percent": @10},
                    @{@"Browser": @"Other",              @"Percent": @5} ];
        
    
        self.arcFormatter = [OCDNodeFormatter arcNodeFormatterWithInnerRadius:100
                                                                  outerRadius:(self.bounds.size.width/2)];
        self.pieLayout = [OCDPieLayout layoutForDataArray:self.data usingKey:@"Percent"];
        self.pieLayout.startAngle = M_PI_2;
        self.pieLayout.endAngle = (2 * M_PI) + M_PI_2;
        OCDSelection *browsers = [[self.view selectAllWithIdentifier:@"browsers"] setData:[self.pieLayout layoutData]
                                                                                 usingKey:nil];
        
        [browsers setEnter:^(OCDNode *node) {
            [self.arcFormatter formatNode:node];
            
            NSLog(@"setting enter on node: %@", node);
            
            double hue = (double) arc4random() / 0x100000000;
            [node setValue:(id)[UIColor colorWithHue:hue saturation:0.95f brightness:0.95f alpha:1.0f].CGColor forAttributePath:@"fillColor"];
            [self.view appendNode:node withTransition:^(CAAnimationGroup *animationGroup, id data, NSUInteger index) {
            } completion:^(BOOL finished) {
                
            }];
        }];
        
        UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [toggleButton setTitle:@"Toggle Bar/Pie" forState:UIControlStateNormal];
        [toggleButton addTarget:self action:@selector(togglePressed:) forControlEvents:UIControlEventTouchUpInside];
        [toggleButton sizeToFit];
        toggleButton.frame = CGRectMake(self.bounds.size.width/2 - toggleButton.bounds.size.width/2,
                                        400, toggleButton.bounds.size.width, toggleButton.bounds.size.height);
        [self addSubview:toggleButton];
    }
    return self;
}

- (void)togglePressed:(id)sender;
{
    if (_isPie) {
        // Change to bar
        
        CGFloat barWidth = (self.bounds.size.width - kBarPaddingWidth * ([self.data count] - 1) ) / [self.data count];
        OCDSelection *browsers = [[self.view selectAllWithIdentifier:@"browsers"] setData:self.data
                                                                                 usingKey:@"Browser"];
        
        [browsers setUpdate:^(OCDNode *node) {
            NSLog(@"setting update on node: %@", node);
//            CGPathRef oldPath = [node valueForKeyPath:<#(NSString *)#>]
            CGPathRef fullBar = [OCDPath rectangleWithWidth:barWidth
                                                     height:[[node.data objectForKey:@"Percent"] floatValue]];
            [node setValue:(__bridge id)fullBar forAttributePath:@"path"];
            
            [node setValue:^(id data, NSUInteger index){
                return [NSNumber numberWithFloat:index * (barWidth + kBarPaddingWidth)];
            } forAttributePath:@"position.x"];
            
            [node setValue:^(id data, NSUInteger index){
                CGFloat dataValue = [[data objectForKey:@"Percent"] floatValue];
                return [NSNumber numberWithFloat:kBarMaxHeight - dataValue];
            } forAttributePath:@"position.y"];
            
            
            [node setValue:(id)[UIColor blueColor].CGColor forAttributePath:@"fillColor"];
            
            [self.view appendNode:node withTransition:^(CAAnimationGroup *animationGroup, id data, NSUInteger index) {
                CABasicAnimation *grow = [CABasicAnimation animationWithKeyPath:@"path"];
                grow.toValue = (__bridge id)fullBar;
                
                CABasicAnimation *move = [CABasicAnimation animationWithKeyPath:@"position.y"];
                CGFloat dataValue = [[data objectForKey:@"Percent"] floatValue];
                move.fromValue = [NSNumber numberWithFloat:kBarMaxHeight];
                move.toValue = [NSNumber numberWithFloat:kBarMaxHeight - dataValue];
                
                animationGroup.duration = 4;
                [animationGroup setAnimations:@[grow, move]];
            } completion:nil];
        }];
        
    } else {        
        // Change to pie
        OCDSelection *browsers = [[self.view selectAllWithIdentifier:@"browsers"] setData:[self.pieLayout layoutData]
                                                                                 usingKey:@"Browser"];
        
        [browsers setUpdate:^(OCDNode *node) {
            [self.arcFormatter formatNode:node];
                        NSLog(@"setting update on node: %@", node);
            double hue = (double) arc4random() / 0x100000000;
            [node setValue:(id)[UIColor colorWithHue:hue saturation:0.95f brightness:0.95f alpha:1.0f].CGColor forAttributePath:@"fillColor"];
        }];
    }
    
    _isPie = !_isPie;
}

@end
