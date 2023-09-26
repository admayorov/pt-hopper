#!/bin/bash

# Run this in backend/
# Currently this assumes the contents of the top level zip have been extracted, and google_transit.zip exist in local/gtfs/(1,2,3,4)

# Get a list of all the folders named 1/2/3/4
folders=(1 2 3 4)

# Iterate over the folders and extract the google_transit.zip file into each folder
for folder in "${folders[@]}"; do
  cd "/local/gtfs/$folder"
  unzip google_transit.zip
  rm google_transit.zip
  cd ..
done