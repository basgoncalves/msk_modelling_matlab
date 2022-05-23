# loadSharing_processing

Load Sharing Data Processing

==============================

The main processing script and functions for processing the load sharing data

First run LS_Pipeline to extract the outputs for use in OpenSIM (e.g., IK/ID).
	This calls the acquisitionInterface and c3d2mat from MOtoNMS
	Crops c3d files into individual gait cycles 
	Processes max EMG for each muscle from the trials in each session and uses the max to normalise values	
	Combines the two force plates with Gerber and Stuessi (1987) method	

Run LinScale.m to scale the generic model bodies 
	Includes staticElaboration function from MOtoNMS to process the static trial, a requirement for LinScale. This has been modified for my trial setup
	Fixes the talus position
	
Run Full_CAST.m 
	Places markers on the model after solving one frame of IK
	Optimises muscle parameters
	
Run openSimProcessing.m to process IK and ID, as well as other OpenSim tools (e.g., static optimisation) for dynamic trials.
	Runs IK first
	Takes IK results and the model spline values to generate abd/add and int/ext 		rotation values and puts them into the .mot file from IK
	Open the knee DOFS of the model - convert splines to linear functions
	Run ID with the modified model and prescribed motion
	Run Point kinematics to get the COM data from he pelvis


