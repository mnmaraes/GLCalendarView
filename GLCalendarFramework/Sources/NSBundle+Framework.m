//
//  NSBundle+Framework.m
//  GLCalendarFramework
//
//  Created by Murillo Nicacio de Maraes on 6/19/15.
//  Copyright (c) 2015 Unreasonable. All rights reserved.
//

#import "NSBundle+Framework.h"

#import "GLCalendarMonthView.h"

@implementation NSBundle (Framework)

+(NSBundle *)frameworkBundle
{
    return [NSBundle bundleForClass:[GLCalendarMonthView class]];
}

@end
