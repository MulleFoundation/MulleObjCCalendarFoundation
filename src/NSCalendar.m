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

   // the default of Apple...
   _minimumDaysInFirstWeek = 1;

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

   if( flags & NSCalendarUnitEra)
      result->_era = [self mulleEraFromExtendedTimeInterval:&extended];
   if( flags & NSCalendarUnitYear)
      result->_year = [self mulleYearFromExtendedTimeInterval:&extended];
   if( flags & NSCalendarUnitQuarter)
      result->_quarter = [self mulleQuarterFromExtendedTimeInterval:&extended];
   if( flags & NSCalendarUnitMonth)
      result->_month = [self mulleMonthFromExtendedTimeInterval:&extended];
   if( flags & NSCalendarUnitWeekOfYear)
      result->_weekOfYear = [self mulleISOWeekOfYearFromExtendedTimeInterval:&extended];
   if( flags & NSCalendarUnitWeekOfMonth)
      result->_weekOfMonth = [self mulleWeekOfMonthFromExtendedTimeInterval:&extended];
   if( flags & NSCalendarUnitDay)
      result->_day = [self mulleDayOfMonthFromExtendedTimeInterval:&extended];

   if( flags & NSCalendarUnitHour)
      result->_hour = [self mulle24HourFromExtendedTimeInterval:&extended];
   if( flags & NSCalendarUnitMinute)
      result->_minute = [self mulleMinuteFromExtendedTimeInterval:&extended];
   if( flags & NSCalendarUnitSecond)
      result->_second = MulleSecondFromTimeInterval( interval);
   if( flags & NSCalendarUnitNanosecond)
      result->_nanosecond = MulleNanosecondFromTimeInterval( interval);

   if( flags & NSCalendarUnitWeekday)
      result->_weekday = [self mulleWeekdayFromExtendedTimeInterval:&extended];
   if( flags & NSCalendarUnitWeekdayOrdinal)
      result->_weekdayOrdinal = [self mulleWeekdayOrdinalFromExtendedTimeInterval:&extended];

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
   NSInteger        nanosecond;

   // the 1 initialization is also calendar dependent, but this is a base for
   // for subclasses.
   year   = components->_year   != NSDateComponentUndefined ? components->_year  : 1;
   month  = components->_month  != NSDateComponentUndefined ? components->_month : 1;
   day    = components->_day    != NSDateComponentUndefined ? components->_day   : 1;

   hour       = components->_hour   != NSDateComponentUndefined ? components->_hour   : 0;
   minute     = components->_minute != NSDateComponentUndefined ? components->_minute : 0;
   second     = components->_second != NSDateComponentUndefined ? components->_second : 0;
   nanosecond = components->_nanosecond != NSDateComponentUndefined ? components->_nanosecond : 0;

   interval = [self mulleTimeIntervalWithYear:year
                                        month:month
                                          day:day
                                         hour:hour
                                       minute:minute
                                       second:second
                                   nanosecond:nanosecond];

   date       = [NSDate dateWithTimeIntervalSinceReferenceDate:interval];
   interval  += [_timeZone secondsFromGMTForDate:date];

   return( [NSDate dateWithTimeIntervalSinceReferenceDate:interval]);
}



static NSInteger  mod_0_n( NSInteger *p_value, NSInteger max)
{
   NSInteger   diff;
   NSInteger   value;

   diff  = 0;
   value = *p_value;

   if( value < 0)
   {
      diff   = value / max - 1;
      value %= max;
      if( value)
         value += max;
   }
   else
      if( value >= max)
      {
         diff   = value / max;
         value %= max;
      }

   *p_value = value;
   return( diff);
}


static inline NSInteger  mod_0_60( NSInteger *value)
{
   NSInteger   diff;

   diff = mod_0_n( value, 60);
   assert( *value >= 0 && *value <= 59);
   return( diff);
}


static inline NSInteger  mod_0_24( NSInteger *value)
{
   NSInteger   diff;

   diff = mod_0_n( value, 24);
   assert( *value >= 0 && *value <= 23);
   return( diff);
}


static inline NSInteger  mod_0_1000000000( NSInteger *value)
{
   NSInteger   diff;

   diff = mod_0_n( value, 100000000000);
   assert( *value >= 0 && *value <= 999999999);
   return( diff);
}



static NSInteger  mod_1_13( NSInteger *value)
{
   NSInteger   diff;

   *value -= 1;
   diff    = mod_0_n( value, 12);
   *value += 1;

   assert( *value >=1 && *value <= 12);
   return( diff);
}


- (NSDate *) dateByAddingComponents:(NSDateComponents *) components
                             toDate:(NSDate *) date
                            options:(NSUInteger) options
{
   NSDateComponents   *dateComponents;
   NSInteger          max;

   if( options)
      abort();

   dateComponents = [self components:NSCalendarUnitEra|NSCalendarUnitYear|\
                                     NSCalendarUnitMonth|NSCalendarUnitDay|\
                                     NSCalendarUnitHour|NSCalendarUnitMinute|\
                                     NSCalendarUnitSecond|\
                                     NSCalendarUnitNanosecond
                            fromDate:date];

   dateComponents->_year   += components->_year   != NSDateComponentUndefined ? components->_year  : 0;
   dateComponents->_month  += components->_month  != NSDateComponentUndefined ? components->_month : 0;

   // days overflow like they want for now
   // we can't overflow them into months as it makes no sense

   //
   // but under/overflowing months is not a problem
   //
   dateComponents->_year   += mod_1_13( &dateComponents->_month);

   // the day can slightly overflow now though...
   max = [self mulleNumberOfDaysInMonth:dateComponents->_month
                                 ofYear:dateComponents->_year];
   if( dateComponents->_day > max)
      dateComponents->_day = max;

   dateComponents->_day    += components->_day    != NSDateComponentUndefined ? components->_day   : 0;

   dateComponents->_hour   += components->_hour   != NSDateComponentUndefined ? components->_hour   : 0;
   dateComponents->_minute += components->_minute != NSDateComponentUndefined ? components->_minute : 0;
   dateComponents->_second += components->_second != NSDateComponentUndefined ? components->_second : 0;
   dateComponents->_nanosecond += components->_nanosecond != NSDateComponentUndefined ? components->_nanosecond : 0;

   dateComponents->_second += mod_0_1000000000( &dateComponents->_nanosecond);
   dateComponents->_minute += mod_0_60( &dateComponents->_second);
   dateComponents->_hour   += mod_0_60( &dateComponents->_minute);
   dateComponents->_day    += mod_0_24( &dateComponents->_hour);

   return( [self dateFromComponents:dateComponents]);
}

@end
