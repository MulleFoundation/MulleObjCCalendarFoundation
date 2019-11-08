/*
 * Copyright (c) 2019 Nat!
 * based on work by Christopher J. W. Lloyd
 */

/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
#import "NSCalendar+NSDate.h"

@implementation NSCalendar( NSDate)


/*
 *
 */
- (NSInteger) mulleEraFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{
   return( 1);
}


- (NSInteger) mulleDayOfCommonEraFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{
   ext->dayOfCommonEra = (ext->interval / 86400.0) + _daysOfCommonEraOfReferenceDate;
   return( ext->dayOfCommonEra);
}


- (NSInteger) mulleYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{
   NSInteger   days;
   NSInteger   year;

   days = ext->dayOfCommonEra;
   if( days == NSIntegerMax)
      days = [self mulleDayOfCommonEraFromExtendedTimeInterval:ext];

   year = days / 366;
   while( days >= [self mulleNumberOfDaysInCommonEraOfDay:1
                                                    month:1
                                                     year:year + 1]) // QUESTIONABLE!!!
   {
      year++;
   }

   ext->year = year;
   return( year);
}


- (NSInteger) mulleDayOfYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{ // 1-366
   NSInteger   result;
   NSInteger   year;
   NSInteger   day;

   year = (ext->year == NSIntegerMax) ? [self mulleYearFromExtendedTimeInterval:ext]
                                      : ext->year;
   day  = (ext->dayOfCommonEra == NSIntegerMax) ? [self mulleDayOfCommonEraFromExtendedTimeInterval:ext]
                                                : ext->dayOfCommonEra;

   result = day - [self mulleNumberOfDaysInCommonEraOfDay:1
                                                    month:1
                                                     year:year] + 1;
   if( result == 0)
      result = 366;

   //
   // result is  not cached yet
   //
   return( result);
}


- (NSInteger) mulleQuarterFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{
   NSInteger  month;

   month = [self mulleMonthFromExtendedTimeInterval:ext];
   return( ((month - 1) / 3) + 1);
}


- (NSInteger) mulleMonthFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{ // 1-12
   NSInteger   year;
   NSInteger   days;
   NSInteger   month;
   NSInteger   monthDays;
   NSInteger   searchDays;

   year = (ext->year == NSIntegerMax) ? [self mulleYearFromExtendedTimeInterval:ext]
                                      : ext->year;
   days = (ext->dayOfCommonEra == NSIntegerMax) ? [self mulleDayOfCommonEraFromExtendedTimeInterval:ext]
                                                : ext->dayOfCommonEra;
   month = 1;

   // TODO: use some form of binary search on this
   for( month = 1;;month++)
   {
      monthDays  = [self mulleNumberOfDaysInMonth:month
                                           ofYear:year];
      searchDays = [self mulleNumberOfDaysInCommonEraOfDay:monthDays
                                                     month:month
                                                      year:year];
      if( days <= searchDays)
         break;
   }
   ext->month = month;
   return( month);
}



// this is not compatible with apple and can't be used to calculate
// calendar weeks. Apple's method project a week band over multiple years
// whereas this is local to one year. The bad side effect this has can be
// observed when iterating over 2018, where you get:
//
// 30.12.2018 0:00:00 weakOfYear:52
// 31.12.2018 0:00:00 weakOfYear:53
//  1.1.2019 0:00:00 weakOfYear:1

- (NSInteger) mulleWeekOfYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{
   NSInteger   day;
   NSInteger   year;
   NSInteger   weeks;
   NSInteger   month;
   NSInteger   weekday;
   NSInteger   monthFirstWeekday;
   NSInteger   diff;
   NSInteger   leftover;
   NSInteger   firstWeekday;

   // use day=0 = 1.x
   day     = [self mulleDayOfYearFromExtendedTimeInterval:ext] - 1;

   // get current weekday, we use this to compute the weekday of the
   // first of the year
   weekday = [self mulleWeekdayFromExtendedTimeInterval:ext] - 1;

   weeks   = day / 7;
   day    %= 7;

   //-----------------------------------
   // compute first weekday of year, lets say tuesday (2)
   monthFirstWeekday = pure_mod_0_n( weekday - day, 7);
   // week starts on a monday though (1)
   firstWeekday      = [self firstWeekday] - 1;
   if( firstWeekday != monthFirstWeekday)
   {
      // compute days in the first week, which are part of this month
      // 0 means all
      leftover  = pure_mod_0_n( firstWeekday - monthFirstWeekday, 7);
      if( leftover >= _minimumDaysInFirstWeek)
      {
         if( day >= leftover)
            weeks = (weeks + 1);
      }
   }

   //
   // weeks are numbered base 1 so adjust
   //
   return( weeks + 1);
}


