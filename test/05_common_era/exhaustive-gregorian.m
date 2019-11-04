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
   NSInteger    daysOfCommonEra;
   NSInteger    month;
   NSInteger     year;

   calendar   = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
   [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];

   for( year = 1; year <= 2001; year++)
      for( month = 1; month <= 12; month += 12)
      {
         daysOfCommonEra = [calendar mulleNumberOfDaysInCommonEraOfDay:1
                                                                 month:month
                                                                  year:year];
         printf( "1.%ld.%ld = %ld\n", (long) month, (long) year, daysOfCommonEra);

      }
   return( 0);
}