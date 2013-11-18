//	DataPro
//	DAC/ADC macros for use with Igor Pro and the ITC-16 or ITC-18
//	Nelson Spruston
//	Northwestern University
//	project began 10/27/1998

#pragma rtGlobals=3		// Use modern global access method and strict wave access

// The Camera "object" wraps all the SIDX functions, so the "FancyCamera" object doesn't have to deal 
// with them directly.  It also deals with errors internally, so you don't have to worry about them 
// at the next level up.  And it adds the ability to fake a camera, for when there is no camera attached.

// Construct the object
Function CameraConstructor()
	// Save the current DF
	String savedDF=GetDataFolder(1)

	// If the data folder doesn't exist, create it (and switch to it)
	if (!DataFolderExists("root:DP_Camera"))
		// IMAGING GLOBALS
		NewDataFolder /O /S root:DP_Camera
				
		// SIDX stuff
		Variable /G areWeForReal=1	// boolean; if false, we have decided to fake the camera
		Variable /G isSidxRootValid=0	// boolean
		Variable /G sidxRoot
		Variable /G isSidxCameraValid=0	// boolean
		Variable /G sidxCamera	
		Variable /G isSidxAcquirerValid=0	// boolean
		Variable /G sidxAcquirer		

		// This stuff is only needed/used if there's no camera and we're faking
		Variable /G widthCCDFake=512	// width of the fake CCD
		Variable /G heightCCDFake=512	// height of the fake CCD
		Variable /G modeTriggerFake=0		// the trigger mode of the fake camera. 0=>free-running, 1=> each frame is triggered, and there are other settings
		Variable /G widthBinFake=1
		Variable /G heightBinFake=1
		Variable /G offsetColumnROIFake=0
		Variable /G offsetRowROIFake=0
		Variable /G heightROIDesiredFake=heightCCDFake
		Variable /G widthROIDesiredFake=widthCCDFake
		Variable /G exposureFake=0.1	// exposure for the fake camera, in sec
		Variable /G temperatureTargetFake=-20		// degC
		Variable /G countFrameFake=1		// How many frames to acquire for the fake camera
		Variable /G isAcquireOpenFake=0		// Whether acquisition is "armed"
		Variable /G isAcquisitionOngoingFake=0
		Variable /G countReadFrameFake=0		// the first frame to be read by subsequent read commands
	endif

	// Create the SIDX root object, referenced by sidxRoot
	String license=""	// License file is stored in C:/Program Files/Bruxton/SIDX
	Variable sidxStatus
	SIDXRootOpen sidxRoot, license, sidxStatus
	isSidxRootValid=(sidxStatus==0)
	areWeForReal= isSidxRootValid	// if we can't get a valid sidx root, then fake

	Variable nCameras
	if (areWeForReal)
		if (isSidxRootValid)
			SIDXRootCameraScanGetCount sidxRoot, nCameras,sidxStatus
			if (sidxStatus != 0)
				nCameras=0
			endif
			//Printf "# of cameras: %d\r", nCameras
			if (nCameras>0)
				// Create the SIDX camera object, referenced by sidxCamera
				SIDXRootCameraOpenName sidxRoot, "", sidxCamera, sidxStatus
				isSidxCameraValid= (sidxStatus==0)
				areWeForReal=isSidxCameraValid		// if no valid camera, then we fake
			else
				// if zero cameras, then we fake
				areWeForReal=0;
			endif
		endif
	endif	
	
	// Restore the data folder
	SetDataFolder savedDF	
End





