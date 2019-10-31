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

- (NSTimeInterval) mulleTimeIntervalWithYear:(NSInteger) year
                                       month:(NSInteger) month
                                         day:(NSInteger) day
                                        hour:(NSInteger) hour
                                      minute:(NSInteger) minute
                                      second:(NSInteger) second
                                 millisecond:(NSInteger) millisecond
{
   NSInteger        daysOfCommonEra;
   NSTimeInterval   interval;


   daysOfCommonEra  = [self mulleNumberOfDaysInCommonEraOfDay:day
                                                        month:month
                                                         year:year];
   daysOfCommonEra -= _daysOfCommonEraOfReferenceDate;

   interval = (daysOfCommonEra * 86400.0) + (hour * 3600) + (minute * 60) + second;

   if( millisecond)
      interval += millisecond / 1000.0 + 0.0001; // + 0.0001 ???

   return( interval);
}


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

   return( day);
}


- (NSInteger) mulleWeekdayFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext
{ // 1-7
   NSInteger   weekday;

   weekday = (ext->dayOfCommonEra == NSIntegerMax) ? [self mulleDayOfCommonEraFromExtendedTimeInterval:ext]
                                                   : ext->dayOfCommonEra;
   weekday = weekday % 7;
   if (weekday < 0)
      weekday += 7;

   return weekday;
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
                                     millisecond:0];

   return( (NSInteger) (ext->interval - startOfHour) / 60);
}


@end
