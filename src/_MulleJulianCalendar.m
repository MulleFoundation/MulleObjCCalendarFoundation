#import "_MulleJulianCalendar.h"

#import "NSDateComponents.h"

#import "NSCalendar+NSDate.h"


NSString  *NSJulianCalendar = @"julian";

//
// hmm, julian day starts 12:00 so maybe it should be half a day less ?
//
#define MulleJulianDaysOfCommonEraOfReferenceDate   730500


@implementation _MulleJulianCalendar

+ (void) load
{
   [self mulleRegisterClass:self
              forIdentifier:NSJulianCalendar];
}


- (id) init
{
   [super init];

   _daysOfCommonEraOfReferenceDate = MulleJulianDaysOfCommonEraOfReferenceDate;
   _firstWeekday                   = MulleCalendarSunday;
   _minimumDaysInFirstWeek         = 1;

   return( self);
}


- (NSString *) calendarIdentifier
{
   return( NSJulianCalendar);
}


- (NSInteger) mulleFirstWeekdayOfCommonEra
{
   return( 7);  // Julian 1.1.1 is a Saturday
}


MULLE_C_CONST_RETURN
static inline int
   mulleJulianIsSchaltjahr( NSInteger year)
{
   return( (year % 4) == 0);
}


- (BOOL) mulleIsLeapYear:(NSInteger) year
{
   return( mulleJulianIsSchaltjahr( year));
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
   case NSCalendarUnitNanosecond  : return( NSMakeRange( 0, 1000000000));
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
   case NSCalendarUnitNanosecond  : return( NSMakeRange( 0, 1000000000));
   case NSCalendarUnitWeekday     : return( NSMakeRange( 1, 7));
   case NSCalendarUnitQuarter     : return( NSMakeRange( 1, 4));
   case NSCalendarUnitWeekOfMonth : return( NSMakeRange( 1, 6));
   case NSCalendarUnitWeekOfYear  : return( NSMakeRange( 1, 53));
   }
   return( NSMakeRange( NSNotFound, 0));
}


MULLE_C_CONST_RETURN
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

         max  = mulleJulianNumberOfDaysInMonthOfYear( month, year);
         day += max;
         if( day >= 1)
            break;
      }
   }
   else
   {
      for(;;)
      {
         max = mulleJulianNumberOfDaysInMonthOfYear( month, year);
         if( day <= max)
            break;

         // adjust (go forwards in time)
         if( ++month > 12)
         {
            month = 1;
            ++year;
         }
         day -= max;
      }
   }

   *p_day   = day;
   *p_month = month;
   *p_year  = year;
}


//
// 15.10.1582 0:00:00 = -13197600000.0
// therefore
// 4.10.1582 23:59:59 = -13197600001.0
// when USE_JULIAN_BEFORE_CHANGE is defined
//
// TODO: possibly steal code from sqlite, which uses a different algorithm
//       which might be better (faster)
//
- (NSTimeInterval) mulleTimeIntervalWithYear:(NSInteger) year
                                       month:(NSInteger) month
                                         day:(NSInteger) day
                                        hour:(NSInteger) hour
                                      minute:(NSInteger) minute
                                      second:(NSInteger) second
                                  nanosecond:(NSInteger) nanosecond
{
   NSInteger        daysOfCommonEra;
   NSTimeInterval   interval;
   NSInteger        max;

   [self _mulleCorrectDay:&day
                    month:&month
                     year:&year];

   daysOfCommonEra  = [self mulleNumberOfDaysInCommonEraOfDay:day
                                                        month:month
                                                         year:year];
   daysOfCommonEra -= _daysOfCommonEraOfReferenceDate;

   interval = (daysOfCommonEra * 86400.0) + (hour * 3600) + (minute * 60) + second;

   if( nanosecond)
      interval += nanosecond / 1000000000.0;

   return( interval);
}



