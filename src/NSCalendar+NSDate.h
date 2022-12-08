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
#import "NSCalendar.h"


enum MulleCalendarWeekday
{
   MulleCalendarSunday    = 1,
   MulleCalendarMonday    = 2,
   MulleCalendarTuesday   = 3,
   MulleCalendarWednesday = 4,
   MulleCalendarThursday  = 5,
   MulleCalendarFriday    = 6,
   MulleCalendarSaturday  = 7
};


struct MulleExtendedTimeInterval
{
   NSTimeInterval    interval;
   NSInteger         year;
   NSInteger         month;
   NSInteger         weekday;
   NSInteger         dayOfCommonEra;
   NSInteger         dayOfMonth;
   NSInteger         hour;
};


static inline void  MulleExtendedTimeIntervalInit( struct MulleExtendedTimeInterval *p,
                                                  NSTimeInterval interval)
{
   p->interval       = interval;

   p->year           =
   p->month          =
   p->weekday        =
   p->dayOfCommonEra =
   p->dayOfMonth     =
   p->hour           = NSIntegerMax;
}


@interface NSCalendar( NSDate)


- (BOOL) mulleIsLeapYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;

- (NSInteger) mulle12HourFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulle24HourFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleAMPMFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleDayOfCommonEraFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleDayOfMonthFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleDayOfWeekFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleDayOfYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleFirstWeekdayOfMonthFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleFirstWeekdayOfYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleISOFirstWeekOffsetInYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext;
- (NSInteger) mulleISONumberOfWeeksInYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext;
- (NSInteger) mulleISOWeekOfYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext;
- (NSInteger) mulleLastWeekdayOfYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext;
- (NSInteger) mulleMinuteFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleMonthFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleNumberOfWeeksInMonthFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext;
- (NSInteger) mulleNumberOfWeeksInYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) ext;
- (NSInteger) mulleQuarterFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleWeekdayFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleWeekdayOrdinalFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleWeekOfMonthFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleWeekOfYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;

// always 1
- (NSInteger) mulleEraFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;

@end


static inline NSInteger   MulleSecondFromTimeInterval(NSTimeInterval interval)
{ // 0-59
    NSInteger   seconds;

    seconds = (NSInteger) interval % 60;
    if( seconds < 0)
        seconds = (60 + seconds);

    return( seconds);
}


static inline NSInteger   MulleNanosecondFromTimeInterval( NSTimeInterval interval)
{ // 0-999999999
   NSInteger   nano;

   // get rid of seconds, trying to keep precision here for the
   // multiply
   interval = interval - (NSInteger) interval;
   nano     = ((NSInteger) (interval * 1000000000)) % 1000000000;
   if( nano < 0)
      nano += 1000000000;

   return( nano);
}
