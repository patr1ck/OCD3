//
//  OCDViewController.m
//  OCD3
//
//  Created by Patrick B. Gibson on 2/22/13.
//  Copyright (c) 2013 Patrick B. Gibson. All rights reserved.
//

#import "OCDViewController.h"
#import "OCD3.h"

#import "BarChartView.h"
#import "PieChartView.h"

@interface OCDViewController ()
@end

@implementation OCDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGSize viewSize = self.view.bounds.size;
    
//    BarChartView *barChart = [[BarChartView alloc] initWithFrame:CGRectMake(0, 0, viewSize.width, 100)];
//    [self.view addSubview:barChart];
//    [barChart setup];
    
    PieChartView *pieChart = [[PieChartView alloc] initWithFrame:CGRectMake(0, 110, viewSize.width, viewSize.width)];
    [self.view addSubview:pieChart];
}




@end
