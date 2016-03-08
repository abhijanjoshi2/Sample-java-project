@echo off

echo FF_start_stop

set /p machine="<Dev-int1/Dev-int2>:"
set /p work="<start/stop/restart/status>:"

set result=false

if not %machine% == Dev-int1 set result=true
if not %machine% == Dev-int2 set result=true
if %result% == true (

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
   pscp.exe -q -pw bea123 %work% bea@9.9.1.129:/tmp
   echo "moved to dev-int1" 
) 
if %machine% == Dev-int2 (
   pscp.exe -q -pw bea123 %work% bea@9.9.1.134:/tmp
   echo "moved to dev-int2"
)   

if %work% == start (
   echo please wait while starting FF...
   timeout /t 205 /nobreak
   if %machine% == Dev-int1 (
      pscp -q -pw bea123 bea@9.9.1.129:/tmp/statuses C:\
      type C:\statuses
      del C:\statuses
   )  
   if %machine% == Dev-int2 (
      pscp -q -pw bea123 bea@9.9.1.134:/tmp/statuses C:\
      type C:\statuses
      del C:\statuses
   )
)

if %work% == stop (
   echo Please wait while stopping FF...
   timeout /t 405 /nobreak
   if %machine% == Dev-int1 (
      pscp -q -pw bea123 bea@9.9.1.129:/tmp/statuses C:\
      type C:\statuses
      del C:\statuses
   )  
   if %machine% == Dev-int2 (
      pscp -q -pw bea123 bea@9.9.1.134:/tmp/statuses C:\
      type C:\statuses
      del C:\statuses    
   )
)
   
if %work% == restart (
   echo Please wait while restarting FF...
   timeout /t 405 /nobreak
   if %machine% == Dev-int1 (
      pscp -q -pw bea123 bea@9.9.1.129:/tmp/statuses C:\
      type C:\statuses
      del C:\statuses
      timeout /t 205 /nobreak
      pscp -q -pw bea123 bea@9.9.1.129:/tmp/statuses C:\
      type C:\statuses
      del C:\statuses
    )
   if %machine% == Dev-int2 (
      pscp -q -pw bea123 bea@9.9.1.134:/tmp/statuses C:\
      type C:\statuses
      del C:\statuses
      timeout /t 205 /nobreak
      pscp -q -pw bea123 bea@9.9.1.134:/tmp/statuses C:\
      type C:\statuses
      del C:\statuses

    )
)

if %work% == status (
   echo Please wait while getting the Status of FF...
   timeout /t 20 /nobreak
   if %machine% == Dev-int1 (
      pscp -q -pw bea123 bea@9.9.1.129:/tmp/statuses C:\
      type C:\statuses
      del C:\statuses
   )
   if %machine% == Dev-int2 (
      pscp -q -pw bea123 bea@9.9.1.134:/tmp/statuses C:\
      type C:\statuses
      del C:\statuses
   )     
)        