//	DataPro
//	DAC/ADC macros for use with Igor Pro and the ITC-16 or ITC-18
//	Nelson Spruston
//	Northwestern University
//	project began 10/27/1998

#pragma rtGlobals=3		// Use modern global access method and strict wave access

//---------------------------------------------------------- IMAGE DISPLAY PROCEDURES -----------------------------------------//

Function Image_Display(imageWaveName): Graph
	String imageWaveName
	
	// Change to the imaging data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Imager
	
	// Declare instance vars
	//SVAR gimage
	NVAR im_plane
	SVAR all_images
	SVAR full_name
	SVAR imageseq_name
	NVAR gray_low, gray_high
	
	//String imageWaveName=gimage
	//Prompt imageWaveName, "Enter image wave", popup, WaveList(full_name+"*",";","")+WaveList(imageseq_name+"*",";","");
	//gimage=imageWaveName
	//String wave=imageWaveName
	String command
	Variable numplanes
	numplanes=DimSize($imageWaveName, 2)
	im_plane=0
	all_images=WaveList(full_name+"*",";","")+WaveList(imageseq_name+"*",";","")
	if (wintype("Image_Display")<1)
		Display /W=(45,40,345,340) /K=1 as "Image_Display"
		SetVariable plane_setvar0,pos={45,23},size={80,16},proc=ImagePlaneSetVarProc,title="plane"
		SetVariable plane_setvar0,limits={0,numplanes-1,1},value= im_plane
		SetVariable gray_setvar0,pos={137,1},size={130,16},proc=GrayScaleSetVarProc,title="gray low"
		SetVariable gray_setvar0,limits={0,64000,1000},value= gray_low
		SetVariable gray_setvar1,pos={137,23},size={130,16},proc=GrayScaleSetVarProc,title="gray high"
		SetVariable gray_setvar1,limits={0,64000,1000},value= gray_high
		Button autogray_button0,pos={282,0},size={80,20},proc=AutoGrayScaleButtonProc,title="Autoscale"
		CheckBox auto_on_fly_check0,pos={282,25},size={111,14},title="Autoscale on the fly"
		CheckBox auto_on_fly_check0,value= 0
		PopupMenu image_popup0,pos={17,0},size={111,21},proc=ImagePopMenuProc,title="Image"
		PopupMenu image_popup0,mode=26	//,value= #"all_images"
		PopupMenu image_popup0,mode=1
	else
		SetVariable plane_setvar0,limits={0,numplanes-1,1},value= im_plane
	endif
	DoWindow /F Image_Display
	PopupMenu image_popup0,value= #"all_images"
	PopupMenu image_popup0,mode=WhichListItem(imageWaveName,all_images)+1
	//sprintf command, "RemoveImage %s", ImageNameList("Image_Display",";")
	//Execute command
	String oldImageWaveName=ImageNameList("Image_Display",";")
	RemoveImage $oldImageWaveName
	AppendImage $imageWaveName
//	SetAxis/A/R left
	ControlInfo auto_on_fly_check0
	if (V_Value>0)
		AutoGrayScaleButtonProc("autogray_button0")
	else
		ModifyImage $imageWaveName ctab= {gray_low,gray_high,Grays,0}
	endif
	ModifyGraph margin(left)=29,margin(bottom)=22,margin(top)=36,gfSize=8,gmSize=8
	ModifyGraph manTick={0,64,0,0},manMinor={8,8}
	
	// Restore the original DF
	SetDataFolder savedDF	
End


