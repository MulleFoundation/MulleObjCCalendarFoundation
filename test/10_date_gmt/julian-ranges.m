#ifdef __MULLE_OBJC__
# import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>
#else
# import <Foundation/Foundation.h>
#endif


//
// Tests for the Julian calendar backend:
//   - mulleIsLeapYear: (any year divisible by 4 — no 100/400 exceptions)
//   - mulleNumberOfDaysInMonth:ofYear:
//   - mulleNumberOfDaysInYear:
//   - minimumRangeOfUnit: / maximumRangeOfUnit:
//
// Key Julian difference from Gregorian: century years (100, 200, ...) ARE
// leap years in Julian.  1900 and 2100 are Julian leap years.
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

   calendar   = [NSCalendar calendarWithIdentifier:NSJulianCalendar];
   u_sentinel = &units[ sizeof( units) / sizeof( units[ 0])];

   // --- leap year tests ---
   // Regular non-leap
   mulle_printf( "isLeap 2001: %d\n", (int) [calendar mulleIsLeapYear:2001]);
   mulle_printf( "isLeap 2003: %d\n", (int) [calendar mulleIsLeapYear:2003]);
   // Divisible by 4: leap (regardless of 100 rule)
   mulle_printf( "isLeap 2004: %d\n", (int) [calendar mulleIsLeapYear:2004]);
   // Century years: Julian DOES treat these as leap (divisible by 4)
   mulle_printf( "isLeap  100: %d\n", (int) [calendar mulleIsLeapYear:100]);
   mulle_printf( "isLeap 1900: %d\n", (int) [calendar mulleIsLeapYear:1900]);
   mulle_printf( "isLeap 2000: %d\n", (int) [calendar mulleIsLeapYear:2000]);
   mulle_printf( "isLeap 2100: %d\n", (int) [calendar mulleIsLeapYear:2100]);
   // Year not divisible by 4
   mulle_printf( "isLeap  101: %d\n", (int) [calendar mulleIsLeapYear:101]);

   mulle_printf( "---\n");

   // --- days in month ---
   // February: Julian century years have 29 days
   mulle_printf( "days Feb  100: %ld\n", (long) [calendar mulleNumberOfDaysInMonth:2 ofYear:100]);
   mulle_printf( "days Feb 1900: %ld\n", (long) [calendar mulleNumberOfDaysInMonth:2 ofYear:1900]);
   mulle_printf( "days Feb 2100: %ld\n", (long) [calendar mulleNumberOfDaysInMonth:2 ofYear:2100]);
   mulle_printf( "days Feb 2001: %ld\n", (long) [calendar mulleNumberOfDaysInMonth:2 ofYear:2001]);
   mulle_printf( "days Feb 2004: %ld\n", (long) [calendar mulleNumberOfDaysInMonth:2 ofYear:2004]);
   // Non-February months same as Gregorian
   mulle_printf( "days Jan 2001: %ld\n", (long) [calendar mulleNumberOfDaysInMonth:1 ofYear:2001]);
   mulle_printf( "days Apr 2001: %ld\n", (long) [calendar mulleNumberOfDaysInMonth:4 ofYear:2001]);
   mulle_printf( "days Dec 2001: %ld\n", (long) [calendar mulleNumberOfDaysInMonth:12 ofYear:2001]);

   mulle_printf( "---\n");

   // --- days in year ---
   mulle_printf( "days in  100: %ld\n", (long) [calendar mulleNumberOfDaysInYear:100]);
   mulle_printf( "days in 1900: %ld\n", (long) [calendar mulleNumberOfDaysInYear:1900]);
   mulle_printf( "days in 2000: %ld\n", (long) [calendar mulleNumberOfDaysInYear:2000]);
   mulle_printf( "days in 2001: %ld\n", (long) [calendar mulleNumberOfDaysInYear:2001]);
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
