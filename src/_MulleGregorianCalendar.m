#import "_MulleGregorianCalendar.h"

#import "NSCalendar+NSDate.h"


// the non-proleptic code is more for documentation purposes
// #define USE_JULIAN_BEFORE_CHANGE


/* $selId: gregor.c,v 2.0 1995/10/24 01:13:06 lees Exp $
 * Copyright 1993-1995, Scott E. Lee, all rights reserved.
 * Permission granted to use, copy, modify, distribute and sell so long as
 * the above copyright and this permission statement are retained in all
 * copies.  THERE IS NO WARRANTY - USE AT YOUR OWN RISK.
 */

/**************************************************************************
 * VALID RANGE
 *
 *     4714 B.C. to at least 10000 A.D.
 *
 *     Although this software can handle dates all the way back to 4714
 *     B.C., such use may not be meaningful.  The Gregorian calendar was
 *     not instituted until October 15, 1582 (or October 5, 1582 in the
 *     Julian calendar).  Some countries did not accept it until much
 *     later.  For example, Britain converted in 1752, The USSR in 1918 and
 *     Greece in 1923.  Most European countries used the Julian calendar
 *     prior to the Gregorian.
 *
 * CALENDAR OVERVIEW
 *
 *     The Gregorian calendar is a modified version of the Julian calendar.
 *     The only difference being the specification of leap years.  The
 *     Julian calendar specifies that every year that is a multiple of 4
 *     will be a leap year.  This leads to a year that is 365.25 days long,
 *     but the current accepted value for the tropical year is 365.242199
 *     days.
 *
 *     To correct this error in the length of the year and to bring the
 *     vernal equinox back to March 21, Pope Gregory XIII issued a papal
 *     bull declaring that Thursday October 4, 1582 would be followed by
 *     Friday October 15, 1582 and that centennial years would only be a
 *     leap year if they were a multiple of 400.  This shortened the year
 *     by 3 days per 400 years, giving a year of 365.2425 days.
 *
 *     Another recently proposed change in the leap year rule is to make
 *     years that are multiples of 4000 not a leap year, but this has never
 *     been officially accepted and this rule is not implemented in these
 *     algorithms.
 *
 * ALGORITHMS
 *
 *     The calculations are based on three different cycles: a 400 year
 *     cycle of leap years, a 4 year cycle of leap years and a 5 month
 *     cycle of month lengths.
 *
 *     The 5 month cycle is used to account for the varying lengths of
 *     months.  You will notice that the lengths alternate between 30
 *     and 31 days, except for three anomalies: both July and August
 *     have 31 days, both December and January have 31, and February
 *     is less than 30.  Starting with March, the lengths are in a
 *     cycle of 5 months (31, 30, 31, 30, 31):
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
 *     For this reason the calculations (internally) assume that the
 *     year starts with March 1.
 *
 * TESTING
 *
 *     This algorithm has been tested from the year 4714 B.C. to 10000
 *     A.D.  The source code of the verification program is included in
 *     this package.
 *
 * REFERENCES
 *
 *     Conversions Between Calendar Date and Julian Day Number by Robert J.
 *     Tantzen, Communications of the Association for Computing Machinery
 *     August 1963.  (Also published in Collected Algorithms from CACM,
 *     algorithm number 199).
 *
 **************************************************************************/
//
// Start of this calendar is 15.10.1582
// Basically any dates before the start are invalid. But one can migrate to
// Julian for that. I believe that is what ISO does.
//
NSString  *NSGregorianCalendar = @"gregorian";

// Our reference date is 00:00:00 UTC on 1 January 2001.
// So if the calendar starts on 00:00:00 1.1.1 (does it or is it noon)
//
// The mean tropical year in 2000 was 365.24219 ephemeris days; each ephemeris
// day lasting 86,400 SI seconds.[1] This is 365.24217 mean solar days
// (Richards 2013, p. 587).
// So 2000*365.24219 = 730484,38 and 2000*365.24219 = 730484,34
// Gregorian defines it as 365.2425 -> 2000*365.2425 = 730485
// It doesn't really work though, because summing up the days from 1.1.1 to
// 1.1.2001 gives: 730486 bummer!
//
// 5.10.1582 - 14.10-1582 as calendar days do not exist, if you do it
// right and migrate from Julian to Gregorian. This is not how its done though.
// The "probleptic" gregoran calendar just doesn't care. There are no lost
// days, so 14.10 in Gegorian is 4.10 Julian. (See ISO norm for that)
//
// +730851 days since 0000-01-01 until Jan 01 2001 according to
// https://www.epochconverter.com/seconds-days-since-y0
// 0000-00-00 is same as 0000-01-01
//
// means 730485 days since 1.1.0001 since 0 is leap year
// Alright then why is this 730487 ? All days summed ala Julian up till
// Gregorian and then ala Gregorian until 1.1.2001 equal 730487
//

