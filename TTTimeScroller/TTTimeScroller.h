//
//  TTTimeScroller.h
//  timescroller
//
//  Created by Tobias Tiemerding on 5/2/14.
//  Copyright (c) 2014 Tobias Tiemerding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class TTTimeScroller;

@protocol TTTimeScrollerDelegate <NSObject>

@required

- (UITableView *)tableViewForTimeScroller:(TTTimeScroller *)timeScroller;
- (NSDate *)timeScroller:(TTTimeScroller *)timeScroller dateForCell:(UITableViewCell *)cell;

@end


@interface TTTimeScroller : UIView

@property (nonatomic, weak) id <TTTimeScrollerDelegate> timeScrollerDelegate;

- (id)initWithDelegate:(id <TTTimeScrollerDelegate>)timeScrollerDelegate;

- (void)scrollViewDidScroll;

@end
