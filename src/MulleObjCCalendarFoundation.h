#ifndef mulle_objc_calendar_foundation_h__
#define mulle_objc_calendar_foundation_h__

#import "import.h"

#include <stdint.h>

/*
   Add other library headers here like so, for exposure to library
   consumers.

   # include "foo.h"
*/

#import "_MulleObjCCalendarFoundation-export.h"
#include "_MulleObjCCalendarFoundation-provide.h"


/*
 *  (c) 2019 nat ORGANIZATION
 *
 *  version:  major, minor, patch
 */
#define MULLE_OBJC_CALENDAR_FOUNDATION_VERSION  ((0UL << 20) | (20 << 8) | 4)


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


MULLE_OBJC_CALENDAR_FOUNDATION_GLOBAL
uint32_t   MulleObjCCalendarFoundation_get_version( void);

#ifdef __has_include
# if __has_include( "_MulleObjCCalendarFoundation-versioncheck.h")
#  include "_MulleObjCCalendarFoundation-versioncheck.h"
# endif
#endif


#endif
