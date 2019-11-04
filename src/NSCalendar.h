
/* Copyright (c) 2007 Christopher J. W. Lloyd
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import "import.h"


@class NSDateComponents;


enum
{
    NSEraCalendarUnit,

    NSYearCalendarUnit,
    NSMonthCalendarUnit,
    NSDayCalendarUnit,
    NSHourCalendarUnit,
    NSMinuteCalendarUnit,
    NSSecondCalendarUnit,

    NSWeekCalendarUnit,
    NSWeekdayCalendarUnit,
    NSWeekdayOrdinalCalendarUnit
};


enum
{
    NSCalendarUnitEra            = NSEraCalendarUnit,

    NSCalendarUnitYear           = NSYearCalendarUnit,
    NSCalendarUnitMonth          = NSMonthCalendarUnit,
    NSCalendarUnitDay            = NSDayCalendarUnit,
    NSCalendarUnitHour           = NSHourCalendarUnit,
    NSCalendarUnitMinute         = NSMinuteCalendarUnit,
    NSCalendarUnitSecond         = NSSecondCalendarUnit,

    NSCalendarUnitWeekOfMonth    = NSWeekCalendarUnit, // ???
    NSCalendarUnitWeekday        = NSWeekdayCalendarUnit,
    NSCalendarUnitWeekdayOrdinal = NSWeekdayOrdinalCalendarUnit,

    NSCalendarUnitQuarter,
    NSCalendarUnitWeekOfYear
};
typedef NSUInteger NSCalendarUnit;


@interface NSCalendar : NSObject <NSCopying>
{
   NSUInteger   _daysOfCommonEraOfReferenceDate;
}

@property( copy) NSLocale     *locale;
@property( copy) NSTimeZone   *timeZone;

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



@interface NSCalendar( Subclasses)

+ (instancetype) currentCalendar;
- (NSString *) calendarIdentifier;

- (NSUInteger) firstWeekday;
- (NSUInteger) minimumDaysInFirstWeek;

- (NSRange) minimumRangeOfUnit:(NSCalendarUnit) unit;
- (NSRange) maximumRangeOfUnit:(NSCalendarUnit) unit;

- (NSRange) rangeOfUnit:(NSCalendarUnit) unit
                 inUnit:(NSCalendarUnit) inUnit
                forDate:(NSDate *)date;

- (NSUInteger) ordinalityOfUnit:(NSCalendarUnit) unit
                         inUnit:(NSCalendarUnit) inUnit
                        forDate:(NSDate *) date;

- (NSInteger) mulleNumberOfDaysInYear:(NSInteger) year;
- (NSInteger) mulleNumberOfWeeksInYear:(NSInteger) year;
- (NSInteger) mulleNumberOfDaysInMonth:(NSInteger) month
                                ofYear:(NSInteger) year;
- (NSInteger) mulleNumberOfDaysInCommonEraOfDay:(NSInteger) day
                                          month:(NSInteger) month
                                           year:(NSInteger) year;

@end



struct MulleCalendarDate
{
   int32_t    year;
   uint16_t   month;
   uint16_t   day;
};


//
// the mulle_canonicalcalendardate_t (SDN) can be used to convert dates
// between calendars
//
typedef int32_t   mulle_canonicalcalendardate_t;


@interface NSCalendar( CalendarConversion)

- (struct MulleCalendarDate) mulleCalendarDateFromCanonicalDate:(mulle_canonicalcalendardate_t) snd;
- (mulle_canonicalcalendardate_t)  mulleCanonicalDateFromCalendarDate:(struct MulleCalendarDate) date;

@end



