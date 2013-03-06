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

@interface OCDViewController ()
@end

@implementation OCDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    BarChartView *barChart = [[BarChartView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)];
    [self.view addSubview:barChart];
    [barChart setup];
}




@end
