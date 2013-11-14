//	DataPro
//	DAC/ADC macros for use with Igor Pro and the ITC-16 or ITC-18
//	Nelson Spruston
//	Northwestern University
//	project began 10/27/1998

#pragma rtGlobals=3		// Use modern global access method and strict wave access

Function ImagerViewConstructor() : Panel
	// If the view already exists, just raise it
	if (PanelExists("ImagingPanel"))
		DoWindow /F ImagingPanel
		return 0
	endif

	// Change to the imaging data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Imaging

	// This is used in several places
	String absVarName
	
	NewPanel /W=(757,268,1068,741)  /N=ImagingPanel /K=1 as "Imaging Controls"
	Button flu_on,pos={10,40},size={130,20},proc=FluONButtonProc,title="Fluorescence ON"
	Button flu_off,pos={10,10},size={130,20},proc=FluOFFButtonProc,title="Fluorescence OFF"
	CheckBox imaging_check0,pos={14,244},size={114,14},proc=ImagingCheckProc,title="trigger filter wheel"
	CheckBox imaging_check0,value= 1
	Button button0,pos={215,283},size={80,20},proc=DFFButtonProc,title="Append DF/F"
	Button button1,pos={9,190},size={130,20},proc=EphysImageButtonProc,title="Electrophys. + Image"
	SetVariable setimagename0,pos={141,223},size={80,15},title="name"
	SetVariable setimagename0,value= imageseq_name
	CheckBox bkgndcheck0,pos={14,265},size={71,14},title="Bkgnd Sub.",value= 1
	SetVariable numimages_setvar0,pos={11,223},size={120,15},title="No. images"
	SetVariable numimages_setvar0,limits={1,10000,1},value= ccd_frames
	SetVariable ccdtemp_setvar0,pos={13,311},size={150,15},proc=SetCCDTempVarProc,title="CCD Temp. Set"
	SetVariable ccdtemp_setvar0,limits={-50,20,5},value= ccd_tempset
	CheckBox showimageavg_check0,pos={14,286},size={84,14},title="Show Average"
	CheckBox showimageavg_check0,value= 0
	Button resetavg_button2,pos={212,253},size={80,20},proc=ResetAvgButtonProc,title="Reset Avg"
	Button focus,pos={10,70},size={130,20},proc=FocusButtonProc,title="Focus"
	Button full_frame,pos={10,130},size={130,20},proc=FullButtonProc,title="Full Frame Image"
	SetVariable fluo_on_set,pos={178,40},size={120,15},title="ON   position"
	SetVariable fluo_on_set,limits={0,9,1},value= fluo_on_wheel
	SetVariable fluo_off_set,pos={177,10},size={120,15},title="OFF position"
	SetVariable fluo_off_set,limits={0,9,1},value= fluo_off_wheel
	SetVariable focusnum_set,pos={229,98},size={70,15},title="no."
	SetVariable focusnum_set,limits={0,1000,1},value= focus_num
	SetVariable fulltime_set,pos={152,130},size={150,15},title="Exp. time (ms)"
	SetVariable fulltime_set,limits={0,10000,100},value= ccd_fullexp
	SetVariable imagetime_setvar0,pos={149,193},size={150,15},title="Exp.time (ms)"
	SetVariable imagetime_setvar0,limits={0,10000,10},value= ccd_seqexp
	SetVariable setfullname0,pos={137,158},size={80,15},title="name"
	SetVariable setfullname0,value= full_name
	SetVariable setfocusname0,pos={139,99},size={80,15},title="name"
	SetVariable setfocusname0,value= focus_name
	
	absVarName=AbsoluteVarName("root:DP_Imaging","ccd_temp")
	ValDisplay tempdisp0,pos={174,311},size={120,14},title="CCD Temp."
	ValDisplay tempdisp0,format="%3.1f",limits={0,0,0},barmisc={0,1000}
	ValDisplay tempdisp0,value= #absVarName
	
	SetVariable focustime_set,pos={151,70},size={150,15},title="Exp. time (ms)"
	SetVariable focustime_set,limits={0,10000,100},value= ccd_focusexp
	SetVariable fullnum_set,pos={230,159},size={70,15},title="no."
	SetVariable fullnum_set,limits={0,1000,1},value= full_num
	SetVariable imageseqnum_set,pos={227,223},size={70,15},title="no."
	SetVariable imageseqnum_set,limits={0,10000,1},value= imageseq_num
	SetVariable roinum_set0,pos={117,341},size={90,15},proc=GetROIProc,title="ROI no."
	SetVariable roinum_set0,format="%d",limits={1,2,1},value= roinum
	SetVariable settop0,pos={182,371},size={77,15},proc=SetROIProc,title="top"
	SetVariable settop0,format="%d",limits={0,512,1},value= roi_top
	SetVariable setright0,pos={54,395},size={85,15},proc=SetROIProc,title="right"
	SetVariable setright0,format="%d",limits={0,512,1},value= roi_right
	SetVariable settleft0,pos={64,370},size={75,15},proc=SetROIProc,title="left"
	SetVariable settleft0,format="%d",limits={0,512,1},value= roi_left
	SetVariable setbottom0,pos={159,395},size={100,15},proc=SetROIProc,title="bottom"
	SetVariable setbottom0,format="%d",limits={0,512,1},value= roi_bottom
	SetVariable setxbin0,pos={55,419},size={85,15},proc=SetROIProc,title="x bin"
	SetVariable setxbin0,format="%d",limits={0,512,1},value= xbin
	SetVariable setybin0,pos={174,419},size={85,15},proc=SetROIProc,title="y bin"
	SetVariable setybin0,format="%d",limits={0,512,1},value= ybin

	absVarName=AbsoluteVarName("root:DP_Imaging","xpixels")
	ValDisplay xpixels0,pos={54,444},size={85,14},title="x pixels",format="%4.2f"
	ValDisplay xpixels0,limits={0,0,0},barmisc={0,1000},value= #absVarName
	
	absVarName=AbsoluteVarName("root:DP_Imaging","ypixels")
	ValDisplay ypixels0,pos={173,446},size={85,14},title="y pixels",format="%4.2f"
	ValDisplay ypixels0,limits={0,0,0},barmisc={0,1000},value= #absVarName
	
	Button getstac_button,pos={125,253},size={80,20},proc=StackButtonProc,title="GetStack"
	CheckBox show_roi_check0,pos={109,286},size={94,14},title="Show ROI Image"
	CheckBox show_roi_check0,value= 0
	
	// Restore the original DF
	SetDataFolder savedDF
End

