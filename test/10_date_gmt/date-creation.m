#ifdef __MULLE_OBJC__
# import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>
#else
# import <Foundation/Foundation.h>
#endif


//
// the values in stdout were produced by macOS
//

struct date
{
   int   day;
   int   month;
   int   year;

   int   hour;
   int   minute;
   int   second;
} dates[] =
{
   {  1,  1, 1970,  12,  0,  0 },
   { 18,  4, 1848,  18, 48,  0 },
   {  1,  1, 2000,  12,  0,  0 },
   { 31, 12, 2000,  23, 59, 59 },

   // schaltjahr
   { 28, 2, 2020,  23, 59, 59 },
   { 29, 2, 2020,   0,  0,  0 },
   { 29, 2, 2020,  23, 59, 59 },
   { 30, 2, 2020,   0,  0,  0 },
   {  1, 3, 2020,   0,  0,  0 },

   // kein schaltjahr
   { 28, 2, 2100,  23, 59, 59 },
   { 29, 2, 2100,  23, 59, 59 },

   // sommerzeit
   { 31, 3, 2019,  1, 59, 59 },
   { 31, 3, 2019,  2,  0,  0 },
   { 31, 3, 2019,  2, 59, 59 },
   { 31, 3, 2019,  3,  0,  0 }
};


int   main( void)
{
   NSCalendar        *calendar;
   NSDateComponents  *components;
   NSDate            *date;
   struct date       *p;
   struct date       *sentinel;

   calendar   = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
   [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];

   p        = &dates[ 0];
   sentinel = &p[ sizeof( dates) / sizeof( dates[ 0])];
   for( ;p < sentinel; ++p)
   {
      components = [[NSDateComponents new] autorelease];

      if( p->day)
         [components setDay:p->day];
      if( p->month)
         [components setMonth:p->month];
      if( p->year)
         [components setYear:p->year];
      if( p->hour >= 0)
         [components setHour:p->hour];
      if( p->minute >= 0)
         [components setMinute:p->minute];
      if( p->second >= 0)
         [components setSecond:p->second];

      date = [calendar dateFromComponents:components];
      printf( "%d.%d.%d %d:%02d:%02d = %.1f\n",
            p->day, p->month, p->year,
            p->hour, p->minute, p->second,
            [date timeIntervalSinceReferenceDate]);
   }

   return( 0);
}