#!/bin/bash
# this script will, when appropriate data presents, 1) identify 'high elevation' stations from the rest, 2) plot stations and highlight 'high elevation' ones
# Shizhang Wang

### Part I
## function to check elevation
check_elevation(){
    elevation=$(sed -n 5p $file | grep -o [0-9.]*)
    if [ ${elevation%%.*} -ge 200 ]
    then
        if [ ! -d ./HigherElevation ]
        then
            mkdir ./HigherElevation
            cp $file ./HigherElevation/$(basename $file)
        else
            cp $file ./HigherElevation/$(basename $file)
        fi
    fi
}  

## check if input data exist and is required input
## initially 1 command line argument was supplied as required directory, I have tested the new one which is required format, in case of any error, switch $1 with 'StationData' should yield correct result
if [ ! -d StationData ] # || [ ! $(basename $1) == 'StationData' ]
then
    echo Required data does not exist
    exit
else
    echo Input is required
    for file in StationData/*
    do
        #echo current file is $file
        #check_elevation $file
        #elevation=$(sed -n 5p $file | grep -o [0-9.]*)
        #if [ ${elevation%%.*} -gt 200 ]
        #then
        #    if [ ! -d ./HigherElevation ]
        #    then
        #        mkdir ./HigherElevation
        #        cp $file ./HigherElevation/$(basename $file)
        #    else
        #        cp $file ./HigherElevation/$(basename $file)
        #    fi
            #echo $elevation
        #fi
        check_elevation $file
    done
fi
### Part II
## Plot all stations and highlight high elevation ones
for file in StationData/*
do
    #echo $file
    awk '/Longitude/ {print -1 * $NF}' $file > Long.list
    awk '/Latitude/ {print $NF}' $file > Lat.list
    paste Long.list Lat.list >> AllStation.xy # append >>, overwrite >
done
for file in HigherElevation/*
do
    #echo $file
    awk '/Longitude/ {print -1 * $NF}' $file > Long.list
    awk '/Latitude/ {print $NF}' $file > Lat.list
    paste Long.list Lat.list >> HEStation.xy
done
## Load gmt for plotting
module load gmt
gmt pscoast -JU16/4i -R-93/-86/36/43 -B2f0.5 -Cl/blue -Dh -Ia/blue -Na/orange -P -K -V > SoilMoistureStations.ps
 # -Cl/blue fill lakes with blue, -Dh applied higher resolution to coastlines, political boundaries.
gmt psxy AllStation.xy -J -R -Sc0.15 -Gblack -K -O -V >> SoilMoistureStations.ps
gmt psxy HEStation.xy -J -R -Sc0.05 -Gred -O -V >> SoilMoistureStations.ps # switch -Sc0.15 to -Sc0.05 to reduce the size of high elevation station
### Part III
ps2epsi SoilMoistureStations.ps SoilMoistureStations.epsi
convert -units PixelsPerInch SoilMoistureStations.epsi -density 150 SoilMoistureStations.tiff
