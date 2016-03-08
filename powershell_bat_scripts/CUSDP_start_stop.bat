@echo off

echo CUSDP_start_stop

set /p machine="<Dev-int1/Dev-int2>:"
set /p work="<start/stop/restart/status>:"

if ((%machine% unequ Dev-int1) & (%machine% unequ Dev-int2)) (

   echo Please provide right parameter Dev-int1/Dev-int2
   echo Exiting...
   timeout /t 5
)

set result1=false
if not %work% == start set result1=true 
if not %work% == stop set result1=true
if not %work% == restart set result1=true
if not %work% == status set result1=true
if %result1% == true (

   echo Please provide right parameter <start/stop/restart/status>
   echo Exiting...
   timeout /t 5
)

del "C:\%work%" >NUL


fsutil file createnew C:\%work% 100 >NUL

if %machine% == Dev-int1 (
   pscp.exe -q -pw intersys@123 %work% admin@9.9.1.110:/tmp
   echo "moved to dev-int1" 
) 
if %machine% == Dev-int2 (
   pscp.exe -q -pw tcatadmin123 %work% admin@9.9.1.115:/tmp
   echo "moved to dev-int2"
)   

if %work% == start (
   echo please wait while starting CUSDP...
   echo please do not CTRL+C
   timeout /t 60 /nobreak
   if %machine% == Dev-int1 (
      pscp -q -pw intersys@123 admin@9.9.1.110:/tmp/statuses C:\
      type C:\statuses
      del C:\statuses
   )  
   if %machine% == Dev-int2 (
      pscp -q -pw tcatadmin123 admin@9.9.1.115:/tmp/statuses C:\
      type C:\statuses
      del C:\statuses
   )
)

if %work% == stop (
   echo Please wait while stopping CUSDP...
   timeout /t 10 /nobreak
   if %machine% == Dev-int1 (
      pscp -q -pw intersys@123 admin@9.9.1.110:/tmp/statuses C:\
      type C:\statuses
      del C:\statuses
   )  
   if %machine% == Dev-int2 (
      pscp -q -pw tcatadmin123 admin@9.9.1.115:/tmp/statuses C:\
      type C:\statuses
      del C:\statuses    
   )
)
   
if %work% == restart (
   echo Please wait while restarting CUSDP...
   timeout /t 60 /nobreak
   if %machine% == Dev-int1 (
      pscp -q -pw intersys@123 admin@9.9.1.110:/tmp/statuses C:\
      type C:\statuses
      del C:\statuses
      timeout /t 205 /nobreak
      pscp -q -pw tcatadmin123 admin@9.9.1.115:/tmp/statuses C:\
      type C:\statuses
      del C:\statuses
    )
   if %machine% == Dev-int2 (
      pscp -q -pw intersys@123 admin@9.9.1.110:/tmp/statuses C:\
      type C:\statuses
      del C:\statuses
      timeout /t 10 /nobreak
      pscp -q -pw tcatadmin123 admin@9.9.1.115:/tmp/statuses C:\
      type C:\statuses
      del C:\statuses

    )
)

if %work% == status (
   echo Please wait while getting the Status of CUSDP...
   timeout /t 10 /nobreak
   if %machine% == Dev-int1 (
      pscp -q -pw intersys@123 admin@9.9.1.110:/tmp/statuses C:\
      type C:\statuses
      del C:\statuses
   )
   if %machine% == Dev-int2 (
      pscp -q -pw tcatadmin123 admin@9.9.1.115:/tmp/statuses C:\
      type C:\statuses
      del C:\statuses
   )     
)