#ifdef __MULLE_OBJC__
# import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>
#else
# import <Foundation/Foundation.h>
#endif


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
   NSCalendarUnit    units[] =
   {
      NSCalendarUnitEra,
      NSCalendarUnitYear,
      NSCalendarUnitQuarter,
      NSCalendarUnitMonth,
      NSCalendarUnitWeekOfYear,
      NSCalendarUnitWeekOfMonth,
      NSCalendarUnitDay,
      NSCalendarUnitWeekday,
      NSCalendarUnitWeekdayOrdinal,
      NSCalendarUnitHour,
      NSCalendarUnitMinute,
      NSCalendarUnitSecond,
      NSCalendarUnitNanosecond
   };
   NSInteger         values[] = { 1, 2001, 3, 7, 26, 4, 15, 2, 3, 10, 30, 45, 500000000 };
   NSDateComponents  *c;
   NSCalendarUnit    *u;
   NSCalendarUnit    *u_sentinel;
   NSInteger         *v;

   u_sentinel = &units[ sizeof( units) / sizeof( units[ 0])];

   // After -init every component must be undefined (NSDateComponentUndefined == NSIntegerMax)
   c = [[NSDateComponents new] autorelease];
   for( u = &units[ 0]; u < u_sentinel; u++)
   {
      mulle_printf( "init %s: %s\n",
            unit_name( *u),
            [c valueForComponent:*u] == NSDateComponentUndefined ? "undefined" : "defined");
   }

   mulle_printf( "---\n");

   // setValue:forComponent: then valueForComponent: must round-trip
   v = &values[ 0];
   for( u = &units[ 0]; u < u_sentinel; u++, v++)
   {
      [c setValue:*v forComponent:*u];
      mulle_printf( "set/get %s: %ld\n",
            unit_name( *u),
            (long) [c valueForComponent:*u]);
   }

   mulle_printf( "---\n");

   // valueForComponent: must agree with the named property accessors
   mulle_printf( "era             : %ld\n", (long) [c era]);
   mulle_printf( "year            : %ld\n", (long) [c year]);
   mulle_printf( "quarter         : %ld\n", (long) [c quarter]);
   mulle_printf( "month           : %ld\n", (long) [c month]);
   mulle_printf( "weekOfYear      : %ld\n", (long) [c weekOfYear]);
   mulle_printf( "weekOfMonth     : %ld\n", (long) [c weekOfMonth]);
   mulle_printf( "day             : %ld\n", (long) [c day]);
   mulle_printf( "weekday         : %ld\n", (long) [c weekday]);
   mulle_printf( "weekdayOrdinal  : %ld\n", (long) [c weekdayOrdinal]);
   mulle_printf( "hour            : %ld\n", (long) [c hour]);
   mulle_printf( "minute          : %ld\n", (long) [c minute]);
   mulle_printf( "second          : %ld\n", (long) [c second]);
   mulle_printf( "nanosecond      : %ld\n", (long) [c nanosecond]);

   mulle_printf( "---\n");

   // Overwrite with a fresh value and verify
   [c setValue:NSDateComponentUndefined forComponent:NSCalendarUnitYear];
   mulle_printf( "year reset: %s\n",
         [c valueForComponent:NSCalendarUnitYear] == NSDateComponentUndefined
            ? "undefined" : "defined");

   return( 0);
}
