#import "_MulleGregorianCalendar.h"

#import "NSCalendar+NSDate.h"


// the non-proleptic code is more for documentation purposes
// #define USE_JULIAN_BEFORE_CHANGE


//
// Start of standard gregorian is 15.10.1582, but this is "proleptic"
// Gregorian meaning the start is 1.1.1. (See ISO norm for that).
//
NSString  *NSGregorianCalendar = @"gregorian";

// Our reference date is 00:00:00 UTC on 1 January 2001.
// The calendar starts on 00:00:00 1.1.1  (not 12:00 as Julian)
//
// The mean tropical year in 2000 was 365.24219 ephemeris days; each ephemeris
// day lasts 86,400 SI seconds. This is 365.24217 mean solar days
// (Richards 2013, p. 587).
// So 2000*365.24219 = 730484,38 and 2000*365.24219 = 730484,34
// Gregorian defines it as 365.2425 -> 2000*365.2425 = 730485
//
// 5.10.1582 - 14.10-1582 as calendar days do not exist in standard gregorian.
// The "proleptic" gregorian calendar, that this represents just doesn't care.
// There are no lost days, so 14.10 comes before 15.10 and is the same as
// 4.10 Julian.  Therefore the NSTimeInterval of 4.10 Julian and 14.10
// proleptic Gregorian is different.
// This also means that 1.1.1 in proleptic Gregorian is not 1.1.1 in Julian.
//
// All days summed up from 1.1.1 to 1.1.2001 are 730485 days
//

#ifdef USE_JULIAN_BEFORE_CHANGE
# define MulleGregorianDaysOfCommonEraOfReferenceDate   730487
#else
# define MulleGregorianDaysOfCommonEraOfReferenceDate   730485
#endif


@implementation _MulleGregorianCalendar

MULLE_OBJC_DEPENDS_ON_LIBRARY( MulleObjCStandardFoundation);

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


- (NSInteger) mulleFirstWeekdayOfCommonEra
{
   return( 2);  // Gregorian 1.1.1 is a Monday (which is 2)
}



#ifdef USE_JULIAN_BEFORE_CHANGE

// because we treat the missing ones in a "special" way, we claim 5-14 as
// gregorian
MULLE_C_CONST_RETURN
static inline int   is_gregorian_date( NSInteger day, NSInteger month, NSInteger year)
{
   return( year > 1582 || (year == 1582 && (month > 10 || (month == 10 && day > 4))));
}


//
// the whole in the middle is gone because of Pope Gregory
//
MULLE_C_CONST_RETURN
static inline int   is_missing_date( NSInteger day, NSInteger month, NSInteger year)
{
   return( year == 1582 && month == 10 && day > 4 && day < 15);
}


MULLE_C_CONST_RETURN
static inline int   mulleGregorianIsSchaltjahr( NSInteger year)
{
   assert( year >= 1 && year <= 144683);

   if( year > 1582)
      return( ((year % 4) == 0 && (year % 100) != 0) || (year % 400) == 0);
   return( (year % 4) == 0);
}


MULLE_C_CONST_RETURN
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


MULLE_C_CONST_RETURN
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


MULLE_C_CONST_RETURN
static inline int   mulleGregorianIsSchaltjahr( NSInteger year)
{
   assert( year >= 1 && year <= 144683);

   return( ((year % 4) == 0 && (year % 100) != 0) || (year % 400) == 0);
}


- (BOOL) mulleIsLeapYear:(NSInteger) year
{
   return( mulleGregorianIsSchaltjahr( year));
}


MULLE_C_CONST_RETURN
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


MULLE_C_CONST_RETURN
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



- (void) _mulleCorrectDay:(NSInteger *) p_day
                    month:(NSInteger *) p_month
                     year:(NSInteger *) p_year
{
   NSInteger   day;
   NSInteger   month;
   NSInteger   year;
   NSInteger   max;

   day   = *p_day;
   month = *p_month;
   year  = *p_year;

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

         day -= mulleGregorianNumberOfDaysInMonthOfYear( month, year);
         // adjust (go forwards in time)
         if( ++month > 12)
         {
            month = 1;
            ++year;
         }
      }
   }

   *p_day   = day;
   *p_month = month;
   *p_year  = year;
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

@end


@implementation NSCalendar( _MulleGregorianCalendar)

+ (instancetype) currentCalendar
{
   return( [[[self alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease]);
}

@end


