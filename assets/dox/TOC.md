# MulleObjCCalendarFoundation Library Documentation for AI

## 1. Introduction & Purpose

MulleObjCCalendarFoundation provides NSCalendar and NSDateComponents classes for calendar-based date operations. Supports multiple calendar systems (Gregorian and Julian) with full date component extraction, manipulation, and arithmetic. Essential for applications needing calendar-aware date handling, scheduling, and date formatting relative to specific calendar systems.

## 2. Key Concepts & Design Philosophy

- **Calendar Abstraction**: Pluggable calendar implementations (Gregorian, Julian, extensible for others)
- **Component-Based**: Breaks dates into calendar components (year, month, day, hour, etc.)
- **NSCalendarUnit Flags**: Bit flags specify which components to extract/operate on
- **Range Queries**: Support for finding ranges of calendar units within larger units
- **Calendar Arithmetic**: Add/subtract components from dates, preserving calendar rules
- **Locale/Timezone Aware**: Respects locale and timezone settings for accurate calculations

## 3. Core API & Data Structures

### NSCalendarUnit Flags

Used to specify which date components to extract or manipulate:

```objc
NSCalendarUnitEra              // Calendar era
NSCalendarUnitYear             // Year value
NSCalendarUnitQuarter          // Quarter (1-4)
NSCalendarUnitMonth            // Month (1-12)
NSCalendarUnitWeekOfYear       // Week number in year
NSCalendarUnitWeekOfMonth      // Week number in month
NSCalendarUnitDay              // Day of month
NSCalendarUnitWeekday          // Day of week (0=Sunday, 6=Saturday)
NSCalendarUnitWeekdayOrdinal   // Ordinal weekday (e.g., 2nd Monday)
NSCalendarUnitHour             // Hour (0-23)
NSCalendarUnitMinute           // Minute (0-59)
NSCalendarUnitSecond           // Second (0-59)
NSCalendarUnitNanosecond       // Nanosecond component
```

### NSCalendar Class

#### Calendar Creation

- `+ calendarWithIdentifier:(NSString *)identifier` → `instancetype`: Create calendar (e.g., NSGregorianCalendar, NSJulianCalendar)
- `+ currentCalendar` → `instancetype`: Get system default calendar
- `- initWithCalendarIdentifier:(NSString *)identifier` → `instancetype`: Initialize with specific calendar system

#### Calendar Identifiers

- `NSGregorianCalendar` (@"gregorian"): Standard Gregorian calendar
- `NSJulianCalendar` (@"julian"): Julian calendar (older system)

#### Properties

- `locale` (NSLocale *): Locale affecting formatting and calculations
- `timeZone` (NSTimeZone *): Timezone for date interpretation
- `firstWeekday` (NSInteger): First day of week (0=Sunday, 1=Monday, etc.)
- `minimumDaysInFirstWeek` (NSInteger): Min days in week to count as week 1

#### Component Extraction

- `- components:(NSCalendarUnit)flags fromDate:(NSDate *)date` → `NSDateComponents *`: Extract specified components from date

#### Date Creation from Components

- `- dateFromComponents:(NSDateComponents *)components` → `NSDate *`: Create date from components

#### Date Arithmetic

- `- dateByAddingComponents:(NSDateComponents *)components toDate:(NSDate *)date options:(NSUInteger)options` → `NSDate *`: Add components to date

#### Range Queries

- `- rangeOfUnit:(NSCalendarUnit)unit inUnit:(NSCalendarUnit)inUnit forDate:(NSDate *)date` → `NSRange`: Get range of unit within larger unit (e.g., days in month)
- `- minimumRangeOfUnit:(NSCalendarUnit)unit` → `NSRange`: Minimum possible range (e.g., min days in month)
- `- maximumRangeOfUnit:(NSCalendarUnit)unit` → `NSRange`: Maximum possible range (e.g., max days in month)
- `- rangeOfUnit:(NSCalendarUnit)unit startDate:(NSDate **)startDate interval:(NSTimeInterval *)interval forDate:(NSDate *)date` → `BOOL`: Get range boundaries and duration

#### Calendar-Specific Queries

- `- ordinalityOfUnit:(NSCalendarUnit)unit inUnit:(NSCalendarUnit)inUnit forDate:(NSDate *)date` → `NSUInteger`: Get ordinal position (e.g., which day of week in month)
- `- mulleIsLeapYear:(NSInteger)year` → `BOOL`: Check if year is leap year
- `- mulleNumberOfDaysInYear:(NSInteger)year` → `NSInteger`: Days in year
- `- mulleNumberOfWeeksInYear:(NSInteger)year` → `NSInteger`: Weeks in year
- `- mulleNumberOfDaysInMonth:(NSInteger)month ofYear:(NSInteger)year` → `NSInteger`: Days in specific month
- `- mulleNumberOfDaysInCommonEraOfDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year` → `NSInteger`: Days since common era start

#### Calendar Identifier

- `- calendarIdentifier` → `NSString *`: Get calendar type identifier

### NSDateComponents Class

#### Purpose

Represents a collection of calendar components (like a structured breakdown of a date).

#### Component Properties

```objc
@property NSInteger era;                // Calendar era
@property NSInteger year;               // Year
@property NSInteger quarter;            // Quarter (1-4)
@property NSInteger month;              // Month (1-12)
@property NSInteger weekOfYear;         // Week of year
@property NSInteger weekOfMonth;        // Week of month
@property NSInteger day;                // Day of month
@property NSInteger weekday;            // Weekday (0=Sunday)
@property NSInteger weekdayOrdinal;     // Ordinal weekday
@property NSInteger hour;               // Hour (0-23)
@property NSInteger minute;             // Minute (0-59)
@property NSInteger second;             // Second (0-59)
@property NSInteger nanosecond;         // Nanosecond value
```

