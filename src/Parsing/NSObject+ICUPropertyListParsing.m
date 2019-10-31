//
//  NSObject+PropertyListParsing.m
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
#import "NSObject+ICUPropertyListParsing.h"

// other files in this library
#import "NSString+ICUPropertyListParsing.h"

// other libraries of MulleObjCPosixFoundation
#import "import-private.h"


// std-c and dependencies

@interface NSObject( _NS)

- (BOOL) __isNSString;

@end


@implementation NSObject( NSICUPropertyListParsing)

// ICU looks like a fairly simple stream of strings and '{' '}'
// so we have:
//
// file   : expr
// expr   : string | dict
// dict   : string '{' expr '}'
// string : string string
// string : [a-zA-Z0-9_%-]+
// string : '"' {[^"]|\"}+ '"''
//
id   _MulleObjCNewFromICUPropertyListWithStreamReader( _MulleObjCPropertyListReader *reader)
{
   id                    plist;
   NSString              *s;
   NSString              *s2;
   NSMutableDictionary   *dict;
   NSMutableArray        *array;
   mulle_utf32_t         x;

   dict = nil;

rekey:
   s = _MulleObjCNewStringFromICUPropertyListWithReader( reader);
loop:
   x = _MulleObjCPropertyListReaderSkipWhiteAndComments( reader);
   switch( x)
   {
   case -1 :
      if( ! s && ! dict)
         return(  (id) _MulleObjCPropertyListReaderFail( reader,
                  @"empty property list is invalid"));
      // fall thru
   case '}' :
      return( dict ? dict : s);

   case '"' : // quoted string
      s2 = _MulleObjCNewStringFromICUPropertyListWithReader( reader);
      s  = [s stringByAppendingString:s2];
      goto loop;

   case '{' :
      plist = _MulleObjCNewFromICUPropertyListWithStreamReader( reader);
      if( ! dict)
         dict  = [NSMutableDictionary dictionaryWithObject:plist
                                                    forKey:s];
      else
         [dict setObject:plist
                  forKey:s];
      goto rekey;
   }

   return( plist);
}

@end
