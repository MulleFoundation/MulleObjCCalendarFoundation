#ifdef __MULLE_OBJC__
# import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>
#else
# import <Foundation/Foundation.h>
#endif


//
// Quarter extraction: quarter = (month-1)/3 + 1
//   Jan/Feb/Mar -> Q1,  Apr/May/Jun -> Q2
//   Jul/Aug/Sep -> Q3,  Oct/Nov/Dec -> Q4
//
// WeekdayOrdinal: position of the weekday within the month
//   days_since_month_start / 7 + 1
//   (day 1-7 -> ordinal 1, day 8-14 -> ordinal 2, etc.)
//
// Nanosecond: sub-second portion * 1e9
//   Intervals with .5 fractional seconds -> 500000000 ns
//
// All dates are GMT.  Reference date = 2001-01-01 00:00:00 UTC = 0.0
//
// Precomputed intervals (in seconds from reference):
//   2001-01-01  =        0.0   (Q1, day 1,  ordinal 1)
//   2001-04-01  =  7776000.0   (Q2, day 1,  ordinal 1)  Jan31+Feb28+Mar31=90d
//   2001-07-01  = 15638400.0   (Q3, day 1,  ordinal 1)  +Apr30+May31+Jun30=181d
//   2001-10-01  = 23587200.0   (Q4, day 1,  ordinal 1)  +Jul31+Aug31+Sep30=273d
//   2001-01-08  =   604800.0   (Q1, day 8,  ordinal 2)
//   2001-01-15  =  1209600.0   (Q1, day 15, ordinal 3)
//   2001-01-29  =  2419200.0   (Q1, day 29, ordinal 5)
//   2001-04-14  =  8985600.0   (Q2, day 14, ordinal 2)  7776000 + 13*86400
//   2004-02-29  = 99532800.0   (Q1, leap day Gregorian)
//

struct entry
{
   NSTimeInterval   interval;
   char             *label;
};

static struct entry entries[] =
{
   {        0.0, "2001-01-01 (Q1 day 1  ordinal 1)" },
   {  7776000.0, "2001-04-01 (Q2 day 1  ordinal 1)" },
   { 15638400.0, "2001-07-01 (Q3 day 1  ordinal 1)" },
   { 23587200.0, "2001-10-01 (Q4 day 1  ordinal 1)" },
   {   604800.0, "2001-01-08 (Q1 day 8  ordinal 2)" },
   {  1209600.0, "2001-01-15 (Q1 day 15 ordinal 3)" },
   {  2419200.0, "2001-01-29 (Q1 day 29 ordinal 5)" },
   {  8985600.0, "2001-04-14 (Q2 day 14 ordinal 2)" },
   { 99532800.0, "2004-02-29 (Q1 leap)"             },
};


int   main( void)
{
   NSCalendar        *calendar;
   NSDateComponents  *c;
   NSDate            *date;
   struct entry      *p;
   struct entry      *sentinel;

   calendar = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
   [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];

   p        = &entries[ 0];
   sentinel = &entries[ sizeof( entries) / sizeof( entries[ 0])];
   for( ; p < sentinel; p++)
   {
      date = [NSDate dateWithTimeIntervalSinceReferenceDate:p->interval];
      c    = [calendar components:NSCalendarUnitQuarter|
                                  NSCalendarUnitWeekdayOrdinal|
                                  NSCalendarUnitNanosecond|
                                  NSCalendarUnitMonth|
                                  NSCalendarUnitDay|
                                  NSCalendarUnitYear
                         fromDate:date];

      mulle_printf( "%s: year=%ld month=%ld day=%ld quarter=%ld ordinal=%ld ns=%ld\n",
            p->label,
            (long) [c year],
            (long) [c month],
            (long) [c day],
            (long) [c quarter],
            (long) [c weekdayOrdinal],
            (long) [c nanosecond]);
   }

   mulle_printf( "---\n");

   // Nanosecond precision tests using sub-second intervals
   {
      NSTimeInterval   ns_intervals[] = { 0.0, 0.5, 0.25, -0.5, -0.25 };
      NSTimeInterval   *q;
      NSTimeInterval   *q_sentinel;

      q          = &ns_intervals[ 0];
      q_sentinel = &ns_intervals[ sizeof( ns_intervals) / sizeof( ns_intervals[ 0])];
      for( ; q < q_sentinel; q++)
      {
         date = [NSDate dateWithTimeIntervalSinceReferenceDate:*q];
         c    = [calendar components:NSCalendarUnitNanosecond|NSCalendarUnitSecond
                            fromDate:date];
         mulle_printf( "interval=%.2f: second=%ld ns=%ld\n",
               *q,
               (long) [c second],
               (long) [c nanosecond]);
      }
   }

   return( 0);
}
