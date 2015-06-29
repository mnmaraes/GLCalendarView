//
//  GLCalendarView.h
//  GLCalendarFramework
//
//  Created by Murillo Nicacio de Maraes on 6/28/15.
//  Copyright (c) 2015 Unreasonable. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GLCalendarDelegate <NSObject>

-(NSString *)annotationForDate:(NSDate *)date;
-(void)didSelectDate:(NSDate *)date;

@end

@interface GLCalendarView: UIView

#pragma mark - Observable Properties
@property (nonatomic, readonly) NSDate *showingDate;

#pragma mark - Setable Properties
@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;
@property (nonatomic, weak) id<GLCalendarDelegate> delegate;

#pragma mark - Actions
- (void)reload;
- (void)setShowingDate:(NSDate *)showingDate animated:(BOOL)animated;

@end
