#!/bin/bash -e
printf " [ START ] PostGIS \n"
starttime=$(date +%s)
PREVIOUS_PWD="$(jq -r '.pwd' "${HOME}"/tmp/pwd.json)"
POSTGIS_VERSION="$(jq -r '.POSTGIS_VERSION' "${PREVIOUS_PWD}"/bootstrap/version.json)"
LIBGEOS_VERSION="$(jq -r '.LIBGEOS_VERSION' "${PREVIOUS_PWD}"/bootstrap/version.json)"
if [ "$(jq -r '.purge' "${PREVIOUS_PWD}"/bootstrap/settings.json)" == y ] ; then
  sudo apt -y purge libgeos-* proj-bin
fi
sudo apt -y remove postgresql postgresql-common
sudo apt -y install libgeos-"${LIBGEOS_VERSION}"
sudo apt -y install proj-bin
if ! curl https://download.osgeo.org/postgis/source/postgis-"${POSTGIS_VERSION}".tar.gz
then
    echo "Download failed! Exiting."
    exit 1
fi
tar -xjSf postgis-"${POSTGIS_VERSION}".tar.gz
cd postgis-"${POSTGIS_VERSION}"
./configure
make
make install

#-- Enable PostGIS (includes raster)
#CREATE EXTENSION postgis;
#-- Enable Topology
#CREATE EXTENSION postgis_topology;
#-- Enable PostGIS Advanced 3D
#-- and other geoprocessing algorithms
#-- sfcgal not available with all distributions
#CREATE EXTENSION postgis_sfcgal;
#-- fuzzy matching needed for Tiger
#CREATE EXTENSION fuzzystrmatch;
#-- rule based standardizer
#CREATE EXTENSION address_standardizer;
#-- example rule data set
#CREATE EXTENSION address_standardizer_data_us;
#-- Enable US Tiger Geocoder
#CREATE EXTENSION postgis_tiger_geocoder;

endtime=$(date +%s)
printf " [ DONE ] PostGIS ... %s seconds \n" "$((endtime-starttime))"
