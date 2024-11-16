#import "NSDateComponents.h"

#import "import-private.h"


@implementation NSDateComponents( NSString)

static void   append( NSMutableString *s, NSString *format, NSString *delim, NSInteger value)
{
   [s appendString:delim];

   if( value == NSIntegerMax)
      [s appendString:@"*"];
   else
      [s appendFormat:format, value];
}


- (NSString *) description
{
   NSMutableString   *s;

   s = [NSMutableString string];

   append( s, @"%04ld", nil, _year);
   append( s, @"%02ld", @"-", _month);
   append( s, @"%02ld", @"-", _day);

   append( s, @"%02ld", @" ", _hour);
   append( s, @"%02ld", @":", _minute);
   append( s, @"%02ld", @":", _second);
   append( s, @"%09ld", @".", _nanosecond);

   return( s);
}


- (NSString *) mulleDebugContentsDescription      MULLE_OBJC_THREADSAFE_METHOD
{
   return( [self description]);
}

@end
