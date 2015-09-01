//
//  GLCalendarView.m
//  GLCalendarFramework
//
//  Created by Murillo Nicacio de Maraes on 6/28/15.
//  Copyright (c) 2015 Unreasonable. All rights reserved.
//

#import "GLCalendarView.h"

#import "GLCalendarMonthCell.h"
#import "GLDateUtils.h"

@interface GLCalendarView() <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GLCalendarMonthDelegate>

#pragma mark - Collection View
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;

#pragma mark - Properties
@property (nonatomic) NSDate *showingDate;

@property (nonatomic) NSDate *selectedDate;

@property (nonatomic) NSDate *initialDate;
@property (nonatomic) NSDate *finalDate;

@end

@implementation GLCalendarView

NSString * const kCalendarCellIdentifier = @"calendarCell";

@synthesize showingDate = _showingDate;

#pragma mark - Initialization
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self load];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self load];
    }
    return self;
}

#pragma mark - Set Up
- (void)load {
    UIView *view = [[[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];

    view.frame = self.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:view];
    [self setup];
}

- (void)setup {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    UINib *nib = [UINib nibWithNibName:NSStringFromClass([GLCalendarMonthCell class]) bundle:[NSBundle bundleForClass:[GLCalendarMonthCell class]]];

    [self.collectionView registerNib:nib forCellWithReuseIdentifier:kCalendarCellIdentifier];
}

-(void)layoutSubviews {
    [super layoutSubviews];

}

#pragma mark - Actions
- (void)reload {
    [self setShowingDate:_showingDate animated:NO];
//    self.showingDate = _showingDate;
}

- (void)reloadData {
    [self.collectionView reloadData];
}

#pragma mark - Month Delegate
-(NSString *)annotationForDate:(NSDate *)date {
    if (self.delegate && [self canSelectDate:date]) {
        return [self.delegate annotationForDate:date];
    }

    return @"";
}

-(BOOL)canSelectDate:(NSDate *)date {
    return ([self.initialDate compare:date] != NSOrderedDescending || !self.initialDate) &&
    ([self.endDate compare:date] == NSOrderedDescending || !self.endDate);
}

-(void)didSelectOutsideDate:(NSDate *)date {
    if ([self canSelectDate:date]) {
        [self setShowingDate:date animated:true];
    }
}

-(void)didSelectDate:(NSDate *)date {
    self.selectedDate = date;

    [self.delegate didSelectDate:date];
}

#pragma mark - Calendar DataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self startAndEndAreSame] ? 1 :
    [self startAndEndAreAdjacent] ? 2 : 3;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GLCalendarMonthCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCalendarCellIdentifier forIndexPath:indexPath];

    NSDate *month = [self dateForIndexPath:indexPath];

    cell.delegate = self;
    cell.monthToShow = month;

    if (self.selectedDate && [[GLDateUtils monthFirstDate:self.selectedDate] isEqualToDate:month]) {
        [cell addRangeForDate:self.selectedDate];
        [cell reload];
    }

    return cell;
}

#pragma mark - Calendar Delegate
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    self.collectionView.userInteractionEnabled = NO;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger delta = (scrollView.contentOffset.x / scrollView.bounds.size.width) - 1;


    NSDate *newDate = [GLDateUtils dateByAddingMonths:delta toDate:self.showingDate];

    if (delta == -1 &&
        self.startDate &&
        [newDate compare:self.startDate] != NSOrderedDescending) {

        [self setShowingDate:self.startDate animated:NO];

    } else if (delta == 0 &&
               self.startDate &&
               [newDate compare:self.startDate] == NSOrderedSame) {

        [self setShowingDate:[GLDateUtils dateByAddingMonths:1 toDate:self.startDate] animated:NO];

    } else if (delta == 1 &&
               self.endDate &&
               [newDate compare:self.endDate] != NSOrderedAscending) {

        [self setShowingDate:self.endDate animated:NO];

    } else if (delta == 0 &&
               self.endDate &&
               [newDate compare:self.endDate] == NSOrderedSame &&
               ![self startAndEndAreAdjacent]) {

        [self setShowingDate:[GLDateUtils dateByAddingMonths:-1 toDate:self.endDate] animated:NO];

    } else {
        
        [self setShowingDate:newDate animated:NO];
        
    }

    self.collectionView.userInteractionEnabled = YES;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = self.collectionView.bounds.size.width;

    return CGSizeMake(width, width);
}

