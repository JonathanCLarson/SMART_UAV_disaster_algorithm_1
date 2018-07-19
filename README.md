# SMART_UAV_disaster_algorithm_1
Code for a single UAV object in a disaster relief fleet

The current working code, uploaded on 7/11/2018, can be found in the folder Simulation_Code_1.

uavDriver5 runs a single simulation, can be used for quick assessment. For a visual assesment of the simulation, use the Display Simulation folder within the Simulation_Code_1 folder

The files Request6.m, UAVDrone6.m, RequestZone6, and Manager6 classes each contain properties and functions of different aspects of the system, UAVSim3.m uses these class files to run a single simulation.

The file "MasterPlan3.m" runs single or multiple simulations, which can either generate excel files from results, or can perform sensitivity analysis of results. Change map and request zone information as indicated to apply the simulation to a desired scenario.

Instructions for use of uavDriver5 or Master Plan to set up a simulation scenario:
	1. Determine the pixel to kilometer ratio for a map image that covers the response region
		This can be accomplished by using the Display Simulation files with 0 UAVs to inspect the resulting figure

	2. Determine the (x,y) locations of the base and all desired delivery locations, and input these values into uavDriver5 or MasterPlan3 as directed in the comments

	3. Insert fleet specifications as desired (
	