#import "NSDateComponents.h"


@implementation NSDateComponents

- (instancetype) init
{
   NSInteger   *p;
   NSInteger   *sentinel;

   p        = &_era;
   sentinel = &_nanosecond + 1;
   while( p < sentinel)
      *p++ = NSDateComponentUndefined;

   return( self);
}


- (void) setWeek:(NSInteger) week
{
   _weekOfYear = week;
}


- (NSInteger) week
{
   return( _weekOfYear);
}


- (NSInteger) valueForComponent:(NSCalendarUnit) unit
{
   switch( unit)
   {
   case NSCalendarUnitEra            : return( _era);
   case NSCalendarUnitYear           : return( _year);
   case NSCalendarUnitQuarter        : return( _quarter);
   case NSCalendarUnitMonth          : return( _month);
   case NSCalendarUnitWeekOfYear     : return( _weekOfYear);
   case NSCalendarUnitWeekOfMonth    : return( _weekOfMonth);
   case NSCalendarUnitDay            : return( _day);
   case NSCalendarUnitWeekday        : return( _weekday);
   case NSCalendarUnitWeekdayOrdinal : return( _weekdayOrdinal);
   case NSCalendarUnitHour           : return( _hour);
   case NSCalendarUnitMinute         : return( _minute);
   case NSCalendarUnitSecond         : return( _second);
   case NSCalendarUnitNanosecond     : return( _nanosecond);
   }
#ifdef DEBUG
   abort();
#endif
   return( 0);
}


- (void) setValue:(NSInteger) value
     forComponent:(NSCalendarUnit) unit
{
   switch( unit)
   {
   case NSCalendarUnitEra            : _era            = value; break;
   case NSCalendarUnitYear           : _year           = value; break;
   case NSCalendarUnitQuarter        : _quarter        = value; break;
   case NSCalendarUnitMonth          : _month          = value; break;
   case NSCalendarUnitWeekOfYear     : _weekOfYear     = value; break;
   case NSCalendarUnitWeekOfMonth    : _weekOfMonth    = value; break;
   case NSCalendarUnitDay            : _day            = value; break;
   case NSCalendarUnitWeekday        : _weekday        = value; break;
   case NSCalendarUnitWeekdayOrdinal : _weekdayOrdinal = value; break;
   case NSCalendarUnitHour           : _hour           = value; break;
   case NSCalendarUnitMinute         : _minute         = value; break;
   case NSCalendarUnitSecond         : _second         = value; break;
   case NSCalendarUnitNanosecond     : _nanosecond     = value; break;
   }
#ifdef DEBUG
   abort();
#endif
}

@end
