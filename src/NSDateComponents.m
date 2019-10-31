#import "NSDateComponents.h"


@implementation NSDateComponents

- (instancetype) init
{
   NSInteger   *p;
   NSInteger   *sentinel;

   p        = &_era;
   sentinel = &_second + 1;
   while( p < sentinel)
      *p++ = NSDateComponentUndefined;

   return( self);
}

@end
