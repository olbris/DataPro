//	DataPro
//	DAC/ADC macros for use with Igor Pro and the ITC-16 or ITC-18
//	Nelson Spruston
//	Northwestern University
//	project began 10/27/1998

Function OutputViewerContConstructor()
	OutputViewerModelConstructor()
	OutputViewerViewConstructor()
End

Function OutputViewerViewConstructor() : Graph
	if (GraphExists("OutputViewerView"))
		DoWindow /F OutputViewerView
		return 0
	endif
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_OutputViewer
	Display /W=(100,150,700,400) /K=1 /N=OutputViewerView as "Output Viewer"
	PopupMenu wavePopup,win=OutputViewerView, pos={650,20},size={115,20},bodyWidth=115,proc=OutputViewerContWavePopup
	OutputViewerContSweprWavsChngd()
	SetDataFolder savedDF	
End

Function OutputViewerModelConstructor()
	// Construct the model
	// One model invariant: If outputWaveName is empty, then currentWaveName is the empty string
	// Another model invariant: If outputWaveName is nonempty, then currentWaveName is equal to exactly one of the items in outputWaveName.

	// if the DF already exists, nothing to do
	if (DataFolderExists("root:DP_OutputViewer"))
		return 0		// have to return something
	endif

	// Save the current DF
	String savedDF=GetDataFolder(1)
	
	// Create a new DF
	NewDataFolder /S root:DP_OutputViewer
				
	// Create instance vars
	String /G dacWaveNames=""
	String /G ttlWaveNames=""
	String /G currentWaveName=""
	Variable /G currentWaveIsDAC=1	// not used if currentWaveName is empty

	// Restore the original data folder
	SetDataFolder savedDF
End

Function OutputViewerContWavePopup(ctrlName,itemNum,itemStr) : PopupMenuControl
	String ctrlName
	Variable itemNum
	String itemStr

	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_OutputViewer

	SVAR currentWaveName
	NVAR currentWaveIsDAC
	
	if ( AreStringsEqual(itemStr,"(none)") )
		currentWaveName=""		// should already be this, but what the heck
	else
		if (GrepString(itemStr," \(TTL\)$"))
			currentWaveName=itemStr[0,strlen(ItemStr)-6-1]
			currentWaveIsDAC=0
		else
			currentWaveName=itemStr
			currentWaveIsDAC=1
		endif
	endif
	OutputViewerViewUpdate()
End

Function OutputViewerContSweprWavsChngd()
	// Used to notify the OV controller that the sweeper waves (may have) changed.
	OutputViewerModelSweprWavsChngd()		// Update our model
	OutputViewerViewUpdate()				// Sync the view to the model
End

Function OutputViewerModelSweprWavsChngd()
	// Used to notify the Output Viewer model that the Sweeper waves have changed.
	// Causes the output viewer to update it's own list of the sweeper waves, and change
	// the current wave name if the old one no longer exists.
	if (!DataFolderExists("root:DP_OutputViewer"))
		return 0
	endif

	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_OutputViewer

	SVAR dacWaveNames
	SVAR ttlWaveNames
	SVAR currentWaveName
	NVAR currentWaveIsDAC	

	// Update the list of output wave names
	dacWaveNames=SweeperGetDACWaveNames()
	ttlWaveNames=SweeperGetTTLWaveNames()

	// If the current wave name is no longer valid, deal with that
	Variable nWavesDAC=ItemsInList(dacWaveNames)
	Variable nWavesTTL=ItemsInList(ttlWaveNames)
	Variable nWaves=nWavesDAC+nWavesTTL
	if (!IsEmptyString(currentWaveName))
		if (currentWaveIsDAC)
			if (IsItemInList(currentWaveName,dacWaveNames))
				// Do nothing, all is well
			else
				currentWaveName=""
				currentWaveIsDAC=0
			endif
		else
			// Current wave is TTL
			if (IsItemInList(currentWaveName,ttlWaveNames))
				// Do nothing, all is well
			else
				currentWaveName=""
				currentWaveIsDAC=0
			endif
		endif
	endif
	// If there is no current wave at this point, pick the first available one, if possible
	if ( IsEmptyString(currentWaveName) && (nWaves>0) )
		if (nWavesDAC>0)
			currentWaveName=StringFromList(0,dacWaveNames)
		elseif (nWavesTTL>0)
			currentWaveName=StringFromList(0,ttlWaveNames)
		endif
	endif
	
	// Restore the original data folder
	SetDataFolder savedDF		
End

Function OutputViewerViewUpdate()
	// Used to notify the view that the model has changed.
	// Causes the view to re-sync with the model.
	if (!GraphExists("OutputViewerView"))
		return 0		// Have to return something
	endif
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_OutputViewer
	
	SVAR dacWaveNames
	SVAR ttlWaveNames
	SVAR currentWaveName
	NVAR currentWaveIsDAC	
	
	Variable nWavesDAC=ItemsInList(dacWaveNames)
	Variable nWavesTTL=ItemsInList(ttlWaveNames)
	Variable nWaves=nWavesDAC+nWavesTTL
	String popupItems=OutputViewerModelGetPopupItems()
	String currentPopupItem
	if (nWaves==0)
		currentPopupItem="(none)"
		RemoveFromGraph /Z /W=OutputViewerView $"#0"
		// The graph now has zero waves showing
	else
		if (currentWaveIsDAC)
			currentPopupItem=currentWaveName
			Duplicate /O SweeperGetDACWaveByName(currentWaveName) currentWave
		else
			currentPopupItem=currentWaveName+" (TTL)"
			Duplicate /O SweeperGetTTLWaveByName(currentWaveName) currentWave
		endif
		AppendToGraph /W=OutputViewerView currentWave
		ModifyGraph /W=OutputViewerView grid(left)=1  // put the grid back
		Label /W=OutputViewerView /Z bottom "Time (ms)"
		Label /W=OutputViewerView /Z left currentWaveName+" (pure)"
		// Don't want units in tic marks
		ModifyGraph /W=OutputViewerView /Z tickUnit(bottom)=1
		ModifyGraph /W=OutputViewerView /Z tickUnit(left)=1
	endif
	String popupItemsStupidized="\""+popupItems+"\""
	PopupMenu wavePopup,win=OutputViewerView,value=#popupItemsStupidized
	PopupMenu wavePopup,win=OutputViewerView,popmatch=currentPopupItem
	SetDataFolder savedDF		
End

Function /S OutputViewerModelGetPopupItems()
	// A method to synthesize the popup items from the dacWaveNames and the ttlWaveNames.
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_OutputViewer
	
	SVAR dacWaveNames
	SVAR ttlWaveNames
	
	String popupItems=fancyWaveList(dacWaveNames,ttlWaveNames)
	if (ItemsInList(popupItems)==0)
		popupItems="(none)"
	endif

	SetDataFolder savedDF
	return popupItems
End