- (NSRange) rangeOfUnit:(NSCalendarUnit) unit
                 inUnit:(NSCalendarUnit) inUnit
                forDate:(NSDate *) date
{
   NSRange                            range;
   NSInteger                          year;
   NSInteger                          month;
   NSInteger                          day;
   NSInteger                          weekday;
   struct MulleExtendedTimeInterval   ext;

   range = NSMakeRange( NSNotFound, NSNotFound);
   switch( unit)
   {
   case NSCalendarUnitEra :
      break;  // no dice

   // NSCalendarUnitYear in NSCalendarUnitEra @ 1.1.1970 12:00:00 : [1,144683]
   case NSCalendarUnitYear :
      switch( inUnit)
      {
      case NSCalendarUnitEra  :
         // TODO: check era and return min or max (for Gregorian)
         range = NSMakeRange( 1, 144683);
      }
      break;

   // NSCalendarUnitMonth in NSCalendarUnitEra @ 1.1.1970 12:00:00  : [1,12]
   // NSCalendarUnitMonth in NSCalendarUnitYear @ 1.1.1970 12:00:00 : [1,12]
   case NSCalendarUnitMonth :
      switch( inUnit)
      {
      case NSCalendarUnitEra  :
      case NSCalendarUnitYear :
         range = NSMakeRange( 1, 12);
      }
      break;

   // NSCalendarUnitDay in NSCalendarUnitEra @ 1.1.1970 12:00:00   : [1,31]
   // NSCalendarUnitDay in NSCalendarUnitYear @ 1.1.1970 12:00:00  : [1,365]
   // NSCalendarUnitDay in NSCalendarUnitMonth @ 1.1.1970 12:00:00 : [1,31]
   // NSCalendarUnitDay in NSCalendarUnitWeekOfYear @ 1.1.1970 12:00:00  : [1,3]
   case NSCalendarUnitDay :
   {
      switch( inUnit)
      {
      case NSCalendarUnitEra :
      case NSCalendarUnitMonth :
         MulleExtendedTimeIntervalInit( &ext, [date timeIntervalSinceReferenceDate]);
         year  = [self mulleYearFromExtendedTimeInterval:&ext];
         month = [self mulleMonthFromExtendedTimeInterval:&ext];
         range = NSMakeRange( 1, [self mulleNumberOfDaysInMonth:month
                                                         ofYear:year]);
         break;

      case NSCalendarUnitYear :
         MulleExtendedTimeIntervalInit( &ext, [date timeIntervalSinceReferenceDate]);
         year  = [self mulleYearFromExtendedTimeInterval:&ext];
         range = NSMakeRange( 1, [self mulleNumberOfDaysInYear:year]);
         break;

      case NSCalendarUnitWeekOfMonth :
      case NSCalendarUnitWeekOfYear :
         // What does 1,3 mean ?
         // It means that that the 1.1.1970 is a Thursday. There are three
         // days left (SO MO DI MI [DO] FR SA) if the week ends on a Saturday.
         //
         MulleExtendedTimeIntervalInit( &ext, [date timeIntervalSinceReferenceDate]);
         weekday = [self mulleWeekdayFromExtendedTimeInterval:&ext] - 1;
         // lastweekday = first + 6 (mod)
         weekday = pure_mod_0_n( (_firstWeekday + 6) - weekday, 7);
         range   = NSMakeRange( weekday + 1, 7);
         break;
      }
      break;
   }

   // NSCalendarUnitHour in NSCalendarUnitEra @ 1.1.1970 12:00:00 : [0,24]
   // NSCalendarUnitHour in NSCalendarUnitYear @ 1.1.1970 12:00:00 : [0,24]
   // NSCalendarUnitHour in NSCalendarUnitMonth @ 1.1.1970 12:00:00 : [0,24]
   // NSCalendarUnitHour in NSCalendarUnitDay @ 1.1.1970 12:00:00 : [0,24]
   // NSCalendarUnitHour in NSCalendarUnitWeekOfYear @ 1.1.1970 12:00:00 : [0,24]
   // NSCalendarUnitHour in NSCalendarUnitWeekday @ 1.1.1970 12:00:00 : [0,24]
   case NSCalendarUnitHour :
      switch( inUnit)
      {
      case NSCalendarUnitEra         :
      case NSCalendarUnitYear        :
      case NSCalendarUnitMonth       :
      case NSCalendarUnitWeekOfYear  :
      case NSCalendarUnitWeekOfMonth :
      case NSCalendarUnitDay         :
      case NSCalendarUnitWeekday     :
         range = NSMakeRange( 0, 24);
      }
      break;


   // NSCalendarUnitMinute in NSCalendarUnitEra @ 1.1.1970 12:00:00 : [0,60]
   // NSCalendarUnitMinute in NSCalendarUnitYear @ 1.1.1970 12:00:00 : [0,60]
   // NSCalendarUnitMinute in NSCalendarUnitMonth @ 1.1.1970 12:00:00 : [0,60]
   // NSCalendarUnitMinute in NSCalendarUnitDay @ 1.1.1970 12:00:00 : [0,60]
   // NSCalendarUnitMinute in NSCalendarUnitHour @ 1.1.1970 12:00:00 : [0,60]
   // NSCalendarUnitMinute in NSCalendarUnitWeekOfYear @ 1.1.1970 12:00:00 : [0,60]
   // NSCalendarUnitMinute in NSCalendarUnitWeekday @ 1.1.1970 12:00:00 : [0,60]
   case NSCalendarUnitMinute :
      switch( inUnit)
      {
      case NSCalendarUnitEra         :
      case NSCalendarUnitYear        :
      case NSCalendarUnitMonth       :
      case NSCalendarUnitWeekOfYear  :
      case NSCalendarUnitWeekOfMonth :
      case NSCalendarUnitDay         :
      case NSCalendarUnitWeekday     :
      case NSCalendarUnitHour        :
         range = NSMakeRange( 0, 60);
      }
      break;

   // NSSecondCalendarUnit in NSCalendarUnitEra @ 1.1.1970 12:00:00 : [0,60]
   // NSSecondCalendarUnit in NSCalendarUnitYear @ 1.1.1970 12:00:00 : [0,60]
   // NSSecondCalendarUnit in NSCalendarUnitMonth @ 1.1.1970 12:00:00 : [0,60]
   // NSSecondCalendarUnit in NSCalendarUnitDay @ 1.1.1970 12:00:00 : [0,60]
   // NSSecondCalendarUnit in NSCalendarUnitHour @ 1.1.1970 12:00:00 : [0,60]
   // NSSecondCalendarUnit in NSCalendarUnitMinute @ 1.1.1970 12:00:00 : [0,60]
   // NSSecondCalendarUnit in NSCalendarUnitWeekOfYear @ 1.1.1970 12:00:00 : [0,60]
   // NSSecondCalendarUnit in NSCalendarUnitWeekday @ 1.1.1970 12:00:00 : [0,60]
   case NSCalendarUnitSecond :
      switch( inUnit)
      {
      case NSCalendarUnitEra         :
      case NSCalendarUnitYear        :
      case NSCalendarUnitMonth       :
      case NSCalendarUnitDay         :
      case NSCalendarUnitHour        :
      case NSCalendarUnitMinute      :
      case NSCalendarUnitWeekOfYear  :
      case NSCalendarUnitWeekOfMonth :
      case NSCalendarUnitWeekday     :
         range = NSMakeRange( 0, 60);
      }
      break;

   // NSCalendarUnitWeekOfYear in NSCalendarUnitEra @ 31.3.2019 2:00:00 : [1,53]
   // NSCalendarUnitWeekOfYear in NSCalendarUnitYear @ 31.3.2019 2:00:00 : [1,53]
   // NSCalendarUnitWeekOfYear in NSCalendarUnitMonth @ 31.3.2019 2:00:00 : [9,6]
   case NSCalendarUnitWeekOfYear :
      switch( inUnit)
      {
      case NSCalendarUnitEra    :
      case NSCalendarUnitYear   :
         MulleExtendedTimeIntervalInit( &ext, [date timeIntervalSinceReferenceDate]);
         range = NSMakeRange( 1, [self mulleNumberOfWeeksInYearFromExtendedTimeInterval:&ext]);
         break;

         // apple output makes no sense to me, so we redefine this more
         // sensibly
      case NSCalendarUnitMonth  :
         MulleExtendedTimeIntervalInit( &ext, [date timeIntervalSinceReferenceDate]);
         range = NSMakeRange( [self mulleWeekOfMonthFromExtendedTimeInterval:&ext],
                              [self mulleNumberOfWeeksInMonthFromExtendedTimeInterval:&ext]);
      }
      break;

   case NSCalendarUnitWeekOfMonth :
      switch( inUnit)
      {
      case NSCalendarUnitEra    :
      case NSCalendarUnitYear   :
         MulleExtendedTimeIntervalInit( &ext, [date timeIntervalSinceReferenceDate]);
         range = NSMakeRange( 1, [self mulleNumberOfWeeksInMonthFromExtendedTimeInterval:&ext]);
         break;

         // apple output makes no sense to me, so we redefine this more
         // sensibly
      case NSCalendarUnitMonth  :
         MulleExtendedTimeIntervalInit( &ext, [date timeIntervalSinceReferenceDate]);
         range = NSMakeRange( [self mulleWeekOfMonthFromExtendedTimeInterval:&ext],
                              [self mulleNumberOfWeeksInMonthFromExtendedTimeInterval:&ext]);
      }
      break;

   // NSCalendarUnitWeekday in NSCalendarUnitEra @ 1.1.1970 12:00:00 : [1,7]
   // NSCalendarUnitWeekday in NSCalendarUnitYear @ 1.1.1970 12:00:00 : [1,7]
   // NSCalendarUnitWeekday in NSCalendarUnitMonth @ 1.1.1970 12:00:00 : [1,7]
   // NSCalendarUnitWeekday in NSCalendarUnitWeekOfYear @ 1.1.1970 12:00:00 : [1,7]
   case NSCalendarUnitWeekday :
      switch( inUnit)
      {
      case NSCalendarUnitEra         :
      case NSCalendarUnitYear        :
      case NSCalendarUnitMonth       :
      case NSCalendarUnitWeekOfYear  :
      case NSCalendarUnitWeekOfMonth :
         range = NSMakeRange( 1, 7);
      }
      break;

   // NSWeekdayOrdinalCalendarUnit in NSCalendarUnitEra @ 1.1.1970 12:00:00 : [1,5]
   // NSWeekdayOrdinalCalendarUnit in NSCalendarUnitYear @ 1.1.1970 12:00:00 : [1,59]
   // NSWeekdayOrdinalCalendarUnit in NSCalendarUnitMonth @ 1.1.1970 12:00:00 : [1,5]
   case NSWeekdayOrdinalCalendarUnit :
      switch( inUnit)
      {
      case NSCalendarUnitEra    :
      case NSCalendarUnitYear   :
      case NSCalendarUnitMonth  :
         MulleExtendedTimeIntervalInit( &ext, [date timeIntervalSinceReferenceDate]);
         year  = [self mulleYearFromExtendedTimeInterval:&ext];
         month = [self mulleMonthFromExtendedTimeInterval:&ext];
         range = NSMakeRange( 1, ([self mulleNumberOfDaysInMonth:month
                                                         ofYear:year] + 6) / 7);
         break;
      }
   }
   return( range);
}


