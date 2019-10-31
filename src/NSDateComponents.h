#import "import.h"


#define NSDateComponentUndefined    NSIntegerMax


@interface NSDateComponents : NSObject
{
   // setting all this stuff via properties is kinda stupid
@public
    NSInteger   _era;
    NSInteger   _year;
    NSInteger   _quarter;
    NSInteger   _month;
    NSInteger   _week;
    NSInteger   _weekday;
    NSInteger   _weekdayOrdinal;
    NSInteger   _day;
    NSInteger   _hour;
    NSInteger   _minute;
    NSInteger   _second;
}

@property( assign) NSInteger   era;
@property( assign) NSInteger   year;
@property( assign) NSInteger   quarter;
@property( assign) NSInteger   month;
@property( assign) NSInteger   week;
@property( assign) NSInteger   weekday;
@property( assign) NSInteger   weekdayOrdinal;
@property( assign) NSInteger   day;
@property( assign) NSInteger   hour;
@property( assign) NSInteger   minute;
@property( assign) NSInteger   second;

@end

