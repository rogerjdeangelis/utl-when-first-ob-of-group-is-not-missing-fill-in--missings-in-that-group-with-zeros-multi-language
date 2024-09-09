%let pgm=utl-when-first-ob-of-group-is-not-missing-fill-in--missings-in-that-group-with-zeros-multi-language;

When first ob of a group is not missing fill in all missings in that group with zeros

       1  sas datastep
       2  sas sql
       3  r sql
       4  python sql
       5  sas loops
       6  r matrix loops
       7  r dplyr (like a different language)
       8  numary macro on end

github
https://tinyurl.com/482r82k9
https://github.com/rogerjdeangelis/utl-when-first-ob-of-group-is-not-missing-fill-in--missings-in-that-group-with-zeros-multi-language

SOABOX ON

  In fairness R has packages to solve this problem, however
  using packages can often seem like learning a new language?

  The issue with R matrix loop solution

  It took me a while to code the R MATRIX loop solution because

     4 data types (numeric,integer, logical and missing
     3 data structures matrix, dataframe and list

     Different syntax based on data types and data structures
    ie = <- == &&, #L, is.na(is.?), !na  (missings NaN NULL NA na na=rm.na)

    less is more

SOAPBOX OFF


stakoverflow
https://tinyurl.com/bde3n888
https://stackoverflow.com/questions/78959147/identify-the-columns-with-value-and-fill-the-blanks-with-0-only-for-a-defined-ra


related repos

https://tinyurl.com/y963wwh7
https://github.com/rogerjdeangelis/utl-convert-the-numeric-values-in-sas-dataset-to-an-in-memory-two-dimensional-array-multi-language
https://github.com/rogerjdeangelis/utl-converting-your-sas-datastep-programs-to-r
https://github.com/rogerjdeangelis/utl-leveraging-your-knowledge-of-regular-expressions-to-wps-r-python-multi-language
https://github.com/rogerjdeangelis/utl-converting-common-wps-coding-to-r-and-python
https://tinyurl.com/2f5579tt
https://github.com/rogerjdeangelis/utl-classic-r-alternatives-for-the-apply-family-of-functions-on-dataframes-for-sas-programmers
https://github.com/rogerjdeangelis/utl_convert-sas-merge-to-r-code

/*               _     _
 _ __  _ __ ___ | |__ | | ___ _ __ ___
| `_ \| `__/ _ \| `_ \| |/ _ \ `_ ` _ \
| |_) | | | (_) | |_) | |  __/ | | | | |
| .__/|_|  \___/|_.__/|_|\___|_| |_| |_|
|_|
*/

/*********************************************************************************************************************************/
/*                                                                                                                               */
/* DOCUMENTATION FOR NUM2 ONLY (SIMLPE TO HANDLE MUTIPLE NUMS)                                                                   */
/*                                                                                                                               */
/*--------------------------------------------------------------------------------------------------------------------------     */
/*                              |                                            |                                                   */
/* FAMILY    SUB    SIZE   NUM2 | If Size='1H' and NUM2 is Populated         | FAMILY    SUB    SIZE     NUM2                    */
/*                              | replace missings in SUB group with         |                                                   */
/*  POP      ABC     1H     0.5 | zeros                                      |   POP      ABC     1H       0.5                   */
/*  POP      ABC     2H     0.2 |                                            |   POP      ABC     2H       0.2                   */
/*  POP      ABC     3H     0.3 | Data want;                                 |   POP      ABC     3H       0.3                   */
/*  POP      ABC     4H      .  |                                            |   POP      ABC     4H       0.0  zero fill        */
/*  POP      ABC     5H      .  |   retain mis1 mis2 .;                      |   POP      ABC     5H       0.0  zero fill        */
/*                              |                                            |                                                   */
/*  POP      XYZ     1H      .  |   set sd1.have;                            |   POP      XYZ     1H        .  1H missing        */
/*  POP      XYZ     2H      .  |                                            |   POP      XYZ     2H        .  do not fill 0s    */
/*  POP      XYZ     3H      .  |   if size='1H' then do;                    |   POP      XYZ     3H        .                    */
/*  POP      XYZ     4H      .  |     if not missing(num1) then mis1=0;      |   POP      XYZ     4H        .                    */
/*  POP      XYZ     5H      .  |     if not missing(num2) then mis2=0;      |   POP      XYZ     5H        .                    */
/*                              |   end;                                     |                                                   */
/*  QOP      PRQ     1H      .  |                                            |   QOP      PRQ     1H        .  1H missing        */
/*  QOP      PRQ     2H      .  |   num1=coalesce(num1,mis1);                |   QOP      PRQ     2H        .  do not fill 0s    */
/*  QOP      PRQ     3H      .  |   num2=coalesce(num2,mis2);                |   QOP      PRQ     3H        .                    */
/*  QOP      PRQ     4H      .  |   output;                                  |   QOP      PRQ     4H        .                    */
/*  QOP      PRQ     5H      .  |                                            |   QOP      PRQ     5H        .                    */
/*                              |   if size='5H' then                        |                                                   */
/*  QOP      STV     1H     1.0 |       do; mis1=.; mis2=.; end;             |   QOP      STV     1H       1.0                   */
/*  QOP      STV     2H      .  |                                            |   QOP      STV     2H       0.0  zero fill        */
/*  QOP      STV     3H      .  | run;quit;                                  |   QOP      STV     3H       0.0  zero fill        */
/*  QOP      STV     4H      .  |                                            |   QOP      STV     4H       0.0  zero fill        */
/*  QOP      STV     5H      .  |                                            |   QOP      STV     5H       0.0  zero fill        */
/*                              |                                            |                                                   */
/*-------------------------------------------------------------------------------------------------------------------------------*/
/*                                                                                                                               */
/*  SIMILAR SAS AND R CODE (I FIND IT UEFULL TO CODE THE ALGORITH IN SAS AND THEN IN R                                           */
/*  SAS IS AN EXCELLENT PROTO-TYPING LANGUAGE (loops are faster in python)                                                       */
/*                                                                                                                               */
/*-------------------------------------------------------------------------------------------------------------------------------*/
/*                                                            |                                                                  */
/*  SAS LOOP                                                  | R (using suffix #L is a good programming practice?)               */
/*                                                            |                                                                  */
/*  * BUILD SAS ARRAY;                                        | It took me a while to code this because                          */
/*                                                            |   4 data types (numeric,integer, logical and missing types       */
/*  %utl_numary(sd1.have,drop=Family Sub Size);               |   3 data structures matrix, dataframe and list                   */
/*                                                            |  These seven issues sometimes require odd sytax                  */
/*  data want;                                                |     ie == &&, #L, is.na, !na  (NaN NULL NA na na=rm.na)          */
/*               /* creates [20,2] (.,0.5,.,0.2 etc) */       |                                                                  */
/*    array n1n2 %utl_numary(sd1.have,drop=Family Sub Size);  |  mat<-unname(as.matrix(have[,4:5]))                              */
/*                                                            |                                                                  */
/*    do j=1 to 2;                                            |  for ( j in seq(1,2,1) )    {                                    */
/*      do g=1 to 5;                                          |    for ( size in seq(1,5,1) ) {                                  */
/*        do k=0 to 15 by 5;                                  |      for ( k in seq(0,15,5)   )  {                               */
/*                                                            |                                                                  */
/*         mis=.;                                             |        mis<-1L                                                   */
/*         if not missing(n1n2[k+1,j]) then mis=0;            |        if (!is.na(mat[k+1,j])) { mis<-0L }                       */
/*         n1n2[g+k,j]=sum(mis,n1n2[g+k,j]);                  |        if (is.na(mat[size+k,j]) && mis==0L) {mat[size+k,j]=0.0}  */
/*       end;                                                 |      }                                                           */
/*      end;                                                  |    }                                                             */
/*    end;                                                    |  }                                                               */
/*                                                            |                                                                  */
/*    do row=1 to 20;                                         |                                                                  */
/*        set sd1.have(drop=num:) point=row;                  |  chr<-have[,1:3]                                                 */
/*        num1 = n1n2[row,1];                                 |  rwant<-cbind(chr,mat);                                          */
/*        num2 = n1n2[row,2];                                 |  colnames(rwant)[4:5] <- c('NUM1','NUM2')                        */
/*        keep  Family Sub Size  Num1  Num2;                  |                                                                  */
/*        output;                                             |                                                                  */
/*    end;                                                    |                                                                  */
/*                                                            |                                                                  */
/*    stop;                                                   |                                                                  */
/*  run;quit;                                                 |                                                                  */
/*                                                            |                                                                  */
/*********************************************************************************************************************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/
data sd1.have;
  input Family $ Sub $ Size $  Num1  Num2;
cards4;
POP ABC 1H .    0.5
POP ABC 2H .    0.2
POP ABC 3H .    0.3
POP ABC 4H .    .
POP ABC 5H .    .
POP XYZ 1H 0.25 .
POP XYZ 2H 0.25 .
POP XYZ 3H 0.25 .
POP XYZ 4H 0.25 .
POP XYZ 5H .    .
QOP PRQ 1H .    .
QOP PRQ 2H .    .
QOP PRQ 3H .    .
QOP PRQ 4H .    .
QOP PRQ 5H .    .
QOP STV 1H .    1
QOP STV 2H .    .
QOP STV 3H .    .
QOP STV 4H .    .
QOP STV 5H .    .
;;;;
run;quit;

/**************************************************************************************************************************/
/*                                                                                                                        */
/* SD1.HAVE total obs=20                                                                                                  */
/*                                                                                                                        */
/*  FAMILY    SUB    SIZE    NUM1    NUM2                                                                                 */
/*                                                                                                                        */
/*   POP      ABC     1H      .       0.5                                                                                 */
/*   POP      ABC     2H      .       0.2                                                                                 */
/*   POP      ABC     3H      .       0.3                                                                                 */
/*   POP      ABC     4H      .        .                                                                                  */
/*   POP      ABC     5H      .        .                                                                                  */
/*   POP      XYZ     1H     0.25      .                                                                                  */
/*   POP      XYZ     2H     0.25      .                                                                                  */
/*   POP      XYZ     3H     0.25      .                                                                                  */
/*   POP      XYZ     4H     0.25      .                                                                                  */
/*   POP      XYZ     5H      .        .                                                                                  */
/*   QOP      PRQ     1H      .        .                                                                                  */
/*   QOP      PRQ     2H      .        .                                                                                  */
/*   QOP      PRQ     3H      .        .                                                                                  */
/*   QOP      PRQ     4H      .        .                                                                                  */
/*   QOP      PRQ     5H      .        .                                                                                  */
/*   QOP      STV     1H      .       1.0                                                                                 */
/*   QOP      STV     2H      .        .                                                                                  */
/*   QOP      STV     3H      .        .                                                                                  */
/*   QOP      STV     4H      .        .                                                                                  */
/*   QOP      STV     5H      .        .                                                                                  */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*                       _       _            _
/ |  ___  __ _ ___    __| | __ _| |_ __ _ ___| |_ ___ _ __
| | / __|/ _` / __|  / _` |/ _` | __/ _` / __| __/ _ \ `_ \
| | \__ \ (_| \__ \ | (_| | (_| | || (_| \__ \ ||  __/ |_) |
|_| |___/\__,_|___/  \__,_|\__,_|\__\__,_|___/\__\___| .__/
                                                     |_|
*/

proc datasets lib=work nodetails nolist;delete want;run;quit;

Data want;

  retain mis1 mis2 .;

  set sd1.have;

  if size='1H' then do;
    if not missing(num1) then mis1=0;
    if not missing(num2) then mis2=0;
  end;

  num1=coalesce(num1,mis1);
  num2=coalesce(num2,mis2);
  output;

  if size='5H' then
      do; mis1=.; mis2=.; end;

  drop mis1 mis2;

run;quit;


/**************************************************************************************************************************/
/*                                                                                                                        */
/* SD1.HAVE total obs=20                                                                                                  */
/*                                                                                                                        */
/*  FAMILY    SUB    SIZE    NUM1    NUM2                                                                                 */
/*                                                                                                                        */
/*   POP      ABC     1H      .       0.5                                                                                 */
/*   POP      ABC     2H      .       0.2                                                                                 */
/*   POP      ABC     3H      .       0.3                                                                                 */
/*   POP      ABC     4H      .       0.0                                                                                 */
/*   POP      ABC     5H      .       0.0                                                                                 */
/*   POP      XYZ     1H     0.25      .                                                                                  */
/*   POP      XYZ     2H     0.25      .                                                                                  */
/*   POP      XYZ     3H     0.25      .                                                                                  */
/*   POP      XYZ     4H     0.25      .                                                                                  */
/*   POP      XYZ     5H     0.00      .                                                                                  */
/*   QOP      PRQ     1H      .        .                                                                                  */
/*   QOP      PRQ     2H      .        .                                                                                  */
/*   QOP      PRQ     3H      .        .                                                                                  */
/*   QOP      PRQ     4H      .        .                                                                                  */
/*   QOP      PRQ     5H      .        .                                                                                  */
/*   QOP      STV     1H      .       1.0                                                                                 */
/*   QOP      STV     2H      .       0.0                                                                                 */
/*   QOP      STV     3H      .       0.0                                                                                 */
/*   QOP      STV     4H      .       0.0                                                                                 */
/*   QOP      STV     5H      .       0.0                                                                                                                     */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*___                              _
|___ \   ___  __ _ ___   ___  __ _| |
  __) | / __|/ _` / __| / __|/ _` | |
 / __/  \__ \ (_| \__ \ \__ \ (_| | |
|_____| |___/\__,_|___/ |___/\__, |_|
                                |_|
*/

proc datasets lib=work nodetails nolist;delete want;run;quit;

proc sql;
  create
     table want as
  select
     l.Family
    ,l.Sub
    ,l.Size
    ,case
       when (missing(l.num1)
         and not missing(r.num1)) then 0
       else coalesce(l.num1)
     end as num1
    ,case
       when (missing(l.num2)
         and not missing(r.num2)) then 0
       else coalesce(l.num2)
     end as num2
  from
     sd1.have as l left join sd1.have as r
  on
     l.sub = r.sub
  where
     strip(r.size)='1H'  /* attach IH num1 and num2 to each group */
  order
     by family, sub, size
;quit;

/**************************************************************************************************************************/
/*  SAME OUTPUT                                                                                                           */
/**************************************************************************************************************************/

/*____                    _
|___ /   _ __   ___  __ _| |
  |_ \  | `__| / __|/ _` | |
 ___) | | |    \__ \ (_| | |
|____/  |_|    |___/\__, |_|
                       |_|
*/
proc datasets lib=work nodetails nolist;delete rwant;run;quit;

%utl_rbeginx;
parmcards4;
library(sqldf)
library(haven)
source("c:/oto/fn_tosas9x.R")
have<-read_sas("d:/sd1/have.sas7bdat")
rwant<-sqldf('
  select
     l.Family
    ,l.Sub
    ,l.Size
    ,case
       when (l.num1 is null and
           r.num1 is not null ) then 0
       else l.num1
     end as num1
    ,case
       when (l.num2 is null and
           r.num2 is not null  ) then 0
       else l.num2
     end as num2
  from
     have as l left join have as r
  on
     l.sub = r.sub
  where
     r.size="1H"
  order
     by l.family, l.sub, l.size
  ')
rwant
fn_tosas9x(
      inp    = rwant
     ,outlib ="d:/sd1/"
     ,outdsn ="want"
     )
;;;;
%utl_rendx;

libname sd1 "d:/sd1";
proc print data=sd1.want;
run;quit;

/**************************************************************************************************************************/
/*                                       |                                                                                */
/* R                                     |                                                                                */
/*                                       |      SAS                                                                       */
/*   rwant                               |                                                                                */
/*    FAMILY SUB SIZE num1 num2          |       ROWNAMES    FAMILY    SUB    SIZE    NUM1    NUM2                        */
/*                                       |                                                                                */
/*       POP ABC   1H   NA  0.5          |           1        POP      ABC     1H      .       0.5                        */
/*       POP ABC   2H   NA  0.2          |           2        POP      ABC     2H      .       0.2                        */
/*       POP ABC   3H   NA  0.3          |           3        POP      ABC     3H      .       0.3                        */
/*       POP ABC   4H   NA  0.0          |           4        POP      ABC     4H      .       0.0                        */
/*       POP ABC   5H   NA  0.0          |           5        POP      ABC     5H      .       0.0                        */
/*       POP XYZ   1H 0.25   NA          |           6        POP      XYZ     1H     0.25      .                         */
/*       POP XYZ   2H 0.25   NA          |           7        POP      XYZ     2H     0.25      .                         */
/*       POP XYZ   3H 0.25   NA          |           8        POP      XYZ     3H     0.25      .                         */
/*       POP XYZ   4H 0.25   NA          |           9        POP      XYZ     4H     0.25      .                         */
/*       POP XYZ   5H 0.00   NA          |          10        POP      XYZ     5H     0.00      .                         */
/*       QOP PRQ   1H   NA   NA          |          11        QOP      PRQ     1H      .        .                         */
/*       QOP PRQ   2H   NA   NA          |          12        QOP      PRQ     2H      .        .                         */
/*       QOP PRQ   3H   NA   NA          |          13        QOP      PRQ     3H      .        .                         */
/*       QOP PRQ   4H   NA   NA          |          14        QOP      PRQ     4H      .        .                         */
/*       QOP PRQ   5H   NA   NA          |          15        QOP      PRQ     5H      .        .                         */
/*       QOP STV   1H   NA  1.0          |          16        QOP      STV     1H      .       1.0                        */
/*       QOP STV   2H   NA  0.0          |          17        QOP      STV     2H      .       0.0                        */
/*       QOP STV   3H   NA  0.0          |          18        QOP      STV     3H      .       0.0                        */
/*       QOP STV   4H   NA  0.0          |          19        QOP      STV     4H      .       0.0                        */
/*       QOP STV   5H   NA  0.0          |          20        QOP      STV     5H      .       0.0                        */
/*                                       |                                                                                */
/**************************************************************************************************************************/

/*  _                 _   _                             _
| || |    _ __  _   _| |_| |__   ___  _ __    ___  __ _| |
| || |_  | `_ \| | | | __| `_ \ / _ \| `_ \  / __|/ _` | |
|__   _| | |_) | |_| | |_| | | | (_) | | | | \__ \ (_| | |
   |_|   | .__/ \__, |\__|_| |_|\___/|_| |_| |___/\__, |_|
         |_|    |___/                                |_|
*/

ibname tmp "c:/temp";
proc datasets lib=tmp nodetails nolist;delete want;run;quit;

%utl_pybeginx;
parmcards4;
import pyperclip
import os
from os import path
import sys
import subprocess
import time
import pandas as pd
import pyreadstat as ps
import numpy as np
import pandas as pd
from pandasql import sqldf
mysql = lambda q: sqldf(q, globals())
from pandasql import PandaSQL
pdsql = PandaSQL(persist=True)
sqlite3conn = next(pdsql.conn.gen).connection.connection
sqlite3conn.enable_load_extension(True)
sqlite3conn.load_extension('c:/temp/libsqlitefunctions.dll')
mysql = lambda q: sqldf(q, globals())
have, meta = ps.read_sas7bdat("d:/sd1/have.sas7bdat")
exec(open('c:/temp/fn_tosas9.py').read())
print(have);
want = pdsql("""
  select
     l.Family
    ,l.Sub
    ,l.Size
    ,case
       when (l.num1 is null and
           r.num1 is not null ) then 0
       else l.num1
     end as num1
    ,case
       when (l.num2 is null and
           r.num2 is not null  ) then 0
       else l.num2
     end as num2
  from
     have as l left join have as r
  on
     l.sub = r.sub
  where
     r.size="1H"
  order
     by l.family, l.sub, l.size
""")
print(want)
fn_tosas9(
   want
   ,dfstr="want"
   ,timeest=3
   )
;;;;
%utl_pyendx;

libname tmp "c:/temp";
proc print data=tmp.want;
run;quit;

 /**************************************************************************************************************************/
 /*                                     |                                                                                  */
 /* PYTHON                              |    SAS                                                                           */
 /*                                     |                                                                                  */
 /*    FAMILY  SUB SIZE  num1  num2     |    FAMILY    SUB    SIZE    NUM1    NUM2                                         */
 /*                                     |                                                                                  */
 /* 0     POP  ABC   1H   NaN   0.5     |     POP      ABC     1H      .       0.5                                         */
 /* 1     POP  ABC   2H   NaN   0.2     |     POP      ABC     2H      .       0.2                                         */
 /* 2     POP  ABC   3H   NaN   0.3     |     POP      ABC     3H      .       0.3                                         */
 /* 3     POP  ABC   4H   NaN   0.0     |     POP      ABC     4H      .       0.0                                         */
 /* 4     POP  ABC   5H   NaN   0.0     |     POP      ABC     5H      .       0.0                                         */
 /* 5     POP  XYZ   1H  0.25   NaN     |     POP      XYZ     1H     0.25      .                                          */
 /* 6     POP  XYZ   2H  0.25   NaN     |     POP      XYZ     2H     0.25      .                                          */
 /* 7     POP  XYZ   3H  0.25   NaN     |     POP      XYZ     3H     0.25      .                                          */
 /* 8     POP  XYZ   4H  0.25   NaN     |     POP      XYZ     4H     0.25      .                                          */
 /* 9     POP  XYZ   5H  0.00   NaN     |     POP      XYZ     5H     0.00      .                                          */
 /* 10    QOP  PRQ   1H   NaN   NaN     |     QOP      PRQ     1H      .        .                                          */
 /* 11    QOP  PRQ   2H   NaN   NaN     |     QOP      PRQ     2H      .        .                                          */
 /* 12    QOP  PRQ   3H   NaN   NaN     |     QOP      PRQ     3H      .        .                                          */
 /* 13    QOP  PRQ   4H   NaN   NaN     |     QOP      PRQ     4H      .        .                                          */
 /* 14    QOP  PRQ   5H   NaN   NaN     |     QOP      PRQ     5H      .        .                                          */
 /* 15    QOP  STV   1H   NaN   1.0     |     QOP      STV     1H      .       1.0                                         */
 /* 16    QOP  STV   2H   NaN   0.0     |     QOP      STV     2H      .       0.0                                         */
 /* 17    QOP  STV   3H   NaN   0.0     |     QOP      STV     3H      .       0.0                                         */
 /* 18    QOP  STV   4H   NaN   0.0     |     QOP      STV     4H      .       0.0                                         */
 /* 19    QOP  STV   5H   NaN   0.0     |     QOP      STV     5H      .       0.0                                         */
 /*                                     |                                                                                  */
 /**************************************************************************************************************************/

/*___                    _
| ___|   ___  __ _ ___  | | ___   ___  _ __  ___
|___ \  / __|/ _` / __| | |/ _ \ / _ \| `_ \/ __|
 ___) | \__ \ (_| \__ \ | | (_) | (_) | |_) \__ \
|____/  |___/\__,_|___/ |_|\___/ \___/| .__/|___/
                                      |_|
*/

proc datasets lib=work nodetails nolist;delete rwant;run;quit;

 data want;
              /* creates [20,2] (.,0.5,.,0.2 etc) */
   array n1n2 %utl_numary(sd1.have,drop=Family Sub Size);

   do j=1 to 2;
     do g=1 to 5;
       do k=0 to 15 by 5;

        mis=.;
        if not missing(n1n2[k+1,j]) then mis=0;
        n1n2[g+k,j]=sum(mis,n1n2[g+k,j]);
      end;
     end;
   end;

   do row=1 to 20;
       set sd1.have(drop=num:) point=row;
       num1 = n1n2[row,1];
       num2 = n1n2[row,2];
       keep  Family Sub Size  Num1  Num2;
       output;
   end;

   stop;
 run;quit;

proc print data=want;
run;quit;

/**************************************************************************************************************************/
/*  SAME OUTPUT                                                                                                           */
/**************************************************************************************************************************/

/*__                            _        _        _
 / /_    _ __   _ __ ___   __ _| |_ _ __(_)_  __ | | ___   ___  _ __  ___
| `_ \  | `__| | `_ ` _ \ / _` | __| `__| \ \/ / | |/ _ \ / _ \| `_ \/ __|
| (_) | | |    | | | | | | (_| | |_| |  | |>  <  | | (_) | (_) | |_) \__ \
 \___/  |_|    |_| |_| |_|\__,_|\__|_|  |_/_/\_\ |_|\___/ \___/| .__/|___/
                                                               |_|
*/

proc datasets lib=sd1 nodetails nolist;delete rwant;run;quit;

%utl_rbeginx;
parmcards4;
library(haven)
source("c:/oto/fn_tosas9x.R")
have<-read_sas("d:/sd1/have.sas7bdat")
mat<-unname(as.matrix(have[,4:5]))
mat
 for ( j in seq(1,2,1) )    {
   for ( size in seq(1,5,1) ) {
     for ( k in seq(0,15,5)   )  {
       mis<-1L
       if (!is.na(mat[k+1,j])) { mis<-0L }
       if (is.na(mat[size+k,j])  && mis==0L ) { mat[size+k,j]=0.0 }
       print(paste(j,size,mis,mat[size+k,j]))
     }
    }
  }
mat
chr<-have[,1:3]
rwant<-cbind(chr,mat);
colnames(rwant)[4:5] <- c('NUM1','NUM2')
str(rwant);
rwant
fn_tosas9x(
      inp    = rwant
     ,outlib ="d:/sd1/"
     ,outdsn ="rwant"
     )
;;;;
%utl_rendx;

libname sd1 "d:/sd1";
proc print data=sd1.rwant;
run;quit;

/**************************************************************************************************************************/
/*                                   |                                                                                    */
/*  R                                |    SAS                                                                             */
/*                                   |                                                                                    */
/*  > rwant                          |                                                                                    */
/*     FAMILY SUB SIZE NUM1 NUM2     |    ROWNAMES    FAMILY    SUB    SIZE    NUM1    NUM2                               */
/*                                   |                                                                                    */
/*  1     POP ABC   1H   NA  0.5     |        1        POP      ABC     1H      .       0.5                               */
/*  2     POP ABC   2H   NA  0.2     |        2        POP      ABC     2H      .       0.2                               */
/*  3     POP ABC   3H   NA  0.3     |        3        POP      ABC     3H      .       0.3                               */
/*  4     POP ABC   4H   NA  0.0     |        4        POP      ABC     4H      .       0.0                               */
/*  5     POP ABC   5H   NA  0.0     |        5        POP      ABC     5H      .       0.0                               */
/*  6     POP XYZ   1H 0.25   NA     |        6        POP      XYZ     1H     0.25      .                                */
/*  7     POP XYZ   2H 0.25   NA     |        7        POP      XYZ     2H     0.25      .                                */
/*  8     POP XYZ   3H 0.25   NA     |        8        POP      XYZ     3H     0.25      .                                */
/*  9     POP XYZ   4H 0.25   NA     |        9        POP      XYZ     4H     0.25      .                                */
/*  10    POP XYZ   5H 0.00   NA     |       10        POP      XYZ     5H     0.00      .                                */
/*  11    QOP PRQ   1H   NA   NA     |       11        QOP      PRQ     1H      .        .                                */
/*  12    QOP PRQ   2H   NA   NA     |       12        QOP      PRQ     2H      .        .                                */
/*  13    QOP PRQ   3H   NA   NA     |       13        QOP      PRQ     3H      .        .                                */
/*  14    QOP PRQ   4H   NA   NA     |       14        QOP      PRQ     4H      .        .                                */
/*  15    QOP PRQ   5H   NA   NA     |       15        QOP      PRQ     5H      .        .                                */
/*  16    QOP STV   1H   NA  1.0     |       16        QOP      STV     1H      .       1.0                               */
/*  17    QOP STV   2H   NA  0.0     |       17        QOP      STV     2H      .       0.0                               */
/*  18    QOP STV   3H   NA  0.0     |       18        QOP      STV     3H      .       0.0                               */
/*  19    QOP STV   4H   NA  0.0     |       19        QOP      STV     4H      .       0.0                               */
/*  20    QOP STV   5H   NA  0.0     |       20        QOP      STV     5H      .       0.0                               */
/*                                   |                                                                                    */
/**************************************************************************************************************************/



library(dplyr)
df %>%
  mutate(
    across(
      starts_with("Num"),
      ~ if (!all(is.na(.x))) replace_na(.x, 0) else .x
    ),
    .by = c(Family, `Sub Family`)
  )

proc datasets lib=sd1 nodetails nolist;delete rwant;run;quit;

%utl_rbeginx;
parmcards4;
library(tidyverse)
library(haven)
source("c:/oto/fn_tosas9x.R")
have<-read_sas("d:/sd1/have.sas7bdat")
have;
rwant <-have %>%
  mutate(
    across(
      starts_with("NUM"),
      ~ if (!all(is.na(.x))) replace_na(.x, 0) else .x
    ),
    .by = c(FAMILY, SUB)
  )
rwant
fn_tosas9x(
      inp    = rwant
     ,outlib ="d:/sd1/"
     ,outdsn ="rwant"
     )
;;;;
%utl_rendx;

libname sd1 "d:/sd1";
proc print data=sd1.rwant;
run;quit;

/**************************************************************************************************************************/
/*  SAME OUTPUT                                                                                                           */
/**************************************************************************************************************************/
/*___
 ( _ )   _ __ ___   __ _  ___ _ __ ___   _ __  _   _ _ __ ___   __ _ _ __ _   _
 / _ \  | `_ ` _ \ / _` |/ __| `__/ _ \ | `_ \| | | | `_ ` _ \ / _` | `__| | | |
| (_) | | | | | | | (_| | (__| | | (_) || | | | |_| | | | | | | (_| | |  | |_| |
 \___/  |_| |_| |_|\__,_|\___|_|  \___/ |_| |_|\__,_|_| |_| |_|\__,_|_|   \__, |
                                                                          |___/
*/
%macro utl_numary(_inp,drop=trt);
/*
 %let _inp=sd1.have;
 %let drop=i j;
*/
 %symdel _array / nowarn;
 %dosubl(%nrstr(
 filename clp clipbrd lrecl=64000;
 data _null_;
 file clp;
 set &_inp(drop=&drop) nobs=rows;
 array ns _numeric_;
 call symputx('rowcol',catx(',',rows,dim(ns)));
 put (_numeric_) ($) @@;
 run;quit;
 %put &=rowcol;
 data _null_;
 length res $32756;
 infile clp;
 input;
 res=cats("[&rowcol] (",translate(_infile_,',',' '),')');
 call symputx('_array',res);
 run;quit;
 ))
 &_array
%mend utl_numary;


/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