//
// TODO: hacked for julian/gregorian
//
- (BOOL) mulleIsLeapYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{
   NSInteger   year;

   year = (ext->year == NSIntegerMax) ? [self mulleYearFromExtendedTimeInterval:ext]
                                      : ext->year;
   return( [self mulleNumberOfDaysInYear:year] == 366);
}


struct MulleCalendarWeekdayRange
{
   enum MulleCalendarWeekday   start;
   enum MulleCalendarWeekday   end;
};


struct MulleCalendarWeekdayRange   MulleCalendarWeekdayRangeMake( enum MulleCalendarWeekday start,
                                                                  enum MulleCalendarWeekday end)
{
   assert( start >= MulleCalendarSunday && start <= MulleCalendarSaturday);
   assert( end >= MulleCalendarSunday && end <= MulleCalendarSaturday);

   return( (struct MulleCalendarWeekdayRange) { .start = start, .end = end });
}


static BOOL   MulleCalendarWeekdayRangeContains( struct MulleCalendarWeekdayRange range,
                                                 enum MulleCalendarWeekday day)
{
   assert( day >= MulleCalendarSunday && day <= MulleCalendarSaturday);

   if( range.start > range.end)
      return( day >= range.start || day <= range.end);
   return( day >= range.start && day <= range.end);
}


static inline enum MulleCalendarWeekday
   MulleCalendarWeekdayAddDays( enum MulleCalendarWeekday day, int days)
{
   return( pure_mod_0_n( day - 1 + days, 7) + 1);
}


// calculate the first weekday of the current year
- (NSInteger) mulleFirstWeekdayOfYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{
   NSInteger   dayOfYear;
   NSInteger   weekday;
   NSInteger   firstWeekday;

   dayOfYear = [self mulleDayOfYearFromExtendedTimeInterval:ext] - 1;
   weekday   = [self mulleWeekdayFromExtendedTimeInterval:ext] - 1;

   firstWeekday = pure_mod_0_n( weekday - dayOfYear, 7);
   return( firstWeekday + 1);
}


// calculate the last weekday of the current year
- (NSInteger) mulleLastWeekdayOfYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{
   NSInteger   dayOfYear;
   NSInteger   weekday;
   NSInteger   lastWeekday;
   NSInteger   daysInYear;
   NSInteger   year;

   dayOfYear  = [self mulleDayOfYearFromExtendedTimeInterval:ext];
   year       = [self mulleYearFromExtendedTimeInterval:ext];
   daysInYear = [self mulleNumberOfDaysInYear:year];
   dayOfYear  = daysInYear - dayOfYear;

   weekday    = [self mulleWeekdayFromExtendedTimeInterval:ext] - 1;

   lastWeekday = pure_mod_0_n( weekday + dayOfYear, 7);
   return( lastWeekday + 1);
}


// calculate the first weekday of the current month
- (NSInteger) mulleFirstWeekdayOfMonthFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{
   NSInteger   dayOfMonth;
   NSInteger   weekday;
   NSInteger   firstWeekday;

   dayOfMonth = [self mulleDayOfMonthFromExtendedTimeInterval:ext] - 1;
   weekday    = [self mulleWeekdayFromExtendedTimeInterval:ext] - 1;

   firstWeekday = pure_mod_0_n( weekday - dayOfMonth, 7);
   return( firstWeekday + 1);
}


//
// The ISO 8601 definition for week 01 is the week with the
// Gregorian year's first Thursday in it.
//
- (NSInteger) mulleISOFirstWeekOffsetInYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{
   enum MulleCalendarWeekday         firstWeekday;
   struct MulleCalendarWeekdayRange  range;

   firstWeekday = [self mulleFirstWeekdayOfYearFromExtendedTimeInterval:ext];

   switch( firstWeekday)
   {
   case MulleCalendarFriday   : return( 3);
   case MulleCalendarSaturday : return( 2);
   case MulleCalendarSunday   : return( 1);
   default                    : return( 0);
   }
}



