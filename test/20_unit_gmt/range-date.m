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


static NSInteger   units[] =
{
#if 0
    NSCalendarUnitEra,

    NSCalendarUnitYear,
    NSCalendarUnitQuarter,
    NSCalendarUnitMonth,
#endif
    NSCalendarUnitWeekOfYear,
    NSCalendarUnitWeekOfMonth
#if 0
    NSCalendarUnitDay,
    NSCalendarUnitWeekday,
    NSCalendarUnitWeekdayOrdinal,
    NSCalendarUnitHour,
    NSCalendarUnitMinute,
    NSCalendarUnitSecond
#endif
};


char  *unit_name( NSInteger   unit)
{
   switch( unit)
   {
   case NSCalendarUnitEra            : return( "Era");
   case NSCalendarUnitYear           : return( "Year");
   case NSCalendarUnitQuarter        : return( "Quarter");
   case NSCalendarUnitMonth          : return( "Month");
   case NSCalendarUnitWeekOfYear     : return( "Week");
   case NSCalendarUnitWeekOfMonth    : return( "WeekOfMonth");
   case NSCalendarUnitDay            : return( "Day");
   case NSCalendarUnitWeekday        : return( "Weekday");
   case NSCalendarUnitWeekdayOrdinal : return( "WeekdayOrdinal");
   case NSCalendarUnitHour           : return( "Hour");
   case NSCalendarUnitMinute         : return( "Minute");
   case NSCalendarUnitSecond         : return( "Second");
   }
   return( "???");
}


int   main( void)
{
   NSCalendar        *calendar;
   NSDateComponents  *components;
   NSDate            *date;
   NSDate            *startDate;
   struct date       *p;
   struct date       *p_sentinel;
   NSInteger         *q;
   NSInteger         *q_sentinel;
   NSRange           range;
   NSTimeInterval    interval;

   calendar = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
   [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
   [calendar setFirstWeekday:2];  // Monday

   p_sentinel = &dates[ sizeof( dates) / sizeof( dates[ 0])];
   q_sentinel = &units[ sizeof( units) / sizeof( units[ 0])];

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

         printf( "%s  @ %d.%d.%d %d:%02d:%02d : ",
                  unit_name( *q),
                  p->day, p->month, p->year,
                  p->hour, p->minute, p->second);

         if( [calendar rangeOfUnit:*q
                         startDate:&startDate
                          interval:&interval
                           forDate:date])
         {
            components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay| \
                                           NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                                     fromDate:startDate];
            printf( "%ld.%ld.%ld %ld:%02ld:%02ld - %.1f\n",
                  (long) [components day],  (long) [components month],  (long) [components year],
                  (long) [components hour], (long) [components minute], (long) [components second],
                  interval);
         }
         else
            printf( "NO\n");
      }
      if( p + 1 < p_sentinel)
         printf( "---\n");
   }

   return( 0);
}