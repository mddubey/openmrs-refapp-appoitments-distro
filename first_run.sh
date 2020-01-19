#!/bin/sh
echo "Installing bahmni appointments omod"
docker exec -it openmrs  wget -q http://repo.mybahmni.org.s3.amazonaws.com/artifactory/snapshot/org/openmrs/module/appointments-omod/1.2-SNAPSHOT/appointments-omod-1.2-20200117.125039-13.jar -O /usr/local/tomcat/.OpenMRS/modules/appointments-1.2-SNAPSHOT.omod
echo "Installing bahmni commons omod"
docker exec -it openmrs  wget -q https://oss.sonatype.org/service/local/repositories/snapshots/content/org/bahmni/module/bahmni-commons-omod/0.1-SNAPSHOT/bahmni-commons-omod-0.1-20191115.054314-3.jar -O /usr/local/tomcat/.OpenMRS/modules/bahmnicommons-0.1-SNAPSHOT.omod
echo "Installing atomfeed omod"
docker exec -it openmrs  wget -q https://oss.sonatype.org/service/local/repositories/releases/content/org/ict4h/openmrs/openmrs-atomfeed-omod/2.5.6/openmrs-atomfeed-omod-2.5.6.jar -O /usr/local/tomcat/.OpenMRS/modules/openmrs-atomfeed-omod-2.5.6.omod
echo "Installing reference metadata 2.10.0 omod"
docker exec -it openmrs  wget -q https://openmrs.jfrog.io/openmrs/public/org/openmrs/module/referencemetadata-omod/2.10.0-SNAPSHOT/referencemetadata-omod-2.10.0-20191028.191253-81.jar -O /usr/local/tomcat/.OpenMRS/modules/referencemetadata-2.10.0-SNAPSHOT.omod
echo "Installing reporting 1.19.0 omod"
docker exec -it openmrs  wget -q https://openmrs.jfrog.io/openmrs/public/org/openmrs/module/reporting-omod/1.19.0/reporting-omod-1.19.0.jar -O /usr/local/tomcat/.OpenMRS/modules/reporting-1.19.0.omod
echo "Installing bahmni appointments owa"
docker exec -it openmrs  wget -q https://bintray.com/openmrs/owa/download_file?file_path=appointments-1.0.0.zip -O /usr/local/tomcat/.OpenMRS/owa/appointments.zip
docker exec -it openmrs  unzip -q /usr/local/tomcat/.OpenMRS/owa/appointments.zip -d /usr/local/tomcat/.OpenMRS/owa/appointments
docker exec -it openmrs  rm -f /usr/local/tomcat/.OpenMRS/owa/appointments.zip
echo "Removing existing appointmentscheduling and other not compatible omods"
docker exec -it openmrs  rm -f /usr/local/tomcat/webapps/openmrs/WEB-INF/bundledModules/appointmentscheduling-1.10.0.omod
docker exec -it openmrs  rm -f /usr/local/tomcat/webapps/openmrs/WEB-INF/bundledModules/appointmentschedulingui-1.7.0.omod
docker exec -it openmrs  rm -f /usr/local/tomcat/webapps/openmrs/WEB-INF/bundledModules/referencemetadata-2.9.0.omod
docker exec -it openmrs  rm -f /usr/local/tomcat/webapps/openmrs/WEB-INF/bundledModules/referencedemodata-1.4.4.omod
docker exec -it openmrs  rm -f /usr/local/tomcat/webapps/openmrs/WEB-INF/bundledModules/reporting-1.17.0.omod
docker exec -it openmrs  rm -f /usr/local/tomcat/webapps/openmrs/WEB-INF/bundledModules/chartsearch-2.1.0.omod

echo "Copying configuration and translations"
docker cp bahmniapps openmrs:/usr/local/tomcat/.OpenMRS/owa/

echo "Configure configuration and translations path"
docker exec -it openmrs sed -i 's/openmrs\/frontend/openmrs\/owa/' /usr/local/tomcat/.OpenMRS/owa/appointments/constants/ng-constants.json
docker cp bahmniapps openmrs:/usr/local/tomcat/.OpenMRS/owa/

echo "Update global propeties for appointments"
#Since properties will be created only after omods have been run once, we will do an INSERT INTO instead of Update
docker exec -it mysql mysql -uopenmrs -ppassword openmrs -e "INSERT INTO global_property(property, property_value, description, uuid) values ('bahmni.appointments.runningOnOpenMRS', 'true', 'If set to true, the appointments ui will run independent of bahmni core', uuid());INSERT INTO global_property(property, property_value, description, uuid) values ('bahmni.primaryIdentifierType', '05a29f94-c0ed-11e2-94be-8c13b969e334', 'Primary identifier type for looking up patients, generating barcodes, etc.', uuid());"

echo "Give admin user a username"
docker exec -it mysql mysql -uopenmrs -ppassword openmrs -e "UPDATE users SET username ='admin' WHERE system_id = 'admin';"

echo "Give admin user appointment privileges"
docker exec -it mysql mysql -uopenmrs -ppassword openmrs -e "INSERT INTO role values('Bahmni Role', 'Role for bahmni Appointments', uuid());"

docker exec -it mysql mysql -uopenmrs -ppassword openmrs -e "INSERT INTO role_privilege values('Bahmni Role', 'Manage Appointments');"
docker exec -it mysql mysql -uopenmrs -ppassword openmrs -e "INSERT INTO role_privilege values('Bahmni Role', 'Manage Appointment Services');"
docker exec -it mysql mysql -uopenmrs -ppassword openmrs -e "INSERT INTO role_privilege values('Bahmni Role', 'Manage Appointment Specialities');"

docker exec -it mysql mysql -uopenmrs -ppassword openmrs -e "INSERT INTO user_role values(1, 'Bahmni Role');"

echo "Restarting the server"
docker-compose restart openmrs-referenceapplication 


