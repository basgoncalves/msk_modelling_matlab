# BOPS

This is a skeleton of code / functions to be used to batch process data from common biomechanical data collection systems 
using OpenSim.

To use the current code please download the [package](/github.com/basgoncalves/DataProcessing-master) 

``` ```
# 📂 BOPS folder structure
The BOPS folder must be saved in the folder containg the data and this folder must be of the following structure:
```
📦Data
 ┣ 📂BOPS
 ┃ ┣ 📂setuptools
 ┃ ┣ 📜README.md
 ┃ ┗ 📜main.m
 ┣ 📂InputData
 ┣ 📂visual3D               (tree not required)
 ┗ 📜demographics.xlsx
```

# 📂 InputData structure
```
📦Data
 ┣ 📂BOPS
 ┣ 📂InputData
 ┃ ┣ 📂subject1
 ┃ ┃ ┣ 📂session1
 ┃ ┃ ┣ 📂session2
 ┃ ┃ ┗ 📂session3
 ┃ ┃ ┃ ┣ 📜trial1.c3d
 ┃ ┃ ┃ ┣ 📜trial2.c3d
 ┃ ┃ ┃ ┣ 📜...   
 ┃ ┃ ┃ ┗ 📜static.c3d
 ┃ ┣ 📂subject2
 ┗ 📂visual3D
```

# 📂 Visual3D structure (tree not required)
```
📦Data
 ┣ 📂BOPS
 ┣ 📂InputData
 ┣ 📂visual3D               
 ┃ ┣ 📂subject1
 ┃ ┃ ┣ 📂session1
 ┃ ┃ ┣ 📂session2
 ┃ ┃ ┣ 📂session3
 ┃ ┃ ┃ ┣ 📂Data
 ┃ ┃ ┃ ┃ ┣ 📂TREATED
 ┃ ┃ ┃ ┃ ┃ ┣ 📂C3D
 ┃ ┃ ┃ ┃ ┃ ┃ ┣ 📜trial1.c3d
 ┃ ┃ ┃ ┃ ┃ ┃ ┣ 📜trial2.c3d
 ┃ ┃ ┃ ┃ ┃ ┃ ┣ 📜...
 ┃ ┃ ┃ ┃ ┃ ┃ ┣ 📜static.c3d
 ┗ ┗ 📂subject2

```