#ifdef __MULLE_OBJC__
# import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>
#else
# import <Foundation/Foundation.h>
#endif


int   main( void)
{
   NSCalendar                         *calendar;
   NSDateComponents                   *components;
   NSDate                             *date;
   NSInteger                          day;
   NSInteger                          year;
   struct MulleExtendedTimeInterval   extended;

   calendar = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
   [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
   [calendar setFirstWeekday:2];
   [calendar setMinimumDaysInFirstWeek:4];

   for( year = 1600; year <= 2000; year++)
   {
      components = [[NSDateComponents new] autorelease];
      [components setYear:year];

      date       = [calendar dateFromComponents:components];
      components = [calendar components:~0
                               fromDate:date];
      MulleExtendedTimeIntervalInit( &extended, [date timeIntervalSinceReferenceDate]);

      printf( "%ld.%ld.%ld ",
            (long) [components day], (long) [components month], (long) [components year]);

      printf( " weeks: %ld\n",
               [calendar mulleISONumberOfWeeksInYearFromExtendedTimeInterval:&extended]);
   }
   return( 0);
}