#### Undefined Value

- `NSDateComponentUndefined`: Constant for unset components (NSIntegerMax)

#### Component Access

- `- valueForComponent:(NSCalendarUnit)unit` → `NSInteger`: Get value of component
- `- setValue:(NSInteger)value forComponent:(NSCalendarUnit)unit` → `void`: Set component value
- `- week` → `NSInteger`: Alias for weekOfYear
- `- setWeek:(NSInteger)week` → `void`: Alias setter for weekOfYear

## 4. Performance Characteristics

- **Component Extraction**: O(1) per component flag
- **Date Arithmetic**: O(1) for most operations; O(n) for complex calendar calculations
- **Range Queries**: O(1) lookup for calendar metadata
- **Leap Year Calculations**: O(1) constant-time check
- **Memory**: NSDateComponents is lightweight struct wrapper
- **Thread-Safety**: NSDateComponents marked MulleObjCThreadUnsafe; don't share across threads

## 5. AI Usage Recommendations & Patterns

### Best Practices

- **Specify Flags**: Only request needed components via NSCalendarUnit flags
- **Respect Locales**: Set locale/timezone appropriately for user's region
- **Validate Components**: Check for NSDateComponentUndefined for unset values
- **Use currentCalendar**: For user-facing dates, use system default calendar
- **Component Arithmetic**: Prefer calendar arithmetic over manual calculations
- **Cache Calendars**: Create once, reuse rather than recreating

### Common Pitfalls

- **Wrong Weekday Numbering**: Sunday=0, not 1; verify expectations
- **Component Undefined**: Unset components have value NSIntegerMax; check explicitly
- **Calendar Differences**: Gregorian vs Julian differ; be aware which calendar affects results
- **Month Numbering**: Months are 1-12, not 0-11 (unlike C)
- **Timezone Issues**: Dates may shift across timezones; set timezone correctly
- **Leap Second Handling**: Leap seconds may cause off-by-one errors; validate critical dates

### Idiomatic Usage

```objc
// Pattern 1: Extract components from date
NSCalendar *cal = [NSCalendar currentCalendar];
NSDateComponents *comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                 fromDate:[NSDate date]];
NSLog(@"Year: %ld, Month: %ld", comps.year, comps.month);

// Pattern 2: Create date from components
NSDateComponents *components = [[NSDateComponents alloc] init];
components.year = 2025;
components.month = 3;
components.day = 15;
components.hour = 14;
components.minute = 30;
NSDate *date = [cal dateFromComponents:components];

// Pattern 3: Add days to date
NSDateComponents *oneDay = [[NSDateComponents alloc] init];
oneDay.day = 1;
NSDate *tomorrow = [cal dateByAddingComponents:oneDay toDate:[NSDate date] options:0];

// Pattern 4: Get day of week
NSDateComponents *comps = [cal components:NSCalendarUnitWeekday fromDate:[NSDate date]];
NSInteger dayOfWeek = comps.weekday;  // 0=Sunday, 1=Monday, etc.
```

## 6. Integration Examples

### Example 1: Extract Date Components

```objc
#import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>

int main() {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    
    NSDateComponents *comps = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                     fromDate:now];
    
    NSLog(@"Today: %ld/%ld/%ld", comps.month, comps.day, comps.year);
    
    return 0;
}
```

### Example 2: Create Date from Components

```objc
#import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>

int main() {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    components.year = 2025;
    components.month = 12;
    components.day = 25;
    components.hour = 9;
    components.minute = 30;
    components.second = 0;
    
    NSDate *christmas = [cal dateFromComponents:components];
    NSLog(@"Christmas 2025: %@", christmas);
    
    [components release];
    return 0;
}
```

### Example 3: Calendar Arithmetic

```objc
#import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>

int main() {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *today = [NSDate date];
    
    NSDateComponents *offset = [[NSDateComponents alloc] init];
    offset.day = 7;  // Add 7 days
    
    NSDate *nextWeek = [cal dateByAddingComponents:offset toDate:today options:0];
    NSLog(@"Next week: %@", nextWeek);
    
    [offset release];
    return 0;
}
```

### Example 4: Days in Month

```objc
#import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>

int main() {
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    NSInteger daysInFeb2024 = [cal mulleNumberOfDaysInMonth:2 ofYear:2024];
    NSLog(@"Days in Feb 2024: %ld", daysInFeb2024);  // 29 (leap year)
    
    NSInteger daysInFeb2025 = [cal mulleNumberOfDaysInMonth:2 ofYear:2025];
    NSLog(@"Days in Feb 2025: %ld", daysInFeb2025);  // 28 (not leap)
    
    return 0;
}
```

### Example 5: Day of Week

```objc
#import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>

int main() {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *date = [NSDate date];
    
    NSDateComponents *comps = [cal components:NSCalendarUnitWeekday fromDate:date];
    
    const char *days[] = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"};
    NSLog(@"Today is: %s", days[comps.weekday]);
    
    return 0;
}
```

### Example 6: Range of Days in Month

```objc
#import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>

int main() {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *date = [NSDate date];
    
    NSRange monthRange = [cal rangeOfUnit:NSCalendarUnitDay 
                                  inUnit:NSCalendarUnitMonth 
                                 forDate:date];
    
    NSLog(@"Days in this month: %lu (from day %lu)", 
          monthRange.length, monthRange.location);
    
    return 0;
}
```

## 7. Dependencies

- MulleObjCTimeFoundation (NSDate, NSTimeInterval)
- MulleObjCValueFoundation (NSString, NSNumber)
- MulleObjCOSFoundation (NSTimeZone, NSLocale)
- MulleFoundationBase
