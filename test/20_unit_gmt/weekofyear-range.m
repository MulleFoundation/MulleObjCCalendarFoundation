#ifdef __MULLE_OBJC__
# import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>
#else
# import <Foundation/Foundation.h>
#endif

//
// The range output is that was is suitable for input into datecomponents
// or so I believe
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


char  *unit_name( NSInteger   unit)
{
   switch( unit)
   {
   case NSEraCalendarUnit            : return( "Era");
   case NSYearCalendarUnit           : return( "Year");
   case NSMonthCalendarUnit          : return( "Month");
   case NSDayCalendarUnit            : return( "Day");
   case NSHourCalendarUnit           : return( "Hour");
   case NSMinuteCalendarUnit         : return( "Minute");
   case NSSecondCalendarUnit         : return( "Second");
   case NSCalendarUnitWeekOfMonth    : return( "WeekOfMonth");
   case NSCalendarUnitWeekOfYear     : return( "WeekOfYear");
   case NSWeekdayCalendarUnit        : return( "Weekday");
   case NSWeekdayOrdinalCalendarUnit : return( "WeekdayOrdinal");
   }
   return( "???");
}



static NSInteger   units[] =
{
    NSEraCalendarUnit,

    NSYearCalendarUnit,
    NSMonthCalendarUnit,
    NSDayCalendarUnit,
    NSHourCalendarUnit,
    NSMinuteCalendarUnit,
    NSSecondCalendarUnit,

    NSWeekdayCalendarUnit,
    NSWeekdayOrdinalCalendarUnit,

    NSCalendarUnitWeekOfMonth,
    NSCalendarUnitWeekOfYear
};


static void   print_range( NSRange range)
{
   printf( "[");
   if( range.location == NSNotFound)
      printf( "NSNotFound");
   else
      printf( "%lu", range.location);
   printf( ",");
   if( range.length == NSNotFound)
      printf( "NSNotFound");
   else
      printf( "%lu", range.length);
   printf( "]");
}


int   main( void)
{
   NSCalendar        *calendar;
   NSDateComponents  *components;
   NSDate            *date;
   struct date       *p;
   struct date       *p_sentinel;
   NSRange           range;
   NSInteger         *q;
   NSInteger         *q_sentinel;

   calendar = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
   [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];

   p_sentinel = &dates[ sizeof( dates) / sizeof( dates[ 0])];
   q_sentinel = &units[ sizeof( units) / sizeof( units[ 0])];

   calendar = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
   [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];

   p_sentinel = &dates[ sizeof( dates) / sizeof( dates[ 0])];

   for( p = &dates[ 0]; p < p_sentinel; ++p)
   {
      for( q = &units[ 0]; q < q_sentinel; ++q)
      {
         components = [[NSDateComponents new] autorelease];

         [components setDay:p->day];
         [components setMonth:p->month];
         [components setYear:p->year];
         [components setHour:p->hour];
         [components setMinute:p->minute];
         [components setSecond:p->second];

         date = [calendar dateFromComponents:components];

         range = [calendar rangeOfUnit:NSCalendarUnitWeekOfYear
                                inUnit:*q
                               forDate:date];

         printf( "%s in %s @ %d.%d.%d %d:%02d:%02d : ",
                  unit_name( NSCalendarUnitWeekOfYear),
                  unit_name( *q),
                  p->day, p->month, p->year,
                  p->hour, p->minute, p->second);
         print_range( range);
         printf( "\n");

         if( q + 1 < q_sentinel)
            printf( "---\n");
      }
      if( p + 1 < p_sentinel)
         printf( "===\n");
   }


   return( 0);
}