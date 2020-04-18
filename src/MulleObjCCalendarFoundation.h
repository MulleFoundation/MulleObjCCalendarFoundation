#ifndef mulle_objc_calendar_foundation_h__
#define mulle_objc_calendar_foundation_h__

#import "import.h"

#include <stdint.h>

/*
 *  (c) 2019 nat ORGANIZATION
 *
 *  version:  major, minor, patch
 */
#define MULLE_OBJC_CALENDAR_FOUNDATION_VERSION  ((0 << 20) | (17 << 8) | 1)


static inline unsigned int   MulleObjCCalendarFoundation_get_version_major( void)
{
   return( MULLE_OBJC_CALENDAR_FOUNDATION_VERSION >> 20);
}


static inline unsigned int   MulleObjCCalendarFoundation_get_version_minor( void)
{
   return( (MULLE_OBJC_CALENDAR_FOUNDATION_VERSION >> 8) & 0xFFF);
}


static inline unsigned int   MulleObjCCalendarFoundation_get_version_patch( void)
{
   return( MULLE_OBJC_CALENDAR_FOUNDATION_VERSION & 0xFF);
}


extern uint32_t   MulleObjCCalendarFoundation_get_version( void);

/*
   Add other library headers here like so, for exposure to library
   consumers.

   # include "foo.h"
*/
#import "NSCalendar.h"
#import "NSCalendar+NSDate.h"
#import "NSDateComponents.h"

#import "_MulleGregorianCalendar.h"
#import "_MulleJulianCalendar.h"

#endif