static inline NSInteger  pure_mod_0_n( NSInteger value, NSInteger max)
{
   value %= max;
   if( value < 0)
      value += max;
   return( value);
}


// such a beautiful API
- (BOOL) rangeOfUnit:(NSCalendarUnit) unit
           startDate:(NSDate **) p_startDate
            interval:(NSTimeInterval *) p_interval
             forDate:(NSDate *) date
{
   struct MulleExtendedTimeInterval   ext;
   NSInteger                          days;
   NSInteger                          year;
   NSInteger                          month;
   NSInteger                          weekday;
   NSInteger                          firstWeekday;
   NSInteger                          day;
   NSInteger                          hour;
   NSInteger                          diff;
   NSInteger                          minute;
   NSInteger                          second;
   NSInteger                          nanosecond;
   NSInteger                          quarter_1;
   NSTimeInterval                     interval;
   BOOL                               flag;
   union
   {
      NSTimeInterval   interval;
      NSDate           *date;
   } dummy;

   if( ! p_startDate)
      p_startDate = &dummy.date;
   if( ! p_interval)
      p_interval = &dummy.interval;

   MulleExtendedTimeIntervalInit( &ext, [date timeIntervalSinceReferenceDate]);

   switch( unit)
   {
   default :
      return( NO);

   case NSCalendarUnitYear :
      year = [self mulleYearFromExtendedTimeInterval:&ext];
      days = [self mulleNumberOfDaysInYear:year];
      *p_interval = 86400.0 * days;
      break;

   case NSCalendarUnitQuarter :
      month     = [self mulleMonthFromExtendedTimeInterval:&ext];
      quarter_1 = (month - 1) / 3;
      switch( quarter_1)
      {
      case 0 :
         year = [self mulleYearFromExtendedTimeInterval:&ext];
         days = 31 + 31 + [self mulleNumberOfDaysInMonth:2
                                                  ofYear:year];
         break;

      case 1 :
         days = 30 + 31 + 30;  // APR-JUN
         break;

      case 2 :
         days = 31 + 31 + 30;  // JUL-SEP
         break;

      default :
         days = 31 + 30 + 31;  // OKT-DEZ
         break;
      }
      *p_interval = 86400.0 * days;
      break;

   case NSCalendarUnitMonth :
      days = [self mulleNumberOfDaysInMonth:[self mulleMonthFromExtendedTimeInterval:&ext]
                                     ofYear:[self mulleYearFromExtendedTimeInterval:&ext]];
      *p_interval = 86400.0 * days;
      break;

   // hard coded values
   case NSCalendarUnitEra            : *p_interval = 4398046511104.0; break;
   case NSCalendarUnitWeekOfYear     :
   case NSCalendarUnitWeekOfMonth    : *p_interval = 604800.0; break;
   case NSCalendarUnitDay            : *p_interval = 86400.0; break;
   case NSCalendarUnitHour           : *p_interval = 3600.0; break;
   case NSCalendarUnitMinute         : *p_interval = 60.0; break;
   case NSCalendarUnitSecond         : *p_interval = 1.0; break;
   case NSCalendarUnitNanosecond     : *p_interval = 1.0 / 60; break;
   case NSCalendarUnitWeekday        :
   case NSCalendarUnitWeekdayOrdinal : *p_interval = 86400.0; break;
      break;
   }

   if( p_startDate)
   {
      year        = (unit >= NSCalendarUnitYear)       ? [self mulleYearFromExtendedTimeInterval:&ext] : 1;
      month       = (unit >= NSCalendarUnitMonth)      ? [self mulleMonthFromExtendedTimeInterval:&ext] : 1;
      day         = (unit >= NSCalendarUnitDay)        ? [self mulleDayOfMonthFromExtendedTimeInterval:&ext] : 1;
      hour        = (unit >= NSCalendarUnitHour)       ? [self mulle24HourFromExtendedTimeInterval:&ext] : 0;
      minute      = (unit >= NSCalendarUnitMinute)     ? [self mulleMinuteFromExtendedTimeInterval:&ext] : 0;
      second      = (unit >= NSCalendarUnitSecond)     ? (NSInteger) ext.interval % 60 : 0;
      nanosecond  = (unit >= NSCalendarUnitNanosecond) ? (NSInteger) ((ext.interval - (NSInteger) ext.interval) * 1000000000) : 0;

      // special needs units
      switch( unit)
      {
      case NSCalendarUnitQuarter :
         // not read yet, because unit is larger
         month = [self mulleMonthFromExtendedTimeInterval:&ext];
         month = ((month - 1) / 3) * 3 + 1;
         break;

      case NSCalendarUnitWeekOfYear :
      case NSCalendarUnitWeekOfMonth :
         weekday      = [self mulleWeekdayFromExtendedTimeInterval:&ext];
         weekday     -= 1;                  // normalize to 0-6
         firstWeekday = _firstWeekday - 1;  // normalize to 0-6
         diff         = pure_mod_0_n( weekday - firstWeekday, 7);
         // not read yet, because unit is larger
         day          = [self mulleDayOfMonthFromExtendedTimeInterval:&ext] - diff;
         break;

      case NSCalendarUnitWeekday :
      case NSCalendarUnitWeekdayOrdinal :
         break;
      }

      interval    = [self mulleTimeIntervalWithYear:year
                                              month:month
                                                day:day
                                               hour:hour
                                             minute:minute
                                             second:second
                                         nanosecond:nanosecond];
      *p_startDate = [NSDate dateWithTimeIntervalSinceReferenceDate:interval];
   }
   return( YES);
}

@end



