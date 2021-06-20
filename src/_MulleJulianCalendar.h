#import "NSCalendar.h"


// this is the non-revised julian calendar
// https://rhodesmill.org/skyfield/time.html#the-julian-date-object-as-cache
// So twelve noon was the moment of Julian date zero
@interface _MulleJulianCalendar : NSCalendar

- (void) _mulleCorrectDay:(NSInteger *) p_day
                    month:(NSInteger *) p_month
                     year:(NSInteger *) p_year;

@end

