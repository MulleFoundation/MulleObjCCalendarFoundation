#import "_MulleJulianCalendar.h"



//
// there is only era==1 so far
// NSTimeIntervals < 15.10.1582 are probably more correct than Apple's but
// because of leap year, sill questionable
//
@interface _MulleGregorianCalendar : _MulleJulianCalendar
@end
