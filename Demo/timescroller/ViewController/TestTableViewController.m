//
//  TestTableViewController.m
//  timescroller
//
//  Created by Tobias Tiemerding on 5/2/14.
//  Copyright (c) 2014 Tobias Tiemerding. All rights reserved.
//

#import "TestTableViewController.h"

@interface TestTableViewController ()

@property (nonatomic, strong) TTTimeScroller *timeScroller;

@end

@implementation TestTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Demo";
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!_timeScroller){
        _timeScroller = [[TTTimeScroller alloc] initWithDelegate:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return MAX(arc4random() % 10, 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return MAX(arc4random() % 100, 1);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Section %li", (long)section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Cell with Index %li, %li", (long)indexPath.section, (long)indexPath.row];

    // Random color for more demo fun
    CGFloat hue = ( arc4random() % 256 / 256.0 );               //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    cell.backgroundColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TestTableViewController *viewController = [[TestTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - TTTimeScrollerDelegate

- (UITableView *)tableViewForTimeScroller:(TTTimeScroller *)timeScroller
{
    return self.tableView;
}

- (NSDate *)timeScroller:(TTTimeScroller *)timeScroller dateForCell:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSDate *randomDate = [[NSDate date] dateByAddingTimeInterval:indexPath.row * 60 * 60];
    return randomDate;
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_timeScroller scrollViewDidScroll];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_timeScroller scrollViewWillBeginDragging];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_timeScroller scrollViewDidEndDecelerating];
}

@end
