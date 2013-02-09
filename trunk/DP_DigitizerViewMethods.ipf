//	DataPro//	DAC/ADC macros for use with Igor Pro and the ITC-16 or ITC-18//	Nelson Spruston//	Northwestern University//	project began 10/27/1998#pragma rtGlobals=1		// Use modern global access method.Function CreateDigitizerControlPanel() : Panel	// This is basically the constructor for the Digitizer view	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	NewPanel /W=(780,540,780+(872-176+24+16+16),540+256) /N=DigitizerControl /K=1 as "Digitizer Control Panel"	ModifyPanel /W=DigitizerControl fixedSize=1		//	// ADC channel area	// 		// ADC checkboxes	CheckBox ADC0Checkbox,pos={10,12},size={44,14},proc=HandleADCCheckbox,title="ADC0"	CheckBox ADC1Checkbox,pos={10,43},size={44,14},proc=HandleADCCheckbox,title="ADC1"	CheckBox ADC2Checkbox,pos={10,74},size={44,14},proc=HandleADCCheckbox,title="ADC2"	CheckBox ADC3Checkbox,pos={10,105},size={44,14},proc=HandleADCCheckbox,title="ADC3"	CheckBox ADC4Checkbox,pos={10,136},size={44,14},proc=HandleADCCheckbox,title="ADC4"	CheckBox ADC5Checkbox,pos={10,167},size={44,14},proc=HandleADCCheckbox,title="ADC5"	CheckBox ADC6Checkbox,pos={10,198},size={44,14},proc=HandleADCCheckbox,title="ADC6"	CheckBox ADC7Checkbox,pos={10,229},size={44,14},proc=HandleADCCheckbox,title="ADC7"	// ADC channel base names	SetVariable adc0BaseNameSetVariable,pos={62,12-1},size={70+5,15},proc=HandleADCBaseNameSetVariable,title="name"	SetVariable adc1BaseNameSetVariable,pos={62,43-1},size={70+5,15},proc=HandleADCBaseNameSetVariable,title="name"	SetVariable adc2BaseNameSetVariable,pos={62,74-1},size={70+5,15},proc=HandleADCBaseNameSetVariable,title="name"	SetVariable adc3BaseNameSetVariable,pos={62,105-1},size={70+5,15},proc=HandleADCBaseNameSetVariable,title="name"	SetVariable adc4BaseNameSetVariable,pos={62,136-1},size={70+5,15},proc=HandleADCBaseNameSetVariable,title="name"	SetVariable adc5BaseNameSetVariable,pos={62,167-1},size={70+5,15},proc=HandleADCBaseNameSetVariable,title="name"	SetVariable adc6BaseNameSetVariable,pos={62,198-1},size={70+5,15},proc=HandleADCBaseNameSetVariable,title="name"	SetVariable adc7BaseNameSetVariable,pos={62,229-1},size={70+5,15},proc=HandleADCBaseNameSetVariable,title="name"	// Channel type list boxes	PopupMenu ADCChannelModePopupMenu0,pos={62+80+5,12-3}	PopupMenu ADCChannelModePopupMenu0, proc=HandleADCChannelModePopupMenu	PopupMenu ADCChannelModePopupMenu1,pos={62+80+5,43-3}	PopupMenu ADCChannelModePopupMenu1, proc=HandleADCChannelModePopupMenu	PopupMenu ADCChannelModePopupMenu2,pos={62+80+5,74-3}	PopupMenu ADCChannelModePopupMenu2, proc=HandleADCChannelModePopupMenu	PopupMenu ADCChannelModePopupMenu3,pos={62+80+5,105-3}	PopupMenu ADCChannelModePopupMenu3, proc=HandleADCChannelModePopupMenu	PopupMenu ADCChannelModePopupMenu4,pos={62+80+5,136-3}	PopupMenu ADCChannelModePopupMenu4, proc=HandleADCChannelModePopupMenu	PopupMenu ADCChannelModePopupMenu5,pos={62+80+5,167-3}	PopupMenu ADCChannelModePopupMenu5, proc=HandleADCChannelModePopupMenu	PopupMenu ADCChannelModePopupMenu6,pos={62+80+5,198-3}	PopupMenu ADCChannelModePopupMenu6, proc=HandleADCChannelModePopupMenu	PopupMenu ADCChannelModePopupMenu7,pos={62+80+5,229-3}	PopupMenu ADCChannelModePopupMenu7, proc=HandleADCChannelModePopupMenu	// ADC gain setvars	SetVariable adcGain0SetVariable,pos={110+20+10+80,12},size={70,15},proc=HandleADCGainSetVariable,title="gain"	SetVariable adcGain0SetVariable,format="%g",limits={0.0001,10000,0}	SetVariable adcGain1SetVariable,pos={110+20+10+80,43},size={70,15},proc=HandleADCGainSetVariable,title="gain"	SetVariable adcGain1SetVariable,format="%g",limits={0.0001,10000,0}	SetVariable adcGain2SetVariable,pos={110+20+10+80,74},size={70,15},proc=HandleADCGainSetVariable,title="gain"	SetVariable adcGain2SetVariable,format="%g",limits={0.0001,10000,0}	SetVariable adcGain3SetVariable,pos={110+20+10+80,105},size={70,15},proc=HandleADCGainSetVariable,title="gain"	SetVariable adcGain3SetVariable,format="%g",limits={0.0001,10000,0}	SetVariable adcGain4SetVariable,pos={110+20+10+80,136},size={70,15},proc=HandleADCGainSetVariable,title="gain"	SetVariable adcGain4SetVariable,format="%g",limits={0.0001,10000,0}	SetVariable adcGain5SetVariable,pos={110+20+10+80,167},size={70,15},proc=HandleADCGainSetVariable,title="gain"	SetVariable adcGain5SetVariable,format="%g",limits={0.0001,10000,0}	SetVariable adcGain6SetVariable,pos={110+20+10+80,198},size={70,15},proc=HandleADCGainSetVariable,title="gain"	SetVariable adcGain6SetVariable,format="%g",limits={0.0001,10000,0}	SetVariable adcGain7SetVariable,pos={110+20+10+80,229},size={70,15},proc=HandleADCGainSetVariable,title="gain"	SetVariable adcGain7SetVariable,format="%g",limits={0.0001,10000,0}	// ADC gain units	TitleBox adcGain0UnitsTitleBox,pos={110+20+10+80+74,12+0*31},frame=0	TitleBox adcGain1UnitsTitleBox,pos={110+20+10+80+74,12+1*31},frame=0	TitleBox adcGain2UnitsTitleBox,pos={110+20+10+80+74,12+2*31},frame=0	TitleBox adcGain3UnitsTitleBox,pos={110+20+10+80+74,12+3*31},frame=0	TitleBox adcGain4UnitsTitleBox,pos={110+20+10+80+74,12+4*31},frame=0	TitleBox adcGain5UnitsTitleBox,pos={110+20+10+80+74,12+5*31},frame=0	TitleBox adcGain6UnitsTitleBox,pos={110+20+10+80+74,12+6*31},frame=0	TitleBox adcGain7UnitsTitleBox,pos={110+20+10+80+74,12+7*31},frame=0	// Vertical rule	Variable xOffset=110+20+10+80+74+40	SetDrawEnv linethick= 2	DrawLine xOffset,0,xOffset,301	//	// DAC channel area	// 	// Checkboxes for turning each DAC on/off	xOffset=xOffset+10	CheckBox DAC0Checkbox,pos={xOffset,10+0*62},size={44,14},proc=HandleDACCheckbox,title="DAC0"	CheckBox DAC1Checkbox,pos={xOffset,10+1*62},size={44,14},proc=HandleDACCheckbox,title="DAC1"	CheckBox DAC2Checkbox,pos={xOffset,10+2*62},size={44,14},proc=HandleDACCheckbox,title="DAC2"	CheckBox DAC3Checkbox,pos={xOffset,10+3*62},size={44,14},proc=HandleDACCheckbox,title="DAC3"	// Popup menus for choosing the wave that gets outputted via a given DAC	PopupMenu DAC0WavePopupMenu,pos={xOffset,34+0*62},size={113,20}	PopupMenu DAC0WavePopupMenu,proc=HandleDACWavePopupMenu	PopupMenu DAC1WavePopupMenu,pos={xOffset,34+1*62},size={113,20}	PopupMenu DAC1WavePopupMenu,proc=HandleDACWavePopupMenu	PopupMenu DAC2WavePopupMenu,pos={xOffset,34+2*62},size={113,20}	PopupMenu DAC2WavePopupMenu,proc=HandleDACWavePopupMenu	PopupMenu DAC3WavePopupMenu,pos={xOffset,34+3*62},size={113,20}	PopupMenu DAC3WavePopupMenu,proc=HandleDACWavePopupMenu	// Channel type list boxes	xOffset=xOffset+56	PopupMenu DACChannelModePopupMenu0,pos={xOffset,8+0*62}	PopupMenu DACChannelModePopupMenu0, proc=HandleDACChannelModePopupMenu	PopupMenu DACChannelModePopupMenu1,pos={xOffset,8+1*62}	PopupMenu DACChannelModePopupMenu1, proc=HandleDACChannelModePopupMenu	PopupMenu DACChannelModePopupMenu2,pos={xOffset,8+2*62}	PopupMenu DACChannelModePopupMenu2, proc=HandleDACChannelModePopupMenu	PopupMenu DACChannelModePopupMenu3,pos={xOffset,8+3*62}	PopupMenu DACChannelModePopupMenu3, proc=HandleDACChannelModePopupMenu	// DAC gain setvars	xOffset=xOffset+70	SetVariable dacGain0SetVariable,pos={xOffset,10+0*62},size={70,15},proc=HandleDACGainSetVariable,title="gain"	SetVariable dacGain0SetVariable,format="%g",limits={0.0001,10000,0}	SetVariable dacGain1SetVariable,pos={xOffset,10+1*62},size={70,15},proc=HandleDACGainSetVariable,title="gain"	SetVariable dacGain1SetVariable,format="%g",limits={0.0001,10000,0}	SetVariable dacGain2SetVariable,pos={xOffset,10+2*62},size={70,15},proc=HandleDACGainSetVariable,title="gain"	SetVariable dacGain2SetVariable,format="%g",limits={0.0001,10000,0}	SetVariable dacGain3SetVariable,pos={xOffset,10+3*62},size={70,15},proc=HandleDACGainSetVariable,title="gain"	SetVariable dacGain3SetVariable,format="%g",limits={0.0001,10000,0}	// Multiplier applied to a wave before being outputted via a given DAC	SetVariable dacMultiplier0SetVariable,pos={xOffset,38+0*62},size={70,15},title="x ",proc=HandleDACMultiplierSetVariable	SetVariable dacMultiplier0SetVariable,limits={-10000,10000,100}	SetVariable dacMultiplier1SetVariable,pos={xOffset,38+1*62},size={70,15},title="x ",proc=HandleDACMultiplierSetVariable	SetVariable dacMultiplier1SetVariable,limits={-10000,10000,100}	SetVariable dacMultiplier2SetVariable,pos={xOffset,38+2*62},size={70,15},title="x ",proc=HandleDACMultiplierSetVariable	SetVariable dacMultiplier2SetVariable,limits={-10000,10000,100}	SetVariable dacMultiplier3SetVariable,pos={xOffset,38+3*62},size={70,15},title="x ",proc=HandleDACMultiplierSetVariable	SetVariable dacMultiplier3SetVariable,limits={-10000,10000,100}	// DAC gain units	xOffset=xOffset+74	TitleBox dacGain0UnitsTitleBox,pos={xOffset,12+0*62},frame=0	TitleBox dacGain1UnitsTitleBox,pos={xOffset,12+1*62},frame=0	TitleBox dacGain2UnitsTitleBox,pos={xOffset,12+2*62},frame=0	TitleBox dacGain3UnitsTitleBox,pos={xOffset,12+3*62},frame=0	// Vertical rule	xOffset=xOffset+36	SetDrawEnv linethick= 2	DrawLine xOffset,-3,xOffset,300	// 	// TTL area	//	// Horizontal rule	SetDrawLayer UserBack	SetDrawEnv linethick= 2	DrawLine xOffset,126,xOffset+717-496-20,126	// Checkboxes to turn on/off	xOffset=xOffset+10	CheckBox TTL0Checkbox,pos={xOffset,12+0*28},size={43,14},proc=HandleTTLCheckbox,title="TTL0"	CheckBox TTL1Checkbox,pos={xOffset,12+1*28},size={43,14},proc=HandleTTLCheckbox,title="TTL1"	CheckBox TTL2Checkbox,pos={xOffset,12+2*28},size={43,14},proc=HandleTTLCheckbox,title="TTL2"	CheckBox TTL3Checkbox,pos={xOffset,12+3*28},size={43,14},proc=HandleTTLCheckbox,title="TTL3"		// Popup menus to set the wave for each	xOffset=xOffset+55	PopupMenu TTL0WavePopupMenu,pos={xOffset,10+0*28},size={67,20}	PopupMenu TTL0WavePopupMenu,proc=HandleTTLWavePopupMenu	PopupMenu TTL1WavePopupMenu,pos={xOffset,10+1*28},size={67,20}	PopupMenu TTL1WavePopupMenu,proc=HandleTTLWavePopupMenu	PopupMenu TTL2WavePopupMenu,pos={xOffset,10+2*28},size={67,20}	PopupMenu TTL2WavePopupMenu,proc=HandleTTLWavePopupMenu	PopupMenu TTL3WavePopupMenu,pos={xOffset,10+3*28},size={67,20}	PopupMenu TTL3WavePopupMenu,proc=HandleTTLWavePopupMenu		// Load, save buttons	xOffset=608	Variable yOffset=160	Button readgain_button,pos={xOffset,yOffset},size={120,25},proc=LoadSettingsButtonPressed,title="Load settings from file"	Button savegain_button,pos={xOffset,yOffset+35},size={120,25},proc=SaveSettingsButtonPressed,title="Save settings to file"	// Thing that tells user what version of ITC is being used	//SetVariable setvar0,pos={540,139},size={100,25},title="ITC",fSize=18,format="%d"	//SetVariable setvar0,limits={16,18,2},value= itc		// Prompt self to update values based on the model	DigitizerModelChanged()		// Restore the original data folder	SetDataFolder savedDFEndFunction ADCChannelModeChanged(i)	Variable i 	// ADC channel index	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	WAVE adcGain=GetADCGain()	WAVE adcMode	String setVariableName=sprintf1d("adcGain%dSetVariable",i)	SetVariable $setVariableName value=_NUM:adcGain[i]	String titleBoxName=sprintf1d("adcGain%dUnitsTitleBox",i)	TitleBox $titleBoxName,title=adcGainUnitsStringFromADCMode(adcMode[i])		SetDataFolder savedDF	EndFunction DACChannelModeChanged(i)	Variable i 	// DAC channel index	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	WAVE dacGain=GetDACGain()	WAVE dacMode	String setVariableName=sprintf1d("dacGain%dSetVariable",i)	SetVariable $setVariableName value=_NUM:dacGain[i]	String titleBoxName=sprintf1d("dacGain%dUnitsTitleBox",i)	TitleBox $titleBoxName,title=dacGainUnitsStringFromDACMode(dacMode[i])	SetDataFolder savedDF	EndFunction DigitizerModelChanged()	// Change to the DigitizerControl data folder	String savedDF=GetDataFolder(1)	SetDataFolder root:DP_Digitizer	// Declare the DF vars we need	WAVE adcChannelOn	WAVE /T adcBaseName	WAVE adcMode	WAVE dacChannelOn	WAVE /T dacWavePopupSelection	WAVE dacMode	WAVE dacMultiplier	WAVE ttlOutputChannelOn	WAVE /T ttlWavePopupSelection	NVAR nADCChannels	NVAR nDACChannels	NVAR nTTLChannels	// Sync all the ADC-related controls	String listOfChannelModes=GetListOfChannelModes()	String listOfChannelModesFU="\""+listOfChannelModes+"\""		String controlName	Variable i	for (i=0; i<nADCChannels; i+=1)		// Checkbox		controlName=sprintf1d("ADC%dCheckbox", i)		CheckBox $controlName win=DigitizerControl, value=adcChannelOn[i]		// Channel base name		controlName=sprintf1d("adc%dBaseNameSetVariable", i)		SetVariable $controlName,value= _STR:adcBaseName[i]		// Channel type (current, voltage, etc.)		controlName=sprintf1d("ADCChannelModePopupMenu%d", i)		PopupMenu $controlName,value=#listOfChannelModesFU		PopupMenu $controlName,mode=adcMode[i]+1		// Channel gain		ADCChannelModeChanged(i)	endfor	// Sync all the DAC-related controls	String listOfDACWaveNames="_none_;"+Wavelist("*_DAC",";","")	String listOfDACWaveNamesFU="\""+listOfDACWaveNames+"\""	String popupSelection	for (i=0;i<nDACChannels;i+=1)		// Checkbox		controlName=sprintf1d("DAC%dCheckbox", i)		CheckBox $controlName win=DigitizerControl, value=dacChannelOn[i]		// Channel type (current, voltage, etc.)		controlName=sprintf1d("DACChannelModePopupMenu%d", i)		PopupMenu $controlName,value=#listOfChannelModesFU		PopupMenu $controlName,mode=dacMode[i]+1		// Channel gain		DACChannelModeChanged(i)		// Wave to be output through the channel		controlName=sprintf1d("DAC%dWavePopupMenu", i)				PopupMenu $controlName,value=#listOfDACWaveNamesFU		popupSelection=SelectString(IsItemInList(dacWavePopupSelection[i],listOfDACWaveNames),"_none_",dacWavePopupSelection[i])		PopupMenu $controlName,popmatch=popupSelection 		// Wave multiplier		controlName=sprintf1d("dacMultiplier%dSetVariable", i)				SetVariable $controlName,value= _NUM:dacMultiplier[i]	endfor		// Sync all the TTL-related controls	String listOfTTLWaveNames="_none_;"+Wavelist("*_TTL",";","")	String listOfTTLWaveNamesFU="\""+listOfTTLWaveNames+"\""	for (i=0;i<nTTLChannels;i+=1)		// Checkbox		controlName=sprintf1d("TTL%dCheckbox", i)		CheckBox $controlName win=DigitizerControl, value=ttlOutputChannelOn[i]		// Wave to be output through the channel		controlName=sprintf1d("TTL%dWavePopupMenu", i)		PopupMenu $controlName,value=#listOfTTLWaveNamesFU		popupSelection=SelectString(IsItemInList(ttlWavePopupSelection[i],listOfTTLWaveNames),"_none_",ttlWavePopupSelection[i])		PopupMenu $controlName,popmatch=popupSelection	endfor	// Restore the original DF	SetDataFolder savedDFEnd