Function CameraROIClear()
	// Switch to the imaging data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Camera

	// Declare instance variables
	NVAR areWeForReal
	NVAR isSidxCameraValid
	NVAR sidxCamera
	NVAR offsetColumnROIFake, offsetRowROIFake
	NVAR widthROIDesiredFake, heightROIDesiredFake	 	// the ROI boundaries
	NVAR widthCCDFake, heightCCDFake

	Variable sidxStatus
	if (areWeForReal)
		if (isSidxCameraValid)
			SIDXCameraROIClear sidxCamera, sidxStatus
			if (sidxStatus!=0)
				String errorMessage
				SIDXCameraGetLastError sidxCamera, errorMessage
				Abort sprintf1s("Error in SIDXCameraROIClear: %s",errorMessage)
			endif	
		else
			Abort "Called CameraROIClear() before camera was created."
		endif
	else
		offsetColumnROIFake=0
		offsetRowROIFake=0
		widthROIDesiredFake=widthCCDFake
		heightROIDesiredFake=heightCCDFake
	endif

	// Restore the data folder
	SetDataFolder savedDF	
End





Function CameraROISet(jLeft, iTop, jRight, iBottom)
	Variable jLeft,iTop,jRight,iBottom
	
	// Switch to the imaging data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Camera

	// Declare instance variables
	NVAR areWeForReal
	NVAR isSidxCameraValid
	NVAR sidxCamera
	NVAR offsetColumnROIFake, offsetRowROIFake
	NVAR heightROIDesiredFake, widthROIDesiredFake	 // the ROI boundaries

	Variable sidxStatus
	if (areWeForReal)
		if (isSidxCameraValid)
			SIDXCameraROISet sidxCamera, jLeft, iTop, jRight, iBottom, sidxStatus
			if (sidxStatus!=0)
				String errorMessage
				SIDXCameraGetLastError sidxCamera, errorMessage
				Abort sprintf1s("Error in SIDXCameraROISet: %s",errorMessage)
			endif
		else
			Abort "Called CameraROISet() before camera was created."
		endif
	else
		offsetColumnROIFake=jLeft
		offsetRowROIFake=iTop
		widthROIDesiredFake=jRight-jLeft+1
		heightROIDesiredFake=iBottom-iTop+1
	endif

	// Restore the data folder
	SetDataFolder savedDF	
End





Function CameraBinningSet(nBinWidth,nBinHeight)
	Variable nBinWidth, nBinHeight
	
	// Switch to the imaging data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Camera

	// Declare instance variables
	NVAR areWeForReal
	NVAR isSidxCameraValid
	NVAR sidxCamera
	NVAR widthBinFake, heightBinFake

	Variable sidxStatus
	if (areWeForReal)
		if (isSidxCameraValid)
			SIDXCameraBinningSet sidxCamera, nBinWidth, nBinHeight, sidxStatus
			if (sidxStatus!=0)
				String errorMessage
				SIDXCameraGetLastError sidxCamera, errorMessage
				Abort sprintf1s("Error in SIDXCameraBinningSet: %s",errorMessage)
			endif
		else
			Abort "Called CameraBinningSet() before camera was created."
		endif
	else
		widthBinFake=nBinWidth
		heightBinFake=nBinHeight
	endif

	// Restore the data folder
	SetDataFolder savedDF	
End






Function CameraTriggerModeSet(triggerMode)
	Variable triggerMode
	
	// Switch to the imaging data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Camera

	// Declare instance variables
	NVAR areWeForReal
	NVAR isSidxCameraValid
	NVAR sidxCamera
	NVAR modeTriggerFake

	Variable sidxStatus
	if (areWeForReal)
		if (isSidxCameraValid)
			SIDXCameraTriggerModeSet sidxCamera, triggerMode, sidxStatus
			if (sidxStatus!=0)
				String errorMessage
				SIDXCameraGetLastError sidxCamera, errorMessage
				Abort sprintf1s("Error in SIDXCameraTriggerModeSet: %s",errorMessage)
			endif
		else
			Abort "Called CameraTriggerModeSet() before camera was created."
		endif
	else
		modeTriggerFake=triggerMode
	endif

	// Restore the data folder
	SetDataFolder savedDF	
End







