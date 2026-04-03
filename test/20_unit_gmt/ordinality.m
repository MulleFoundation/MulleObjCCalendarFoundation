#ifdef __MULLE_OBJC__
# import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>
#else
# import <Foundation/Foundation.h>
#endif


//
// Tests for NSCalendar minimumRangeOfUnit: and maximumRangeOfUnit:
// called on both the Gregorian and Julian calendar instances.
//
// _MulleGregorianCalendar inherits from _MulleJulianCalendar, so both
// use the same implementation.  This test documents their output.
//


static void   print_range( NSRange r)
{
   if( r.location == NSNotFound)
      mulle_printf( "[NSNotFound,");
   else
      mulle_printf( "[%lu,", (unsigned long) r.location);

   if( r.length == NSNotFound)
      mulle_printf( "NSNotFound]");
   else
      mulle_printf( "%lu]", (unsigned long) r.length);
}


static char  *unit_name( NSCalendarUnit unit)
{
   switch( unit)
   {
   case NSCalendarUnitEra            : return( "Era");
   case NSCalendarUnitYear           : return( "Year");
   case NSCalendarUnitQuarter        : return( "Quarter");
   case NSCalendarUnitMonth          : return( "Month");
   case NSCalendarUnitWeekOfYear     : return( "WeekOfYear");
   case NSCalendarUnitWeekOfMonth    : return( "WeekOfMonth");
   case NSCalendarUnitDay            : return( "Day");
   case NSCalendarUnitWeekday        : return( "Weekday");
   case NSCalendarUnitHour           : return( "Hour");
   case NSCalendarUnitMinute         : return( "Minute");
   case NSCalendarUnitSecond         : return( "Second");
   case NSCalendarUnitNanosecond     : return( "Nanosecond");
   }
   return( "???");
}


static void   print_calendar_ranges( NSCalendar *calendar,
                                     NSCalendarUnit *units,
                                     NSCalendarUnit *sentinel)
{
   NSCalendarUnit  *u;

   for( u = units; u < sentinel; u++)
   {
      mulle_printf( "min %-16s: ", unit_name( *u));
      print_range( [calendar minimumRangeOfUnit:*u]);
      mulle_printf( "\n");
   }
   mulle_printf( "---\n");
   for( u = units; u < sentinel; u++)
   {
      mulle_printf( "max %-16s: ", unit_name( *u));
      print_range( [calendar maximumRangeOfUnit:*u]);
      mulle_printf( "\n");
   }
}


int   main( void)
{
   NSCalendar     *gregorian;
   NSCalendar     *julian;
   NSCalendarUnit  units[] =
   {
      NSCalendarUnitEra,
      NSCalendarUnitYear,
      NSCalendarUnitQuarter,
      NSCalendarUnitMonth,
      NSCalendarUnitWeekOfYear,
      NSCalendarUnitWeekOfMonth,
      NSCalendarUnitDay,
      NSCalendarUnitWeekday,
      NSCalendarUnitHour,
      NSCalendarUnitMinute,
      NSCalendarUnitSecond,
      NSCalendarUnitNanosecond
   };
   NSCalendarUnit  *u_sentinel;

   gregorian  = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
   julian     = [NSCalendar calendarWithIdentifier:NSJulianCalendar];
   u_sentinel = &units[ sizeof( units) / sizeof( units[ 0])];

   mulle_printf( "=== Gregorian minimumRangeOfUnit / maximumRangeOfUnit ===\n");
   print_calendar_ranges( gregorian, units, u_sentinel);

   mulle_printf( "=== Julian minimumRangeOfUnit / maximumRangeOfUnit ===\n");
   print_calendar_ranges( julian, units, u_sentinel);

   // Unknown unit returns NSNotFound range
   mulle_printf( "unknown unit (0): ");
   print_range( [gregorian minimumRangeOfUnit:0]);
   mulle_printf( "\n");
   mulle_printf( "unknown unit (0): ");
   print_range( [gregorian maximumRangeOfUnit:0]);
   mulle_printf( "\n");

   return( 0);
}
