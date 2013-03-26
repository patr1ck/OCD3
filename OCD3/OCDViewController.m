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
#import "OMGParticles.h"
#import "RisingBarChart.h"

typedef enum {
    OCDViewExampleBarChart = 0,
    OCDViewExamplePieChart,
    OCDViewExampleOMGParticles,
    OCDViewExampleRisingBar
} OCDViewExample;

@implementation OCDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"OCD3 Demo";
}

#pragma mark UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    switch (indexPath.row) {
        case OCDViewExampleBarChart:
            cell.textLabel.text = @"Bar Chart";
            break;
            
        case OCDViewExamplePieChart:
            cell.textLabel.text = @"Pie Chart";
            break;
            
        case OCDViewExampleOMGParticles:
            cell.textLabel.text = @"OMG Particles";
            break;
            
        case OCDViewExampleRisingBar:
            cell.textLabel.text = @"Rising Bar Chart";
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UIViewController *demoView = [[UIViewController alloc] init];
    demoView.title = @"Demo";
    demoView.view.backgroundColor = [UIColor whiteColor];
    CGSize viewSize = demoView.view.bounds.size;

    
    switch (indexPath.row) {
        case OCDViewExampleBarChart: {
            BarChartView *barChart = [[BarChartView alloc] initWithFrame:CGRectMake(0, 20, viewSize.width, 100)];
            [demoView.view addSubview:barChart];
            break;
        }
            
        case OCDViewExamplePieChart: {
            PieChartView *pieChart = [[PieChartView alloc] initWithFrame:CGRectMake(0, 20, viewSize.width, viewSize.width)];
            [demoView.view addSubview:pieChart];
            break;
        }
            
        case OCDViewExampleOMGParticles: {
            OMGParticles *particlesView = [[OMGParticles alloc] initWithFrame:CGRectMake(0, 0, viewSize.width, viewSize.height)];
            [demoView.view addSubview:particlesView];
            break;
        }
        
        case OCDViewExampleRisingBar: {
            RisingBarChart *risingView = [[RisingBarChart alloc] initWithFrame:CGRectMake(0, 0, viewSize.width, viewSize.height)];
            [demoView.view addSubview:risingView];
            break;
        }
            
        default:
            break;
    }
    
    [self.navigationController pushViewController:demoView animated:YES];
}

@end
