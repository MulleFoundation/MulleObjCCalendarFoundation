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


struct date   additions[] =
{
   { 0, 0, 0,   0, 0, 0  },

   { 0, 0, 0,   0, 0, 1  },
   { 0, 0, 0,   0, 1, 0  },
   { 0, 0, 0,   1, 0, 0  },
   { 0, 0, 1,   0, 0, 0  },
   { 0, 1, 0,   0, 0, 0  },
   { 1, 0, 0,   0, 0, 0  },

   { 0, 0, 0,   0, 0, -1 },
   { 0, 0, 0,   0, -1, 0 },
   { 0, 0, 0,  -1, 0, 0  },
   { 0, 0, -1,  0, 0, 0  },
   { 0, -1, 0,  0, 0, 0  },
   { -1, 0, 0,  0, 0, 0  }
};



int   main( void)
{
   NSCalendar        *calendar;
   NSDateComponents  *components;
   NSDateComponents  *resultComponents;
   NSDate            *date;
   NSDate            *addedDate;
   struct date       *p;
   struct date       *p_sentinel;
   struct date       *q;
   struct date       *q_sentinel;

   calendar   = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
   [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];


   p_sentinel = &dates[ sizeof( dates) / sizeof( dates[ 0])];
   q_sentinel = &additions[ sizeof( additions) / sizeof( additions[ 0])];

   q = &additions[ 0];
   for( ;q < q_sentinel; ++q)
   {
      p = &dates[ 0];
      for( ;p < p_sentinel; ++p)
      {
         components = [[NSDateComponents new] autorelease];

         [components setDay:p->day];
         [components setMonth:p->month];
         [components setYear:p->year];
         [components setHour:p->hour];
         [components setMinute:p->minute];
         [components setSecond:p->second];

         date = [calendar dateFromComponents:components];

         components = [[NSDateComponents new] autorelease];

         if( q->day)
            [components setDay:q->day];
         if( q->month)
            [components setMonth:q->month];
         if( q->year)
            [components setYear:q->year];
         if( q->hour)
            [components setHour:q->hour];
         if( q->minute)
            [components setMinute:q->minute];
         if( q->second)
            [components setSecond:q->second];


         addedDate = [calendar dateByAddingComponents:components
                                               toDate:date
                                              options:0];

         components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay| \
                                           NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond
                                  fromDate:addedDate];
         printf( "%d.%d.%d %d:%02d:%02d (%.1f) + %d.%d.%d %d:%02d:%02d = %ld.%ld.%ld %ld:%02ld:%02ld (%.1f)\n",
               p->day, p->month, p->year,
               p->hour, p->minute, p->second,
               [date timeIntervalSinceReferenceDate],
               q->day, q->month, q->year,
               q->hour, q->minute, q->second,
               (long) [components day], (long) [components month], (long) [components year],
               (long) [components hour], (long) [components minute], (long) [components second],
               [addedDate timeIntervalSinceReferenceDate]);
      }
      if( q + 1 < q_sentinel)
         printf( "---\n");
   }
   return( 0);
}