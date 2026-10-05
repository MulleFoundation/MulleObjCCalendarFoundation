# MulleObjCCalendarFoundation Library Documentation for AI
<!-- Keywords: calendar, gregorian, julian, date, timezone, locale, weekday -->

## 1. Introduction & Purpose

MulleObjCCalendarFoundation adds a Gregorian and a Julian `NSCalendar` to the
[MulleFoundation](https://github.com/MulleFoundation) (a foundational part of
the `MulleFoundation` project collection). It provides:

* `NSCalendar` — an abstract, Apple-NSCalendar-inspired calendar class whose
  subclasses implement the calendrical rules (proleptic Gregorian and
  non-revised Julian).
* `NSDateComponents` — a "glorified struct wrapped into an object" that holds a
  breakdown of a date into calendar fields (era, year, month, day, hour, ...).
* `NSCalendar+NSDate` — an extension API that splits an `NSTimeInterval`
  (seconds since the reference date) into calendar fields, including ISO week
  numbers and "days of common era".

It solves calendar-aware date decomposition, date composition and date
arithmetic that is independent of a specific calendar system. It depends on
`mulle-objc`-based infrastructure (via `MulleObjCOSFoundation`) for the `NSDate`,
`NSTimeInterval`, `NSRange`, `NSTimeZone` and `NSLocale` types. The design is
derived from Christopher J. W. Lloyd's precision-date code (see the copyright in
`NSCalendar+NSDate.h`).

## 2. Key Concepts & Design Philosophy

* **Calendar abstraction.** `NSCalendar` is abstract. Concrete rules live in the
  subclasses `_MulleGregorianCalendar` and `_MulleJulianCalendar`
  (`_MulleGregorianCalendar : _MulleJulianCalendar : NSCalendar`). A calendar
  class registers itself under an identifier string during `+load` via
  `mulleRegisterClass:`. `calendarWithIdentifier:` looks the identifier up in a
  class registry (a map table) and news an instance of the matching class.
