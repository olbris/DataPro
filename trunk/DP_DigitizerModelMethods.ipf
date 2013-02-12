//	DataPro//	DAC/ADC macros for use with Igor Pro and the ITC-16 or ITC-18//	Nelson Spruston//	Northwestern University//	project began 10/27/1998#pragma rtGlobals=1		// Use modern global access method.Function DigitizerModelConstructor()	//	USERS SHOULD NOT EDIT ANYTHING HERE	//	EDIT ONLY IN THE MyVariables FILE		// Save the current DF	String savedDF=GetDataFolder(1)		// Create a new DF	NewDataFolder /O/S root:DP_Digitizer		// dimensions	Variable /G nADCChannels=8	Variable /G nDACChannels=4	Variable /G nTTLChannels=4		// Each ADC and DAC channel has a "mode".  Currently, this described whether it's a 	// current channel or a voltage channel, but other modes may be added in the future.	// Technically, the channel mode is either 0 or 1, and the channel's mode name is "Current" or	// "Voltage"	Variable /G nChannelModes=2		// current, voltage		// Current and voltage units	//String /G unitsCurrent="pA"	//String /G unitsVoltage="mV"	Make /O /T /N=(nChannelModes) modeNameFromMode={"Current","Voltage"}		Make /O /T /N=(nChannelModes) unitsFromMode={"pA","mV"}	// Auto-detect the ITC version present	// itc is 16 if ITC-16 is being used, 18 if ITC-18, and 0 if neither is present	// If neither is present, DataPro runs in "demo" mode.	Variable /G itc=detectITCVersion()	Variable /G usPerDigitizerClockTick=((itc<18)?1:1.25)		// 1 us for itc16, 1.25 usec for itc18	//if (itc<18)	//	usPerDigitizerClockTick=1	// 1 usec for itc16	//else	//	usPerDigitizerClockTick=1.25	// 1.25 usec for itc18	//endif	// Should we run the user's custom automatic analysis function after each sweep?	Variable /G autoAnalyzeChecked=0		// true iff AutoAnalyze checkbox is checked	// Variables controlling the trials and sweeps	Variable /G iSweep=1		// index of the current/next sweep to be acquired	Variable /G nSweepsPerTrial=1	Variable /G sweepInterval=10		// seconds//	// Variables related to the test pulse//	Variable /G tpamp	// test pulse amplitude, units determined by channel mode//	Variable /G tpdur		// test pulse duration, ms//	Variable /G sinttp=0.02		// sample interval for the test pulse, ms//	Variable /G testadc=0		// index of the ADC channel to be used for the test pulse//	Variable /G testdac=0		// index of the DAC channel to be used for the test pulse	//	Variable /G baseline_sub=1	// boolean, whether or not to do baseline subtraction//	Variable /G testPulseTTLOutput=0		// whether or not to do a TTL output during test pulse//	Variable /G testPulseTTLOutChannel=0	   // index of the TTL used for gate output, if testPulseTTLOutput is true//	Variable /G testPulseDoBaselineSubtraction=1	// whether to do baseline subtraction//	//Variable /G RSeal			// the computed seal resistance, GOhm	// global variables for DAC waves (?)	//Variable /G ffseg=1	//Variable /G sintdisp=0.01	// These are used by all kinds of Sweeper stimuli, and currently dt is also used by TestPulse	Variable /G dt=0.05	// sampling interval, ms	Variable /G totalDuration=200		// total duration, ms		// totalDuration is used only by the Sweeper, not TestPulse		// Should probably be moved into a future SweeperModel "object" at some point	// These control the StepPulse_DAC wave	Variable /G stepPulseAmplitude=1		// amplitude in units given by channel mode	Variable /G stepPulseDuration=100		// duration in ms	// Initialize the StepPulse wave	Make /O StepPulse_DAC	StepPulseParametersChanged()	// Parameters of SynPulse_TTL	Variable /G synPulseDelay=50		Variable /G synPulseDuration=0.1	// ms	// Initialize the SynPulse wave	Make /O SynPulse_TTL	SynPulseParametersChanged()	// Parameters of five-segment stimulus	Variable /G stepDuration0=10	Variable /G stepDuration1=10	Variable /G stepDuration2=10	Variable /G stepDuration3=10	Variable /G stepDuration4=10	Variable /G stepAmplitude0=10	Variable /G stepAmplitude1=10	Variable /G stepAmplitude2=10	Variable /G stepAmplitude3=10	Variable /G stepAmplitude4=10	Make /O Step5DAC	Make /O /N=(5) duration	Make /O /N=(5) amplitude			// Parameters of train stimulus	Variable /G trainDuration0=10	Variable /G trainDuration1=10	Variable /G trainDuration2=10	Variable /G trainNumber=10	Variable /G trainFrequency=10	Variable /G trainAmplitude=10	Variable /G trainBase=0	Variable /G trainDuration=2	Make /O TrainDAC	// Parameters of ramp stimulus	//Variable /G rampDuration1=10	//Variable /G rampDuration2=50	//Variable /G rampDuration3=10	//Variable /G rampDuration4=10	//Variable /G rampAmplitude1=-10	//Variable /G rampAmplitude2=0	//Variable /G rampAmplitude3=10	//Variable /G rampAmplitude4=0	//Make /O RampDAC	// initial mode of ADC, DAC channels	Make /O /N=(nADCChannels) adcMode={1,1,1,1,1,1,1,1}	// all voltage channels	Make /O /N=(nDACChannels) dacMode={0,0,0,0}			// all current channels 	// Make waves for adc and dac gains	Make /O /N=(nADCChannels,nChannelModes) adcGainAll={ {0.0001,0.0001,0.0001,0.0001,0.0001,0.0001,0.0001,0.0001}, {0.01,0.01,0.01,0.01,0.01,0.01,0.01,0.01} }	Make /O /N=(nDACChannels,nChannelModes) dacGainAll={ {10000,10000,10000,10000}, {20,20,20,20} }	// Multipliers for the DAC channels	Make /O /N=(nDACChannels) dacMultiplier={1,1,1,1}		// string variables for adc in wave names	Make /O/T/N=(nADCChannels) adcBaseName={"ad0","ad1","ad2","ad3","ad4","ad5","ad6","ad7"}	// wave names for DAC, TTL output channels	Make /O /T /N=(nDACChannels) dacWavePopupSelection	dacWavePopupSelection={"StepPulse_DAC","StepPulse_DAC","StepPulse_DAC","StepPulse_DAC"}	Make /O /T /N=(nTTLChannels) ttlWavePopupSelection	ttlWavePopupSelection={"_none_","_none_","_none_","_none_"}		// Make waves to read which adc/dac/ttl devices should be on	Make /O /N=(nADCChannels) adcChannelOn	adcChannelOn[0]=1		// turn on ADC 0 by default, leave rest off	Make /O /N=(nDACChannels) dacChannelOn	dacChannelOn[0]=1		// turn on DAC 0 by default, leave rest off	Make /O /N=(nTTLChannels) ttlOutputChannelOn  	// all TTL outputs off by default		// Do the usr customization	SetupDigitizerForUser()  // Allows user to set desired channel gains, etc.		// Restore the original data folder	SetDataFolder savedDFEndFunction StepPulseParametersChanged()	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer		NVAR dt, totalDuration,stepPulseAmplitude, stepPulseDuration	WAVE StepPulse_DAC	// bound wave		Variable offDuration=totalDuration-stepPulseDuration	Variable delayDuration=offDuration/4	Duplicate /O SimplePulse(dt,totalDuration,delayDuration,stepPulseDuration,stepPulseAmplitude) StepPulse_DAC		Note /K StepPulse_DAC	ReplaceStringByKeyInWaveNote(StepPulse_DAC,"WAVETYPE","stepPulse")	ReplaceStringByKeyInWaveNote(StepPulse_DAC,"TIME",time())	ReplaceStringByKeyInWaveNote(StepPulse_DAC,"stepPulseAmplitude",num2str(stepPulseAmplitude))	ReplaceStringByKeyInWaveNote(StepPulse_DAC,"stepPulseDuration",num2str(stepPulseDuration))	SetDataFolder savedDFEndFunction SynPulseParametersChanged()	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	NVAR dt, totalDuration, synPulseDelay, synPulseDuration	WAVE SynPulse_TTL	Duplicate /O SimplePulseBoolean(dt,totalDuration,synPulseDelay,synPulseDuration) SynPulse_TTL	Note /K SynPulse_TTL	ReplaceStringByKeyInWaveNote(SynPulse_TTL,"WAVETYPE","synPulse")	ReplaceStringByKeyInWaveNote(SynPulse_TTL,"TIME",time())	ReplaceStringByKeyInWaveNote(SynPulse_TTL,"synPulseDelay",num2str(synPulseDelay))	ReplaceStringByKeyInWaveNote(SynPulse_TTL,"synPulseDuration",num2str(synPulseDuration))	SetDataFolder savedDFEndFunction GetNumADCChannelsInUse()	// Gets the number of ADC channels currently in use in the model.		// Change to the Digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	// Declare the DF vars we need	WAVE adcChannelOn	NVAR nADCChannels	// Build up the strings that the ITC functions use to sequence the	// inputs and outputs		Variable nADCChannelsInUse=0	Variable i	for (i=0; i<nADCChannels; i+=1)		nADCChannelsInUse+=adcChannelOn[i]	endfor		// Restore the original DF	SetDataFolder savedDF	return nADCChannelsInUseEndFunction GetNumDACChannelsInUse()	// Gets the number of DAC channels currently in use in the model.	// Change to the Digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	// Declare the DF vars we need	WAVE dacChannelOn	NVAR nDACChannels	// Build up the strings that the ITC functions use to sequence the	// inputs and outputs		Variable nDACChannelsInUse=0	Variable i	for (i=0; i<nDACChannels; i+=1)		nDACChannelsInUse+=dacChannelOn[i]	endfor		// Restore the original DF	SetDataFolder savedDF	return nDACChannelsInUseEndFunction GetNumTTLOutputChannelsInUse()	// Gets the number of TTL output channels currently in use in the model.	// Change to the Digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	// Declare the DF vars we need	WAVE ttlOutputChannelOn	NVAR nTTLChannels	// Build up the strings that the ITC functions use to sequence the	// inputs and outputs		Variable nTTLOutputChannelsInUse=0	Variable i	for (i=0; i<nTTLChannels; i+=1)		nTTLOutputChannelsInUse+=ttlOutputChannelOn[i]	endfor		// Restore the original DF	SetDataFolder savedDF	return nTTLOutputChannelsInUseEndFunction /S GetRawDACSequence()	// Computes the DAC sequence string needed by the ITC functions, given the model state.	//  Note, however, that this is the RAW sequence string.  The raw DAC sequence must be reconciled with	// the raw ADC sequence to produce the final DAC and ADC seqeuences.	// Change to the Digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	WAVE dacChannelOn, ttlOutputChannelOn	// boolean waves that say which DAC, TTL channels are on	NVAR nDACChannels	// Build up the strings that the ITC functions use to sequence the	// inputs and outputs, by probing the view state	String dacSequence=""	Variable i	for (i=0; i<nDACChannels; i+=1)		if ( dacChannelOn[i] )			dacSequence+=num2str(i)		endif	endfor	// All the TTL outputs are controlled by a single 16-bit number.	// (There are 16 TTL outputs, but only 0-3 are exposed in the front panel.  All are available	// on a multi-pin connector in the back.)	// If the user has checked any of the TTL outputs, we need to add a "D" to the DAC sequence,	// which reads a 16-bit value to set all of the TTL outputs.	if (sum(ttlOutputChannelOn)>0)		dacSequence+="D"	endif		// Restore the original DF	SetDataFolder savedDF	return dacSequence	EndFunction /S GetRawADCSequence()	// Computes the ADC sequence string needed by the ITC functions, given the model state	// Note, however, that this is the RAW sequence string.  The raw DAC sequence must be reconciled with	// the raw ADC sequence to produce the final DAC and ADC seqeuences.	// Change to the Digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	// Declare the DF vars we need	WAVE adcChannelOn	NVAR nADCChannels	// Build up the strings that the ITC functions use to sequence the	// inputs and outputs		String adcSequence=""	Variable i	for (i=0; i<nADCChannels; i+=1)		if ( adcChannelOn[i] )			adcSequence+=num2str(i)		endif	endfor	// Restore the original DF	SetDataFolder savedDF	return adcSequence	EndFunction /S ReconcileADCSequence(adcSequenceRaw,dacSequenceRaw)	// Reconciles the raw ADC sequence with the given raw DAC sequence, returning an	// ADC sequence which consists of some number of repeats of the raw ADC sequence.	String adcSequenceRaw,dacSequenceRaw	Variable nCommon=lcmLength(dacSequenceRaw,adcSequenceRaw)  // the reconciled sequences must be the same length	Variable nRepeats=nCommon/strlen(adcSequenceRaw)	String adcSequence=RepeatString(adcSequenceRaw,nRepeats)			return adcSequence	EndFunction /S ReconcileDACSequence(dacSequenceRaw,adcSequenceRaw)	// Reconciles the raw DAC sequence with the given raw ADC sequence, returning a	// DAC sequence which consists of some number of repeats of the raw DAC sequence.	String adcSequenceRaw,dacSequenceRaw	Variable nCommon=lcmLength(dacSequenceRaw,adcSequenceRaw)  // the reconciled sequences must be the same length	Variable nRepeats=nCommon/strlen(dacSequenceRaw)	String dacSequence=RepeatString(dacSequenceRaw,nRepeats)			return dacSequenceEndFunction /S GetDACSequence()	// Computes the DAC sequence string needed by the ITC functions, given the model state.	String dacSequenceRaw=GetRawDACSequence()	String adcSequenceRaw=GetRawADCSequence()	String dacSequence=ReconcileDACSequence(dacSequenceRaw,adcSequenceRaw)	return dacSequence	EndFunction /S GetADCSequence()	// Computes the ADC sequence string needed by the ITC functions, given the model state.	String dacSequenceRaw=GetRawDACSequence()	String adcSequenceRaw=GetRawADCSequence()	String adcSequence=ReconcileADCSequence(adcSequenceRaw,dacSequenceRaw)	return adcSequence	EndFunction GetRawDACSequenceLength()	String dacSequenceRaw=GetRawDACSequence()	Variable nSequence=strlen(dacSequenceRaw)	return nSequenceEndFunction GetRawADCSequenceLength()	String adcSequenceRaw=GetRawADCSequence()	Variable nSequence=strlen(adcSequenceRaw)	return nSequenceEndFunction GetSequenceLength()	String dacSequenceRaw=GetRawDACSequence()	String adcSequenceRaw=GetRawADCSequence()	Variable nSequence=lcmLength(dacSequenceRaw,adcSequenceRaw)	return nSequenceEndFunction /WAVE GetMultiplexedTTLOutput()	// Multiplexes the active TTL outputs onto a single wave.  If there are no active and valid	// TTL output waves, returns a length-zero wave.	WAVE ttlOutputChannelOn	WAVE /T ttlWavePopupSelection	Make /FREE /N=(0) multiplexedTTL  // default return value	NVAR nTTLChannels		Variable firstActiveChannel=1	// boolean	Variable i	for (i=0; i<nTTLChannels; i+=1)		if (ttlOutputChannelOn[i])			if ( AreStringsEqual(ttlWavePopupSelection[i],"_none_") )				Abort "An active TTL output channel can't have the wave set to \"_none_\"."			endif			String thisTTLWaveNameRel=ttlWavePopupSelection[i]			WAVE thisTTLWave=$thisTTLWaveNameRel			if (firstActiveChannel)				firstActiveChannel=0				Duplicate /FREE /O thisTTLWave multiplexedTTL				multiplexedTTL=0			endif			multiplexedTTL+=(2^i)*thisTTLWave		endif	endfor		return multiplexedTTLEndFunction /WAVE GetFIFOout()	// Builds the FIFOout wave, as a free wave, and returns a reference to it.		// Switch to the digitizer control data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer		// Declare data folder vars we access	WAVE /T dacWavePopupSelection	//NVAR error	WAVE dacMultiplier	//	// The digitizer panel must exist for this to work, so check for it//	if (!PanelExists("Digitizer"))//		error=1//		Abort "You need to open the digitizer control panel first. Once it's open, you can hide it by double clicking the top bar."//	endif		// get the DAC sequence	String daseq=GetDACSequence()	Variable seqLength=strlen(daseq)	//String daseqRaw=GetRawDACSequence()	//Variable seqLengthRaw=strlen(daseqRaw)		// These things will be set to finite values at soon as we are able to determine them from a wave	Variable atLeastOneOutput=0		// boolean	Variable dt=nan		// sampling interval, ms	Variable nScans=nan	// number of samples in each output wave ("scans" is an NI-ism)		// the default value of FIFOout	Make /FREE /N=(0) FIFOout		// First, need to multiplex all the TTL outputs the user has specified onto a single wave, where each	// sample is interpreted 16-bit number that specifies all the 16 TTL outputs, only the first four	// of which are exposed on the front panel.	// Source TTL waves should consist of zeros (low) and ones (high) only.	// The multiplexed wave is called multiplexedTTL	Wave multiplexedTTL=GetMultiplexedTTLOutput()	Variable atLeastOneTTLOutput=(numpnts(multiplexedTTL)>0)	if (atLeastOneTTLOutput)		atLeastOneOutput=1		dt=deltax(multiplexedTTL)		nScans=numpnts(multiplexedTTL)		Redimension /N=(seqLength*nScans) FIFOout	endif	// now assign values to FIFOout according to the DAC sequence	Variable outgain	String stepAsString=""	Variable i	for (i=0; i<seqLength; i+=1)		// Either use the specified DAC wave, or use the multiplexed TTL wave, as appropriate		if ( AreStringsEqual(daseq[i],"D") )			// Means this is the slot for the multiplexed TTL output			Wave thisDACWave=multiplexedTTL			outgain=1		else						Variable iDACChannel=str2num(daseq[i])			if ( AreStringsEqual(dacWavePopupSelection[iDACChannel],"_none_") )				Abort "An active DAC channel can't have the wave set to \"_none_\"."			endif			String thisDACWaveNameRel=dacWavePopupSelection[iDACChannel]			Wave thisDACWave=$thisDACWaveNameRel			outgain=GetDACPointsPerNativeUnit(iDACChannel)		endif		// If this is the first output, set some variables and dimension FIFOout.  Otherwise,		// make sure this wave is consistent with the previous ones.		if (atLeastOneOutput)			// If there has already been an output wave, make sure this one agrees with it			if (dt!=deltax(thisDACWave))				Abort "There is a sample interval mismatch in your DAC and/or TTL output waves."			endif			if (nScans!=numpnts(thisDACWave))				Abort "There is a mismatch in the number of points in your DAC and/or TTL output waves."			endif		else			// If this is the first output wave, use its dimensions to create FIFOout			atLeastOneOutput=1			dt=deltax(thisDACWave)			nScans=numpnts(thisDACWave)			Redimension /N=(seqLength*nScans) FIFOout		endif		// Get the step value, if it's present in this wave		String stepAsStringThis=StringByKeyInWaveNote(thisDACWave,"STEP")		if ( !IsEmptyString(stepAsStringThis) )			stepAsString=stepAsStringThis		endif		// Finally, write this output wave into FIFOout		FIFOout[i,;seqLength]=thisDACWave[floor(p/seqLength)]*outgain*dacMultiplier[iDACChannel]	endfor			// Set the time scaling for FIFOout	Setscale /P x, 0, dt/seqLength, "ms", FIFOout		// Set the STEP wave note in FIFOout, so that it can be copied into the ADC waves eventually	if (!IsEmptyString(stepAsString))		ReplaceStringByKeyInWaveNote(FIFOout,"STEP",stepAsString)	endif		// Restore the data folder	SetDataFolder savedDF		// Return	return FIFOoutEndFunction /S adcGainUnitsStringFromADCMode(adcMode)	// Returns the units string for an ADC of the given mode.	Variable adcMode	// Switch to the digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	// Core of the method	WAVE /T unitsFromMode	String out=sprintf1s("V/%s",unitsFromMode[adcMode])	// Restore the data folder	SetDataFolder savedDF		// Return		return outEndFunction /S dacGainUnitsStringFromDACMode(dacMode)	// Returns the units string for a DAC of the given mode.	Variable dacMode	// Switch to the digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	// Core of the method	WAVE /T unitsFromMode	String out=sprintf1s("%s/V",unitsFromMode[dacMode])	// Restore the data folder	SetDataFolder savedDF		// Return		return outEndFunction SwitchADCChannelMode(iChannel,mode)	// Switches the indicated ADC channel to the given mode.	Variable iChannel, mode		String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer		WAVE adcMode		adcMode[iChannel]=mode	SetDataFolder savedDFEndFunction SwitchDACChannelMode(iChannel,mode)	// Switches the indicated DAC channel to the given mode.	Variable iChannel, mode	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	WAVE dacMode	dacMode[iChannel]=mode	SetDataFolder savedDFEndFunction GetADCChannelMode(iChannel)	Variable iChannel		String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer		WAVE adcMode	Variable mode=adcMode[iChannel]	SetDataFolder savedDF		return modeEndFunction /S GetADCChannelModeString(iChannel)	// Returns the units string for an ADC of the given mode.	Variable iChannel	// Switch to the digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	// Core of the method	WAVE adcMode	WAVE /T modeNameFromMode	String modeName=modeNameFromMode[adcMode[iChannel]]	// Restore the data folder	SetDataFolder savedDF		// Return		return modeNameEndFunction /S GetADCChannelUnitsString(iChannel)	// Returns the units string for an ADC of the given mode.	Variable iChannel	// Switch to the digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	// Core of the method	WAVE adcMode	WAVE /T unitsFromMode	String unitsString=unitsFromMode[adcMode[iChannel]]	// Restore the data folder	SetDataFolder savedDF		// Return		return unitsStringEndFunction GetDACChannelMode(iChannel)	Variable iChannel		String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer		WAVE dacMode	Variable mode=dacMode[iChannel]	SetDataFolder savedDF		return modeEndFunction /S GetDACChannelModeString(iChannel)	Variable iChannel		String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer		WAVE dacMode	WAVE /T modeNameFromMode	Variable mode=dacMode[iChannel]	String modeString=modeNameFromMode[mode]	SetDataFolder savedDF		return modeStringEndFunction /S GetDACChannelUnitsString(iChannel)	Variable iChannel		String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer		WAVE dacMode	WAVE /T unitsFromMode	Variable mode=dacMode[iChannel]	String unitsString=unitsFromMode[mode]	SetDataFolder savedDF		return unitsStringEndFunction /WAVE GetADCGain()	// Gets the current gain on each ADC channel, returns them as a wave.	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	WAVE adcMode	WAVE adcGainAll	NVAR nADCChannels		Make /FREE /N=(nADCChannels) adcGain  // return value			Variable i	for (i=0; i<nADCChannels; i=i+1) 		adcGain[i]=adcGainAll[i][adcMode[i]]	endfor	SetDataFolder savedDF		return adcGainEndFunction /WAVE GetDACGain()	// Gets the current gain on each DAC channel, returns them as a wave.	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	WAVE dacMode	WAVE dacGainAll	NVAR nADCChannels	Make /FREE /N=(nADCChannels) dacGain  // return value			Variable i	for (i=0; i<nADCChannels; i=i+1)		dacGain[i]=dacGainAll[i][dacMode[i]]	endfor	SetDataFolder savedDF		return dacGainEndFunction GetADCNativeUnitsPerPoint(iADCChannel)	// Calculates the input gain (in native units per point) based on the gain for the given 	// channel and pointsPerVoltADC.	Variable iADCChannel		// Set the DF	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer		// these are the "inputs" to this procedure	Variable pointsPerVoltADC=32768/10.24		// points/V	Wave adcGain=GetADCGain()	// V/(native unit)		// do what's described above	Variable result=1/(adcGain[iADCChannel]*pointsPerVoltADC)		// (native units)/point	// Restore the DF		SetDataFolder savedDF	// Exit	return resultEndFunction GetDACPointsPerNativeUnit(iDACChannel)	// Calculates the output gain (in points per native unit) based on the gain for the given 	// channel and pointsPerVoltDAC.	Variable iDACChannel	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	WAVE dacGain=GetDACGain()	// (native units)/V	Variable pointsPerVoltDAC=32768/10.24	// points/V	//NVAR pointsPerVoltDAC	// points/V	Variable result=pointsPerVoltDAC/dacGain[iDACChannel]	// points/(native unit)	SetDataFolder savedDF	return resultEndFunction /S GetListOfChannelModes()	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	NVAR nChannelModes	WAVE /T modeNameFromMode	String result=""	Variable i	for (i=0; i<nChannelModes; i+=1)		result+=(modeNameFromMode[i]+";")	endfor	SetDataFolder savedDF		return resultEndFunction /S GetDigitizerWaveNamesEndingIn(suffix)	String suffix	String theFolderPath = "root:DP_Digitizer"	if (!DataFolderExists(theFolderPath))		return ""	endif	String dfSave = GetDataFolder(1)	SetDataFolder theFolderPath	String items, theString	theString="*_"+suffix	items=WaveList(theString, ";", "")	SetDataFolder dfSave		return itemsEndFunction DigitizerGetDt()	// Change to the Digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	// Declare the DF vars we need	NVAR dt	Variable result=dt	// Restore the original DF	SetDataFolder savedDF	return resultEndFunction DigitizerGetTotalDuration()	// Gets the number of TTL output channels currently in use in the model.	// Change to the Digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	// Declare the DF vars we need	NVAR totalDuration	Variable result=totalDuration	// Restore the original DF	SetDataFolder savedDF	return resultEndFunction /WAVE DigitizerGetWaveByName(waveNameString)	String waveNameString	// Change to the Digitizer data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	// Duplicate the wave to a free wave	Wave exportedWave	Duplicate /FREE $waveNameString exportedWave	// Restore the original DF	SetDataFolder savedDF	return exportedWave	End