CXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX           
C                                                                               
C   TIME SUBROUTINES                                                            
c                                                                               
c   lates update:                                                               
c   jan 92 by jh: add date_doy                                                  
c   aug 98      : ----------- version 7.0  check ---------------
c                 add century to output for year in sectim
*                                                                               
*   TIMSEC  - Converts time in year, month, day hour, minutes and seconds       
*             to double precision seconds after 1.1.1900                        
*   SECTIM  - Converts double precision seconds after 1.1.1900 to year,         
*             day-of-year and date                                              
*   DTE     - Converts day-of-year to date (month,day)                          
*   TIMDIF  - Calculates time-difference in double precision seconds of         
*             two input dates (year,month,day,hour,minute,second)               
*   TIMADD  - Adds double precision seconds to date, and returns the new        
*             date                                                              
*   MONTH_DAY Find number of days in a month from month and year                
*                                                                               
*   DATE_DOY  Find doy from date                                                
*-------------------------------------------------------------------------      
*                                                                               
* Routine to convert from time to seconds after 1.1 1900, 00:00:00.00           
*                                                                               
*                                                         Leif Kvamme 9-4-87    
       subroutine TIMSEC (YEAR,MTH,DAY,HR,MIN,SECS,MSECS)                         
*
       implicit none                                                                               
c-- Total seconds to be returned   
       double precision MSECS                  
c--                                
       real             SECS                   
c-- Input date                     
       integer          YR,YEAR,MTH,DAY,HR,MIN      
c-- Flag for leap-year             
       integer          DYR                    
c-- Number of leap-years since 1900
       integer          IYR                    
c-- Number of days in current year 
       integer          YDY                    
*                                    
       yr=year                                           
       if (YEAR .ge. 1900) YR = YEAR - 1900                                         
       DYR = 0                                                                  
       if (mod(YR,4) .eq. 0) DYR = 1                                            
       IYR = YR/4 - DYR                                                         
c-- Seconds to beginning of     
       MSECS = real(IYR*366) + real((YR-IYR)*365) 
c-- current year                
       MSECS = MSECS*86400.0                      
c-- January                     
       if (MTH .eq. 1) YDY = DAY                  
c-- February                    
       if (MTH .eq. 2) YDY = DAY + 31             
c-- ....                        
       if (MTH .eq. 3) YDY = DAY + DYR + 59       
       if (MTH .eq. 4) YDY = DAY + DYR + 90                                     
       if (MTH .eq. 5) YDY = DAY + DYR + 120                                    
       if (MTH .eq. 6) YDY = DAY + DYR + 151                                    
       if (MTH .eq. 7) YDY = DAY + DYR + 181                                    
       if (MTH .eq. 8) YDY = DAY + DYR + 212                                    
       if (MTH .eq. 9) YDY = DAY + DYR + 243                                    
       if (MTH .eq.10) YDY = DAY + DYR + 273                                    
       if (MTH .eq.11) YDY = DAY + DYR + 304                                    
       if (MTH .eq.12) YDY = DAY + DYR + 334                                    
       MSECS = MSECS + real(YDY*86400 + HR*3600 + MIN*60) + SECS                
       return                                                                   
       end                                                                      
*=========================================================================      
* Routine to convert from seconds after year 1900 to time and date              
*  NOTE: Routine calculates only from 1.1.1901 to 31.12.2099                    
*                                                                               
*                                                         Leif Kvamme 21-4-87   
       subroutine SECTIM (MSECS,YR,DOY,MTH,DAY,HR,MIN,SEC)                      
*                   
       implicit none                                                            
c-- Input seconds             
       double precision MSECS                       
c-- Temporary seconds         
       double precision SSEC                        
c-- Seconds per day           
       double precision SECDAY                      
c-- Seconds per year          
       double precision SECYR                       
c--                           
       real             SEC                         
c-- Date and day-time         
       integer          YR, MTH, DAY, HR, MIN       
c--                           
       integer          DOY                         
c-- Leap-year indicators      
       real             IND, SIN                    
