#pragma rtGlobals=1		// Use modern global access method.

Function BuilderViewModelChanged(builderType)
	String builderType
	
	// Synthesize the window name from the builderType
	String windowName=builderType+"BuilderView"
	
	// If the view doesn't exist, just return
	if (!GraphExists(windowName))
		return 0		// Have to return something
	endif

	// Save, set data folder
	String savedDF=GetDataFolder(1)
	String dataFolderName=sprintf1s("root:DP_%sBuilder",builderType)
	SetDataFolder $dataFolderName

	WAVE parameters
	WAVE /T parameterNames


	// Set each SetVariable to hold the current model value
	Variable nParameters=numpnts(parameters)
	Variable i
	for (i=0; i<=nParameters; i+=1)
		String controlName=parameterNames[i]+"SV"
		SetVariable $controlName, win=$windowName, value= _NUM:parameters[i]
	endfor
	
	SetDataFolder savedDF
End