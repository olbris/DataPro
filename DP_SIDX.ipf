//	DataPro
//	DAC/ADC macros for use with Igor Pro and the ITC-16 or ITC-18
//	Nelson Spruston
//	Northwestern University
//	project began 10/27/1998
//	last updated 12/22/2000

//	This file contains macros for using the SIDX imaging package

//-------------------------------------------------------- DataPro SIDX MENU -------------------------------------------------------//

//Menu "SIDX Macros"
//	"SIDX_Begin"
//	"SIDX_Setup"
//	"SIDX_Acquisition"
//	"SIDX_End"
//End

//------------------------------------------- START OF SIDX BREAKDOWN MACROS ---------------------------------------------//
//------------------------------------------------- LIN CI BROWN - BRUXTON CORP. -------------------------------------------------//

//	SIDX BEGIN
//	This macro will setup the hardware configurations
//	that should not be changed during the experiment
//	This macro should be called once at the very beginning
//	of the experiment. If there is any error, no further
//	operation should be performed.

Proc SIDX_Begin()
	Variable /G sidx_handle
	Variable status, canceled
	String message
	SIDXOpen sidx_handle, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		printf "%s: %s", "SIDXOpen", message
		return 0
	endif
	SIDXSettingsLoad sidx_handle, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		printf "%s: %s", "SIDXSettingsLoad", message
		return 0
	endif
	SIDXDriverDialog sidx_handle, canceled, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		SIDXClose sidx_handle
		printf "%s: %s", "SIDXDriverDialog", message
		return 0
	endif
	if (canceled != 0)
		SIDXClose sidx_handle
		print "Driver dialog canceled."
		return 0
	endif
	message = ""
	SIDXDriverBegin sidx_handle, $message, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		SIDXClose sidx_handle
		printf "%s: %s", "SIDXDriverBegin", message
		return 0
	endif
	SIDXHardwareDialog sidx_handle, canceled, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		SIDXDriverEnd sidx_handle, status
		SIDXClose sidx_handle
		printf "%s: %s", "SIDXHardwareDialog", message
		return 0
	endif
	if (canceled != 0)
		SIDXDriverEnd sidx_handle, status
		SIDXClose sidx_handle
		print "Hardware dialog canceled."
		return 0
	endif
	message = ""
	SIDXHardwareBegin sidx_handle, $message, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		SIDXDriverEnd sidx_handle, status
		SIDXClose sidx_handle
		printf "%s: %s", "SIDXHardwareBegin", message
		return 0
	endif
//	Uncomment the next lines to determine the driver and hardware settings
//	SIDXDriverGetSettings sidx_handle, message, status
//	print "driver:", message
//	SIDXHardwareGetSettings sidx_handle, message, status
//	print "hardware:", message
	ccd_opened=1	// Nelson added this flag so this procedure only needs to be run once each expt.
End

//	SIDX SETUP
//	This macro allows you to setup the imaging and acquisition
//	parameters and prepare for the acquisition. This macro can
//	be called any number of times between macro SIDXBegin and macro
//	SIDXEnd. The most of the parameters (execpt temperature) set in 
//	this macro will take into effect in the subsequent call to 
//	macro SIDXAcquisition.

Proc SIDX_Setup()
	Variable status, canceled
	String message
	SIDXCameraDialog sidx_handle, canceled, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		printf "%s: %s", "SIDXCameraDialog", message
		return 0
	endif
	if (canceled != 0)
		print "Hardware dialog canceled."
		return 0
	endif
	//	The second parameter is set to 0 for open shutter before exposure. Non zero for dark image
	//	Use SIDXCameraSetSetting to set shutter modes other than the above two.
	//	SIDXCameraSetShutterMode sidx_handle, 0, status
	//	if (status != 0)
	//		SIDXGetStatusText sidx_handle, status, message
	//		printf "%s: %s", "SIDXCameraSetShutterMode", message
	//		return 0
	//	endif
	//	SIDXCameraSetTempSetpoint sidx_handle, -10.0, status
	//	if (status != 0)
	//		SIDXGetStatusText sidx_handle, status, message
	//		printf "%s: %s", "SIDXCameraSetTempSetpoint", message
	//		return 0
	//	endif
	SIDXImageDialog sidx_handle, canceled, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		printf "%s: %s", "SIDXImageDialog", message
		return 0
	endif
	if (canceled != 0)
		print "Image dialog canceled."
		return 0
	endif
