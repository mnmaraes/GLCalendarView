//
//  GLCalendarMonthCell.m
//  GLCalendarFramework
//
//  Created by Murillo Nicacio de Maraes on 6/28/15.
//  Copyright (c) 2015 Unreasonable. All rights reserved.
//

#import "GLCalendarMonthCell.h"

#import "GLDateUtils.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface GLCalendarMonthCell () <GLCalendarViewDelegate, GLCalendarDataSource>

@property (nonatomic, weak) GLCalendarDateRange *range;

@end

@implementation GLCalendarMonthCell

@synthesize monthToShow = _monthToShow;

- (void)awakeFromNib {
    self.monthView.delegate = self;
    self.monthView.dataSource = self;
}

-(NSDate *)monthToShow {
    if (!_monthToShow) {
        _monthToShow = [GLDateUtils monthFirstDate:[NSDate date]];
    }

    return _monthToShow;
}

-(void)setMonthToShow:(NSDate *)monthToShow {
    self.monthView.monthToShow = monthToShow;
    [self.monthView reload];

    _monthToShow = monthToShow;
}

#pragma mark - Action
-(void)removeRange {
    if (self.range) {
        [self.monthView removeRange:self.range];
        self.range = nil;
    }
}

-(void)prepareForReuse {
    [super prepareForReuse];

    if (self.range){
        [self.monthView.ranges removeObject:self.range];
        self.range = nil;
    }
}

-(void)addRangeForDate:(NSDate *)date {
    GLCalendarDateRange *range = [GLCalendarDateRange rangeWithBeginDate:date endDate:date];
    range.backgroundColor = UIColorFromRGB(0x2C77B5);
    range.editable = NO;

    self.range = range;

    [self.monthView addRange:range];
}

-(void)reload {
    [self.monthView reload];
}

#pragma mark - Calendar DataSource
-(NSString *)annotationForDate:(NSDate *)date {
    if (self.delegate && [[GLDateUtils monthFirstDate:date] isEqualToDate:self.monthToShow]) {
        return [self.delegate annotationForDate:date];
    }

    return @"";
}


#pragma mark - Calendar Delegate
-(BOOL)calenderView:(GLCalendarMonthView *)calendarView canAddRangeWithBeginDate:(NSDate *)beginDate {
    if (self.delegate && [[GLDateUtils monthFirstDate:beginDate] isEqualToDate:self.monthToShow]) {
        return [self.delegate canSelectDate:beginDate];
    } else if (self.delegate) {
        [self.delegate didSelectOutsideDate:beginDate];
    }

    return NO;
}

- (GLCalendarDateRange *)calenderView:(GLCalendarMonthView *)calendarView rangeToAddWithBeginDate:(NSDate *)beginDate {

    [self removeRange];

    [self.delegate didSelectDate:beginDate];

    GLCalendarDateRange *range = [GLCalendarDateRange rangeWithBeginDate:beginDate endDate:beginDate];
    range.backgroundColor = UIColorFromRGB(0x2C77B5);
    range.editable = NO;

    self.range = range;

    return range;
}

- (void)calenderView:(GLCalendarMonthView *)calendarView beginToEditRange:(GLCalendarDateRange *)range
{

}

- (void)calenderView:(GLCalendarMonthView *)calendarView finishEditRange:(GLCalendarDateRange *)range continueEditing:(BOOL)continueEditing
{
}

- (BOOL)calenderView:(GLCalendarMonthView *)calendarView canUpdateRange:(GLCalendarDateRange *)range toBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate
{
    return NO;
}

- (void)calenderView:(GLCalendarMonthView *)calendarView didUpdateRange:(GLCalendarDateRange *)range toBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate
{
    NSLog(@"did update range: %@", range);
}
@end
