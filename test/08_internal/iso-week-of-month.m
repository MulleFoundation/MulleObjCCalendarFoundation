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
   NSInteger                          month;
   NSInteger                          year;
   struct MulleExtendedTimeInterval   extended;

   calendar = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
   [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
   [calendar setFirstWeekday:2];
   [calendar setMinimumDaysInFirstWeek:4];

   for( year = 2009; year <= 2020; year++)
     for( day = 30; day <= 24+7+7+7; day++)
      {
         components = [[NSDateComponents new] autorelease];
         [components setYear:year];
         [components setMonth:12];
         [components setDay:day];

         date       = [calendar dateFromComponents:components];
         components = [calendar components:~0
                                  fromDate:date];
         MulleExtendedTimeIntervalInit( &extended, [date timeIntervalSinceReferenceDate]);

         printf( "%ld.%ld.%ld ",
               (long) [components day], (long) [components month], (long) [components year]);

         printf( " week: %ld\n",
                  [calendar mulleISOWeekOfYearFromExtendedTimeInterval:&extended]);
      }
   return( 0);
}