//	uncomment the next two lines to report camera settings
//	SIDXCameraGetSettings sidx_handle, message, status
//	print message
End

//	SIDX ACQUISITION
//	Prompt frames_per_sequence, "Number of frames per sequence:" // The number of frames to acquire after a call to SIDXAcquisitionStart
//	Prompt frames, "Number of frames to acquire:"
//	Prompt wave_image, "Wave name for saving the acquired image:"

Proc SIDX_Acquisition(wave_image, frames_per_sequence, frames)
	String wave_image
	Variable frames_per_sequence, frames
	Variable status, canceled
	Silent 1
	//  Perform acquisition
	SIDXAcquisitionBegin sidx_handle, frames_per_sequence, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		printf "%s: %s", "SIDXAcquisitionBegin", message
		return 0
	endif
	Variable bytes, buffer, index, done, roi_index
	Variable x_pixels, y_pixels, maximum_pixel_value, temperature
	SIDXAcquisitionAllocate sidx_handle, frames_per_sequence, buffer, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		SIDXAcquisitionEnd sidx_handle, status
		printf "%s: %s", "SIDXAcquisitionAllocate", message
		return 0
	endif
	Variable locked, hardware_provided, scan
	roi_index = 0
	do
		// Start a sequence of images.
		SIDXAcquisitionStart sidx_handle, buffer, status
		if (status != 0)
			SIDXGetStatusText sidx_handle, status, message
			SIDXAcquisitionDeallocate sidx_handle, buffer, status
			SIDXAcquisitionEnd sidx_handle, status
			printf "%s: %s", "SIDXAcquisitionStart", message
			return 0
		endif
		// If the acquisition is external trigger mode, start the trigger here
		// Nelson added the next line to do this
		if (image_trig>0)
			DoDataAcq()
		endif
		// Acquire a sequence of frames
		do
			SIDXAcquisitionIsDone sidx_handle, done, status
			if (status != 0)
				SIDXGetStatusText sidx_handle, status, message
				SIDXAcquisitionFinish sidx_handle, status
				SIDXAcquisitionDeallocate sidx_handle, buffer, status
				SIDXAcquisitionEnd sidx_handle, status
				printf "%s: %s", "SIDXAcquisitionIsDone", message
				return 0
			endif
		while (!done)
		SIDXAcquisitionFinish sidx_handle, status
		if (status != 0)
			SIDXGetStatusText sidx_handle, status, message
			SIDXAcquisitionDeallocate sidx_handle, buffer, status
			SIDXAcquisitionEnd sidx_handle, status
			printf "%s: %s", "SIDXAcquisitionFinish", message
			return 0
		endif
		// Transfer images from acquisition buffer to IGOR wave
		// To put a stack of images into a 3D wave, call SIDXAcquisitionGetImagesStart and then 
		// SIDXAcquisitionGetImagesGet within the acquisition loop to build the 3D wave.
		// If there are multiple ROIs in each frame, only the first ROI will be saved in the 3D wave.
		SIDXAcquisitionGetImagesStart sidx_handle, $wave_image, frames_per_sequence, status
		if (status != 0)
			SIDXGetStatusText sidx_handle, status, message
			SIDXAcquisitionDeallocate sidx_handle, buffer, status
			SIDXAcquisitionEnd sidx_handle, status
			printf "%s: %s", "SIDXAcquisitionGetImagesStart", message
			return 0
		endif
		scan = 0	
		do
			// The second parameter is the frame index in the acquisition buffer (starting from zero). 
			// The fourth parameter is the frame index in the 3D wave.
			SIDXAcquisitionGetImagesGet sidx_handle, scan, $wave_image, scan, status
			if (status != 0)
				SIDXGetStatusText sidx_handle, status, message
				SIDXAcquisitionDeallocate sidx_handle, buffer, status
				SIDXAcquisitionEnd sidx_handle, status
				printf "%s: %s", "SIDXAcquisitionGetImagesGet", message
				return 0
			endif
			scan = scan + 1
		while (scan < frames_per_sequence)
		// To put images into individual wave, use SIDXAcquisitionGetImage
		//	SIDXAcquisitionGetImage sidx_handle, 0, $wave_image, status
		//	if (status != 0)
		//		SIDXGetStatusText sidx_handle, status, message
		//		SIDXAcquisitionDeallocate sidx_handle, buffer, status
		//		SIDXAcquisitionEnd sidx_handle, status
		//		printf "%s: %s", "SIDXAcquisitionGetImage", message
		//		return 0
		//	endif
		SIDXAcquisitionGetSize sidx_handle, roi_index, bytes, x_pixels, y_pixels, status
		if (status != 0)
			SIDXGetStatusText sidx_handle, status, message
			SIDXAcquisitionDeallocate sidx_handle, buffer, status
			SIDXAcquisitionEnd sidx_handle, status
			printf "%s: %s", "SIDXAcquisitionGetSize", message
			return 0
		endif
