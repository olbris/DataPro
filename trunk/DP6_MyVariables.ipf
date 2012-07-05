//	DataPro//	DAC/ADC macros for use with Igor Pro and the ITC-16 or ITC-18//	Nelson Spruston//	Northwestern University//	project began 10/27/1998//	last updated 8/7/2002//	Use this file to set all of your preferences for DataPro#pragma rtGlobals=1		// Use modern global access method.Proc MyVariables()	String savDF=GetDataFolder(1)	SetDataFolder root:DP_ADCDACcontrol//	what type of interface are you using?	itc=16	// set equal to 16 or 18//	Set the units you will be working in for current and voltage//	It is extremely important that you set the gains using the units you designate below//	For example, if you want to work in pA for current units,//	but your amplifier says the gain is 1V/nA, you need to set the gain to 0.001 (V/pA)	current_units="pA"	voltage_units="mV"//	set up the dac and adc channels and gains (default values)//	setup the DAC/ADC channels used for voltage clamp and current clamp	dac_vc=0	dac_cc=0	adc_vc=0	adc_cc=1//	read DACgain values off the appropriate external command on the amplifier//	for voltage clamp, units are voltage_units/V	dacgain0_vc=20	dacgain1_vc=20	dacgain2_vc=0.1	// for Isolator-10, make it 0.001, units are mA/V	dacgain3_vc=1//	for current clamp, units are current_units/V	dacgain0_cc=200	dacgain1_cc=200		dacgain2_cc=0.1	dacgain3_cc=1//	multiplier values for dacs	multdac=1; multdac0=1; multdac1=1; multdac2=1; multdac3=1; multdacD=1//	read ADCgain values off the appropriate output on the amplifier//	don't forget filter gain and appropriate units conversion//	for voltage clamp, units are volts/current_units	adcgain0_cc=1000	adcgain0_vc=0.001	adcgain1_vc=0.001	adcgain2_vc=0.001	adcgain3_vc=0.001	adcgain4_vc=0.001	adcgain5_vc=0.001	adcgain6_vc=0.001	adcgain7_vc=0.001//	for current clamp, units are volts/voltage_units	adcgain0_cc=0.1	adcgain1_cc=0.1	adcgain2_cc=0.1	adcgain3_cc=0.1	adcgain4_cc=0.1	adcgain5_cc=0.1	adcgain6_cc=0.1	adcgain7_cc=0.1//	Variables related to the Test Pulse	testadc=0			// display ADC in test pulse window	testdac=0			// output DAC for test pulse	tpamp=1	tpgate=5000	tpgateamp=10	tpdur=10//	Variables for the Data Pulse (StepPulse_DAC)	dplow=1	dphigh=200	dpshort=50	dplong=1000	dpamp=dplow	dpdur=dplong//	Variables for synaptic stimulation	syntime=50	syndur=0.1//	Variables for LTP analysis	SetDataFolder root:DP_Analysis	slope_left=8	slope_right=30	ltp_interval=10////	Variables for analysis display//	SetDataFolder root:DP_Browser//	ymax=3//	ymin=-3//	xmin=0//	xmax=100//	acsrx=0//	bcsrx=0//	----------------------------------------------------------------------------------------//	USERS SHOULD NOT CHANGE ANYTHING BELOW HERE//	----------------------------------------------------------------------------------------	SetDataFolder root:DP_ADCDACcontrol	if (itc<18)		clockspeed=1	// 1 usec clockspeed for itc16	else		clockspeed=1.25	// 1.25 usec clockspeed for itc18	endif	if (clamp_mode<1)	//  voltage clamp		adcgain0=adcgain0_vc; adcgain1=adcgain1_vc; adcgain2=adcgain2_vc; adcgain3=adcgain3_vc		adcgain4=adcgain4_vc; adcgain5=adcgain5_vc; adcgain6=adcgain6_vc; adcgain7=adcgain7_vc	else					//  current clamp		adcgain0=adcgain0_cc; adcgain1=adcgain1_cc; adcgain2=adcgain2_cc; adcgain3=adcgain3_cc		adcgain4=adcgain4_cc; adcgain5=adcgain5_cc; adcgain6=adcgain6_cc; adcgain7=adcgain7_cc	endif	if (clamp_mode<1)	//  voltage clamp		dacgain0=dacgain0_vc; dacgain1=dacgain1_vc; dacgain2=dacgain2_vc; dacgain3=dacgain3_vc	else					//  current clamp		dacgain0=dacgain0_cc; dacgain1=dacgain1_cc; dacgain2=dacgain2_cc; dacgain3=dacgain3_cc	endif	dacgain_vc={dacgain0_vc, dacgain1_vc, dacgain2_vc, dacgain3_vc}	adcgain_vc={adcgain0_vc, adcgain1_vc, adcgain2_vc, adcgain3_vc, adcgain4_vc, adcgain5_vc, adcgain6_vc, adcgain7_vc}	dacgain_cc={dacgain0_cc, dacgain1_cc, dacgain2_cc, dacgain3_cc}	adcgain_cc={adcgain0_cc, adcgain1_cc, adcgain2_cc, adcgain3_cc, adcgain4_cc, adcgain5_cc, adcgain6_cc, adcgain7_cc}	SetDataFolder savDFEnd