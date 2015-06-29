//
//  GLPeriodCalendarView.h
//  GLPeriodCalendar
//
//  Created by ltebean on 15-4-16.
//  Copyright (c) 2015 glow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLCalendarDateRange.h"

@class GLCalendarMonthView;

@protocol GLCalendarDataSource <NSObject>

- (NSString *)annotationForDate:(NSDate *)date;

@end

@protocol GLCalendarViewDelegate <NSObject>
- (BOOL)calenderView:(GLCalendarMonthView *)calendarView canAddRangeWithBeginDate:(NSDate *)beginDate;
- (GLCalendarDateRange *)calenderView:(GLCalendarMonthView *)calendarView rangeToAddWithBeginDate:(NSDate *)beginDate;
- (void)calenderView:(GLCalendarMonthView *)calendarView beginToEditRange:(GLCalendarDateRange *)range;
- (void)calenderView:(GLCalendarMonthView *)calendarView finishEditRange:(GLCalendarDateRange *)range continueEditing:(BOOL)continueEditing;
- (BOOL)calenderView:(GLCalendarMonthView *)calendarView canUpdateRange:(GLCalendarDateRange *)range toBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate;
- (void)calenderView:(GLCalendarMonthView *)calendarView didUpdateRange:(GLCalendarDateRange *)range toBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate;
@end


@interface GLCalendarMonthView : UIView
@property (nonatomic) CGFloat padding UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat rowHeight UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSDictionary *weekDayTitleAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSDictionary *monthCoverAttributes UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIImage *backToTodayButtonImage UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *backToTodayButtonColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *backToTodayButtonBorderColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, readonly) NSCalendar *calendar;
@property (nonatomic) NSDate *monthToShow;
@property (nonatomic, strong) NSMutableArray *ranges;
@property (nonatomic) BOOL showMaginfier;
@property (nonatomic, weak) id<GLCalendarViewDelegate> delegate;
@property (nonatomic, weak) id<GLCalendarDataSource> dataSource;
- (void)reload;
- (void)addRange:(GLCalendarDateRange *)range;
- (void)removeRange:(GLCalendarDateRange *)range;
- (void)updateRange:(GLCalendarDateRange *)range withBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate;
- (void)forceFinishEdit;
- (void)beginToEditRange:(GLCalendarDateRange *)range;
- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated;
@end