#ifdef USE_JULIAN_BEFORE_CHANGE
# define MulleGregorianDaysOfCommonEraOfReferenceDate   730487
#else
# define MulleGregorianDaysOfCommonEraOfReferenceDate   730485
#endif


@implementation _MulleGregorianCalendar

+ (void) load
{
   [self mulleRegisterClass:self
              forIdentifier:NSGregorianCalendar];
}


- (NSString *) calendarIdentifier
{
   return( NSGregorianCalendar);
}


- (id) init
{
   [super init];

   _daysOfCommonEraOfReferenceDate = MulleGregorianDaysOfCommonEraOfReferenceDate;

   return( self);
}


- (NSInteger) mulleDaysOfCommonEraOfReferenceDate
{
   return( _daysOfCommonEraOfReferenceDate);
}


#ifdef USE_JULIAN_BEFORE_CHANGE

// because we treat the missing ones in a "special" way, we claim 5-14 as
// gregorian
static inline int   is_gregorian_date( NSInteger day, NSInteger month, NSInteger year)
{
   return( year > 1582 || (year == 1582 && (month > 10 || (month == 10 && day > 4))));
}


//
// the whole in the middle is gone because of Pope Gregory
//
static inline int   is_missing_date( NSInteger day, NSInteger month, NSInteger year)
{
   return( year == 1582 && month == 10 && day > 4 && day < 15);
}


static inline int
   mulleGregorianIsSchaltjahr( NSInteger year)
{
   assert( year >= 1 && year <= 144683);

   if( year > 1582)
      return( ((year % 4) == 0 && (year % 100) != 0) || (year % 400) == 0);
   return( (year % 4) == 0);
}


static inline NSInteger
   mulleGregorianMaxCalendarDayInMonthOfYear( NSInteger month,
                                            NSInteger year)
{
   assert( month >= 1 && month <= 12);
   assert( year >= 1 && year <= 144683);

   switch( month)
   {
   case 2:
      return( mulleGregorianIsSchaltjahr( year) ? 29 : 28);

   case 4:
   case 6:
   case 9:
   case 11:
      return 30;

   default:
      return 31; // we have a hole in 10 but the last day is 31
   }
}


static inline NSInteger
   mulleGregorianNumberOfDaysInMonthOfYear( NSInteger month,
                                            NSInteger year)
{
   assert( month >= 1 && month <= 12);
   assert( year >= 1 && year <= 144683);

   switch( month)
   {
   case 2:
      return( mulleGregorianIsSchaltjahr( year) ? 29 : 28);

   case 4:
   case 6:
   case 9:
   case 11:
      return 30;

   case 10 :
      return( year == 1582 ? 21 : 31);

   default:
      return 31;
   }
}

#endif

static inline int
   mulleGregorianIsSchaltjahr( NSInteger year)
{
   assert( year >= 1 && year <= 144683);

   return( ((year % 4) == 0 && (year % 100) != 0) || (year % 400) == 0);
}


static inline NSInteger
   mulleGregorianMaxCalendarDayInMonthOfYear( NSInteger month,
                                                       NSInteger year)
{
   assert( month >= 1 && month <= 12);
   assert( year >= 1 && year <= 144683);

   switch( month)
   {
   case 2:
      return( mulleGregorianIsSchaltjahr( year) ? 29 : 28);

   case 4:
   case 6:
   case 9:
   case 11:
      return 30;

   default:
      return 31; // we have a hole in 10 but the last day is 31
   }
}


