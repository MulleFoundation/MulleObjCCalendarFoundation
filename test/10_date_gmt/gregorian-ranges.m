#ifdef __MULLE_OBJC__
# import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>
#else
# import <Foundation/Foundation.h>
#endif


//
// Tests for the Gregorian calendar backend:
//   - mulleIsLeapYear: (divisible by 4 but not 100, or divisible by 400)
//   - mulleNumberOfDaysInMonth:ofYear:
//   - mulleNumberOfDaysInYear:
//   - minimumRangeOfUnit: / maximumRangeOfUnit:
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
   case NSCalendarUnitWeekdayOrdinal : return( "WeekdayOrdinal");
   case NSCalendarUnitHour           : return( "Hour");
   case NSCalendarUnitMinute         : return( "Minute");
   case NSCalendarUnitSecond         : return( "Second");
   case NSCalendarUnitNanosecond     : return( "Nanosecond");
   }
   return( "???");
}


int   main( void)
{
   NSCalendar     *calendar;
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
   NSCalendarUnit  *u;
   NSCalendarUnit  *u_sentinel;

   calendar    = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
   u_sentinel  = &units[ sizeof( units) / sizeof( units[ 0])];

   // --- leap year tests ---
   // Regular non-leap
   mulle_printf( "isLeap 2001: %d\n", (int) [calendar mulleIsLeapYear:2001]);
   // Divisible by 4: leap
   mulle_printf( "isLeap 2004: %d\n", (int) [calendar mulleIsLeapYear:2004]);
   // Divisible by 100 but not 400: not leap (Gregorian rule)
   mulle_printf( "isLeap 1900: %d\n", (int) [calendar mulleIsLeapYear:1900]);
   mulle_printf( "isLeap 2100: %d\n", (int) [calendar mulleIsLeapYear:2100]);
   // Divisible by 400: leap
   mulle_printf( "isLeap 2000: %d\n", (int) [calendar mulleIsLeapYear:2000]);
   mulle_printf( "isLeap 1600: %d\n", (int) [calendar mulleIsLeapYear:1600]);

   mulle_printf( "---\n");

   // --- days in month ---
   // February in leap and non-leap years
   mulle_printf( "days Feb 2000: %ld\n", (long) [calendar mulleNumberOfDaysInMonth:2 ofYear:2000]);
   mulle_printf( "days Feb 2001: %ld\n", (long) [calendar mulleNumberOfDaysInMonth:2 ofYear:2001]);
   mulle_printf( "days Feb 1900: %ld\n", (long) [calendar mulleNumberOfDaysInMonth:2 ofYear:1900]);
   mulle_printf( "days Feb 2004: %ld\n", (long) [calendar mulleNumberOfDaysInMonth:2 ofYear:2004]);
   // 30-day months
   mulle_printf( "days Apr 2001: %ld\n", (long) [calendar mulleNumberOfDaysInMonth:4 ofYear:2001]);
   mulle_printf( "days Jun 2001: %ld\n", (long) [calendar mulleNumberOfDaysInMonth:6 ofYear:2001]);
   mulle_printf( "days Sep 2001: %ld\n", (long) [calendar mulleNumberOfDaysInMonth:9 ofYear:2001]);
   mulle_printf( "days Nov 2001: %ld\n", (long) [calendar mulleNumberOfDaysInMonth:11 ofYear:2001]);
   // 31-day months
   mulle_printf( "days Jan 2001: %ld\n", (long) [calendar mulleNumberOfDaysInMonth:1 ofYear:2001]);
   mulle_printf( "days Mar 2001: %ld\n", (long) [calendar mulleNumberOfDaysInMonth:3 ofYear:2001]);
   mulle_printf( "days Dec 2001: %ld\n", (long) [calendar mulleNumberOfDaysInMonth:12 ofYear:2001]);

   mulle_printf( "---\n");

   // --- days in year ---
   mulle_printf( "days in 2000: %ld\n", (long) [calendar mulleNumberOfDaysInYear:2000]);
   mulle_printf( "days in 2001: %ld\n", (long) [calendar mulleNumberOfDaysInYear:2001]);
   mulle_printf( "days in 2004: %ld\n", (long) [calendar mulleNumberOfDaysInYear:2004]);
   mulle_printf( "days in 1900: %ld\n", (long) [calendar mulleNumberOfDaysInYear:1900]);
   mulle_printf( "days in 2100: %ld\n", (long) [calendar mulleNumberOfDaysInYear:2100]);

   mulle_printf( "---\n");

   // --- minimumRangeOfUnit: / maximumRangeOfUnit: ---
   for( u = &units[ 0]; u < u_sentinel; u++)
   {
      mulle_printf( "min %s: ", unit_name( *u));
      print_range( [calendar minimumRangeOfUnit:*u]);
      mulle_printf( "\n");
   }

   mulle_printf( "---\n");

   for( u = &units[ 0]; u < u_sentinel; u++)
   {
      mulle_printf( "max %s: ", unit_name( *u));
      print_range( [calendar maximumRangeOfUnit:*u]);
      mulle_printf( "\n");
   }

   return( 0);
}
