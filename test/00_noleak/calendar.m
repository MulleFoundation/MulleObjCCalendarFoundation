#import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>


int   main( void)
{
   NSCalendar   *calendar;

   calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
   [calendar release];
   return( 0);
}