//		printf "ROI: %d, Bytes: %d, X pixels: %d, Y pixels: %d\r", roi_index, bytes, x_pixels, y_pixels
		SIDXCameraGetTemperature sidx_handle, temperature, locked, hardware_provided, status
		if (status != 0)
			SIDXGetStatusText sidx_handle, status, message
			SIDXAcquisitionDeallocate sidx_handle, buffer, status
			SIDXAcquisitionEnd sidx_handle, status
			printf "%s: %s", "SIDXCameraGetTemperature", message
			return 0
		endif
		printf "CCD temperature measured: %d, Temperature locked (1 means true): %d, Temperature locked info provided by hardware (1 means true): %d\r", temperature, locked, hardware_provided
		index = index + frames_per_sequence
		print "image stack done"
	while (index < frames)
	print "image acquisition done"
	SIDXAcquisitionDeallocate sidx_handle, buffer, status
	SIDXAcquisitionEnd sidx_handle, status
End

//	SIDX END
//	This macro will shutdown the communication with the
//	controller and release memory. It should be called at
//	the end of the experiment. If you want to restart a new
//	experiment after you call this macro, you should call
//	macro SIDXSetup again to start over.

Proc SIDX_End()
	Variable status
	String message
	SIDXSettingsSave sidx_handle, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		printf "%s: %s", "SIDXSettingsSave", message
	endif
	SIDXHardwareEnd sidx_handle, status
	SIDXDriverEnd sidx_handle, status
	SIDXClose sidx_handle
	ccd_opened=0
End

//----------------------------NELSON'S INDIVIDUAL SETUP MACROS USING SIDX Procedures------------------------//
//------------------------------------------BASED ON LIN CI BROWN'S SIDX Procedures---------------------------------------//
//-----------------------------------------THESE MAY BE SUPPLANTED EVENTUALLY----------------------------------------//
//--------------------------------BY ADAPTATIONS OF LIN CI'S SIDX_BEGIN AND SIDX_SETUP-----------------------//

//	SIDX BEGIN AUTO
//	This macro will setup the hardware configurations
//	without going through the menus.

Proc SIDX_Begin_Auto()
	Variable /G sidx_handle
	Variable status, canceled
	String message, driver_set, hardware_set
	SIDXOpen sidx_handle, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		printf "%s: %s", "SIDXOpen", message
		return 0
	endif
	SIDXSettingsLoad sidx_handle, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		printf "%s: %s", "SIDXSettingsLoad", message
		return 0
	endif
	sprintf driver_set, "Driver=\"3\""
	SIDXDriverSetSettings sidx_handle, driver_set, status
	sprintf hardware_set, "RoperPIController=\"10\" RoperPIInterface=\"20\" RoperPICCD=\"94\""
	message = ""
	SIDXDriverBegin sidx_handle, $message, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		SIDXClose sidx_handle
		printf "%s: %s", "SIDXDriverBegin", message
		return 0
	endif
	sprintf hardware_set, "RoperPIController=\"10\" RoperPIInterface=\"20\" RoperPICCD=\"94\""
	SIDXHardwareSetSettings sidx_handle, hardware_set, status
	sprintf hardware_set, "RoperPIReadout=\"2\" RoperPIShutterType=\"1\""
	SIDXHardwareSetSettings sidx_handle, hardware_set, status
	message = ""
	SIDXHardwareBegin sidx_handle, $message, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		SIDXDriverEnd sidx_handle, status
		SIDXClose sidx_handle
		printf "%s: %s", "SIDXHardwareBegin", message
		return 0
	endif
	ccd_opened=1	// Nelson added this flag so this procedure only needs to be run once each expt.
End

//	SIDX SETUP AUTO
//	This macro allows you to setup the imaging and acquisition
//	parameters without going through a series of menus.

Proc SIDX_Setup_Auto()
	Variable status, canceled
	Variable x1, y1, x2, y2
	String message, camera_set, image_set, driver_set, hardware_set
