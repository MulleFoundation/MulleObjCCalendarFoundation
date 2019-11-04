#import "_MulleJulianCalendar.h"

#import "NSDateComponents.h"


/* $selId: julian.c,v 2.0 1995/10/24 01:13:06 lees Exp $
 * Copyright 1993-1995, Scott E. Lee, all rights reserved.
 * Permission granted to use, copy, modify, distribute and sell so long as
 * the above copyright and this permission statement are retained in all
 * copies.  THERE IS NO WARRANTY - USE AT YOUR OWN RISK.
 */

/**************************************************************************
 *
 * VALID RANGE
 *
 *     4713 B.C. to at least 10000 A.D.
 *
 *     Although this software can handle dates all the way back to 4713
 *     B.C., such use may not be meaningful.  The calendar was created in
 *     46 B.C., but the details did not stabilize until at least 8 A.D.,
 *     and perhaps as late at the 4th century.  Also, the beginning of a
 *     year varied from one culture to another - not all accepted January
 *     as the first month.
 *
 * CALENDAR OVERVIEW
 *
 *     Julias Ceasar created the calendar in 46 B.C. as a modified form of
 *     the old Roman republican calendar which was based on lunar cycles.
 *     The new Julian calendar set fixed lengths for the months, abandoning
 *     the lunar cycle.  It also specified that there would be exactly 12
 *     months per year and 365.25 days per year with every 4th year being a
 *     leap year.
 *
 *     Note that the current accepted value for the tropical year is
 *     365.242199 days, not 365.25.  This lead to an 11 day shift in the
 *     calendar with respect to the seasons by the 16th century when the
 *     Gregorian calendar was created to replace the Julian calendar.
 *
 *     The difference between the Julian and today's Gregorian calendar is
 *     that the Gregorian does not make centennial years leap years unless
 *     they are a multiple of 400, which leads to a year of 365.2425 days.
 *     In other words, in the Gregorian calendar, 1700, 1800 and 1900 are
 *     not leap years, but 2000 is.  All centennial years are leap years in
 *     the Julian calendar.
 *
 *     The details are unknown, but the lengths of the months were adjusted
 *     until they finally stablized in 8 A.D. with their current lengths:
 *
 *         January          31
 *         February         28/29
 *         March            31
 *         April            30
 *         May              31
 *         June             30
 *         Quintilis/July   31
 *         Sextilis/August  31
 *         September        30
 *         October          31
 *         November         30
 *         December         31
 *
 *     In the early days of the calendar, the days of the month were not
 *     numbered as we do today.  The numbers ran backwards (decreasing) and
 *     were counted from the Ides (15th of the month - which in the old
 *     Roman republican lunar calendar would have been the full moon) or
 *     from the Nonae (9th day before the Ides) or from the beginning of
 *     the next month.
 *
 *     In the early years, the beginning of the year varied, sometimes
 *     based on the ascension of rulers.  It was not always the first of
 *     January.
 *
 *     Also, today's epoch, 1 A.D. or the birth of Jesus Christ, did not
 *     come into use until several centuries later when Christianity became
 *     a dominant religion.
 *
 * ALGORITHMS
 *
 *     The calculations are based on two different cycles: a 4 year cycle
 *     of leap years and a 5 month cycle of month lengths.
 *
 *     The 5 month cycle is used to account for the varying lengths of
 *     months.  You will notice that the lengths alternate between 30 and
 *     31 days, except for three anomalies: both July and August have 31
 *     days, both December and January have 31, and February is less than
 *     30.  Starting with March, the lengths are in a cycle of 5 months
 *     (31, 30, 31, 30, 31):
 *
 *         Mar   31 days  \
 *         Apr   30 days   |
 *         May   31 days    > First cycle
 *         Jun   30 days   |
 *         Jul   31 days  /
 *
 *         Aug   31 days  \
 *         Sep   30 days   |
 *         Oct   31 days    > Second cycle
 *         Nov   30 days   |
 *         Dec   31 days  /
 *
 *         Jan   31 days  \
 *         Feb 28/9 days   |
 *                          > Third cycle (incomplete)
 *
 *     For this reason the calculations (internally) assume that the year
 *     starts with March 1.
 *
 * TESTING
 *
 *     This algorithm has been tested from the year 4713 B.C. to 10000 A.D.
 *     The source code of the verification program is included in this
 *     package.
 *
 * REFERENCES
 *
 *     Conversions Between Calendar Date and Julian Day Number by Robert J.
 *     Tantzen, Communications of the Association for Computing Machinery
 *     August 1963.  (Also published in Collected Algorithms from CACM,
 *     algorithm number 199).  [Note: the published algorithm is for the
 *     Gregorian calendar, but was adjusted to use the Julian calendar's
 *     simpler leap year rule.]
 *
 **************************************************************************/

