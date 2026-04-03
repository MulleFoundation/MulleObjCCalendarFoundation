#ifdef __MULLE_OBJC__
# import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>
#else
# import <Foundation/Foundation.h>
#endif


int   main( void)
{
   NSDateComponents  *c;

   // All values undefined after init — each field prints as "*"
   c = [[NSDateComponents new] autorelease];
   mulle_printf( "all-undefined: %s\n", [[c description] UTF8String]);

   // Full date/time with nanosecond zero
   c = [[NSDateComponents new] autorelease];
   [c setYear:2001];
   [c setMonth:1];
   [c setDay:1];
   [c setHour:0];
   [c setMinute:0];
   [c setSecond:0];
   [c setNanosecond:0];
   mulle_printf( "2001-01-01 00:00:00.000000000: %s\n", [[c description] UTF8String]);

   // Gregorian leap day with non-trivial nanosecond
   c = [[NSDateComponents new] autorelease];
   [c setYear:2020];
   [c setMonth:2];
   [c setDay:29];
   [c setHour:12];
   [c setMinute:30];
   [c setSecond:45];
   [c setNanosecond:123456789];
   mulle_printf( "2020-02-29 12:30:45.123456789: %s\n", [[c description] UTF8String]);

   // Only year and month set — day/time fields remain undefined
   c = [[NSDateComponents new] autorelease];
   [c setYear:1970];
   [c setMonth:6];
   mulle_printf( "partial year+month: %s\n", [[c description] UTF8String]);

   // End-of-year maximum values
   c = [[NSDateComponents new] autorelease];
   [c setYear:2000];
   [c setMonth:12];
   [c setDay:31];
   [c setHour:23];
   [c setMinute:59];
   [c setSecond:59];
   [c setNanosecond:999999999];
   mulle_printf( "2000-12-31 23:59:59.999999999: %s\n", [[c description] UTF8String]);

   // mulleDebugContentsDescription should equal description
   c = [[NSDateComponents new] autorelease];
   [c setYear:1848];
   [c setMonth:4];
   [c setDay:18];
   [c setHour:18];
   [c setMinute:48];
   [c setSecond:0];
   [c setNanosecond:0];
   mulle_printf( "debug==description: %d\n",
         [[c description] isEqualToString:[c mulleDebugContentsDescription]]);

   return( 0);
}
