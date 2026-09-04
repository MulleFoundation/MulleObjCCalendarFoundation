//
//  NSCalendar.h
//  MulleObjCCalendarFoundation
//
//  Copyright (c) 2019 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
#import "import.h"


@class NSDateComponents;


// keep order as is
enum
{
    NSCalendarUnitEra            = 0x0001,
    NSCalendarUnitYear           = 0x0002,
    NSCalendarUnitQuarter        = 0x0004,
    NSCalendarUnitMonth          = 0x0008,
    NSCalendarUnitWeekOfYear     = 0x0010,
    NSCalendarUnitWeekOfMonth    = 0x0020,
    NSCalendarUnitDay            = 0x0040,
    NSCalendarUnitWeekday        = 0x0080,
    NSCalendarUnitWeekdayOrdinal = 0x0100,
    NSCalendarUnitHour           = 0x0200,
    NSCalendarUnitMinute         = 0x0400,
    NSCalendarUnitSecond         = 0x0800,
    NSCalendarUnitNanosecond     = 0x1000
};
typedef NSUInteger NSCalendarUnit;


enum
{
    NSEraCalendarUnit            = NSCalendarUnitEra,

    NSYearCalendarUnit           = NSCalendarUnitYear,
    NSMonthCalendarUnit          = NSCalendarUnitMonth,
    NSWeekCalendarUnit           = NSCalendarUnitWeekOfYear,
    NSDayCalendarUnit            = NSCalendarUnitDay,
    NSWeekdayCalendarUnit        = NSCalendarUnitWeekday,
    NSWeekdayOrdinalCalendarUnit = NSCalendarUnitWeekdayOrdinal,
    NSHourCalendarUnit           = NSCalendarUnitHour,
    NSMinuteCalendarUnit         = NSCalendarUnitMinute,
    NSSecondCalendarUnit         = NSCalendarUnitSecond
};


// these should be in _MulleGregorianCalendar.h really but then they
// ain't visible
MULLE_OBJC_CALENDAR_FOUNDATION_GLOBAL
NSString  *NSGregorianCalendar; // = @"gregorian";

MULLE_OBJC_CALENDAR_FOUNDATION_GLOBAL
NSString  *NSJulianCalendar; //  = @"julian";



@interface NSCalendar : NSObject
{
   NSUInteger   _daysOfCommonEraOfReferenceDate;
}


@property( copy) NSLocale     *locale;
@property( copy) NSTimeZone   *timeZone;

// Sunday: 0, Monday: 1
@property( assign) NSInteger  firstWeekday;

// numbers of days a week must have to be considered a week for weekOfYear
@property( assign) NSInteger  minimumDaysInFirstWeek;


// must be done during +load
+ (void) mulleRegisterClass:(Class) cls
              forIdentifier:(NSString *) identifier;

+ (instancetype) calendarWithIdentifier:(NSString *) identifier;
- (instancetype) initWithCalendarIdentifier:(NSString *) identifier;

- (NSDateComponents *) components:(NSUInteger) flags
                         fromDate:(NSDate *) date;

- (NSDate *) dateByAddingComponents:(NSDateComponents *) components
                             toDate:(NSDate *) date
                            options:(NSUInteger) options;

- (NSDate *) dateFromComponents:(NSDateComponents *) components;

@end



@interface NSCalendar( SubclassesFuture) <MulleObjCFuture>

+ (instancetype) currentCalendar;
- (NSString *) calendarIdentifier;

- (NSInteger) mulleFirstWeekdayOfCommonEra;

- (NSRange) minimumRangeOfUnit:(NSCalendarUnit) unit;
- (NSRange) maximumRangeOfUnit:(NSCalendarUnit) unit;

- (NSRange) rangeOfUnit:(NSCalendarUnit) unit
                 inUnit:(NSCalendarUnit) inUnit
                forDate:(NSDate *)date;

- (BOOL) rangeOfUnit:(NSCalendarUnit) unit
           startDate:(NSDate **) p_startDate
            interval:(NSTimeInterval *) p_interval
             forDate:(NSDate *) date;

- (NSUInteger) ordinalityOfUnit:(NSCalendarUnit) unit
                         inUnit:(NSCalendarUnit) inUnit
                        forDate:(NSDate *) date;

- (BOOL) mulleIsLeapYear:(NSInteger) year;
- (NSInteger) mulleNumberOfDaysInYear:(NSInteger) year;
- (NSInteger) mulleNumberOfWeeksInYear:(NSInteger) year;
- (NSInteger) mulleNumberOfDaysInMonth:(NSInteger) month
                                ofYear:(NSInteger) year;
- (NSInteger) mulleNumberOfDaysInCommonEraOfDay:(NSInteger) day
                                          month:(NSInteger) month
                                           year:(NSInteger) year;

- (NSTimeInterval) mulleTimeIntervalWithYear:(NSInteger) year
                                       month:(NSInteger) month
                                         day:(NSInteger) day
                                        hour:(NSInteger) hour
                                      minute:(NSInteger) minute
                                      second:(NSInteger) second
                                  nanosecond:(NSInteger) nanosecond;

@end

