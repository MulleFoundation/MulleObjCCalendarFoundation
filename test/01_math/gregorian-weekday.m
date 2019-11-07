#include <stdio.h>


static char  *s_wochentag[] =
{
   "So",
   "Mo",
   "Di",
   "Mi",
   "Do",
   "Fr",
   "Sa",
};


int  main( void)
{
   int   year;
   int   daysInYear;
   int   total;
   int   wochentag;

   wochentag = 1; // montag war 1.1.1 (proleptic)

   total = 0;
   for( year = 1; year <= 2001; year++)
   {
      daysInYear  = 365;
      daysInYear += ((year % 4) == 0 && (year % 100) != 0) || ((year % 400) == 0);

      printf( "%s 1.1.%d\n", s_wochentag[ wochentag], year);
      wochentag   = (wochentag + daysInYear) % 7;
   }
   return( 0);
}

