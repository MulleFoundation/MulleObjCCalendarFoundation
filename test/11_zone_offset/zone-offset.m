#ifdef __MULLE_OBJC__
# import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>
#else
# import <Foundation/Foundation.h>
#endif


//
// Regression test: NSCalendar must apply a timezone offset forwards.
//
// The instant is 2026-09-29 16:00:00 UTC. In a +02:00 zone the wall clock is
// 18:00, so -components:fromDate: must answer 18, and composing 18:00 in that
// zone must round-trip back to the same UTC instant.
//
int   main( void)
{
   NSCalendar        *calendar;
   NSDateComponents  *components;
   NSDate            *date;
   NSDate            *back;
   NSTimeZone        *zone;

   // 2026-09-29 16:00:00 UTC
   date = [NSDate dateWithTimeIntervalSince1970:1790697600.0];

   calendar = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
   zone     = [NSTimeZone timeZoneForSecondsFromGMT:2 * 60 * 60];
   [calendar setTimeZone:zone];

   components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth |
                                      NSCalendarUnitDay | NSCalendarUnitHour |
                                      NSCalendarUnitMinute | NSCalendarUnitSecond)
                            fromDate:date];
   mulle_printf( "%04ld-%02ld-%02ld %02ld:%02ld:%02ld\n",
                 (long) [components year],
                 (long) [components month],
                 (long) [components day],
                 (long) [components hour],
                 (long) [components minute],
                 (long) [components second]);

   components = [[NSDateComponents new] autorelease];
   [components setYear:2026];
   [components setMonth:9];
   [components setDay:29];
   [components setHour:18];
   [components setMinute:0];
   [components setSecond:0];

   back = [calendar dateFromComponents:components];
   mulle_printf( "%.0f\n", [back timeIntervalSince1970]);

   return( 0);
}