//	These next few lines (SIDXHardwareEnd, SIDXHardwareBegin) are a kludge to get rid of the
//	line dividing the image in half. To do this better, the data should be cleared (need a new
//	routine for this) or I need to take two images, and throw away the first one.
//	update: all of this can be avoided by using Automatic Cleans for single image acquisition.
//--------------------------------------------------------------------------------------------------------------------------------------
//	SIDXHardwareEnd sidx_handle, status
//	message=""
//	SIDXHardwareBegin sidx_handle, $message, status
//	if (status != 0)
//		SIDXGetStatusText sidx_handle, status, message
//		SIDXDriverEnd sidx_handle, status
//		SIDXClose sidx_handle
//		printf "%s: %s", "SIDXHardwareBegin", message
//		return 0
// 	endif
//--------------------------------------------------------------------------------------------------------------------------------------
//	from the SIDX html manual
//	RoperPIAD:	1 for fast A/D
//				0 for slow A/D
//	RoperPICollection: 3 for focusing mode, 4 for acquisition
//	RoperPIShutterMode:	1 for normal
//						2 for close
//						3 for disabled open
//	RoperPICleanScans: Number of clean scans
//	RoperPIStripsPerScan: Number of strips per scan
//	RoperSpeedEntry: Entry index in the speed table
//	RoperClearMode and RoperClearCycles are only for Roper Photometrics cameras
//	RoperShutterOpenDelay: In milliseconds
//	RoperShutterCloseDelay: In milliseconds
//	RoperShutterMode:	0 for never open
//						1 for open pre exposure
//						2 for open before sequence
//						3 for open before trigger
//						4 for open.
	sprintf camera_set "RoperPIAD=\"1\" RoperPIGain=\"0\" RoperPITiming=\"0\" RoperPITemperature=\"-25.0\" RoperPIExposure=\"0.030000\""
	SIDXCameraSetSettings sidx_handle, camera_set, status
//     sprintf camera_set "RoperPIAD=\"1\" RoperPITiming=\"0\""
//	SIDXCameraSetSettings sidx_handle, camera_set, status
//	sprintf camera_set "RoperPITemperature=\"%5.1f\" RoperPIExposure=\"%f\"", ccd_tempset, ccd_fullexp/1000
//	SIDXCameraSetSettings sidx_handle, camera_set, status
//	sprintf camera_set "RoperClearMode=\"1\""
//	SIDXCameraSetSettings sidx_handle, camera_set, status
//	sprintf camera_set "RoperClearCycles=\"1\""
//	SIDXCameraSetSettings sidx_handle, camera_set, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		SIDXHardwareEnd sidx_handle, status
		SIDXDriverEnd sidx_handle, status
		SIDXClose sidx_handle
		printf "%s: %s", "SIDXCameraSetSettings", message
		return 0
	endif
//	this alternate form allows setttings to be done one at at time
//	make sure to uncomment the CleansScans and StripsPerScan lines for multiple images (????)
//	SIDXCameraSetSetting sidx_handle, "RoperPIAD", "1", status
	SIDXCameraSetSetting sidx_handle, "RoperPICleanScans", "1", status
	SIDXCameraSetSetting sidx_handle, "RoperPIStripsPerScan", "512", status
//	SIDXCameraSetSetting sidx_handle, "RoperPIShutterMode", "1", status
//	The second parameter below is set to 0 for open shutter before exposure. Non zero for dark image
//	Use SIDXCameraSetSetting to set shutter modes other than these two.
	SIDXCameraSetShutterMode sidx_handle, 4, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		SIDXClose sidx_handle
		printf "%s: %s", "SIDXCameraSetSetting", message
		return 0
	endif
//	The next several lines can be uncommented to determine values set in menus
	SIDXCameraGetSettings sidx_handle, message, status
	print message