NSString  *NSJulianCalendar = @"julian";


@implementation _MulleJulianCalendar

+ (void) load
{
   [self mulleRegisterClass:self
              forIdentifier:NSJulianCalendar];
}


- (NSString *) calendarIdentifier
{
   return( NSJulianCalendar);
}


static inline int
   mulleJulianIsSchaltjahr( NSInteger year)
{
   return( (year % 4) == 0);
}



- (NSInteger) mulleNumberOfDaysInYear:(NSInteger) year
{
   return( 365 + mulleJulianIsSchaltjahr( year));
}


// the ranges are compatible with Apple
- (NSRange) minimumRangeOfUnit:(NSCalendarUnit) unit
{
   switch( unit)
   {
   case NSCalendarUnitEra         : return( NSMakeRange( 0, 2));
   case NSCalendarUnitYear        : return( NSMakeRange( 1, 140742));
   case NSCalendarUnitMonth       : return( NSMakeRange( 1, 12));
   case NSCalendarUnitDay         : return( NSMakeRange( 1, 28));
   case NSCalendarUnitHour        : return( NSMakeRange( 0, 24));
   case NSCalendarUnitMinute      : return( NSMakeRange( 0, 60));
   case NSCalendarUnitSecond      : return( NSMakeRange( 0, 60));
   case NSCalendarUnitWeekday     : return( NSMakeRange( 1, 7));
   case NSCalendarUnitQuarter     : return( NSMakeRange( 1, 4));
   case NSCalendarUnitWeekOfMonth : return( NSMakeRange( 1, 4));
   case NSCalendarUnitWeekOfYear  : return( NSMakeRange( 1, 52));
   }
   return( NSMakeRange( NSNotFound, 0));
}


- (NSRange) maximumRangeOfUnit:(NSCalendarUnit) unit;
{
   switch( unit)
   {
   case NSCalendarUnitEra         : return( NSMakeRange( 0, 2));
   case NSCalendarUnitYear        : return( NSMakeRange( 1, 144683));
   case NSCalendarUnitMonth       : return( NSMakeRange( 1, 12));
   case NSCalendarUnitDay         : return( NSMakeRange( 1, 31));
   case NSCalendarUnitHour        : return( NSMakeRange( 0, 24));
   case NSCalendarUnitMinute      : return( NSMakeRange( 0, 60));
   case NSCalendarUnitSecond      : return( NSMakeRange( 0, 60));
   case NSCalendarUnitWeekday     : return( NSMakeRange( 1, 7));
   case NSCalendarUnitQuarter     : return( NSMakeRange( 1, 4));
   case NSCalendarUnitWeekOfMonth : return( NSMakeRange( 1, 6));
   case NSCalendarUnitWeekOfYear  : return( NSMakeRange( 1, 53));
   }
   return( NSMakeRange( NSNotFound, 0));
}


static inline NSInteger
   mulleJulianNumberOfDaysInMonthOfYear( NSInteger month,
                                         NSInteger year)
{
   assert( month >= 1 && month <= 12);
   assert( year >= 1 && year <= 144683);

   switch( month)
   {
   case 2:
      return( mulleJulianIsSchaltjahr( year) ? 29 : 28);

   case 4:
   case 6:
   case 9:
   case 11:
      return 30;

   default:
      return 31; // we have a hole in 10 but the last day is 31
   }
}


- (NSInteger) mulleNumberOfDaysInMonth:(NSInteger) month
                                ofYear:(NSInteger) year
{
   return( mulleJulianNumberOfDaysInMonthOfYear( month, year));
}


static int  accumulated_month_days[] =
{
   0,        // invalid
   0,        // JAN: accumulate nothing
   31,       // FEB: + JAN days
   31 + 28,  // MAR: JAN + FEB
   59 + 31,  // APR: JAN + FEB + MAR
   90 + 30,  // MAY: JAN + ... + APR
   120 + 31, // JUN: JAN + ... + MAY

   151 + 30, // JUL: ...
   181 + 31, // AUG:
   212 + 31, // SEP:
   243 + 30, // OKT:
   273 + 31, // NOV:
   304 + 30  // DEZ:
};

