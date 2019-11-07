#ifdef __MULLE_OBJC__
# import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>
#else
# import <Foundation/Foundation.h>
#endif


char   *day_name( NSInteger index)
{
   switch( index)
   {
   case 1 : return( "So");
   case 2 : return( "Mo");
   case 3 : return( "Di");
   case 4 : return( "Mi");
   case 5 : return( "Do");
   case 6 : return( "Fr");
   case 7 : return( "Sa");
   }
   return( "???");
}


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

   for( year = 2015; year <= 2020; year++)
      for( day = -15; day < 15; day +=5)
      {
         components = [[NSDateComponents new] autorelease];
         [components setYear:year];
         [components setMonth:1];
         [components setDay:day];

         date       = [calendar dateFromComponents:components];
         components = [calendar components:~0
                                  fromDate:date];
         MulleExtendedTimeIntervalInit( &extended, [date timeIntervalSinceReferenceDate]);

         printf( "%ld.%ld.%ld ",
               (long) [components day], (long) [components month], (long) [components year]);

         printf( " firstWeekday: %s\n",
                  day_name( [calendar mulleFirstWeekdayOfYearFromExtendedTimeInterval:&extended]));
      }
   return( 0);
}