- (NSInteger) mulleNumberOfWeeksInYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{
   NSInteger   firstWeekdayOfYear;
   NSInteger   firstWeekday;
   NSInteger   days;
   NSInteger   month;
   NSInteger   weeks;
   NSInteger   year;

   firstWeekdayOfYear  = [self mulleFirstWeekdayOfYearFromExtendedTimeInterval:ext] - 1;
   firstWeekday        = _firstWeekday - 1;
   year                = [self mulleYearFromExtendedTimeInterval:ext];
   days                = [self mulleNumberOfDaysInYear:year];

   weeks  = days / 7;
   days  %= 7;
   weeks += days != 0;

   // e.g. days = 30. 30 % 7 -> 2.  7 - 2 + 1 = 6
   // add a week, if (compensated) week start is the last weekday
   weeks += pure_mod_0_n( firstWeekdayOfYear - firstWeekday, 7) >= (7 - days + 1);

   return( weeks);
}


- (NSInteger) mulleNumberOfWeeksInMonthFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{
   NSInteger   firstWeekdayOfMonth;
   NSInteger   firstWeekday;
   NSInteger   days;
   NSInteger   month;
   NSInteger   weeks;
   NSInteger   year;

   firstWeekdayOfMonth = [self mulleFirstWeekdayOfMonthFromExtendedTimeInterval:ext] - 1;
   firstWeekday        = _firstWeekday - 1;
   year                = [self mulleYearFromExtendedTimeInterval:ext];
   month               = [self mulleMonthFromExtendedTimeInterval:ext];
   days                = [self mulleNumberOfDaysInMonth:month
                                                 ofYear:year];

   weeks  = days / 7;
   days  %= 7;
   weeks += days != 0;

   // e.g. days = 30. 30 % 7 -> 2.  7 - 2 + 1 = 6
   // add a week, if (compensated) week start is the last weekday
   weeks += pure_mod_0_n( firstWeekdayOfMonth - firstWeekday, 7) >= (7 - days + 1);

   return( weeks);
}


- (NSInteger) mulleISONumberOfWeeksInYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{
   NSInteger   firstWeekdayOfYear;
   NSInteger   lastWeekdayOfYear;

   firstWeekdayOfYear = [self mulleFirstWeekdayOfYearFromExtendedTimeInterval:ext];
   if( firstWeekdayOfYear == MulleCalendarThursday)
      return( 53);

   lastWeekdayOfYear = [self mulleLastWeekdayOfYearFromExtendedTimeInterval:ext];
   if( lastWeekdayOfYear == MulleCalendarThursday)
      return( 53);

   return( 52);
}