//
// the result should be elapsed DaysInCommonEra
//
- (NSInteger) mulleNumberOfDaysInCommonEraOfDay:(NSInteger) day
                                          month:(NSInteger) month
                                           year:(NSInteger) year
{
   NSInteger   result;

   assert( month >= 1 && month <= 12);
   assert( year >= 1 && year <= 144683);
   assert( day >= 1 && day <= mulleJulianNumberOfDaysInMonthOfYear( month, year));

   result = accumulated_month_days[ month];
   if( month > 2 && mulleJulianIsSchaltjahr( year))
     result++;

   year   -= 1;
   result += 365 * year;
   result += year / 4;
   result += day;
   result -= 1;  // 1.1.1 is not a full day

   return( result);
}



- (NSRange) rangeOfUnit:(NSCalendarUnit) unit
                 inUnit:(NSCalendarUnit) inUnit
                forDate:(NSDate *) date
{
   NSRange            range;
   NSDateComponents   *components;

   range = NSMakeRange( NSNotFound, NSNotFound);
   switch( unit)
   {
   case NSEraCalendarUnit :
      break;  // no dice

   // NSYearCalendarUnit in NSEraCalendarUnit @ 1.1.1970 12:00:00 : [1,144683]
   case NSYearCalendarUnit :
      switch( inUnit)
      {
      case NSEraCalendarUnit  :
         // TODO: check era and return min or max (for Gregorian)
         range = NSMakeRange( 1, 144683);
      }
      break;

   // NSMonthCalendarUnit in NSEraCalendarUnit @ 1.1.1970 12:00:00  : [1,12]
   // NSMonthCalendarUnit in NSYearCalendarUnit @ 1.1.1970 12:00:00 : [1,12]
   case NSMonthCalendarUnit :
      switch( inUnit)
      {
      case NSEraCalendarUnit  :
      case NSYearCalendarUnit :
         range = NSMakeRange( 1, 12);
      }
      break;

   // NSDayCalendarUnit in NSEraCalendarUnit @ 1.1.1970 12:00:00   : [1,31]
   // NSDayCalendarUnit in NSYearCalendarUnit @ 1.1.1970 12:00:00  : [1,365]
   // NSDayCalendarUnit in NSMonthCalendarUnit @ 1.1.1970 12:00:00 : [1,31]
   // NSDayCalendarUnit in NSWeekCalendarUnit @ 1.1.1970 12:00:00  : [1,3]
   case NSDayCalendarUnit :
   {
      components = [self components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                           fromDate:date];
      switch( inUnit)
      {
      case NSEraCalendarUnit :
      case NSMonthCalendarUnit :
         range = NSMakeRange( 1, [self mulleNumberOfDaysInMonth:components->_month
                                                         ofYear:components->_year]);
         break;

      case NSYearCalendarUnit :
         range = NSMakeRange( 1, [self mulleNumberOfDaysInYear:components->_year]);
         break;

      case NSWeekCalendarUnit :
         // What does 1,3 mean ?
         // It means that that the 1.1.1970 is a Thursday. There are three
         // days left (SO MO DI MI [DO] FR SA) if the week ends on a Saturday.
         // why is it a "1" though ?
         //
         // range = NSMakeRange( 1, 7);
         break;
      }
      break;
   }

   // NSHourCalendarUnit in NSEraCalendarUnit @ 1.1.1970 12:00:00 : [0,24]
   // NSHourCalendarUnit in NSYearCalendarUnit @ 1.1.1970 12:00:00 : [0,24]
   // NSHourCalendarUnit in NSMonthCalendarUnit @ 1.1.1970 12:00:00 : [0,24]
   // NSHourCalendarUnit in NSDayCalendarUnit @ 1.1.1970 12:00:00 : [0,24]
   // NSHourCalendarUnit in NSWeekCalendarUnit @ 1.1.1970 12:00:00 : [0,24]
   // NSHourCalendarUnit in NSWeekdayCalendarUnit @ 1.1.1970 12:00:00 : [0,24]
   case NSHourCalendarUnit :
      switch( inUnit)
      {
      case NSEraCalendarUnit    :
      case NSYearCalendarUnit   :
      case NSMonthCalendarUnit  :
      case NSDayCalendarUnit    :
      case NSWeekCalendarUnit   :
      case NSWeekdayCalendarUnit :
         range = NSMakeRange( 0, 24);
      }
      break;


   // NSMinuteCalendarUnit in NSEraCalendarUnit @ 1.1.1970 12:00:00 : [0,60]
   // NSMinuteCalendarUnit in NSYearCalendarUnit @ 1.1.1970 12:00:00 : [0,60]
   // NSMinuteCalendarUnit in NSMonthCalendarUnit @ 1.1.1970 12:00:00 : [0,60]
   // NSMinuteCalendarUnit in NSDayCalendarUnit @ 1.1.1970 12:00:00 : [0,60]
   // NSMinuteCalendarUnit in NSHourCalendarUnit @ 1.1.1970 12:00:00 : [0,60]
   // NSMinuteCalendarUnit in NSWeekCalendarUnit @ 1.1.1970 12:00:00 : [0,60]
   // NSMinuteCalendarUnit in NSWeekdayCalendarUnit @ 1.1.1970 12:00:00 : [0,60]
   case NSMinuteCalendarUnit :
      switch( inUnit)
      {
      case NSEraCalendarUnit     :
      case NSYearCalendarUnit    :
      case NSMonthCalendarUnit   :
      case NSDayCalendarUnit     :
      case NSHourCalendarUnit    :
      case NSWeekCalendarUnit    :
      case NSWeekdayCalendarUnit :
         range = NSMakeRange( 0, 60);
      }
      break;

   // NSSecondCalendarUnit in NSEraCalendarUnit @ 1.1.1970 12:00:00 : [0,60]
   // NSSecondCalendarUnit in NSYearCalendarUnit @ 1.1.1970 12:00:00 : [0,60]
   // NSSecondCalendarUnit in NSMonthCalendarUnit @ 1.1.1970 12:00:00 : [0,60]
   // NSSecondCalendarUnit in NSDayCalendarUnit @ 1.1.1970 12:00:00 : [0,60]
   // NSSecondCalendarUnit in NSHourCalendarUnit @ 1.1.1970 12:00:00 : [0,60]
   // NSSecondCalendarUnit in NSMinuteCalendarUnit @ 1.1.1970 12:00:00 : [0,60]
   // NSSecondCalendarUnit in NSWeekCalendarUnit @ 1.1.1970 12:00:00 : [0,60]
   // NSSecondCalendarUnit in NSWeekdayCalendarUnit @ 1.1.1970 12:00:00 : [0,60]
   case NSSecondCalendarUnit :
      switch( inUnit)
      {
      case NSEraCalendarUnit     :
      case NSYearCalendarUnit    :
      case NSMonthCalendarUnit   :
      case NSDayCalendarUnit     :
      case NSHourCalendarUnit    :
      case NSMinuteCalendarUnit  :
      case NSWeekCalendarUnit    :
      case NSWeekdayCalendarUnit :
         range = NSMakeRange( 0, 60);
      }
      break;

   // NSWeekCalendarUnit in NSEraCalendarUnit @ 31.3.2019 2:00:00 : [1,53]
   // NSWeekCalendarUnit in NSYearCalendarUnit @ 31.3.2019 2:00:00 : [1,53]
   // NSWeekCalendarUnit in NSMonthCalendarUnit @ 31.3.2019 2:00:00 : [9,6]
   case NSWeekCalendarUnit :
   {
      components = [self components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                           fromDate:date];
      switch( inUnit)
      {
      case NSEraCalendarUnit    :
      case NSYearCalendarUnit   :
         range = NSMakeRange( 1, [self mulleNumberOfWeeksInYear:components->_year]);
         break;

      case NSMonthCalendarUnit  :
         // figure out given month, figure out number of weeks in month
         // figure out week number of first week intersecting month
         break;
      }
      break;
   }

   // NSWeekdayCalendarUnit in NSEraCalendarUnit @ 1.1.1970 12:00:00 : [1,7]
   // NSWeekdayCalendarUnit in NSYearCalendarUnit @ 1.1.1970 12:00:00 : [1,7]
   // NSWeekdayCalendarUnit in NSMonthCalendarUnit @ 1.1.1970 12:00:00 : [1,7]
   // NSWeekdayCalendarUnit in NSWeekCalendarUnit @ 1.1.1970 12:00:00 : [1,7]
   case NSWeekdayCalendarUnit :
      switch( inUnit)
      {
      case NSEraCalendarUnit    :
      case NSYearCalendarUnit   :
      case NSMonthCalendarUnit  :
      case NSWeekCalendarUnit   :
         range = NSMakeRange( 1, 7);
      }
      break;

   // NSWeekdayOrdinalCalendarUnit in NSEraCalendarUnit @ 1.1.1970 12:00:00 : [1,5]
   // NSWeekdayOrdinalCalendarUnit in NSYearCalendarUnit @ 1.1.1970 12:00:00 : [1,59]
   // NSWeekdayOrdinalCalendarUnit in NSMonthCalendarUnit @ 1.1.1970 12:00:00 : [1,5]
   case NSWeekdayOrdinalCalendarUnit :
      switch( inUnit)
      {
      case NSEraCalendarUnit    :
      case NSMonthCalendarUnit  :
         range =NSMakeRange( 1, 5);
         break;

      case NSYearCalendarUnit   :
      //  I don't know what this means
      //   return( NSMakeRange( 1, 59); // or often 60
         break;
      }
   }
   return( range);
}


