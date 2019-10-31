#include <stdio.h>
#include <assert.h>


static int  mod_0_n( int *p_value, int max)
{
   int   diff;
   int   value;

   diff  = 0;
   value = *p_value;

   if( value < 0)
   {
      diff  = value / max - 1;
      value %= max;
      if( value)
         value += max;
   }
   else
      if( value >= max)
      {
         diff   = value / max;
         value %= max;
      }

   *p_value = value;
   return( diff);
}


static int  mod_1_13( int *value)
{
   int   diff;

   *value -= 1;
   diff    = mod_0_n( value, 12);
   *value += 1;

   assert( *value >= 1 && *value <= 12);

   return( diff);
}

int  main( void)
{
   int   i;
   int   value;
   int   diff;

   for( i = -25; i <= 25; i++)
   {
      value = i;
      diff  = mod_1_13( &value);
      printf( "%d: mod=%d diff=%d\n", i, value, diff);
   }
   return( 0);
}