//
// https://en.wikipedia.org/wiki/ISO_week_date
// REF: ISO 8601
// NOTE 1 A calendar year has 52 or 53 calendar weeks.
// NOTE 2 The first calendar week of a calendar year includes up to three days from the previous calendar year; the last
// calendar week of a calendar year includes up to three days from the following calendar year. Therefore, for certain
// calendar days the calendar date contains a different calendar year than the week date. For instance:
// — Sunday 1 January 1995 is identified by the calendar date [1995-01-01] and week date [1994-W52-7]
// — Tuesday 31 December 1996 is identified by the calendar date [1996-31-12] and week date [1997-W01-2].
//
// ISO prescribes Monday as first and Thursday as the cutoff point, regardless
// of locale!
//
- (NSInteger) mulleISOWeekOfYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{
   enum MulleCalendarWeekday         weekday;
   NSInteger                         day;
   NSInteger                         days;
   NSInteger                         diff;
   NSInteger                         firstWeekday;
   NSInteger                         lastWeekday;
   NSInteger                         isoDay;
   NSInteger                         isoOffset;
   NSInteger                         isoRemainder;
   NSInteger                         isoWeeks;
   NSInteger                         leftover;
   NSInteger                         month;
   NSInteger                         monthFirstWeekday;
   NSInteger                         weeks;
   NSInteger                         year;
   struct MulleCalendarWeekdayRange  range;
   struct MulleExtendedTimeInterval  tmp;

   // use day=0 = 1.x
   day          = [self mulleDayOfYearFromExtendedTimeInterval:ext] - 1;

   isoWeeks     = day / 7;    // that many weeks
   isoRemainder = day % 7;    // leftover days

   //
   // if there was no offset then. Then 1.1 is the first week.
   // Now just check if isoRemainder is inside the first partial week
   //
   isoOffset = [self mulleISOFirstWeekOffsetInYearFromExtendedTimeInterval:ext];
   if( isoOffset)
   {
      // we are in the past year ?
      if( ! isoWeeks && isoRemainder < isoOffset)
      {
         MulleExtendedTimeIntervalInit( &tmp, ext->interval - 7 * 86400.0);
         return( [self mulleISONumberOfWeeksInYearFromExtendedTimeInterval:&tmp]);
      }
      //
      // Otherwise we are a week in the past year, so dial a week back
      // and get the number of weeks for this year
      --isoWeeks;
   }

   firstWeekday = [self mulleFirstWeekdayOfYearFromExtendedTimeInterval:ext];
   range        = MulleCalendarWeekdayRangeMake( firstWeekday, MulleCalendarSunday);
   weekday      = MulleCalendarWeekdayAddDays( firstWeekday, isoRemainder);
   if( ! MulleCalendarWeekdayRangeContains( range, weekday))
      isoWeeks++;

   if( isoWeeks == 52)
   {
      // now this could be a 52 +1 or just a 0
      lastWeekday = [self mulleLastWeekdayOfYearFromExtendedTimeInterval:ext];
      range       = MulleCalendarWeekdayRangeMake( MulleCalendarThursday, MulleCalendarSunday);
      if( ! MulleCalendarWeekdayRangeContains( range, lastWeekday))
         isoWeeks = 0;
   }
   return( isoWeeks + 1);
}


//
// weekOfMonth. a week can partially belong to the previous month
// Ideally: starts on Sunday when firstWeekday is 1
// In December 2018 there are 6 weeks in December
//
- (NSInteger) mulleWeekOfMonthFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{
   NSInteger   dayOfMonth;
   NSInteger   year;
   NSInteger   month;
   NSInteger   weekday;
   NSInteger   monthFirstWeekday;
   NSInteger   diff;
   NSInteger   firstWeekday;

   // use day=0 = 1.x
   dayOfMonth        = [self mulleDayOfMonthFromExtendedTimeInterval:ext] - 1;

   // use So=0 for weekdays
   weekday           = [self mulleWeekdayFromExtendedTimeInterval:ext] - 1;
   monthFirstWeekday = pure_mod_0_n( weekday - dayOfMonth, 7);
   firstWeekday      = [self firstWeekday] - 1;

   // 1st is Fr.  but we have overhang until first so that's the first week
   diff        = pure_mod_0_n( monthFirstWeekday - firstWeekday, 7);
   dayOfMonth += diff;

   return( (dayOfMonth / 7) + 1);
}


- (NSInteger) mulleDayOfMonthFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{ // 1-31
   NSInteger   day;
   NSInteger   year;
   NSInteger   month;

   year  = (ext->year == NSIntegerMax) ? [self mulleYearFromExtendedTimeInterval:ext]
                                       : ext->year;
   day   = (ext->dayOfCommonEra == NSIntegerMax) ? [self mulleDayOfCommonEraFromExtendedTimeInterval:ext]
                                                 : ext->dayOfCommonEra;
   month = (ext->month == NSIntegerMax) ? [self mulleMonthFromExtendedTimeInterval:ext]
                                        : ext->month;

   day  -= [self mulleNumberOfDaysInCommonEraOfDay:1
                                             month:month
                                              year:year] - 1;

   ext->dayOfMonth = day;

   return( ext->dayOfMonth);
}


static inline NSInteger  pure_mod_0_n( NSInteger value, NSInteger max)
{
   value %= max;
   if( value < 0)
      value += max;

   return( value);
}


- (NSInteger) mulleWeekdayFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{ // 1-7 SU MO SA
   NSInteger   weekday;

   weekday = (ext->dayOfCommonEra == NSIntegerMax) ? [self mulleDayOfCommonEraFromExtendedTimeInterval:ext]
                                                   : ext->dayOfCommonEra;

   // Julian 1.1.1 is a Saturday
   weekday += [self mulleFirstWeekdayOfCommonEra] - 1;
   weekday  = pure_mod_0_n( weekday, 7);
   ext->weekday = weekday + 1;   // move to 1-7

   return( ext->weekday);
}


