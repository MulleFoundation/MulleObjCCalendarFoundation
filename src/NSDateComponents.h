//
//  NSDateComponents.h
//  MulleObjCCalendarFoundation
//
//  Copyright (c) 2019 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
#import "import.h"

#import "NSCalendar.h"


#define NSDateComponentUndefined    NSIntegerMax

//
// this is just a glorified struct wrapped into an object
//
@interface NSDateComponents : NSObject < MulleObjCThreadUnsafe>
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

- (NSString *) description;
- (NSString *) mulleDebugContentsDescription;

@end


