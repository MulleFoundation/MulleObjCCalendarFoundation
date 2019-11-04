#ifdef __MULLE_OBJC__
# import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>
#else
# import <Foundation/Foundation.h>
#endif


//
// the values in stdout were produced by macOS
//

int   main( void)
{
   NSCalendar   *calendar;
   NSInteger    year;
   NSInteger    total;
   NSInteger    days;

   calendar   = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
   [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];

   total = 0;
   for( year = 1; year <= 2001; year++)
   {
      days   = (long) [calendar mulleNumberOfDaysInYear:year];
      total += days;
      printf( "%ld: +%ld = %ld\n", (long) year, days, total);
   }

   return( 0);
}
