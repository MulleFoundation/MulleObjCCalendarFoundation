#import "import.h"

#import "NSCalendar.h"


#define NSDateComponentUndefined    NSIntegerMax

//
// this is just a glorified struct wrapped into an object
//
@interface NSDateComponents : NSObject < NSMutableCopying, MulleObjCThreadUnsafe>
{
   // setting all this stuff via properties is kinda stupid
@public
    NSInteger   _era;
    NSInteger   _year;
    NSInteger   _quarter;
    NSInteger   _month;
    NSInteger   _weekOfYear;
    NSInteger   _weekOfMonth;
    NSInteger   _day;
    NSInteger   _weekday;
    NSInteger   _weekdayOrdinal;
    NSInteger   _hour;
    NSInteger   _minute;
    NSInteger   _second;
    NSInteger   _nanosecond;
}

@property( assign) NSInteger   era;
@property( assign) NSInteger   year;
@property( assign) NSInteger   quarter;
@property( assign) NSInteger   month;
@property( assign) NSInteger   weekOfYear;
@property( assign) NSInteger   weekOfMonth;

// Su=0, Mo=1, Sa=6
@property( assign) NSInteger   day;
@property( assign) NSInteger   weekday;
@property( assign) NSInteger   weekdayOrdinal;
@property( assign) NSInteger   hour;
@property( assign) NSInteger   minute;
@property( assign) NSInteger   second;
@property( assign) NSInteger   nanosecond;

- (void) setWeek:(NSInteger) week;
- (NSInteger) week;

- (NSInteger) valueForComponent:(NSCalendarUnit) unit;
- (void) setValue:(NSInteger) value
     forComponent:(NSCalendarUnit) unit;

@end