c-- Counter                   
       integer          I                           
*                                                                               
       data SECDAY,SECYR /86400.0,31536000.0/                                   
*-------------------------------------------------------------------------      
*  Find year:                                                                   
*                                                                               
      SSEC = 0.0                                                                
      do 1 I = 1,200                                                            
           IND = 0.0                                                            
c-- Leap year                 
           if (mod(I,4) .eq. 0) IND = 1.0           
c-- Add years                 
           SSEC = SSEC + SECYR + IND*SECDAY         
c-- Year found                
           if (SSEC .gt. MSECS) goto 2              
           SIN = IND                                                            
    1  continue                                                                 
    2  YR = I - 1
c
c   make sure century is there
c
       yr=yr+1900
c                                                               
*                                                                               
*  Find day-of-year and date:                                                   
*                                                                               
c-- Reset remaining seconds   
       SSEC = MSECS - (SSEC - SECYR - IND*SECDAY)   
       do 3 I = 1, 366                                                          
           SSEC = SSEC - SECDAY                                                 
           if (SSEC .lt. 0) goto 4                                              
    3  continue                                                                 
    4  I = I - 1                                                                
c-- 366 days of year          
       if (SIN .gt. 0.0) I = I + 1                  
c--                           
       if (I .eq. 0) then                           
c-- Justifying if change      
          YR = YR - 1                               
c-- of year                   
          I  = 365                                  
          if (mod(YR,4) .eq. 0) I = 366                                         
       endif                                                                    
       DOY = I                                                                  
c-- convert from doy to date  
       call DTE (i,DAY,MTH,yr)                      
*                                                                               
*  Find hour:                                                                   
*                                                                               
       SSEC = SSEC + SECDAY                                                     
       do 5 I = 1, 24                                                           
           SSEC = SSEC - 60.0*60.0                                              
           if (SSEC .lt. 0) goto 6                                              
    5  continue                                                                 
    6  HR = I - 1                                                               
*                                                                               
*  Find minutes and remaining seconds:                                          
*                                                                               
       SSEC = SSEC + 60.0*60.0                                                  
       do 7 I = 1, 60                                                           
           SSEC = SSEC - 60.0                                                   
           if (SSEC .lt. 0) goto 8                                              
    7  continue                                                                 
    8  MIN = I - 1                                                              
       SEC = SSEC + 60.0                                                        
       return                                                                   
       end                                                                      
*=========================================================================      
*                                                                               
* Routine to convert from day-of-year to date                                   
*                                                         Leif Kvamme 12-1-85   
       subroutine DTE (DOY,DAY,MON,YR)                                          
*                   
       implicit none                                                            
       integer DOY,DAY,MON,YR,MTH(12),J,M,N                                     
*                                                                               
       do 1 J = 1,7,2                                                           
           MTH(J) = 31                                                          
    1  continue                                                                 
       do 2 J = 8,12,2                                                          
           MTH(J) = 31                                                          
    2  continue                                                                 
       MTH(2) = 28                                                              
       MTH(4) = 30                                                              
       MTH(6) = 30                                                              
       MTH(9) = 30                                                              
       MTH(11)= 30                                                              
       if (mod(YR,4) .eq. 0) MTH(2) = 29                                        
       M = 0                                                                    
       do 3 J = 1,12                                                            
       M = M + MTH(J)                                                           
       N = DOY - M                                                              
       if (N .le. 0) then                                                       
           MON = J                                                              
           DAY = N + MTH(J)                                                     
           goto 4                                                               
       endif                                                                    
    3  continue                                                                 
    4  return                                                                   
       end                                                                      
*==========================================================================     
*                                                                               
* Routine to calculate time-difference in seconds (MSDIF = TIME_1 - TIME_2)     
*                                                                               
*                                                         Leif Kvamme 24-4-87   
       subroutine TIMDIF (YR1,MN1,DA1,HR1,MI1,SC1,                              
     .                    YR2,MN2,DA2,HR2,MI2,SC2,MSDIF)                        
*                   
       implicit none                                                            
