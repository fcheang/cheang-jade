rem Copy this file to your C:\Program File\Apache Software Foundation\Tomcat 5.5\bin directory and run it there 
rem to start the Tomcat in debug mode
set JPDA_TRANSPORT=dt_socket
set JPDA_ADDRESS=8000
catalina jpda start
