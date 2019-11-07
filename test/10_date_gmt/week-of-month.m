#ifdef __MULLE_OBJC__
# import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>
#else
# import <Foundation/Foundation.h>
#endif



int   main( void)
{
   NSCalendar         *calendar;
   NSDateComponents   *components;
   NSDate             *date;
   NSInteger          day;
   NSInteger          year;
   NSInteger          min;

   calendar   = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
   [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
   [calendar setFirstWeekday:2];

   // incompatible with apple but shucks
   for( min = 1; min <= 7; min +=3)
   {
      [calendar setMinimumDaysInFirstWeek:min];
      printf( "--------%ld days in first week---------\n", min);
      for( year = 2017; year <= 2020; year++)
         for( day = -1; day < 15; day++)
         {
            components = [[NSDateComponents new] autorelease];
            [components setYear:year];
            [components setMonth:1];
            [components setDay:day];

            date       = [calendar dateFromComponents:components];
            components = [calendar components:~0
                                     fromDate:date];

            printf( "%ld.%ld.%ld %ld:%02ld:%02ld",
                  (long) [components day], (long) [components month], (long) [components year],
                  (long) [components hour], (long) [components minute], (long) [components second]);

            printf( " weekOfMonth: %ld\n",
                    (long) [components weekOfMonth]);
         }
   }
   return( 0);
}