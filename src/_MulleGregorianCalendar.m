#import "_MulleGregorianCalendar.h"

/* $selId: gregor.c,v 2.0 1995/10/24 01:13:06 lees Exp $
 * Copyright 1993-1995, Scott E. Lee, all rights reserved.
 * Permission granted to use, copy, modify, distribute and sell so long as
 * the above copyright and this permission statement are retained in all
 * copies.  THERE IS NO WARRANTY - USE AT YOUR OWN RISK.
 */

/**************************************************************************
 *
 * These are the externally visible components of this file:
 *
 *     void
 *     SdnToGregorian(
 *         long int  sdn,
 *         int      *pYear,
 *         int      *pMonth,
 *         int      *pDay);
 *
 * Convert a SDN to a Gregorian calendar date.  If the input SDN is less
 * than 1, the three output values will all be set to zero, otherwise
 * *pYear will be >= -4714 and != 0; *pMonth will be in the range 1 to 12
 * inclusive; *pDay will be in the range 1 to 31 inclusive.
 *
 *     long int
 *     GregorianToSdn(
 *         int inputYear,
 *         int inputMonth,
 *         int inputDay);
 *
 * Convert a Gregorian calendar date to a SDN.  Zero is returned when the
 * input date is detected as invalid or out of the supported range.  The
 * return value will be > 0 for all valid, supported dates, but there are
 * some invalid dates that will return a positive value.  To verify that a
 * date is valid, convert it to SDN and then back and compare with the
 * original.
 *
 *     char *MonthNameShort[13];
 *
 * Convert a Gregorian month number (1 to 12) to the abbreviated (three
 * character) name of the Gregorian month (null terminated).  An index of
 * zero will return a zero length string.
 *
 *     char *MonthNameLong[13];
 *
 * Convert a Gregorian month number (1 to 12) to the name of the Gregorian
 * month (null terminated).  An index of zero will return a zero length
 * string.
 *
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
#define SDN_OFFSET         32045
#define DAYS_PER_5_MONTHS  153
#define DAYS_PER_4_YEARS   1461
#define DAYS_PER_400_YEARS 146097

static void
SdnToGregorian(
    long int  sdn,
    int      *pYear,
    int      *pMonth,
    int      *pDay)
{
    int       century;
    int       year;
    int       month;
    int       day;
    long int  temp;
    int       dayOfYear;

    if (sdn <= 0) {
   *pYear = 0;
   *pMonth = 0;
   *pDay = 0;
   return;
    }

    temp = (sdn + SDN_OFFSET) * 4 - 1;

    /* Calculate the century (year/100). */
    century = temp / DAYS_PER_400_YEARS;

    /* Calculate the year and day of year (1 <= dayOfYear <= 366). */
    temp = ((temp % DAYS_PER_400_YEARS) / 4) * 4 + 3;
    year = (century * 100) + (temp / DAYS_PER_4_YEARS);
    dayOfYear = (temp % DAYS_PER_4_YEARS) / 4 + 1;

    /* Calculate the month and day of month. */
    temp = dayOfYear * 5 - 3;
    month = temp / DAYS_PER_5_MONTHS;
    day = (temp % DAYS_PER_5_MONTHS) / 5 + 1;

    /* Convert to the normal beginning of the year. */
    if (month < 10) {
   month += 3;
    } else {
   year += 1;
   month -= 9;
    }

    /* Adjust to the B.C./A.D. type numbering. */
    year -= 4800;
    if (year <= 0) year--;

    *pYear = year;
    *pMonth = month;
    *pDay = day;
}

static long int
GregorianToSdn(
    int inputYear,
    int inputMonth,
    int inputDay)
{
    int year;
    int month;

    /* check for invalid dates */
    if (inputYear == 0 || inputYear < -4714 ||
   inputMonth <= 0 || inputMonth > 12 ||
   inputDay <= 0 || inputDay > 31)
    {
   return(0);
    }

    /* check for dates before SDN 1 (Nov 25, 4714 B.C.) */
    if (inputYear == -4714) {
   if (inputMonth < 11) {
       return(0);
   }
   if (inputMonth == 11 && inputDay < 25) {
       return(0);
   }
    }

    /* Make year always a positive number. */
    if (inputYear < 0) {
   year = inputYear + 4801;
    } else {
   year = inputYear + 4800;
    }

    /* Adjust the start of the year. */
    if (inputMonth > 2) {
   month = inputMonth - 3;
    } else {
   month = inputMonth + 9;
   year--;
    }

    return( ((year / 100) * DAYS_PER_400_YEARS) / 4
       + ((year % 100) * DAYS_PER_4_YEARS) / 4
       + (month * DAYS_PER_5_MONTHS + 2) / 5
       + inputDay
       - SDN_OFFSET );
}



NSString  *NSGregorianCalendar = @"gregorian";

#define MulleGregorianDaysOfCommonEraOfReferenceDate  730486

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


- (struct MulleCalendarDate) mulleCalendarDateFromCanonicalDay:(mulle_canonicalcalendardate_t) sdn
{
   struct MulleCalendarDate   date;
   int                        year;
   int                        month;
   int                        day;

   SdnToGregorian( sdn, &year, &month, &day);
   date.year  = year;
   date.month = month;
   date.day   = day;
   return( date);
}


- (mulle_canonicalcalendardate_t) mulleCanonicalDateFromCalendarDate:(struct MulleCalendarDate) date
{
   return( GregorianToSdn( date.year, date.month, date.day));
}


- (NSInteger) mulleDaysOfCommonEraOfReferenceDate
{
   return( MulleGregorianDaysOfCommonEraOfReferenceDate);
}



static inline int
   mulleGregorianIsSchaltjahr( NSInteger year)
{
   assert( year >= 1 && year <= 144683);

   return( ((year % 4) == 0 && (year % 100) != 0) || (year % 400) == 0);
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

   default:
      return 31;
   }
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



- (NSInteger) mulleNumberOfDaysInCommonEraOfDay:(NSInteger) day
                                          month:(NSInteger) month
                                           year:(NSInteger) year
{
   NSInteger result;

   assert( day >= 1 && day <= 366);
   assert( month >= 1 && month <= 12);
   assert( year >= 1 && year <= 144683);

   result = accumulated_month_days[ month];
   if( month > 2 && mulleGregorianIsSchaltjahr( year))
     result++;

   year   -= 1;
   result += 365 * year;
   result += year / 4;
   result -= year / 100;
   result += year / 400;

   result += day;

   return( result);
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

@end


@implementation NSCalendar( _MulleGregorianCalendar)


+ (instancetype) currentCalendar
{
   return( [[[self alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease]);
}

@end