Function CameraExposeSet(exposureInSeconds)
	Variable exposureInSeconds
	
	// Switch to the imaging data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Camera

	// Declare instance variables
	NVAR areWeForReal
	NVAR isSidxCameraValid
	NVAR sidxCamera
	NVAR exposureFake		// in seconds

	Variable sidxStatus
	if (areWeForReal)
		if (isSidxCameraValid)
			SIDXCameraExposeSet sidxCamera, exposureInSeconds, sidxStatus
			if (sidxStatus!=0)
				String errorMessage
				SIDXCameraGetLastError sidxCamera, errorMessage
				Abort sprintf1s("Error in SIDXCameraExposeSet: %s",errorMessage)
			endif
		else
			Abort "Called CameraExposeSet() before camera was created."
		endif
	else
		exposureFake=exposureInSeconds
	endif

	// Restore the data folder
	SetDataFolder savedDF	
End







Function CameraBufferCountSet(nFrames)
	Variable nFrames
	
	// Switch to the imaging data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Camera

	// Declare instance variables
	NVAR areWeForReal
	NVAR isSidxCameraValid
	NVAR sidxCamera
	NVAR countFrameFake

	Variable sidxStatus
	if (areWeForReal)
		if (isSidxCameraValid)
			SIDXCameraBufferCountSet sidxCamera, nFrames, sidxStatus
			if (sidxStatus!=0)
				String errorMessage
				SIDXCameraGetLastError sidxCamera, errorMessage
				Abort sprintf1s("Error in SIDXCameraBufferCountSet: %s",errorMessage)
			endif
		else
			Abort "Called CameraBufferCountSet() before camera was created."
		endif
	else
		countFrameFake=nFrames
	endif

	// Restore the data folder
	SetDataFolder savedDF	
End






Function CameraAcquireOpen()
	// This basically "arms" the camera for acquisition
	
	// Switch to the imaging data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Camera

	// Declare instance variables
	NVAR areWeForReal
	NVAR isSidxCameraValid
	NVAR sidxCamera
	NVAR isSidxAcquirerValid
	NVAR sidxAcquirer
	NVAR isAcquireOpenFake

	Variable sidxStatus
	if (areWeForReal)
		if (isSidxCameraValid)
			SIDXCameraAcquireOpen sidxCamera, sidxAcquirer, sidxStatus
			if (sidxStatus!=0)
				String errorMessage
				SIDXCameraGetLastError sidxCamera, errorMessage
				Abort sprintf1s("Error in SIDXCameraAcquireOpen: %s",errorMessage)
			else
				isSidxAcquirerValid=0
			endif
		else
			Abort "Called CameraAcquireOpen() before camera was created."
		endif
	else
		isAcquireOpenFake=1
	endif

	// Restore the data folder
	SetDataFolder savedDF	
End






Function CameraAcquireStart()
	// Switch to the imaging data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Camera

	// Declare instance variables
	NVAR areWeForReal
	NVAR isSidxAcquirerValid
	NVAR sidxAcquirer
	NVAR isAcquisitionOngoingFake

	Variable sidxStatus
	if (areWeForReal)
		if (isSidxAcquirerValid)
			SIDXAcquireStart sidxAcquirer, sidxStatus
			if (sidxStatus!=0)
				String errorMessage
				SIDXAcquireGetLastError sidxAcquirer, errorMessage
				Abort sprintf1s("Error in SIDXAcquireStart: %s",errorMessage)
			endif
		else
			Abort "Called CameraAcquireStart() before acquisition was armed."
		endif
	else
		isAcquisitionOngoingFake=1
	endif

	// Restore the data folder
	SetDataFolder savedDF	
End