#pragma mark - Accessors
-(NSDate *)showingDate {
    if (!_showingDate) {
        _showingDate = [GLDateUtils monthFirstDate:[self defaultDate]];

        [self scrollToProperPage];
    }

    return _showingDate;
}

//-(void)setShowingDate:(NSDate *)showingDate {
//    [self setShowingDate:showingDate animated:NO];
//}

-(void)setShowingDate:(NSDate *)showingDate animated:(BOOL)animated {
    if ([showingDate compare:self.startDate] == NSOrderedAscending) {
        showingDate = self.startDate;
    } else if ([showingDate compare:self.endDate] == NSOrderedDescending) {
        showingDate = self.endDate;
    }

    NSDate *oldDate = _showingDate;

    NSDate *newDate = [GLDateUtils monthFirstDate:showingDate];

    self.showingDate = newDate;

    if (animated) {
        [self animateTransitionFrom:oldDate to: newDate];
    } else {
        [self scrollToProperPage];
        [self.collectionView reloadData];
    }
}

-(void)setStartDate:(NSDate *)startDate {
    _initialDate = [GLDateUtils cutDate:startDate];
    _startDate = [GLDateUtils monthFirstDate:startDate];
}

-(void)setEndDate:(NSDate *)endDate {
    _finalDate = [GLDateUtils cutDate:endDate];
    _endDate = [GLDateUtils monthFirstDate:endDate];
}

#pragma mark - Helper Methods
-(NSDate *)defaultDate {
    if ([self startAndEndAreSame] || [self.startDate compare:[NSDate date]] == NSOrderedDescending) {
        return self.startDate;
    } else if ([self.endDate compare:[NSDate date]] == NSOrderedAscending) {
        return self.endDate;
    } else {
        return [NSDate date];
    }
}

- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath {
    NSInteger delta = indexPath.row - 1;

    if ((delta == -1 && [self showingIsStart]) ||
        (delta == 1 && [self showingIsEnd])) {
        return self.showingDate;
    }

    if ([self showingIsStart]) {
        delta += 1;
    }

    if ([self showingIsEnd] && ![self startAndEndAreAdjacent]) {
        delta -= 1;
    }

    return [GLDateUtils dateByAddingMonths:delta toDate:self.showingDate];
}

- (void)scrollToProperPage {
    NSInteger page = [self showingIsStart] ? 0 : [self showingIsEnd] && ![self startAndEndAreAdjacent] ? 2 : 1;

    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:page inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)animateTransitionFrom:(NSDate *)fromDate to:(NSDate *)toDate {
    if ([fromDate compare:toDate] == NSOrderedAscending &&
        (!self.endDate || [toDate compare:self.endDate] != NSOrderedSame ||
         [self startAndEndAreAdjacent])) {

            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];

        } else if ([fromDate compare:toDate] == NSOrderedAscending) {
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        } else if ([fromDate compare:toDate] == NSOrderedDescending &&
                   (!self.startDate || [toDate compare:self.startDate] != NSOrderedSame)) {
                       [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
                       [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
                   } else if ([fromDate compare:toDate] == NSOrderedDescending) {
                       [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
                   }
}

#pragma mark - Date Information
- (BOOL)startAndEndAreSame {
    return self.endDate && self.startDate && [self.startDate compare:self.endDate] == NSOrderedSame;
}

- (BOOL)showingIsStart {
    return self.startDate && [self.showingDate compare:self.startDate] == NSOrderedSame;
}

- (BOOL)showingIsEnd {
    return self.endDate && [self.showingDate compare:self.endDate] == NSOrderedSame;
}

- (BOOL)startAndEndAreAdjacent {
    return self.startDate && self.endDate && [[GLDateUtils dateByAddingMonths:1 toDate:self.startDate] compare:self.endDate] == NSOrderedSame;
}

@end
