/* Copyright (c) 2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE. */

#import "NSCalendar.h"

#import "NSCalendar+NSDate.h"
#import "NSDateComponents.h"

#import "import-private.h"



@implementation NSCalendar


static struct
{
   NSMapTable   *_table;
} Self;


MULLE_OBJC_DEPENDS_ON_LIBRARY( MulleObjCStandardFoundation);


+ (void) initialize
{
   if( Self._table)
      return;

   Self._table = NSCreateMapTable( NSObjectMapKeyCallBacks,
                                   NSObjectMapValueCallBacks,
                                   4);
}


+ (void) deinitialize
{
   if( Self._table)
   {
      NSFreeMapTable( Self._table);
      Self._table = NULL;
   }
}


+ (void) mulleRegisterClass:(Class) cls
              forIdentifier:(NSString *) identifier
{
   NSMapInsert( Self._table, identifier, cls);
}


- (id) copy
{
   NSCalendar   *clone;

   clone            = NSCopyObject( self, 0, NULL);
   clone->_timeZone = [clone->_timeZone copy];
   clone->_locale   = [clone->_locale copy];

   return( clone);
}


- (instancetype) init
{
   _timeZone = [[NSTimeZone localTimeZone] copy];
   _locale   = [[NSLocale currentLocale] copy];
   return( self);
}


+ (instancetype) calendarWithIdentifier:(NSString *) identifier;
{
   return( [[[self alloc] initWithCalendarIdentifier:identifier] autorelease]);
}


- (instancetype) initWithCalendarIdentifier:(NSString *) identifier
{
   Class   calendarClass;

   calendarClass = NSMapGet( Self._table, identifier);
   [self autorelease];
   return( [calendarClass new]);
}


- (NSDateComponents *) components:(NSUInteger) flags
                         fromDate:(NSDate *) date
{
   NSDateComponents                   *result;
   struct MulleExtendedTimeInterval   extended;
   NSTimeInterval                     interval;

   interval  = [date timeIntervalSinceReferenceDate];
   interval -= [_timeZone secondsFromGMTForDate:date];

   result = [[NSDateComponents new] autorelease];

   MulleExtendedTimeIntervalInit( &extended, interval);

   if( flags & NSEraCalendarUnit)
      result->_era = [self mulleEraFromExtendedTimeInterval:&extended];
   if( flags & NSYearCalendarUnit)
      result->_year = [self mulleYearFromExtendedTimeInterval:&extended];
   if( flags & NSMonthCalendarUnit)
      result->_month = [self mulleMonthFromExtendedTimeInterval:&extended];
   if( flags & NSDayCalendarUnit)
      result->_day = [self mulleDayOfMonthFromExtendedTimeInterval:&extended];

   if( flags & NSHourCalendarUnit)
      result->_hour = [self mulle24HourFromExtendedTimeInterval:&extended];
   if( flags & NSMinuteCalendarUnit)
      result->_minute = [self mulleMinuteFromExtendedTimeInterval:&extended];
   if( flags & NSSecondCalendarUnit)
      result->_second = MulleSecondFromTimeInterval( interval);

   if( flags & NSWeekdayCalendarUnit)
      result->_weekday = [self mulleWeekdayFromExtendedTimeInterval:&extended];

   return( result);
}


- (NSDate *) dateFromComponents:(NSDateComponents *) components
{
   NSDate           *date;
   NSTimeInterval   interval;
   NSInteger        year;
   NSInteger        month;
   NSInteger        day;
   NSInteger        hour;
   NSInteger        minute;
   NSInteger        second;

   // the 1 initialization is also calendar dependent, but this is a base for
   // for subclasses.
   year   = components->_year   != NSDateComponentUndefined ? components->_year  : 1;
   month  = components->_month  != NSDateComponentUndefined ? components->_month : 1;
   day    = components->_day    != NSDateComponentUndefined ? components->_day   : 1;

   hour   = components->_hour   != NSDateComponentUndefined ? components->_hour   : 0;
   minute = components->_minute != NSDateComponentUndefined ? components->_minute : 0;
   second = components->_second != NSDateComponentUndefined ? components->_second : 0;

   interval = [self mulleTimeIntervalWithYear:year
                                        month:month
                                          day:day
                                         hour:hour
                                       minute:minute
                                       second:second
                                  millisecond:0];

   date       = [NSDate dateWithTimeIntervalSinceReferenceDate:interval];
   interval  += [_timeZone secondsFromGMTForDate:date];

   return( [NSDate dateWithTimeIntervalSinceReferenceDate:interval]);
}


static NSInteger  mod_0_n( NSInteger *value, NSInteger max)
{
   NSInteger   diff;

   if( *value < 0)
   {
      diff   = *value / max;
      *value = max - (*value  % max);
      return( diff);
   }

   if( *value >= max)
   {
      diff    = *value / max;
      *value %= max;
      return( diff);
   }

   return( 0);
}


static inline NSInteger  mod_0_60( NSInteger *value)
{
   return( mod_0_n( value, 60));
}


static inline NSInteger  mod_0_24( NSInteger *value)
{
   return( mod_0_n( value, 24));
}


static NSInteger  mod_1_13( NSInteger *value)
{
   NSInteger   diff;

   *value -= 1;
   diff    = mod_0_n( value, 12);
   *value += 1;
   return( diff);
}


- (NSDate *) dateByAddingComponents:(NSDateComponents *) components
                             toDate:(NSDate *) date
                            options:(NSUInteger) options
{
   NSDateComponents   *dateComponents;

   if( ! options)
      abort();

   dateComponents = [self components:NSEraCalendarUnit|\
                                     NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|\
                                     NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
                            fromDate:date];

   dateComponents->_year   += components->_year   != NSDateComponentUndefined ? components->_year  : 0;
   dateComponents->_month  += components->_month  != NSDateComponentUndefined ? components->_month : 1;
   dateComponents->_day    += components->_day    != NSDateComponentUndefined ? components->_day   : 1;

   dateComponents->_hour   += components->_hour   != NSDateComponentUndefined ? components->_hour   : 0;
   dateComponents->_minute += components->_minute != NSDateComponentUndefined ? components->_minute : 0;
   dateComponents->_second += components->_second != NSDateComponentUndefined ? components->_second : 0;

   dateComponents->_minute += mod_0_60( &dateComponents->_second);
   dateComponents->_hour   += mod_0_60( &dateComponents->_minute);
   dateComponents->_day    += mod_0_24( &dateComponents->_hour);

   // days overflow like they want
   // we can't overflow them into months or years as it makes no sense

   //
   // but under/overflowing months is not a problem
   //
   dateComponents->_year   += mod_1_13( &dateComponents->_month);

   return( [self dateFromComponents:dateComponents]);
}

@end
