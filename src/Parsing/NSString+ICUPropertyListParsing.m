//
//  NSString+PropertyListParsing.m
//  MulleObjCStandardFoundation
//
//  Copyright (c) 2009 Nat! - Mulle kybernetiK.
//  Copyright (c) 2009 Codeon GmbH.
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
#import "NSString+ICUPropertyListParsing.h"

// other files in this library
#import "import-private.h"

// other libraries of MulleObjCStandardFoundation

// std-c and dependencies



@implementation NSString ( NSICUPropertyListParsing)


NSString   *
   _MulleObjCNewStringParsedQuotedFromICUPropertyListWithReader( _MulleObjCPropertyListReader *reader)
{
   long                    x;
   size_t                  len;
   size_t                  escaped;
   MulleObjCMemoryRegion   region;
   NSMutableData           *data;
   unsigned char           *src;
   unsigned char           *dst;
   NSString                *s;

   // grab '"' off
   x = _MulleObjCPropertyListReaderNextUTF32Character( reader);

   _MulleObjCPropertyListReaderBookmark(reader);
   escaped = 0;

   //
   // consume string... figure out how long it is
   // first slurp in the string unescaped and check boundaries
   //
   while( x != '"')
   {
      if( x == '\\')
      {
         x = _MulleObjCPropertyListReaderNextUTF32Character( reader);
         switch( x)
         {
         case -1   : return( (id) _MulleObjCPropertyListReaderFail( reader, @"escape in quoted string not finished !"));
         case 'a'  :
         case 'b'  :
         case 'f'  :
         case 'n'  :
         case 'r'  :
         case 't'  :
         case 'v'  :
         case '\\' :
         case '\"' :
#if ESCAPED_ZERO_IN_UTF8_STRING_IS_A_GOOD_THING
         case '0' :
#endif
            break;
         }
         escaped++;
      }
      x = _MulleObjCPropertyListReaderNextUTF32Character( reader);
      if( x < 0)
         return( (id) _MulleObjCPropertyListReaderFail( reader, @"quoted string not closed (expected '\"')"));
   }


   // get region without the trailing quote
   region = _MulleObjCPropertyListReaderBookmarkedRegion( reader);
   // now we can't read the stream anymore, until we are done with the region
   // it's fragile but faster

   if( ! region.length)
   {
      _MulleObjCPropertyListReaderConsumeCurrentUTF32Character( reader); // skip '"'
      return( [[reader->nsStringClass alloc] initWithString:@""]);
   }

   if( ! escaped)
   {
      s = [[reader->nsStringClass alloc] mulleInitWithUTF8Characters:region.bytes
                                                              length:region.length];
      _MulleObjCPropertyListReaderConsumeCurrentUTF32Character( reader); // skip '"'
      return( s);
   }

   len  = region.length - escaped;
   data = [[NSMutableData alloc] initWithLength:len];

   src = (unsigned char *) region.bytes;
   dst = (unsigned char *) [data bytes];

   while( len)
   {
      --len;
      if( (*dst++ = *src++) == '\\') // oldskool code
         switch( *src++)
         {
         case 'a'  : dst[ -1] = '\a'; break;
         case 'b'  : dst[ -1] = '\b'; break;
         case 'e'  : dst[ -1] = '\e'; break;
         case 'f'  : dst[ -1] = '\f'; break;
         case 'n'  : dst[ -1] = '\n'; break;
         case 'r'  : dst[ -1] = '\r'; break;
         case 't'  : dst[ -1] = '\t'; break;
         case 'v'  : dst[ -1] = '\v'; break;
         case '?'  : dst[ -1] = '?';  break;
         case '\\' : dst[ -1] = '\\'; break;
         case '\"' : dst[ -1] = '\"'; break;
#if ESCAPED_ZERO_IN_UTF8_STRING_IS_A_GOOD_THING
         case '0' :
#endif
            break;
         }
   }
   s = [[reader->nsStringClass alloc] initWithData:data
                                          encoding:NSUTF8StringEncoding];
   [data release];
   _MulleObjCPropertyListReaderConsumeCurrentUTF32Character( reader);  // skip '"'
   return( s);
}


NSString   *
   _MulleObjCNewStringFromICUPropertyListWithReader( _MulleObjCPropertyListReader *reader)
{
   long  x;

   x = _MulleObjCPropertyListReaderCurrentUTF32Character( reader);
   if( x == '"')
      return( _MulleObjCNewStringParsedQuotedFromICUPropertyListWithReader( reader));

   // reuse plist code here
   return( _MulleObjCNewObjectParsedUnquotedFromPropertyListWithReader( reader));
}

@end
