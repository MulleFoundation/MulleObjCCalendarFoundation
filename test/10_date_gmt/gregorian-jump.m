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
   NSCalendar        *calendar;
   NSDateComponents  *components;
   NSDate            *date;
   struct date       *p;
   struct date       *sentinel;

   calendar   = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
   [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];

   components = [[NSDateComponents new] autorelease];

   [components setMonth:10];
   [components setYear:1582];

   [components setDay:15];

   date = [calendar dateFromComponents:components];
   printf( "15.10.1582 = %.1f\n",
            [date timeIntervalSinceReferenceDate]);

   [components setDay:10];

   date = [calendar dateFromComponents:components];
   printf( "10.10.1582 = %.1f\n",
            [date timeIntervalSinceReferenceDate]);

   [components setDay:5];

   date = [calendar dateFromComponents:components];
   printf( "5.10.1582 = %.1f\n",
            [date timeIntervalSinceReferenceDate]);

   [components setDay:4];

   date = [calendar dateFromComponents:components];
   printf( "4.10.1582 = %.1f\n",
            [date timeIntervalSinceReferenceDate]);

   [components setHour:23];
   [components setMinute:59];
   [components setSecond:59];

   date = [calendar dateFromComponents:components];
   printf( "4.10.1582 23:59:59 = %.1f\n",
            [date timeIntervalSinceReferenceDate]);

   return( 0);
}