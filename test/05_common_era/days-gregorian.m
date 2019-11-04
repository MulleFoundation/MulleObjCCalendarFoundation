#ifdef __MULLE_OBJC__
# import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>
#else
# import <Foundation/Foundation.h>
#endif


//
// the values saved in stdout were cross-checked with
// https://www.epochconverter.com/seconds-days-since-y0
// If that's wrong we are wrong too...
// Unfortunately: epochconverter.com is wrong
// Days since 0001-01-01AD:
// 577724 -> 4.10.1582
// 577725 -> should be 15.10.1582 but is 5.10.1582
//
int   main( void)
{
   NSCalendar   *calendar;
   NSInteger    daysOfCommonEra;

   calendar   = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
   [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];


   daysOfCommonEra = [calendar mulleNumberOfDaysInCommonEraOfDay:4
                                                           month:10
                                                            year:1582];
   printf( "4.10.1582 = %ld\n", daysOfCommonEra);


   daysOfCommonEra = [calendar mulleNumberOfDaysInCommonEraOfDay:5
                                                           month:10
                                                            year:1582];
   printf( "5.10.1582 = %ld\n", daysOfCommonEra);


   daysOfCommonEra = [calendar mulleNumberOfDaysInCommonEraOfDay:15
                                                           month:10
                                                            year:1582];
   printf( "15.10.1582 = %ld\n", daysOfCommonEra);


   daysOfCommonEra = [calendar mulleNumberOfDaysInCommonEraOfDay:1
                                                           month:1
                                                            year:1582];
   printf( "1.1.1582 = %ld\n", daysOfCommonEra);


   daysOfCommonEra = [calendar mulleNumberOfDaysInCommonEraOfDay:1
                                                           month:1
                                                            year:1];
   // this is 1.1.1 basically first day of A.D. so
   // expect daysOfCommonEra to be 0
   printf( "1.1.1 = %ld\n", daysOfCommonEra);

   return( 0);
}