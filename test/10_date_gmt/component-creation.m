#ifdef __MULLE_OBJC__
# import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>
#else
# import <Foundation/Foundation.h>
#endif


//
// the values in stdout were produced by macOS
//
NSTimeInterval   intervals[] =
{
   -32535172800.0,
   -13197686400.0,
   -13197600000.0,
   -13197000000.0,
   -10000000000.0,
   -7299138600.0,
   -4818892320.0,
   -978264000.0,
   -31579200.0,
   -1.0,
   0.0,
   604713600.0,
   604713599.0,
   604627200.0, // = 29.2.2020 0:00:00 { e:1 q:1 wd:7 wO:5 wY:9 wM:5 ns:0 }
   604627199.0,
   575694000.0,
   575693999.0,
   575690400.0,
   575690399.0
};


int   main( void)
{
   NSCalendar        *calendar;
   NSDateComponents  *components;
   NSDate            *date;
   NSTimeInterval    *p;
   NSTimeInterval    *sentinel;

   calendar   = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
   [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
   [calendar setFirstWeekday:2];

   p        = &intervals[ 0];
   sentinel = &p[ sizeof( intervals) / sizeof( intervals[ 0])];
   for( ;p < sentinel; ++p)
   {
      date       = [NSDate dateWithTimeIntervalSinceReferenceDate:*p];
      components = [calendar components:~0
                               fromDate:date];

      printf( "%.1f = %ld.%ld.%ld %ld:%02ld:%02ld.%09ld\n",
            [date timeIntervalSinceReferenceDate],
            (long) [components day], (long) [components month], (long) [components year],
            (long) [components hour], (long) [components minute], (long) [components second],
            (long) [components nanosecond]);
   }
   return( 0);
}