//	Variable v1, v2, v3
//	SIDXImageGetExposure sidx_handle, v1, status
//	print "Exp:", v1
//	SIDXImageGetExposureRange sidx_handle, v1, v2, v3, status
//	print "Exp range:", v1, v2, v3
//	SIDXImageGetGain sidx_handle, v1, status
//	print "GetGain:", v1
//	SIDXImageGetGainCount sidx_handle, v1, status
//	print "GetGainCount:", v1
//	SIDXImageGetGainRange sidx_handle, v1, v2, status
//	print "GetGainRange:", v1
//	SIDXImageGetROICount sidx_handle, v1, status
//	print "GetROICount:", v1
//	SIDXImageGetTrigger sidx_handle, v1, status
//	print "GetTrigger:", v1
	SIDXImageROIFullFrame sidx_handle, status
	if (image_roi>0)
		x1=roiwave[0][1]; y1=roiwave[3][1]; x2=roiwave[1][1]; y2=roiwave[2][1]
		SIDXImageAddROI sidx_handle, x1, y1, x2, y2, status
		printf "ROI status=%d\r", status
		print x1, y1, x2, y2
		if (image_roi>1)	// add bkgnd ROI
			x1=roiwave[0][2]; y1=roiwave[3][2]; x2=roiwave[1][2]; y2=roiwave[2][2]
			SIDXImageAddROI sidx_handle, x1, y1, x2, y2, status
			printf "ROI status=%d\r", status
			print x1, y1, x2, y2
		endif
		Variable roi_count
		SIDXImageGetROICount sidx_handle, roi_count, status
		printf "%d ROIs set\r", roi_count
	endif
	SIDXImageSetBinning sidx_handle, xbin, ybin, status
	SIDXImageSetGain sidx_handle, 0, status
	if (image_trig>0)
		SIDXImageSetTrigger sidx_handle, 1, status		// trigger required
	else
		SIDXImageSetTrigger sidx_handle, 0, status		// no trigger required
		sprintf image_set, "SIDXImageSetExposure sidx_handle, %f, status", ccd_fullexp/1000
		Execute image_set 
	endif
//	check and report temp before finishing
	CCD_Temp_Set()
End

Proc CCD_Temp_Set()
	Variable status, temperature, locked, hardware_provided
	String message
	if (ccd_opened<1)
//		SIDX_Begin()
		SIDX_Begin_Auto()
	endif
	SIDXCameraSetTempSetpoint sidx_handle, ccd_tempset, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		SIDXHardwareEnd sidx_handle, status
		SIDXDriverEnd sidx_handle, status
		SIDXClose sidx_handle
		printf "%s: %s", "SIDXCameraSetTempSetpoint", message
		return 0
	endif
	Variable setpoint, temperature_maximum, temperature_minimum, range_valid, difference, counter
	SIDXCameraGetTempSetpoint sidx_handle, setpoint, temperature_minimum, temperature_maximum, range_valid, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		SIDXHardwareEnd sidx_handle, status
		SIDXDriverEnd sidx_handle, status
		SIDXClose sidx_handle
		printf "%s: %s", "SIDXCameraGetTempSetpoint", message
		return 0
	endif
	printf "Temperature setpoint: %.1f, Maximum temperature: %.1f, Minimum temperature: %.1f\r", setpoint, temperature_maximum, temperature_minimum
	SIDXCameraGetTemperature sidx_handle, temperature, locked, hardware_provided, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		SIDXHardwareEnd sidx_handle, status
		SIDXDriverEnd sidx_handle, status
		SIDXClose sidx_handle
		printf "%s: %s", "SIDXCameraSetTemperature", message
		return 0
	endif
	if ((setpoint-temperature)>0.5)
		printf "warming (press space bar to stop) ..."
	else
		if (abs(setpoint-temperature)>0.5)
			printf "cooling (press space bar to stop) ..."
		endif
	endif
	counter=0
	do
		SIDXCameraGetTemperature sidx_handle, temperature, locked, hardware_provided, status
		ccd_temp=temperature
		difference=abs(temperature-setpoint)
		counter+=1
		if (counter>100)
			printf "."
			counter=0
		endif
		if (HaltProcedures()>0)
			break
		endif
	while(locked<1)
//	usually exits this loop off by a couple of degrees because camera continues to cool too far
//	could consider going back in again to adjust this, but it eventually does it on its own anyway
	printf "\r"
	SIDXCameraGetTemperature sidx_handle, temperature, locked, hardware_provided, status
	printf "CCD temperature measured: %d, Temperature locked (1 means true): %d, Temperature locked info provided by hardware (1 means true): %d\r", temperature, locked, hardware_provided
End

//---------------NELSON'S ADAPTATIONS OF LIN CI BROWN'S SIDX ACQUISITION Procedures---------------------//

//	SIDX FOCUS
//	This is an adaptation of SIDX_ACQUISITION
//	which puts the acquisition withing a loop for focusing
//	exit the loop by pressing the space bar

