#include <stdio.h>


int  main( void)
{
   int   year;
   int   daysInYear;
   int   total;

   total = 0;
   for( year = 1; year <= 2001; year++)
   {
     //
      daysInYear = 365;
      if( year < 1582)
         daysInYear += ((year % 4) == 0);
      else
         if( year > 1582)
            daysInYear += ((year % 4) == 0 && (year % 100) != 0) || ((year % 400) == 0);
         else
            daysInYear -= 10;  // 1582 exactly
      total += daysInYear;

      printf( "%d: +%d = %d\n", year, daysInYear, total);
   }
   return( 0);
}