//
// this calculates if the index into the week starting from [self firstWeekday]
// e.g.  7.11.2019 (a thursday) -> Weekstart monday : 4, but weekstart sunday : 5
// 1-7
- (NSInteger) mulleDayOfWeekFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{
   NSInteger   weekday;

   weekday = (ext->weekday ? [self mulleWeekdayFromExtendedTimeInterval:ext]
                           : ext->weekday);
   // Julian 1.1.1
   weekday -= 1;
   weekday += [self firstWeekday] - 1;
   weekday  = pure_mod_0_n( weekday, 7);

   return( weekday + 1);
}


//
// Weekday ordinal units represent the position of the weekday within the next
// larger calendar unit, such as the month. For example, 2 is the weekday
// ordinal unit for the second Friday of the month.
//
- (NSInteger) mulleWeekdayOrdinalFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{
   NSInteger        year;
   NSInteger        month;
   NSInteger        days;
   NSTimeInterval   monthFirst;

   year  = (ext->year == NSIntegerMax) ? [self mulleYearFromExtendedTimeInterval:ext]
                                       : ext->year;
   month = (ext->month == NSIntegerMax) ? [self mulleMonthFromExtendedTimeInterval:ext]
                                        : ext->month;
   monthFirst = [self mulleTimeIntervalWithYear:year
                                          month:month
                                            day:1
                                           hour:0
                                         minute:0
                                         second:0
                                     nanosecond:0];

   //
   // Calculate number of days between "ext" and first day of month.
   // Rounding would be bad here, because ext->interval can be 23:59:59
   //
   days = ((NSInteger) ext->interval - (NSInteger) monthFirst) / 86400;
   return( days / 7 + 1);
}


- (NSInteger) mulle24HourFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{ // 0-23
    NSTimeInterval   hour;

   hour = (ext->dayOfCommonEra == NSIntegerMax) ? [self mulleDayOfCommonEraFromExtendedTimeInterval:ext]
                                                : ext->dayOfCommonEra;

   hour -= _daysOfCommonEraOfReferenceDate;
   hour *= 86400.0;
   hour -= ext->interval;
   hour /= 3600;
   hour  = hour <  0 ? -hour : hour;

   if( hour == 24)
      hour = 0;

   ext->hour = hour;

   return hour;
}


- (NSInteger) mulle12HourFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{ // 1-12
   NSInteger   hour;

   hour = (ext->hour == NSIntegerMax) ? [self mulle24HourFromExtendedTimeInterval:ext]
                                      : ext->hour;
   if( hour == 0)
      hour = 12;
   return hour;
}


- (NSInteger) mulleAMPMFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{ // 0-1
   NSInteger   hour;

   hour = (ext->hour == NSIntegerMax) ? [self mulle24HourFromExtendedTimeInterval:ext]
                                      : ext->hour;
   return( (hour < 11) ? 0 : 1);
}


- (NSInteger) mulleMinuteFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{ // 0-59
   NSTimeInterval   startOfHour;
   NSInteger        year;
   NSInteger        month;
   NSInteger        dayOfMonth;
   NSInteger        hour;

   year        = (ext->year == NSIntegerMax) ? [self mulleYearFromExtendedTimeInterval:ext]
                                             : ext->year;
   month       = (ext->month == NSIntegerMax) ? [self mulleMonthFromExtendedTimeInterval:ext]
                                              : ext->month;
   dayOfMonth  = (ext->dayOfMonth == NSIntegerMax) ? [self mulleDayOfMonthFromExtendedTimeInterval:ext]
                                                   : ext->dayOfMonth;
   hour        = (ext->hour == NSIntegerMax) ? [self mulle24HourFromExtendedTimeInterval:ext]
                                             : ext->hour;
   startOfHour = [self mulleTimeIntervalWithYear:year
                                           month:month
                                             day:dayOfMonth
                                            hour:hour
                                          minute:0
                                          second:0
                                      nanosecond:0];

   return( (NSInteger) (ext->interval - startOfHour) / 60);
}


@end