Proc SIDX_Focus()
	Variable frames_per_sequence, frames
	Variable status, canceled
	Silent 1
	String wave_image
	sprintf wave_image, "%s%d", focus_name, focus_num
	frames_per_sequence=1
	frames=1
	SIDXAcquisitionBegin sidx_handle, frames_per_sequence, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		printf "%s: %s", "SIDXAcquisitionBegin", message
		return 0
	endif
	Variable bytes, buffer, index, done, roi_index
	Variable x_pixels, y_pixels, maximum_pixel_value, temperature
	SIDXAcquisitionAllocate sidx_handle, 1, buffer, status
	if (status != 0)
		SIDXGetStatusText sidx_handle, status, message
		SIDXAcquisitionEnd sidx_handle, status
		printf "%s: %s", "SIDXAcquisitionAllocate", message
		return 0
	endif
	Variable locked, hardware_provided
	do
		// Start a sequence of images. In the current case, there is 
		// only one frame in the sequence.
		SIDXAcquisitionStart sidx_handle, buffer, status		
		if (status != 0)
			SIDXGetStatusText sidx_handle, status, message
			SIDXAcquisitionDeallocate sidx_handle, buffer, status
			SIDXAcquisitionEnd sidx_handle, status
			printf "%s: %s", "SIDXAcquisitionStart", message
			return 0
		endif
		do
			SIDXAcquisitionIsDone sidx_handle, done, status		
			if (status != 0)
				SIDXGetStatusText sidx_handle, status, message
				SIDXAcquisitionFinish sidx_handle, status
				SIDXAcquisitionDeallocate sidx_handle, buffer, status
				SIDXAcquisitionEnd sidx_handle, status
				printf "%s: %s", "SIDXAcquisitionIsDone", message
				return 0
			endif
		while (!done)		
		SIDXAcquisitionFinish sidx_handle, status
		if (status != 0)
			SIDXGetStatusText sidx_handle, status, message
			SIDXAcquisitionDeallocate sidx_handle, buffer, status
			SIDXAcquisitionEnd sidx_handle, status
			printf "%s: %s", "SIDXAcquisitionFinish", message
			return 0
		endif
		SIDXAcquisitionGetImage sidx_handle, 0, $wave_image, status
		if (status != 0)
			SIDXGetStatusText sidx_handle, status, message
			SIDXAcquisitionDeallocate sidx_handle, buffer, status
			SIDXAcquisitionEnd sidx_handle, status
			printf "%s: %s", "SIDXAcquisitionGetImage", message
			return 0
		endif
		SIDXAcquisitionGetSize sidx_handle, roi_index, bytes, x_pixels, y_pixels, status
		if (status != 0)
			SIDXGetStatusText sidx_handle, status, message
			SIDXAcquisitionDeallocate sidx_handle, buffer, status
			SIDXAcquisitionEnd sidx_handle, status
			printf "%s: %s", "SIDXAcquisitionGetSize", message
			return 0
		endif
//		printf "ROI: %d, Bytes: %d, X pixels: %d, Y pixels: %d\r", roi_index, bytes, x_pixels, y_pixels
		SIDXCameraGetTemperature sidx_handle, temperature, locked, hardware_provided, status
		if (status != 0)
			SIDXGetStatusText sidx_handle, status, message
			SIDXAcquisitionDeallocate sidx_handle, buffer, status
			SIDXAcquisitionEnd sidx_handle, status
			printf "%s: %s", "SIDXCameraGetTemperature", message
			return 0
		endif
//		printf "CCD temperature measured: %d, Temperature locked (1 means true): %d, Temperature locked info provided by hardware (1 means true): %d\r", temperature, locked, hardware_provided
		if (index<1)
			Image_Display(wave_image)
		endif
		if (index>0)
			if (index<2)
				ModifyImage $wave_image ctab= {gray_low,gray_high,Grays,0}
			endif
			ControlInfo auto_on_fly_check0
			if (V_Value>0)
				AutoGrayScaleButtonProc("autogray_button0")
			endif
		endif
		printf "."
	while ((HaltProcedures()<1))
	printf "CCD temperature measured: %d, Temperature locked (1 means true): %d, Temperature locked info provided by hardware (1 means true): %d\r", temperature, locked, hardware_provided
	SIDXAcquisitionDeallocate sidx_handle, buffer, status
	SIDXAcquisitionEnd sidx_handle, status
//	The next line just puts the image into a single-plane "stack" for consistency with 
//	other acquisition modes and simplicity of the display and autoscale procedures
	Redimension /N=(512,512,1) $wave_image
End

//------------------------------------------------END OF SIDX PROCEDURES-----------------------------------------------------------//