// such a beautiful API
- (BOOL) rangeOfUnit:(NSCalendarUnit) unit
           startDate:(NSDate **) p_startDate
            interval:(NSTimeInterval *) p_interval
             forDate:(NSDate *) date
{
   NSDateComponents   *components;
   union
   {
      NSTimeInterval   interval;
      NSDate           *date;
   } dummy;
   BOOL                flag;

   if( ! p_startDate)
      p_startDate = &dummy.date;
   if( ! p_interval)
      p_interval = &dummy.interval;

   components = [self components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|\
                                 NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
                        fromDate:date];

   //
   // NSEraCalendarUnit  @ 18.4.1848 12:00:00 : 3.1.1 0:00:00 - 4398046511104.0
   // NSYearCalendarUnit  @ 18.4.1848 12:00:00 : 1.1.1848 0:00:00 - 31622400.0
   // NSMonthCalendarUnit  @ 18.4.1848 12:00:00 : 1.4.1848 0:00:00 - 2592000.0
   // NSDayCalendarUnit  @ 18.4.1848 12:00:00 : 18.4.1848 0:00:00 - 86400.0
   // NSHourCalendarUnit  @ 18.4.1848 12:00:00 : 18.4.1848 12:00:00 - 3600.0
   // NSMinuteCalendarUnit  @ 18.4.1848 12:00:00 : 18.4.1848 12:00:00 - 60.0
   // NSSecondCalendarUnit  @ 18.4.1848 12:00:00 : 18.4.1848 12:00:00 - 1.0
   // NSWeekCalendarUnit  @ 18.4.1848 12:00:00 : 16.4.1848 0:00:00 - 604800.0
   // NSWeekdayCalendarUnit  @ 18.4.1848 12:00:00 : 18.4.1848 0:00:00 - 86400.0
   // NSWeekdayOrdinalCalendarUnit  @ 18.4.1848 12:00:00 : 18.4.1848 0:00:00 - 86400.0
   //
   switch( unit)
   {
   default                        : return( NO);
   case NSCalendarUnitEra         : return( NO);
   case NSCalendarUnitYear        : return( NO);
   case NSCalendarUnitMonth       : return( NO);
   // hard coded values
   case NSCalendarUnitDay         : *p_interval = 86400.0; break;
   case NSCalendarUnitHour        : *p_interval = 3600.0; break;
   case NSCalendarUnitMinute      : *p_interval = 60.0; break;
   case NSCalendarUnitSecond      : *p_interval = 1.0; break;
   case NSCalendarUnitWeekday     : *p_interval = 604800.0; break;
   case NSCalendarUnitWeekOfMonth :
   case NSCalendarUnitWeekOfYear  : *p_interval = 86400.0; break;
      break;
   }

   if( p_startDate)
   {
      switch( unit)
      {
      default                        : break;
      case NSCalendarUnitEra         : break;
      case NSCalendarUnitYear        : break;
      case NSCalendarUnitMonth       : break;
      // hard coded values
      case NSCalendarUnitDay         : break;
      case NSCalendarUnitHour        :
      case NSCalendarUnitMinute      :
      case NSCalendarUnitSecond      : *p_startDate = date; break;
      case NSCalendarUnitWeekday     : break;
      case NSCalendarUnitWeekOfMonth : break;
      case NSCalendarUnitWeekOfYear  : break;
      }
   }
   return( YES);
}

@end



