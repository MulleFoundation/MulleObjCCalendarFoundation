# This file will be regenerated by `mulle-match-to-cmake` via
# `mulle-sde reflect` and any edits will be lost.
#
# This file will be included by cmake/share/sources.cmake
#
if( MULLE_TRACE_INCLUDE)
   MESSAGE( STATUS "# Include \"${CMAKE_CURRENT_LIST_FILE}\"" )
endif()

#
# contents selected with patternfile ??-source--sources
#
set( SOURCES
src/_MulleGregorianCalendar.m
src/_MulleJulianCalendar.m
src/MulleObjCCalendarFoundation.m
src/NSCalendar+NSDate.m
src/NSCalendar.m
src/NSDateComponents+NSString.m
src/NSDateComponents.m
)

#
# contents selected with patternfile ??-source--stage2-sources
#
set( STAGE2_SOURCES
src/MulleObjCLoader+MulleObjCCalendarFoundation.m
)
