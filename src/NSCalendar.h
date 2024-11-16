#import "import.h"


@class NSDateComponents;


// keep order as is
enum
{
    NSCalendarUnitEra            = 0x0001,
    NSCalendarUnitYear           = 0x0002,
    NSCalendarUnitQuarter        = 0x0004,
    NSCalendarUnitMonth          = 0x0008,
    NSCalendarUnitWeekOfYear     = 0x0010,
    NSCalendarUnitWeekOfMonth    = 0x0020,
    NSCalendarUnitDay            = 0x0040,
    NSCalendarUnitWeekday        = 0x0080,
    NSCalendarUnitWeekdayOrdinal = 0x0100,
    NSCalendarUnitHour           = 0x0200,
    NSCalendarUnitMinute         = 0x0400,
    NSCalendarUnitSecond         = 0x0800,
    NSCalendarUnitNanosecond     = 0x1000
};
typedef NSUInteger NSCalendarUnit;


enum
{
    NSEraCalendarUnit            = NSCalendarUnitEra,

    NSYearCalendarUnit           = NSCalendarUnitYear,
    NSMonthCalendarUnit          = NSCalendarUnitMonth,
    NSWeekCalendarUnit           = NSCalendarUnitWeekOfYear,
    NSDayCalendarUnit            = NSCalendarUnitDay,
    NSWeekdayCalendarUnit        = NSCalendarUnitWeekday,
    NSWeekdayOrdinalCalendarUnit = NSCalendarUnitWeekdayOrdinal,
    NSHourCalendarUnit           = NSCalendarUnitHour,
    NSMinuteCalendarUnit         = NSCalendarUnitMinute,
    NSSecondCalendarUnit         = NSCalendarUnitSecond
};


// these should be in _MulleGregorianCalendar.h really but then they
// ain't visible
MULLE_OBJC_CALENDAR_FOUNDATION_GLOBAL
NSString  *NSGregorianCalendar; // = @"gregorian";

MULLE_OBJC_CALENDAR_FOUNDATION_GLOBAL
NSString  *NSJulianCalendar; //  = @"julian";



@interface NSCalendar : NSObject
{
   NSUInteger   _daysOfCommonEraOfReferenceDate;
}


@property( copy) NSLocale     *locale;
@property( copy) NSTimeZone   *timeZone;

// Sunday: 0, Monday: 1
@property( assign) NSInteger  firstWeekday;

// numbers of days a week must have to be considered a week for weekOfYear
@property( assign) NSInteger  minimumDaysInFirstWeek;


// must be done during +load
+ (void) mulleRegisterClass:(Class) cls
              forIdentifier:(NSString *) identifier;

+ (instancetype) calendarWithIdentifier:(NSString *) identifier;
- (instancetype) initWithCalendarIdentifier:(NSString *) identifier;

- (NSDateComponents *) components:(NSUInteger) flags
                         fromDate:(NSDate *) date;

- (NSDate *) dateByAddingComponents:(NSDateComponents *) components
                             toDate:(NSDate *) date
                            options:(NSUInteger) options;

- (NSDate *) dateFromComponents:(NSDateComponents *) components;

@end



@interface NSCalendar( Subclasses)

+ (instancetype) currentCalendar;
- (NSString *) calendarIdentifier;

- (NSInteger) mulleFirstWeekdayOfCommonEra;

- (NSRange) minimumRangeOfUnit:(NSCalendarUnit) unit;
- (NSRange) maximumRangeOfUnit:(NSCalendarUnit) unit;

- (NSRange) rangeOfUnit:(NSCalendarUnit) unit
                 inUnit:(NSCalendarUnit) inUnit
                forDate:(NSDate *)date;

- (BOOL) rangeOfUnit:(NSCalendarUnit) unit
           startDate:(NSDate **) p_startDate
            interval:(NSTimeInterval *) p_interval
             forDate:(NSDate *) date;

- (NSUInteger) ordinalityOfUnit:(NSCalendarUnit) unit
                         inUnit:(NSCalendarUnit) inUnit
                        forDate:(NSDate *) date;

- (BOOL) mulleIsLeapYear:(NSInteger) year;
- (NSInteger) mulleNumberOfDaysInYear:(NSInteger) year;
- (NSInteger) mulleNumberOfWeeksInYear:(NSInteger) year;
- (NSInteger) mulleNumberOfDaysInMonth:(NSInteger) month
                                ofYear:(NSInteger) year;
- (NSInteger) mulleNumberOfDaysInCommonEraOfDay:(NSInteger) day
                                          month:(NSInteger) month
                                           year:(NSInteger) year;

- (NSTimeInterval) mulleTimeIntervalWithYear:(NSInteger) year
                                       month:(NSInteger) month
                                         day:(NSInteger) day
                                        hour:(NSInteger) hour
                                      minute:(NSInteger) minute
                                      second:(NSInteger) second
                                  nanosecond:(NSInteger) nanosecond;

@end

