 //
//  TTTimeScroller.m
//  timescroller
//
//  Created by Tobias Tiemerding on 5/2/14.
//  Copyright (c) 2014 Tobias Tiemerding. All rights reserved.
//

#import "TTTimeScroller.h"

@interface TTTimeScroller ()

@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIView *hours, *minutes;
@property (nonatomic, strong) NSDate *lastDate;
@property (nonatomic, strong) UILabel *dateLabel;

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIImageView *scrollBar;

@property (nonatomic, copy) NSDateFormatter *timeFormatter;
@property (nonatomic, copy) NSDateFormatter *dateFormatter;

- (void)captureTableViewAndScrollBar;

@end

@implementation TTTimeScroller

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        [self.layer insertSublayer:self.toolbar.layer atIndex:0];
        
        // If we don't clip to bounds the toolbar draws a thin shadow on top
        self.clipsToBounds = YES;
        
        // Create mask layer
        CALayer* maskLayer = [CALayer layer];
        maskLayer.frame = CGRectMake(0, 0, CGRectGetWidth(frame) , CGRectGetHeight(frame));
        maskLayer.contents = (__bridge id)[[UIImage imageNamed:@"mask"] CGImage];
        
        // Apply the mask layer
        self.toolbar.layer.mask = maskLayer;
        self.toolbar.layer.masksToBounds = YES;
        self.toolbar.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        self.toolbar.barTintColor = [[[[UIApplication sharedApplication] delegate] window] tintColor];
        
        // Get tint color
        UIColor *tintColor = [[[[UIApplication sharedApplication] delegate] window] tintColor];
        if(!tintColor){
            tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
        }
        
        // Clock
        _hours = [[UIView alloc] initWithFrame:CGRectMake(15.0f, 9.0f, 2.0f, 11.0f)];
        _hours.layer.anchorPoint = CGPointMake(0.5f, 1.0/11.0f);
        _hours.layer.cornerRadius = 1.0;
        _hours.layer.shouldRasterize = YES;
        _hours.layer.contentsScale = [[UIScreen mainScreen] scale];
        _hours.backgroundColor = tintColor;
        [self addSubview:_hours];
        
        _minutes = [[UIView alloc] initWithFrame:CGRectMake(15.0f, 8.0f, 2.0f, 13.0f)];
        _minutes.layer.anchorPoint = CGPointMake(0.5f, 1.0/13.0f);
        _minutes.layer.cornerRadius = 1.0;
        _minutes.layer.shouldRasterize = YES;
        _minutes.layer.contentsScale = [[UIScreen mainScreen] scale];
        _minutes.backgroundColor = tintColor;
        [self addSubview:_minutes];
        
        UIView *border = [[UIView alloc] initWithFrame:CGRectMake(2.0f, 1.0f, 28.0f, 28.0f)];
        border.layer.borderColor = tintColor.CGColor;
        border.layer.borderWidth = 1.0f;
        border.layer.cornerRadius = 14.0f;
        [self addSubview:border];
        
        // Label
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(34.0f, 0.0f, 46.0f, 30.0f)];
        
        _dateLabel.numberOfLines = 2;
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.font = [UIFont systemFontOfSize:11.0f];
        [self addSubview:_dateLabel];
        
        // Create date formatter
        _timeFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] localeIdentifier]]];
        [_timeFormatter setDateFormat:@"hh:mm"];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] localeIdentifier]]];
        [_dateFormatter setDateStyle:NSDateFormatterShortStyle];

    }
    return self;
}

- (id)initWithDelegate:(id <TTTimeScrollerDelegate>)timeScrollerDelegate;
{
    self = [self initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 30.0f)];
    _timeScrollerDelegate = timeScrollerDelegate;
    return self;
}

- (void)scrollViewDidScroll
{
    // Check if necessary views are available
    if (!_tableView || !_scrollBar){
        [self captureTableViewAndScrollBar];
        if(!_scrollBar){
            return;
        }
    }
    
    CGRect selfFrame = self.frame;
    CGRect scrollBarFrame = _scrollBar.frame;
    
    // Set frame
    CGFloat newX =  CGRectGetWidth(selfFrame) * -1.f;
    CGFloat newY = CGRectGetHeight(scrollBarFrame) / 2.0f - CGRectGetHeight(selfFrame) / 2.0f;
    self.frame = CGRectMake(newX, newY, CGRectGetWidth(selfFrame), CGRectGetHeight(selfFrame));
    
    // Get date
    CGPoint point = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    point = [_scrollBar convertPoint:point toView:_tableView];
    
    UITableViewCell* cell = [_tableView cellForRowAtIndexPath:[_tableView indexPathForRowAtPoint:point]];
    if (cell) {
        if (!self.alpha){
            [UIView animateWithDuration:0.2f delay:0.0f options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState)  animations:^{
                self.alpha = 1.0f;
            } completion:nil];
        }
        
        // Update date
        NSDate *date = [_timeScrollerDelegate timeScroller:self dateForCell:cell];
        if (!date || [date isEqualToDate:_lastDate]){
            return;
        }
        if (!_lastDate) {
            _lastDate = [NSDate date];
        }
        
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:date];
        
        CGFloat minuteHourAngle = (dateComponents.minute / 60.0f) * 360.0f;
        CGFloat dateHourAngle = (((dateComponents.hour * 60.0f) + dateComponents.minute) / (24.0f * 60.0f)) * 360.0f;
        
        [UIView animateWithDuration:0.2f delay:0.0f options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState)  animations:^{
            _hours.transform = CGAffineTransformMakeRotation(dateHourAngle * (M_PI / 180.0f));
            _minutes.transform = CGAffineTransformMakeRotation(minuteHourAngle * (M_PI / 180.0f));
        } completion:nil];
        
        _dateLabel.text = [NSString stringWithFormat:@"%@\r%@", [_timeFormatter stringFromDate:date], [_dateFormatter stringFromDate:date]];
        
        
        _lastDate = date;
    } else {
        // No cell, thus fade out
        if (self.alpha){
            [UIView animateWithDuration:0.2f delay:0.0f options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState) animations:^{
                self.alpha = 0.0f;
            } completion:nil];
        }
    }
}

#pragma mark - Helper
- (void)captureTableViewAndScrollBar
{
    // Refresh tableView
    _tableView = [_timeScrollerDelegate tableViewForTimeScroller:self];
    
    // Search for scrollBar
    for (id subview in [_tableView subviews]){
        if ([subview isKindOfClass:[UIImageView class]]){
            UIImageView *imageView = (UIImageView *)subview;
            if (imageView.frame.size.width == 7.0f || imageView.frame.size.width == 5.0f || imageView.frame.size.width == 3.5f){
                imageView.clipsToBounds = NO;
                [imageView addSubview:self];
                _scrollBar = imageView;
            }
        }
    }
}

@end