c-- Time in seconds        
       double precision SEC1,SEC2                      
c-- Difference (returned)  
       double precision MSDIF                          
       real             SC1, SC2                                                
c-- Time 1                 
       integer          YR1,MN1,DA1,HR1,MI1            
c-- Time 2                 
       integer          YR2,MN2,DA2,HR2,MI2            
*                                                                               
c-- Convert time 2         
       call TIMSEC (yr1,mn1,da1,hr1,mi1,sc1,SEC1)      
c-- Convert time 2         
       call TIMSEC (yr2,mn2,da2,hr2,mi2,sc2,SEC2)      
*                                                                               
c-- Calculate difference   
       MSDIF = SEC1 - SEC2                             
       return                                                                   
       end                                                                      
*___________________________________________________________________            
*                                                                               
* Routine to add time in seconds to date- and day-time (TIME_2 = TIME_1 + MSDIF)
*                                                                               
*                                                         Leif Kvamme 24-4-87   
       subroutine TIMADD (YR1,MN1,DA1,HR1,MI1,SC1,MSDIF,                        
     .                    YR2,MN2,DA2,HR2,MI2,SC2)                              
*                   
       implicit none                                                            
c-- Seconds to be added    
       double precision MSDIF                          
c-- Time in seconds        
       double precision SEC1,SEC2                      
       real             SC1, SC2                                                
c-- Time 1                 
       integer          YR1,MN1,DA1,HR1,MI1            
c-- Time 2 (returned)      
       integer          YR2,MN2,DA2,HR2,MI2,DOY        
*                                                                               
c-- Convert time 1         
       call TIMSEC (yr1,mn1,da1,hr1,mi1,sc1,SEC1)      
*                                                                               
c-- Adding                 
       SEC2 = SEC1 + MSDIF                             
*                                                                               
c-- Reconverting           
       call SECTIM (sec2,YR2,DOY,MN2,DA2,HR2,MI2,SC2)  
       return                                                                   
       end                                                                      
*=========================================================================      
*                                                                               
* Routine to convert from month to number of days in a month                    
*                                                         J. Havskov oct 91     
*                                                         Leif Kvamme 12-1-85   
       subroutine MONTH_DAY(YR,MON,DAY)                                         
*                                                                               
       implicit none                                                            
       integer DAY,MON,YR,MTH(12),J                                             
*                                                                               
       do 1 J = 1,7,2                                                           
           MTH(J) = 31                                                          
    1  continue                                                                 
       do 2 J = 8,12,2                                                          
           MTH(J) = 31                                                          
    2  continue                                                                 
       MTH(2) = 28                                                              
       MTH(4) = 30                                                              
       MTH(6) = 30                                                              
       MTH(9) = 30                                                              
       MTH(11)= 30                                                              
       if (mod(YR,4) .eq. 0) MTH(2) = 29                                        
       DAY=MTH(MON)                                                             
       return                                                                   
       end                                                                      
                                                                                
*=========================================================================      
*                                                                               
* Routine to convert from date to day-of-year                                   
* j. havskov 1992 and Leif Kvamme 12-1-85                                       
*                                                                               
       subroutine DATE_DOY (DOY,DAY,MON,YR)                                     
*  
       implicit none                                                                             
       integer DOY,DAY,MON,YR,MTH(12),J                                     
*                                                                               
       do 1 J = 1,7,2                                                           
           MTH(J) = 31                                                          
    1  continue                                                                 
       do 2 J = 8,12,2                                                          
           MTH(J) = 31                                                          
    2  continue                                                                 
       MTH(2) = 28                                                              
       MTH(4) = 30                                                              
       MTH(6) = 30                                                              
       MTH(9) = 30                                                              
       MTH(11)= 30                                                              
       if (mod(YR,4) .eq. 0) MTH(2) = 29                                        
c                                                                               
       doy=0                                                                    
       do j=1,mon-1                                                             
         doy=doy+mth(j)                                                         
       enddo                                                                    
       doy=doy+day	   		 	                                                      
c                                                                               
       return                                                                   
       end                                                                      
