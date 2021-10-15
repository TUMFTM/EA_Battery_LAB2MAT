# Toolbox for processing of raw measurement data (Gamry devices, Basytec devices, Biologic devices) to MATLAB

This repository provides a one-stop-toolbox for lab data processing and transformation to MATLAB compatible datasets.

## Features
- Transformation of .DTA files (Gamry devices) to .MAT files (MATLAB)
- Transformation of .TXT files (Basytec devices) to .MAT files (MATLAB)
- Transformation of .TXT files (Biologic devices) to .MAT files (MATLAB)

## Usage of the toolbox

We are very happy if you choose this toolbox for your projects and provide all updates under GNU LESSER GENERAL PUBLIC LICENSE Version 3 (29 June 2007). Please refer to the license file for any further questions about incorporating this battery model into your projects. We are looking forward to hear your feedback and kindly ask you to share bugfixes, improvements and updates on the parameterization or real-time implementation.

## Requirements

The model was created with MATLAB 2019b. If you want to commit an updated version using another software release or a specific toolbox please give us a short heads-up. 

## How To Use

The main path contains three functions, *gamry2mat.m*, *biologic2mat* and *basytec2mat.m*, and two directories, *01_Input* and *02_Output*. First, place your raw data from your measurement device into *01_Input*. Run the function of choice in MATLAB. After completion, all files are converted and saved into *02_Output*.

## Authors

- Leo Wildfeuer, wildfeuer@ftm.mw.tum.de
  - Repository author and maintainer
- Nikolaos Wassiliadis, wassiliadis@ftm.mw.tum.de
  - Repository author and maintainer
- Manuel Ank, ank@ftm.mw.tum.de
  - Repository author and maintainer

## Contributions

- TBA
