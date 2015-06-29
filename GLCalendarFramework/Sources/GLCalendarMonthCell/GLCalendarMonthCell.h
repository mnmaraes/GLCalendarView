//
//  GLCalendarMonthCell.h
//  GLCalendarFramework
//
//  Created by Murillo Nicacio de Maraes on 6/28/15.
//  Copyright (c) 2015 Unreasonable. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GLCalendarMonthView.h"

@protocol GLCalendarMonthDelegate <NSObject>

-(NSString *)annotationForDate:(NSDate *)date;
-(BOOL)canSelectDate:(NSDate *)date;
-(void)didSelectOutsideDate:(NSDate *)date;
-(void)didSelectDate:(NSDate *)date;

@end

@interface GLCalendarMonthCell : UICollectionViewCell
#pragma mark - Subviews
@property (weak, nonatomic) IBOutlet GLCalendarMonthView *monthView;

#pragma mark - Properties
@property (nonatomic) NSDate *monthToShow;
@property (nonatomic, weak) id<GLCalendarMonthDelegate> delegate;

#pragma mark - Action
-(void)removeRange;
-(void)addRangeForDate:(NSDate *)date;
-(void)reload;

@end
