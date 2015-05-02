call mvn -f pom.xml clean install  if not "%ERRORLEVEL%" == "0" goto error

exit

:error @echo Build Failed pause