static inline NSInteger
   mulleGregorianNumberOfDaysInMonthOfYear( NSInteger month,
                                            NSInteger year)
{
   return( mulleGregorianMaxCalendarDayInMonthOfYear( month, year));
}



- (NSInteger) mulleNumberOfDaysInMonth:(NSInteger) month
                                ofYear:(NSInteger) year
{
   return( mulleGregorianNumberOfDaysInMonthOfYear( month, year));
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


- (NSInteger) mulleNumberOfDaysInYear:(NSInteger) year
{
#ifdef USE_JULIAN_BEFORE_CHANGE
   if( year == 1582)
      return( 355);
#endif
   return( 365 + mulleGregorianIsSchaltjahr( year));
}



//
// the result should be elapsed DaysInCommonEra
// Which isn't necessarily the same as tropical days
//
- (NSInteger) mulleNumberOfDaysInCommonEraOfDay:(NSInteger) day
                                          month:(NSInteger) month
                                           year:(NSInteger) year
{
   NSInteger   result;
   BOOL        isGregorian;

   assert( month >= 1 && month <= 12);
   assert( year >= 1 && year <= 144683);
   assert( day >= 1 && day <= mulleGregorianMaxCalendarDayInMonthOfYear( month, year));

   result = accumulated_month_days[ month];
   if( month > 2 && mulleGregorianIsSchaltjahr( year))
     result++;

#ifdef USE_JULIAN_BEFORE_CHANGE
   isGregorian = is_gregorian_date( day, month, year);

   if( year == 1582)
   {
      // there are 10 days less in Okt. 1582, so adjust Nov Dez accumulate
      if( month >= 11)
         result -= 10;
      else
      {
         if( is_missing_date( day, month, year))
         {
            // adjust invalid dates away
            day = 15;
         }
      }
   }
   //
   // with the julian calendar ending on 4.10.1582
   // 57736 days were elapsed
   //
   if( isGregorian)
#endif
   {
      year   -= 1;
      result += 365 * year;
      result += year / 4;
      result -= year / 100;
      result += year / 400;
      result += day;
#ifdef USE_JULIAN_BEFORE_CHANGE
      result += 1;  // fudge
#else
      result -= 1;
#endif
      return( result);
   }

#ifdef USE_JULIAN_BEFORE_CHANGE
   year   -= 1;
   result += 365 * year;
   result += year / 4;
   result += day;
   result -= 1;  // 1.1.1 is not a full day

   return( result);
#endif
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

#ifdef USE_JULIAN_BEFORE_CHANGE
   if( is_missing_date( day, month, year))
      day = 15;
#endif

   ext->dayOfMonth = day;

   return( day);
}


//
// 15.10.1582 0:00:00 = -13197600000.0
// therefore
// 4.10.1582 23:59:59 = -13197600001.0
// when USE_JULIAN_BEFORE_CHANGE is defined
//
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
   NSInteger        max;

   //
   // day can be crazy and must be adjusted, all the other
   // values are assumed to be sane...
   // Shabby code follows to get something going
   //
   if( day < 1)
   {
      // adjust (go backwards in time)
      for(;;)
      {
         if( --month < 1)
         {
            month = 12;
            --year;
         }

         max  = mulleGregorianNumberOfDaysInMonthOfYear( month, year);
         day += max;
         if( day >= 1)
            break;
      }
   }
   else
   {
      for(;;)
      {
         max = mulleGregorianMaxCalendarDayInMonthOfYear( month, year);
         if( day <= max)
            break;

         // adjust (go forwards in time)
         if( ++month > 12)
         {
            month = 1;
            ++year;
         }
         if( year == 1582 && month == 10)
            max -= 10;
         day -= max;
      }
   }

   daysOfCommonEra  = [self mulleNumberOfDaysInCommonEraOfDay:day
                                                        month:month
                                                         year:year];
   daysOfCommonEra -= _daysOfCommonEraOfReferenceDate;

   interval = (daysOfCommonEra * 86400.0) + (hour * 3600) + (minute * 60) + second;

   if( millisecond)
      interval += millisecond / 1000.0 + 0.0001; // + 0.0001 ???

   return( interval);
}

@end


@implementation NSCalendar( _MulleGregorianCalendar)


+ (instancetype) currentCalendar
{
   return( [[[self alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease]);
}

@end


