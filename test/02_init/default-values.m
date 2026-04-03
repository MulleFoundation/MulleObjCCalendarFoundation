#ifdef __MULLE_OBJC__
# import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>
#else
# import <Foundation/Foundation.h>
#endif


int   main( void)
{
   NSCalendar   *calendar;

   calendar = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];

   mulle_printf( "firstWeekday           : %ld\n", (long) [calendar firstWeekday]);
   mulle_printf( "minimumDaysInFirstWeek : %ld\n", (long) [calendar minimumDaysInFirstWeek]);
#if 0
   mulle_printf( "timeZone               : \"%s\"\n",  [calendar timeZone] ? [[[calendar timeZone] abbreviation] UTF8String] : "nil");
   mulle_printf( "locale                 : \"%s\"\n",  [calendar locale] ? [[[calendar locale] localeIdentifier] UTF8String] : "nil");
#endif
   return( 0);
}