OpenMRS RefApp Appointments Distro
==================================
Bahmni appointments on OpenMRS RefApp. 

## How to setup
It has been tested on top of refapp in a docker environment. To start with an automated docker environment please refer to the [Docker Setup](https://github.com/mddubey/openmrs-refapp-appoitments-distro#Docker-Setup) section.   

Following are things needs to be done on top of the refapp distro to support the bahmni appointments.

#### Install Bahmni Appointments omods and dependencies
We will need to install below modules to be able to run bahmni appointments omod
* [Bahmni Appointments omod](http://repo.mybahmni.org.s3.amazonaws.com/artifactory/snapshot/org/openmrs/module/appointments-omod/1.2-SNAPSHOT/)
* [Bahmni Commons omod](https://oss.sonatype.org/service/local/repositories/snapshots/content/org/bahmni/module/bahmni-commons-omod/0.1-SNAPSHOT/)
* [Atomfeed omod](https://oss.sonatype.org/service/local/repositories/releases/content/org/ict4h/openmrs/openmrs-atomfeed-omod/2.5.6/)

For compatibility reasons we need to upgrade reference-metadata omod to >= 2.10.0-SNAPSHOT and its dependencies
* [Reference Metadata omod 2.10.0-SNAPSHOT](https://openmrs.jfrog.io/openmrs/public/org/openmrs/module/referencemetadata-omod/2.10.0-SNAPSHOT/)
* [Reporting Omod 1.19.0](https://openmrs.jfrog.io/openmrs/public/org/openmrs/module/reporting-omod/1.19.0/)
  

We will need to uninstall below modules because they have conflicts with appointments module or have been upgraded. Refer to this thread to know more details.(https://talk.openmrs.org/t/running-bahmni-appointments-scheduling-on-openmrs/24935)
* Appointment Scheduling Module
* Appointment Scheduling UI Module
* Reference Demo Data Module
* Chart Search Module
* Reference Demo Data Module < 2.9.0

#### Install Bahmni Appointments owa
Bahmni appointments openmrs owa can be downloaded from [openmrs bintray](https://bintray.com/openmrs/owa/openmrs-owa-bahmni-appointments).
We need to put this in the `<openmrs_data_dir>/owa` folder. 
      

### Setup openmrs server to serve static JSON files
The bahmni appointments ui expects configurations and translations to be served as static JSON files. 

* Path to a folder containing configurations for appointments UI. See the expected folder structure [here](https://github.com/mddubey/openmrs-refapp-appoitments-distro/tree/master/bahmniapps/config)
* Path to a folder containing translations for appointments UI. See the expected folder structure [here](https://github.com/mddubey/openmrs-refapp-appoitments-distro/tree/master/bahmniapps/i18n)

These URLs to serve these folders can be configured in a JSON file in OWA. In json file `appointments-owa/constants/ng-constants.json`
* `Common.Constants.baseUrl` will be path to configurations folder.
* `Common.Constants.customLocaleURL` will be path to translations folder.

E.g. If we have configured `Common.Constants.baseUrl` to be `/openmrs/config/` then the UI will expect the configuration folder to be present as http://<host>/openmrs/config/

### Update global properties for appointments
* The global property `Admin => Settings => Bahmni => Appointments running on Openmrs` should be set to `true`. 
* The global property `Admin => Settings => Bahmni => Bahmni Primary Identifier Type` should be set to the uuid of `Primary Identifier Type`. Generally for refapp, it will be `05a29f94-c0ed-11e2-94be-8c13b969e334` the UUID of `OpenMRS ID` Identifier type. 

### Give admin user a username
The Appointments API leverages the username of the logged-in user. For some reason `admin` user doesn't have a username. It has been fixed in the recent versions but if it is not available we need to provide it. Refer to [this thread](https://talk.openmrs.org/t/admin-user-doesnt-have-a-username/25145)  

### Give admin user a username
The below privileges are required for `users` to be able to do everything in the appointments module
* Manage Appointments
* Manage Appointment Services
* Manage Appointment Specialities

## Docker Setup
To get it setup on docker follow below steps:



### Steps
* Start the docker env
```
docker-compose up -d
```

* [One time setup] For the first time we need to setup appointments. We can run below script after the server has started and migrations has been run
```
sh first_run.sh
```