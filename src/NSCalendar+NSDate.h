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


struct MulleExtendedTimeInterval
{
   NSTimeInterval    interval;
   NSInteger         year;
   NSInteger         month;
   NSInteger         dayOfCommonEra;
   NSInteger         dayOfMonth;
   NSInteger         hour;
};


static void  MulleExtendedTimeIntervalInit( struct MulleExtendedTimeInterval *p,
                                            NSTimeInterval interval)
{
   p->interval       = interval;

   p->year           =
   p->month          =
   p->dayOfCommonEra =
   p->dayOfMonth     =
   p->hour           = NSIntegerMax;
}


@interface NSCalendar( NSDate)

- (NSTimeInterval) mulleTimeIntervalWithYear:(NSInteger) year
                                       month:(NSInteger) month
                                         day:(NSInteger) day
                                        hour:(NSInteger) hour
                                      minute:(NSInteger) minute
                                      second:(NSInteger) second
                                 millisecond:(NSInteger) millisecond;

- (NSInteger) mulleDayOfCommonEraFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
// always 1
- (NSInteger) mulleEraFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleDayOfYearFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleMonthFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleDayOfMonthFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleWeekdayFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulle24HourFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulle12HourFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleAMPMFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;
- (NSInteger) mulleMinuteFromExtendedTimeInterval:(struct MulleExtendedTimeInterval *) extended;

@end


static inline NSInteger   MulleSecondFromTimeInterval(NSTimeInterval interval)
{ // 0-59
    NSInteger   seconds;

    seconds = (NSInteger) interval % 60;
    if( seconds < 0)
        seconds = (60 + seconds);

    return seconds;
}


static inline NSInteger   MulleMillisecondsFromTimeInterval( NSTimeInterval interval)
{ // 0-999
   NSInteger   milli;

   milli = (NSInteger) (interval * 1000) % 1000;
   if( milli < 0)
   {
      milli = (1000 + milli);
   }
   return milli;
}