Function CameraAcquireGetStatus()
	// Switch to the imaging data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Camera

	// Declare instance variables
	NVAR areWeForReal
	NVAR isSidxAcquirerValid
	NVAR sidxAcquirer
	NVAR isAcquisitionOngoingFake

	Variable isAcquiring
	Variable sidxStatus
	if (areWeForReal)
		if (isSidxAcquirerValid)
			SIDXAcquireGetStatus sidxAcquirer, isAcquiring, sidxStatus
			if (sidxStatus!=0)
				String errorMessage
				SIDXAcquireGetLastError sidxAcquirer, errorMessage
				Abort sprintf1s("Error in SIDXAcquireStart: %s",errorMessage)
			endif
		else
			Abort "Called CameraAcquireGetStatus() before acquisition was armed."
		endif
	else
		isAcquiring=0	// if faking, we always claim that we're done
	endif

	// Restore the data folder
	SetDataFolder savedDF	
	
	// return
	return isAcquiring
End





Function CameraAcquireStop()
	// Switch to the imaging data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Camera

	// Declare instance variables
	NVAR areWeForReal
	NVAR isSidxAcquirerValid
	NVAR sidxAcquirer
	NVAR isAcquisitionOngoingFake
	WAVE bufferFrame
	NVAR widthCCDFake, heightCCDFake
	NVAR widthBinFake, heightBinFake
	NVAR offsetColumnROIFake, offsetRowROIFake
	NVAR widthROIDesiredFake, heightROIDesiredFake	// the ROI boundaries
	NVAR countFrameFake

	Variable sidxStatus
	if (areWeForReal)
		if (isSidxAcquirerValid)
			SIDXAcquireStop sidxAcquirer, sidxStatus
			if (sidxStatus!=0)
				String errorMessage
				SIDXAcquireGetLastError sidxAcquirer, errorMessage
				Abort sprintf1s("Error in SIDXAcquireStop: %s",errorMessage)
			endif
		else
			Abort "Called CameraAcquireStop() before acquisition was armed."
		endif
	else
		// Fill the framebuffer with fake data
		Variable widthROIBinnedFake=floor(widthROIDesiredFake/widthBinFake)
		Variable heightROIBinnedFake=floor(heightROIDesiredFake/heightBinFake)			
		Redimension /N=(heightROIBinnedFake,widthROIBinnedFake,countFrameFake) bufferFrame
		bufferFrame=2^15+(2^14)*gnoise(1)
				
		// Note that the acquisiton is done
		isAcquisitionOngoingFake=0
	endif

	// Restore the data folder
	SetDataFolder savedDF	
End





Function /WAVE CameraAcquireRead(nFramesToRead)
	Variable nFramesToRead

	// Switch to the imaging data folder
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_Camera

	// Declare instance variables
	NVAR areWeForReal
	NVAR isSidxAcquirerValid
	NVAR sidxAcquirer
	NVAR isAcquisitionOngoingFake
	WAVE bufferFrame
	NVAR widthROIDesiredFake, heightROIDesiredFake
	NVAR widthBinFake, heightBinFake
	NVAR countFrameReadFake

	Variable sidxStatus
	Wave frames
	if (areWeForReal)
		if (isSidxAcquirerValid)
			SIDXAcquireRead sidxAcquirer, nFramesToRead, frames, sidxStatus
			if (sidxStatus!=0)
				String errorMessage
				SIDXAcquireGetLastError sidxAcquirer, errorMessage
				Abort sprintf1s("Error in SIDXAcquireRead: %s",errorMessage)
			endif
		else
			Abort "Called CameraAcquireRead() before acquisition was armed."
		endif
	else
		if (isAcquisitionOngoingFake)
			Abort "Have to stop the fake acquisition before reading the fake data."
		endif
		Variable widthROIBinnedFake=floor(widthROIDesiredFake/widthBinFake)
		Variable heightROIBinnedFake=floor(heightROIDesiredFake/heightBinFake)			
		Duplicate /FREE /R=[][][countFrameReadFake,countFrameReadFake+nFramesToRead] bufferFrame frames
		countFrameReadFake+=nFramesToRead
	endif

	// Restore the data folder
	SetDataFolder savedDF	
	
	// Return result
	return frames
End





