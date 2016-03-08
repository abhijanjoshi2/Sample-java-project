@echo off

echo PORTAL_start_stop

set /p machine="<Dev-int1/Dev-int2>:"
set /p work="<start/stop/restart/status>:"

del "C:\%work%" >NUL

fsutil file createnew C:\%work% 100 >NUL

if %machine% == Dev-int1 (
   pscp.exe -q -pw tcatadmin %work% admin@9.9.1.123:/tmp
) 
if %machine% == Dev-int2 (
   pscp.exe -q -pw tcatdemo123 %work% admin@9.9.1.139:/tmp
)   

if %work% == start (
   echo Please wait while starting PORTAL...
   echo ..
   echo .
   echo Please do not CTRL+C
   echo ..
   echo . 
   timeout /t 60 /nobreak
   if %machine% == Dev-int1 (
      pscp -q -pw tcatadmin admin@9.9.1.123:/tmp/statuses C:\
      echo ..
      echo .
      type C:\statuses
      echo ..
      echo CHEERS!! 
      del C:\statuses
   )  
   if %machine% == Dev-int2 (
      pscp -q -pw tcatdemo123 admin@9.9.1.139:/tmp/statuses C:\
      echo ..
      echo .
      type C:\statuses
      echo ..
      echo CHEERS!! 
      timeout /t 15 /nobreak      
      del C:\statuses
   )
)

if %work% == stop (
   echo Please wait while stopping PORTAL...
   echo ..
   echo .
   echo Please do not CTRL+C
   echo ..
   echo . 
   timeout /t 15 /nobreak
   if %machine% == Dev-int1 (
      pscp -q -pw tcatadmin admin@9.9.1.123:/tmp/statuses C:\
      echo ..
      echo .
      type C:\statuses
      echo ..
      echo CHEERS!! 
      del C:\statuses
   )  
   if %machine% == Dev-int2 (
      pscp -q -pw tcatdemo123 admin@9.9.1.139:/tmp/statuses C:\
      echo ..
      echo .
      type C:\statuses
      echo ..
      echo CHEERS!! 
      del C:\statuses    
   )
)
   
if %work% == restart (
   echo Please wait while restarting PORTAL...
   echo ..
   echo .
   echo Please do not CTRL+C
   echo ..
   echo . 
   timeout /t 60 /nobreak
   if %machine% == Dev-int1 (
      pscp -q -pw tcatadmin admin@9.9.1.123:/tmp/statuses C:\
      echo ..
      echo .
      type C:\statuses
      echo ..     
      timeout /t 15 /nobreak
      del C:\statuses
    )
   if %machine% == Dev-int2 (
      pscp -q -pw tcatdemo123 admin@9.9.1.139:/tmp/statuses C:\
      echo ..
      echo .
      type C:\statuses
      echo ..
      echo CHEERS!!
      timeout /t 15 /nobreak
      del C:\statuses

    )
)

if %work% == status (
   echo Please wait while getting the Status of PORTAL...
   echo ..
   echo .
   echo Please do not CTRL+C
   echo ..
   echo . 
   timeout /t 5 /nobreak
   if %machine% == Dev-int1 (
      pscp -q -pw tcatadmin admin@9.9.1.123:/tmp/statuses C:\
      echo ..
      echo .
      type C:\statuses
      echo ..
      echo "CHEERS!!"
      timeout /t 5 /nobreak
      del C:\statuses
   )
   if %machine% == Dev-int2 (
      pscp -q -pw tcatdemo123 admin@9.9.1.139:/tmp/statuses C:\
      echo ..
      echo .
      type C:\statuses
      echo ..
      echo "CHEERS!!"
      timeout /t 5 /nobreak
      del C:\statuses      
   )     
)