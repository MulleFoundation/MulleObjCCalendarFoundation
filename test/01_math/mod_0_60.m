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
      diff   = value / max - 1;
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


int  main( void)
{
   int   i;
   int   value;
   int   diff;

   for( i = -125; i <= 125; i +=5)
   {
      value = i;
      diff  = mod_0_n( &value, 60);
      printf( "%d: mod=%d diff=%d\n", i, value, diff);
   }
   return( 0);
}

