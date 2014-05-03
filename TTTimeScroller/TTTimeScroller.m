 //
//  TTTimeScroller.m
//  timescroller
//
//  Created by Tobias Tiemerding on 5/2/14.
//  Copyright (c) 2014 Tobias Tiemerding. All rights reserved.
//

#import "TTTimeScroller.h"

@interface TTTimeScroller ()

@property (nonatomic, strong) NSDate *lastDate;
@property (nonatomic, strong) UIView *hours, *minutes;
@property (nonatomic, strong) UILabel *dateLabel, *timeLabel;

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIImageView *scrollBar;

@property (nonatomic, copy) NSDateFormatter *timeFormatter;
@property (nonatomic, copy) NSDateFormatter *dateFormatter;

- (void)captureTableViewAndScrollBar;
- (void)constructSubviews;
- (void)createDateFormatters;

@end

@implementation TTTimeScroller

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // If we don't clip to bounds the toolbar draws a thin shadow on top
        self.clipsToBounds = YES;
        self.layer.contentsScale = [UIScreen mainScreen].scale;
        
        // Create mask layer
        CALayer* maskLayer = [CALayer layer];
        maskLayer.contents = (__bridge id)[[[UIImage imageNamed:@"mask"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 30.0f, 0.0f, 20.0f)] CGImage];
        maskLayer.contentsScale = [UIScreen mainScreen].scale;
        maskLayer.contentsCenter = CGRectMake(30.0f/100.0f, 0.0f, 50.0f/100.0f, 0.0f);
        
        // Apply the mask layer
        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.98];
        self.layer.mask = maskLayer;
        
        // Create stuff
        [self constructSubviews];
        [self createDateFormatters];
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
    
    // Set frame
    CGFloat newX =  (CGRectGetWidth(self.frame) * -1.f) - CGRectGetWidth(_scrollBar.frame);
    CGFloat newY = CGRectGetHeight(_scrollBar.frame) / 2.0f - CGRectGetHeight(self.frame) / 2.0f;
    self.frame = CGRectMake(newX, newY, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    
    // Get date
    CGPoint point = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    point = [_scrollBar convertPoint:point toView:_tableView];
    
    UITableViewCell* cell = [_tableView cellForRowAtIndexPath:[_tableView indexPathForRowAtPoint:point]];
    if (cell) {
        [self updateDisplayWithCell:cell];
        if (!self.alpha){
            [UIView animateWithDuration:0.2f delay:0.0f options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState)  animations:^{
                self.alpha = 1.0f;
            } completion:nil];
        }
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
    
    if(_scrollBar){
        [_scrollBar addSubview:self];
    }
}

- (void)updateDisplayWithCell:(UITableViewCell *)cell
{
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
    
    NSString *timeLabelText = [_timeFormatter stringFromDate:date];
    NSString *dateLabelText = [_dateFormatter stringFromDate:date];
    
    CGSize timeLabelTextSize = [timeLabelText sizeWithAttributes:@{NSFontAttributeName : _timeLabel.font}];
    CGSize dateLabelTextSize = [dateLabelText sizeWithAttributes:@{NSFontAttributeName : _dateLabel.font}];
    
    [UIView animateWithDuration:0.2f delay:0.0f options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowAnimatedContent)  animations:^{
        // Animate clock rotation
        _hours.transform = CGAffineTransformMakeRotation(dateHourAngle * (M_PI / 180.0f));
        _minutes.transform = CGAffineTransformMakeRotation(minuteHourAngle * (M_PI / 180.0f));
        
        // Fit size to labels
        CGFloat maxWidth = MAX(timeLabelTextSize.width, dateLabelTextSize.width);
        _timeLabel.frame = CGRectMake(CGRectGetMinX(_timeLabel.frame), CGRectGetMinY(_timeLabel.frame), maxWidth, CGRectGetHeight(_timeLabel.frame));
        _dateLabel.frame = CGRectMake(CGRectGetMinX(_dateLabel.frame), CGRectGetMinY(_dateLabel.frame), maxWidth, CGRectGetHeight(_dateLabel.frame));
        
        // Fit frame
        CGFloat frameWidth = maxWidth + 50.f;
        self.frame = CGRectMake((frameWidth * -1) - CGRectGetWidth(_scrollBar.frame), CGRectGetMinY(self.frame), frameWidth, CGRectGetHeight(self.frame));
        self.layer.mask.frame = self.bounds;
    } completion:^(BOOL finished){
        _timeLabel.text = timeLabelText;
        _dateLabel.text = dateLabelText;
    }];
    
    _lastDate = date;
}

- (void)constructSubviews
{
    // Get tint color
    UIColor *tintColor = [[[[UIApplication sharedApplication] delegate] window] tintColor];
    if(!tintColor){
        tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    }
    
    // Clock
    _hours = [[UIView alloc] initWithFrame:CGRectMake(14.0f, 9.0f, 2.0f, 11.0f)];
    _hours.layer.anchorPoint = CGPointMake(0.5f, 1.0/11.0f);
    _hours.layer.cornerRadius = 1.0;
    _hours.layer.shouldRasterize = YES;
    _hours.layer.contentsScale = [[UIScreen mainScreen] scale];
    _hours.backgroundColor = tintColor;
    [self addSubview:_hours];
    
    _minutes = [[UIView alloc] initWithFrame:CGRectMake(14.0f, 8.0f, 2.0f, 13.0f)];
    _minutes.layer.anchorPoint = CGPointMake(0.5f, 1.0/13.0f);
    _minutes.layer.cornerRadius = 1.0;
    _minutes.layer.shouldRasterize = YES;
    _minutes.layer.contentsScale = [[UIScreen mainScreen] scale];
    _minutes.backgroundColor = tintColor;
    [self addSubview:_minutes];
    
    UIView *border = [[UIView alloc] initWithFrame:CGRectMake(1.0f, 1.0f, 28.0f, 28.0f)];
    border.layer.borderColor = [UIColor blackColor].CGColor;
    border.layer.borderWidth = 1.0f;
    border.layer.cornerRadius = 14.0f;
    [self addSubview:border];
    
    // Label
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(32.0f, 0.0f, 0.0f, 14.0f)];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.font = [UIFont boldSystemFontOfSize:11.0f];
    [self addSubview:_timeLabel];
    
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(32.0f, 15.0f, 0.0f, 14.0f)];
    _dateLabel.backgroundColor = [UIColor clearColor];
    _dateLabel.font = [UIFont systemFontOfSize:11.0f];
    [self addSubview:_dateLabel];
    
}

- (void)createDateFormatters
{
    _timeFormatter = [[NSDateFormatter alloc] init];
    _timeFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] localeIdentifier]];
    _timeFormatter.timeStyle = NSDateFormatterShortStyle;
    _timeFormatter.doesRelativeDateFormatting = YES;
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] localeIdentifier]];
    _dateFormatter.dateStyle = NSDateFormatterShortStyle;
    _dateFormatter.doesRelativeDateFormatting = YES;

}

@end