* **Proleptic calendars.** The Gregorian implementation is *proleptic*: it
  starts at 1.1.1 and has no lost days around the 1582-10 reform
  (`NSTimeIntervals < 15.10.1582` are "probably more correct than Apple's but,
  because of leap years, still questionable"). The Julian implementation is the
  non-revised Julian calendar, whose Julian date zero moment is twelve noon.
  The two calendars therefore produce different `NSTimeInterval`s for the same
  (day, month, year).
* **Time interval as the internal representation.** A date is stored as an
  `NSTimeInterval` (seconds since the reference date). The ivar
  `_daysOfCommonEraOfReferenceDate` anchors calendar days to that epoch:
  Gregorian = 730485 (reference date 00:00:00 1.1.2001, epoch at
  00:00:00 1.1.1), Julian = 730500.
  `mulleNumberOfDaysInCommonEraOfDay:` returns the number of elapsed days since
  day 0 of the common era (1.1.1 = 0).
* **Extended time interval (memoization).** `struct MulleExtendedTimeInterval`
  is filled with an `NSTimeInterval` and lazily caches derived fields (`year`,
  `month`, `weekday`, `dayOfCommonEra`, `dayOfMonth`, `hour`). All
  `mulle...FromExtendedTimeInterval:` methods read from or compute into this
  struct, so a decomposition pass computes each derived value at most once.
  Uncomputed fields are initialized to `NSIntegerMax` (via
  `MulleExtendedTimeIntervalInit`).
* **Undefined means "not set".** Every field of `NSDateComponents` (and of a
  fresh `NSDateComponents`) is set to `NSDateComponentUndefined`
  (`NSIntegerMax`) on `-init`. `dateFromComponents:` substitutes defaults for
  undefined fields (year/month/day = 1, time = 0), while
  `dateByAddingComponents:` and `components:` treat `NSIntegerMax` as "absent".
  The `description` prints `*` for undefined fields.
* **Timezone / locale awareness.** `NSCalendar` carries `timeZone`
  (`NSTimeZone *`) and `locale` (`NSLocale *`) properties. Date decomposition
  *adds* `[timeZone secondsFromGMTForDate:]` to the UTC reference interval to
  obtain local wall-clock components; composition *subtracts* it again to get
  back the UTC instant. Results are therefore relative to the calendar's time
  zone (default: the local time zone).

## 3. Core API & Data Structures

### 3.1. `NSCalendar.h`

Defines the calendar abstraction, the `NSCalendarUnit` flag bitmask, and the
two calendar identifier strings.

#### `NSCalendarUnit` (Calendar unit flag bitmask)

A bitmask of date components to extract or act on. All values verbatim from the
header:

```objc
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
```

The header also provides legacy spellings of some of these flags
(`NSEraCalendarUnit`, `NSYearCalendarUnit`, `NSMonthCalendarUnit`,
`NSWeekCalendarUnit`, `NSDayCalendarUnit`, `NSWeekdayCalendarUnit`,
`NSWeekdayOrdinalCalendarUnit`, `NSHourCalendarUnit`, `NSMinuteCalendarUnit`,
`NSSecondCalendarUnit`), which are aliases of the `NSCalendarUnit*` values.

#### Calendar identifier globals

```objc
MULLE_OBJC_CALENDAR_FOUNDATION_GLOBAL
NSString  *NSGregorianCalendar; // = @"gregorian";

MULLE_OBJC_CALENDAR_FOUNDATION_GLOBAL
NSString  *NSJulianCalendar; //  = @"julian";
```

Pass these to `calendarWithIdentifier:` / `initWithCalendarIdentifier:`.

#### `@interface NSCalendar : NSObject`

- **Purpose:** Abstract calendar. Concrete subclasses implement the calendrical
  arithmetic; `NSCalendar` provides registry, creation, decomposition,
  composition and arithmetic.
- **Instance variables:**
  - `NSUInteger _daysOfCommonEraOfReferenceDate;` — day count between 1.1.1
    and the reference date, per calendar.
- **Properties** (read/write via message sends, e.g. `[calendar timeZone]`,
  `[calendar setFirstWeekday:2]`):
  - `@property( copy) NSLocale *locale;`
  - `@property( copy) NSTimeZone *timeZone;`
  - `@property( assign) NSInteger firstWeekday;` — Sunday: 0, Monday: 1
  - `@property( assign) NSInteger minimumDaysInFirstWeek;` — days a week must
    have to count for `weekOfYear`; default 1.
- **Registry & creation:**
  - `+ (void) mulleRegisterClass:(Class) cls forIdentifier:(NSString *) identifier;`
    Register a calendar class under an identifier. Called by the subclasses
    during `+load`.
  - `+ (instancetype) calendarWithIdentifier:(NSString *) identifier;`
    Create the calendar registered under `identifier`.
  - `- (instancetype) initWithCalendarIdentifier:(NSString *) identifier;`
    Look up the class for `identifier` and return a new instance of it.
- **Core operations:**
  - `- (NSDateComponents *) components:(NSUInteger) flags fromDate:(NSDate *) date;`
    Decompose `date` into a new `NSDateComponents` holding exactly the fields
    selected by `flags` (bitmask, e.g. `~0` for all fields). Fields not
    selected remain `NSDateComponentUndefined`.
  - `- (NSDate *) dateFromComponents:(NSDateComponents *) components;`
    Compose an `NSDate` from the (possibly partial) components. Undefined
    fields default to year/month/day = 1 and hour/minute/second/nanosecond = 0.
  - `- (NSDate *) dateByAddingComponents:(NSDateComponents *) components toDate:(NSDate *) date options:(NSUInteger) options;`
    Add the (possibly partial) components to `date`. Month overflow carries
    into the year; a day overflow is *clamped* to the last day of the resulting
    month rather than carried over; time fields normalize (nanosecond → second
    → minute → hour → day). `options` must be 0 — any other value aborts.

#### `@interface NSCalendar( SubclassesFuture) <MulleObjCFuture>`

- **Purpose:** Calendar-rule API that subclasses must (or, where marked, will)
  implement. Declared for forward compatibility with Apple's `NSCalendar`
  API. All methods below are implemented by the concrete subclasses (both
  calendars share the `_MulleJulianCalendar` implementation, Gregorian only
  overrides per-calendar constants and the leap-year/day-count rules).
- **Creation:**
  - `+ (instancetype) currentCalendar;`
    Create the "current" (system/locale default, here: Gregorian) calendar.
    Implemented in the `NSCalendar( _MulleGregorianCalendar)` category.
- **Calendar identity:**
  - `- (NSString *) calendarIdentifier;`
    Returns `NSGregorianCalendar` or `NSJulianCalendar`.
  - `- (NSInteger) mulleFirstWeekdayOfCommonEra;`
    Weekday of 1.1.1: Gregorian → Monday (2), Julian → Saturday (7). The value
    uses the `MulleCalendarWeekday` numbering (see `NSCalendar+NSDate.h`).
- **Range queries:**
  - `- (NSRange) minimumRangeOfUnit:(NSCalendarUnit) unit;`
    Minimum possible range (`NSRangeMake( location, length)`), e.g. day
    `[1,28]`; an unknown unit yields `NSRangeMake( NSNotFound, 0)`.
  - `- (NSRange) maximumRangeOfUnit:(NSCalendarUnit) unit;`
    Maximum possible range, e.g. day `[1,31]`, weekOfYear `[1,53]`.
  - `- (NSRange) rangeOfUnit:(NSCalendarUnit) unit inUnit:(NSCalendarUnit) inUnit forDate:(NSDate *)date;`
    Range of `unit` inside `inUnit` at `date` (e.g. days in month `[1,31]`).
  - `- (BOOL) rangeOfUnit:(NSCalendarUnit) unit startDate:(NSDate **) p_startDate interval:(NSTimeInterval *) p_interval forDate:(NSDate *) date;`
    Fills `*p_startDate` with the start of the unit period containing `date`
    and `*p_interval` with the unit's duration in seconds; returns `YES` on
    success. `p_startDate`/`p_interval` may be `NULL`-pointers.
  - `- (NSUInteger) ordinalityOfUnit:(NSCalendarUnit) unit inUnit:(NSCalendarUnit) inUnit forDate:(NSDate *) date;`
    Declared in the header but **not yet implemented** — do not call it.
- **Day-count & leap-year helpers** (calendar-specific):
  - `- (BOOL) mulleIsLeapYear:(NSInteger) year;`
    Gregorian: divisible by 4, not by 100, unless by 400. Julian: divisible by 4.
  - `- (NSInteger) mulleNumberOfDaysInYear:(NSInteger) year;` (365 or 366)
  - `- (NSInteger) mulleNumberOfWeeksInYear:(NSInteger) year;`
  - `- (NSInteger) mulleNumberOfDaysInMonth:(NSInteger) month ofYear:(NSInteger) year;`
  - `- (NSInteger) mulleNumberOfDaysInCommonEraOfDay:(NSInteger) day month:(NSInteger) month year:(NSInteger) year;`
    Days elapsed since the start of the common era (1.1.1 = 0). Valid input
    range: year 1..144683, months 1..12.
- **Time interval construction:**
  - `- (NSTimeInterval) mulleTimeIntervalWithYear:(NSInteger) year month:(NSInteger) month day:(NSInteger) day hour:(NSInteger) hour minute:(NSInteger) minute second:(NSInteger) second nanosecond:(NSInteger) nanosecond;`
    Build the calendar-specific `NSTimeInterval` for the given date/time.

### 3.2. `NSDateComponents.h`

#### `@interface NSDateComponents : NSObject < MulleObjCThreadUnsafe>`

- **Purpose:** A flat container of all calendar fields, used to shuttle partial
  date information between the `NSCalendar` methods. It is marked
  `MulleObjCThreadUnsafe` — do not share instances across threads.
- **Instance variables** (declared `@public`, accessible directly as
  `_year` etc., but the idiomatic access is the property messages below):
  `_era`, `_year`, `_quarter`, `_month`, `_weekOfYear`, `_weekOfMonth`, `_day`,
  `_weekday`, `_weekdayOrdinal`, `_hour`, `_minute`, `_second`, `_nanosecond`
  (all `NSInteger`).
- **Constant:** `#define NSDateComponentUndefined NSIntegerMax` — the initial
  value of every field after `-init`.
- **Properties:** 13 `@property( assign)` properties of the same names as the
  ivars above (read via `[components year]`, write via `[components setYear:2001]`).
  `weekday` convention: Su=0, Mo=1, Sa=6.
- **Lifecycle:** `-init` sets every field to `NSDateComponentUndefined`. Use
  `[[NSDateComponents new] autorelease]` to create instances.
- **Core operations:**
  - `- (void) setWeek:(NSInteger) week;` / `- (NSInteger) week;`
    Alias pair for `weekOfYear`.
  - `- (NSInteger) valueForComponent:(NSCalendarUnit) unit;`
    Read the field selected by a single `NSCalendarUnit` flag.
  - `- (void) setValue:(NSInteger) value forComponent:(NSCalendarUnit) unit;`
    Write the field selected by a single `NSCalendarUnit` flag.
- **Inspection:**
  - `- (NSString *) description;`
    Formats as `"YYYY-MM-DD HH:MM:SS.NNNNNNNNN"`, printing `*` in place of any
    undefined field.
  - `- (NSString *) mulleDebugContentsDescription;` — returns `description`.

### 3.3. `NSCalendar+NSDate.h`

Low-level calendar decomposition API built around
`struct MulleExtendedTimeInterval`.

```objc
enum MulleCalendarWeekday
{
   MulleCalendarSunday    = 1,
   MulleCalendarMonday    = 2,
   MulleCalendarTuesday   = 3,
   MulleCalendarWednesday = 4,
   MulleCalendarThursday  = 5,
   MulleCalendarFriday    = 6,
   MulleCalendarSaturday  = 7
};
```

Note that this enumeration numbers Sunday = 1 (unlike the `firstWeekday`
property of `NSCalendar`, where Sunday = 0).

```objc
struct MulleExtendedTimeInterval
{
   NSTimeInterval    interval;
   NSInteger         year;
   NSInteger         month;
   NSInteger         weekday;
   NSInteger         dayOfCommonEra;
   NSInteger         dayOfMonth;
   NSInteger         hour;
};
```

- `static inline void MulleExtendedTimeIntervalInit( struct MulleExtendedTimeInterval *p, NSTimeInterval interval);`
  Sets `interval` and initializes all derived fields to `NSIntegerMax`
  ("not yet computed").

#### `@interface NSCalendar( NSDate)` extension methods

All take `(struct MulleExtendedTimeInterval *)` and return the respective
field, computing it from `interval` on first use and caching it in the struct:

- `- (BOOL) mulleIsLeapYearFromExtendedTimeInterval:...`
- `- (NSInteger) mulle12HourFromExtendedTimeInterval:...` (1-12)
- `- (NSInteger) mulle24HourFromExtendedTimeInterval:...` (0-23)
- `- (NSInteger) mulleAMPMFromExtendedTimeInterval:...`
- `- (NSInteger) mulleDayOfCommonEraFromExtendedTimeInterval:...`
  (`(interval / 86400.0) + _daysOfCommonEraOfReferenceDate`)
- `- (NSInteger) mulleDayOfMonthFromExtendedTimeInterval:...` (1-31)
- `- (NSInteger) mulleDayOfWeekFromExtendedTimeInterval:...`
- `- (NSInteger) mulleDayOfYearFromExtendedTimeInterval:...` (1-366)
- `- (NSInteger) mulleFirstWeekdayOfMonthFromExtendedTimeInterval:...`
- `- (NSInteger) mulleFirstWeekdayOfYearFromExtendedTimeInterval:...`
- `- (NSInteger) mulleISOFirstWeekOffsetInYearFromExtendedTimeInterval:...`
- `- (NSInteger) mulleISONumberOfWeeksInYearFromExtendedTimeInterval:...`
- `- (NSInteger) mulleISOWeekOfYearFromExtendedTimeInterval:...`
- `- (NSInteger) mulleLastWeekdayOfYearFromExtendedTimeInterval:...`
- `- (NSInteger) mulleMinuteFromExtendedTimeInterval:...` (0-59)
- `- (NSInteger) mulleMonthFromExtendedTimeInterval:...` (1-12)
- `- (NSInteger) mulleNumberOfWeeksInMonthFromExtendedTimeInterval:...`
- `- (NSInteger) mulleNumberOfWeeksInYearFromExtendedTimeInterval:...`
- `- (NSInteger) mulleQuarterFromExtendedTimeInterval:...` (1-4)
- `- (NSInteger) mulleWeekdayFromExtendedTimeInterval:...`
- `- (NSInteger) mulleWeekdayOrdinalFromExtendedTimeInterval:...`
- `- (NSInteger) mulleWeekOfMonthFromExtendedTimeInterval:...`
- `- (NSInteger) mulleWeekOfYearFromExtendedTimeInterval:...`
- `- (NSInteger) mulleYearFromExtendedTimeInterval:...`
- `- (NSInteger) mulleEraFromExtendedTimeInterval:...` — always 1.

Standalone helpers:

- `static inline NSInteger MulleSecondFromTimeInterval(NSTimeInterval interval);`
  Second of the minute of `interval` (0-59, negative-safe).
- `static inline NSInteger MulleNanosecondFromTimeInterval( NSTimeInterval interval);`
  Nanosecond of the second of `interval` (0-999999999, negative-safe).

### 3.4. `_MulleJulianCalendar.h` and `_MulleGregorianCalendar.h`

- `@interface _MulleJulianCalendar : NSCalendar` — the non-revised Julian
  calendar; implements virtually all of the `SubclassesFuture`/`NSDate` API
  that both calendars share. Adds one public helper:
  - `- (void) _mulleCorrectDay:(NSInteger *) p_day month:(NSInteger *) p_month year:(NSInteger *) p_year;`
    Normalizes an out-of-range `*p_day` into a valid date, carrying into the
    month/year (used internally by the interval construction).
  - Julian specifics: reference anchor = 730500 days, 1.1.1 is a Saturday,
    `_firstWeekday` starts as `MulleCalendarSunday`, leap year if `year % 4 == 0`.
- `@interface _MulleGregorianCalendar : _MulleJulianCalendar` — the proleptic
  Gregorian calendar. Overrides the leap-year rule (`(y%4==0 && y%100!=0) ||
  y%400==0`), the reference anchor (730485 days), `mulleFirstWeekdayOfCommonEra`
  (= 2, Monday), day-count and month-length functions, and
  `_mulleCorrectDay:`. `currentCalendar` (in the `NSCalendar(_MulleGregorianCalendar)`
  category) returns a Gregorian calendar.

### 3.5. `MulleObjCCalendarFoundation.h`

Version macros and accessors:

```c
#define MULLE_OBJC_CALENDAR_FOUNDATION_VERSION  ((0UL << 20) | (21 << 8) | 6)

static inline unsigned int   MulleObjCCalendarFoundation_get_version_major( void);
static inline unsigned int   MulleObjCCalendarFoundation_get_version_minor( void);
static inline unsigned int   MulleObjCCalendarFoundation_get_version_patch( void);

MULLE_OBJC_CALENDAR_FOUNDATION_GLOBAL
uint32_t   MulleObjCCalendarFoundation_get_version( void);
```

### 3.6. `MulleObjCDeps+MulleObjCCalendarFoundation.h`

`@interface MulleObjCDeps( MulleObjCCalendarFoundation)` with
`+ (struct _mulle_objc_dependency *) dependencies;` — used by the mulle-objc
runtime/loader bookkeeping; not part of the practical date API.

## 4. Performance Characteristics

- **Leap year & month lengths:** O(1) arithmetic (modulo-based), with the
  month-length table computed via switch.
- **Days of common era:** O(1) — accumulated-month table plus `365*year +
  year/4 - year/100 + year/400` (Gregorian) or `365*year + year/4` (Julian).
- **Interval → field decomposition (extended time interval):** the epoch-based
  year guess `days / 366` is followed by a *linear* search to the correct year
  (`mulleYearFromExtendedTimeInterval`), and the month is found by a linear
  scan over months 1..12 (a binary search is a noted TODO). In practice these
  loops are tiny (≤ 1-2 iterations for the year fix-up, ≤ 12 for the month).
  All derived fields are memoized in `struct MulleExtendedTimeInterval`, so a
  full decomposition computes the expensive parts once.
- **Calendar registry:** `calendarWithIdentifier:` is an O(1) map-table lookup;
  registration happens once during class `+load`.
- **Memory:** `NSDateComponents` is a fixed 13-field object; `NSCalendar`
  holds 5 ivars plus two `copy`-owned objects (`timeZone`, `locale`).
- **Thread-safety:** `NSDateComponents` is declared `MulleObjCThreadUnsafe`.
  `NSCalendar` instances are not internally synchronized; use them from a
  single thread (or manage locking externally).

## 5. AI Usage Recommendations & Patterns

### Best Practices

- **Create calendars via the registry factory:**
  `[NSCalendar calendarWithIdentifier:NSGregorianCalendar]` (or
  `NSJulianCalendar`/`currentCalendar`) and reuse the instance.
- **Pin the time zone for reproducible results:** call
  `[calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]]`.
  Without this, results are relative to the local time zone.
- **Use message sends, never dot-syntax:** write
  `[components setYear:2001]` / `[components year]`, not `components.year`.
  The styleguide and the codebase forbid dot-syntax property access.
- **Create `NSDateComponents` via `[[NSDateComponents new] autorelease]`.**
  Never use `alloc`/`init`/`-release` outside `-init`/`-dealloc`.
- **Set only the fields you need.** Every unset field is
  `NSDateComponentUndefined` (`NSIntegerMax`); `dateFromComponents:` and
  `dateByAddingComponents:` interpret it as "not set".
- **Use `~0` to request every field** in one `components:...fromDate:` call and
  read the ones you need with the property getters.
- **Trust the calendar for arithmetic**: prefer
  `dateByAddingComponents:`/`dateFromComponents:` over manual epoch math; the
  calendar correctly handles leap years and month lengths.

### Common Pitfalls

- **Do not call `ordinalityOfUnit:`** — it is declared in the header but not
  implemented yet.
- **Pass 0 as `options:` to `dateByAddingComponents:`** — any nonzero value
  calls `abort()`.
- **Weekday numbering has two conventions:** the `NSCalendar.firstWeekday`
  property uses Sunday = 0, while `enum MulleCalendarWeekday` (and thus
  `mulle...WeekdayFromExtendedTimeInterval` return values and
  `mulleFirstWeekdayOfCommonEra`) uses Sunday = 1. Do not mix them.
- **Undefined ≠ 0.** An unset `NSDateComponents` field reads as
  `NSIntegerMax`, and `description` prints `*` for it.
- **Month numbers are 1-12**, not 0-11.
- **Day overflow is clamped, not carried.** Adding many days stops at the last
  day of the resulting month; only month overflow carries into the year.
- **Gregorian is proleptic.** There are no lost days around 5.-14.10.1582, and
  Gregorian and Julian disagree outside their shared epoch conventions. The
  supported year range is 1..144683 with asserts in day-count helpers.
- **Do not share `NSDateComponents` across threads** (`MulleObjCThreadUnsafe`).
- **Internal fields are `@public` but `_`-prefixed.** Prefer the property
  accessors over touching `_year` etc., except where the existing implementation
  itself does so.

### Idiomatic Usage

```objc
NSCalendar        *calendar;
NSDateComponents  *components;
NSDate            *date;

calendar   = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
[calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];

components = [[NSDateComponents new] autorelease];
[components setYear:2020];
[components setMonth:2];
[components setDay:29];
[components setHour:12];

date       = [calendar dateFromComponents:components];
components = [calendar components:~0 fromDate:date];
mulle_printf( "%ld.%ld.%ld %ld:%02ld\n",
      (long) [components day], (long) [components month], (long) [components year],
      (long) [components hour], (long) [components minute]);
```

## 6. Integration Examples

Coding style: 3-space indent, Allman braces, aligned declarations, C89 variable
rules, `return( expr);`, no dot-syntax.

### Example 1: Create a Gregorian calendar, compose and decompose a date

```objc
#import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>

int  main( void)
{
   NSCalendar        *calendar;
   NSDateComponents  *components;
   NSDate            *date;

   calendar   = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
   [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];

   components = [[NSDateComponents new] autorelease];
   [components setYear:2001];
   [components setMonth:1];
   [components setDay:1];
   [components setHour:12];

   date = [calendar dateFromComponents:components];
   mulle_printf( "interval: %.1f\n", [date timeIntervalSinceReferenceDate]);

   components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth |
                                      NSCalendarUnitDay | NSCalendarUnitHour
                              fromDate:date];
   mulle_printf( "%ld.%ld.%ld %ld:00\n",
         (long) [components day],
         (long) [components month],
         (long) [components year],
         (long) [components hour]);
   return( 0);
}
```

### Example 2: Calendar arithmetic (add days, compare both calendars)

```objc
#import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>

static void   add_a_day( NSString *identifier)
{
   NSCalendar        *calendar;
   NSDateComponents  *components;
   NSDate            *date;
   NSDate            *added;

   calendar   = [NSCalendar calendarWithIdentifier:identifier];
   [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];

   components = [[NSDateComponents new] autorelease];
   [components setYear:2020];
   [components setMonth:2];
   [components setDay:28];

   date   = [calendar dateFromComponents:components];
   components = [[NSDateComponents new] autorelease];
   [components setDay:1];   // one day

   added  = [calendar dateByAddingComponents:components
                                       toDate:date
                                      options:0];
   components = [calendar components:NSCalendarUnitYear |
                                      NSCalendarUnitMonth |
                                      NSCalendarUnitDay
                              fromDate:added];
   mulle_printf( "%s 28.2.2020 + 1 day = %ld.%ld.%ld\n",
         [[calendar calendarIdentifier] UTF8String],
         (long) [components day],
         (long) [components month],
         (long) [components year]);
}


int  main( void)
{
   add_a_day( NSGregorianCalendar);
   add_a_day( NSJulianCalendar);
   return( 0);
}
```

### Example 3: Range queries, leap years and day counts

```objc
#import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>

int  main( void)
{
   NSCalendar   *calendar;
   NSRange      range;

   calendar = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];

   mulle_printf( "leap 2020: %d, days in year: %ld\n",
         [calendar mulleIsLeapYear:2020],
         (long) [calendar mulleNumberOfDaysInYear:2020]);
   mulle_printf( "days in feb 2020: %ld\n",
         (long) [calendar mulleNumberOfDaysInMonth:2 ofYear:2020]);

   range = [calendar maximumRangeOfUnit:NSCalendarUnitDay];
   mulle_printf( "max day range: [%lu, %lu]\n",
         (unsigned long) range.location, (unsigned long) range.length);
   range = [calendar minimumRangeOfUnit:NSCalendarUnitDay];
   mulle_printf( "min day range: [%lu, %lu]\n",
         (unsigned long) range.location, (unsigned long) range.length);
   return( 0);
}
```

### Example 4: ISO weeks and the extended time interval API

```objc
#import <MulleObjCCalendarFoundation/MulleObjCCalendarFoundation.h>

int  main( void)
{
   NSCalendar                         *calendar;
   NSDateComponents                   *components;
   NSDate                             *date;
   struct MulleExtendedTimeInterval   extended;

   calendar   = [NSCalendar calendarWithIdentifier:NSGregorianCalendar];
   [calendar setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
   [calendar setFirstWeekday:2];
   [calendar setMinimumDaysInFirstWeek:4];

   components = [[NSDateComponents new] autorelease];
   [components setYear:2020];
   [components setMonth:1];
   [components setDay:6];

   date = [calendar dateFromComponents:components];
   components = [calendar components:NSCalendarUnitWeekOfYear |
                                      NSCalendarUnitWeekday |
                                      NSCalendarUnitWeekdayOrdinal
                              fromDate:date];
   mulle_printf( "ISO week: %ld weekday: %ld\n",
         (long) [components weekOfYear],
         (long) [components weekday]);

   MulleExtendedTimeIntervalInit( &extended, [date timeIntervalSinceReferenceDate]);
   mulle_printf( "first weekday of year: %ld, weeks in year: %ld\n",
         [calendar mulleFirstWeekdayOfYearFromExtendedTimeInterval:&extended],
         [calendar mulleISONumberOfWeeksInYearFromExtendedTimeInterval:&extended]);
   return( 0);
}
```

## 7. Dependencies

Direct `mulle-sde` dependencies (from `.mulle/etc/sourcetree/config`):

- `MulleObjCOSBaseFoundation` — platform-independent base classes/categories;
  provides the `NSTimeZone`, `NSLocale` infrastructure this library builds on.
- `MulleObjCPosixFoundation` — POSIX platform layer (`no-platform-windows`).
- `MulleObjCBSDFoundation` — BSD platform layer (`no-header`, selected per
  platform).
- `MulleObjCDarwinFoundation` — Darwin platform layer (`no-header`,
  `only-platform-darwin`).
- `MulleObjCLinuxFoundation` — Linux/Android platform layer (`no-header`,
  `only-platform-linux`, `only-platform-android`).
- `MulleObjCWindowsFoundation` — Windows platform layer (`only-platform-mingw`,
  `only-platform-windows`).
- `mulle-objc-list` — runtime metadata only (`no-import`, `no-header`,
  `no-link`).

Types used by the public API (`NSDate`, `NSTimeInterval`, `NSRange`,
`NSTimeZone`, `NSLocale`, `NSString`, `NSMapTable`, ...) come transitively from
the `MulleFoundation` Objective-C stack (e.g. `MulleObjCTimeFoundation`,
`MulleObjCValueFoundation`, `MulleObjCStandardFoundation`) via
`MulleObjCOSBaseFoundation`.