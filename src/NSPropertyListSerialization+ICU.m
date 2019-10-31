//
//  NSPropertyListSerialization.m
//  MulleObjCStandardFoundation
//
//  Copyright (c) 2011 Nat! - Mulle kybernetiK.
//  Copyright (c) 2011 Codeon GmbH.
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
#import "NSPropertyListSerialization+ICU.h"

// other files in this library
#import "NSObject+ICUPropertyListParsing.h"
#import "NSString+ICUPropertyListParsing.h"

#import "import-private.h"

// std-c and dependencies
#include <ctype.h>
#include <string.h>


@implementation NSPropertyListSerialization( ICU)

+ (void) load
{
   [self mulleAddFormatDetector:@selector( mulleDetectICUPropertyListFormat:)];

   [self mulleAddParser:@selector( mulleParseICUPropertyListData:mutabilityOptions:)
  forPropertyListFormat:MullePropertyListICUFormat_v1_0];
}


enum
{
   start,
   comment1,
   comment2,
   identifier,
   stringstart,
   stringescape,
   stringend
};


static inline int   is_icu_identifier( int c)
{
   return( (c >= 'a' && c <= 'z') || (c >='A' && c <= 'Z') || c == '_' ||
           (c >='0' && c <= '9') || c == '%' || c == '-');
}


+ (NSPropertyListFormat) mulleDetectICUPropertyListFormat:(NSData *) data
{
   char         *s;
   char         *sentinel;
   int          c;
   NSUInteger   len;
   int          state;

   // skip lines with //

   s   = [data bytes];
   len = [data length];

   state    = start;
   sentinel = &s[ len];
   while( s < sentinel)
   {
      c = *s++;
      switch( state)
      {
      case start :
         if( isspace( c))
            continue;

         if( c == '/')
         {
            state = comment1;
            continue;
         }

         if( c == '"')
         {
            state = stringstart;
            continue;
         }

         if( is_icu_identifier( c))
         {
            state = identifier;
            continue;
         }
         return( 0);

      case comment1 :
         if( c == '/')
         {
            state = comment2;
            continue;
         }
         return( 0);

      case comment2 :
         if( c == '\n')
            state = start;
         continue;

      case stringstart :
         if( c == '\n')
            return( 0);
         if( c == '\\')
         {
            state = stringescape;
            continue;
         }
         if( c == '"')
            c = stringend;
         continue;

      case stringescape :
         if( c == '\n')
            return( 0);
         continue;

      case stringend :
         if( c == '{')
            return( MullePropertyListICUFormat_v1_0);
         // allow multiline string though who uses that for keys ?
         if( isspace( c))
            continue;
         if( c == '"')
            c = stringstart;
         return( 0);

      case identifier :
         if( c == '{')
            return( MullePropertyListICUFormat_v1_0);

         if( is_icu_identifier( c))
            continue;
         return( 0);
      }
   }
   return( 0);
}


- (id) mulleParseOpenStepPropertyListData:(NSData *) data
                         mutabilityOption:(NSPropertyListMutabilityOptions) opt
{
   _MulleObjCPropertyListReader        *reader;
   _MulleObjCBufferedDataInputStream   *stream;
   id                                  plist;
   NSPropertyListSerialization         *parser;
   NSString                            *dummy;

   stream = [[[_MulleObjCBufferedDataInputStream alloc] initWithData:data] autorelease];
   reader = [[[_MulleObjCPropertyListReader alloc] initWithBufferedInputStream:stream] autorelease];

   [reader setMutableContainers:opt != NSPropertyListImmutable];
   [reader setMutableLeaves:opt == NSPropertyListMutableContainersAndLeaves];
   [reader setDecodesComments:YES];
   // defaults don't have to be set
   // [reader setDecodesPBX:NO];
   // [reader setDecodesNumber:NO];

   plist = [_MulleObjCNewFromICUPropertyListWithStreamReader( reader) autorelease];
   return( plist);
}

@end
