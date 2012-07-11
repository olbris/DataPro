//	DataPro Utilities//	last updated 12/29/99#pragma rtGlobals=1		// Use modern global access method.#include <Strings as Lists>#include <Axis Utilities>//---------------------- Graph Axis Scaling Procedures -----------------------//Function RescaleTopAxes()	// Calls RescaleAxes() on the top DPBrowser	Variable browserNumber=GetTopBrowserNumber()	RescaleAxes(browserNumber)EndFunction RescaleAxes(browserNumber)	// In the indicated DPBrowser, configures the scaling of the graph axes based on whether 	// the "Autoscale y" and "Autoscale x" checkboxes are checked, and on the xMin, xMax, 	// yMin, and yMax variables in the browser's data folder.	Variable browserNumber	// Change to the DF of the indicated DPBrowser	String savedDF=ChangeToBrowserDF(browserNumber)		//ControlInfo cursor_check  // no control named "cursor_check" seems to exist anymore--ALT 2012-07-05	//if (V_value>0)	//	String doit	//	sprintf doit, "PlaceCursors(\"%s\")", thiswave	//	Execute doit	//endif		// Get the window name of the DPBrowser	String browserName=BrowserNameFromNumber(browserNumber)		// Scale the y axis	ControlInfo autoscaley_check	if (V_value)		Setaxis /W=$browserName /A left  // autoscale the left (y) axis	else		NVAR yMin=yMin, yMax=yMax		Setaxis /W=$browserName left yMin, yMax  // set the y axis to have the limits stored in the DF	endif		// Scale the x axis	ControlInfo autoscalex_check	if (V_value)		Setaxis /W=$browserName /A bottom    // autoscale the bottom (x) axis	else		NVAR xMin=xMin, xMax=xMax		Setaxis /W=$browserName bottom xMin, xMax  // set the x axis to have the limits stored in the DF	endif		// Restore the original DF	SetDataFolder savedDFEndFunction SyncDFAxesLimitsWithGraph(browserNumber)	// Reads the axes limits from the graph of the given DPBrowser, and writes those values to the	// xMin, xMax, etc. variables in the DF	Variable browserNumber	// Switch the DF to the browser DF, note the former DF name	String savedDFName=ChangeToBrowserDF(browserNumber)	// Get the graph limits, set the ones stored in the browser DF to those	NVAR xMin=xMin, xMax=xMax, yMin=yMin, yMax=yMax	GetAxis /Q bottom	xMin=V_min; xMax=V_max	GetAxis /Q left	yMin=V_min; yMax=V_max		// Restore old DF	SetDataFolder savedDFNameEndFunction PlaceCursors(where)	String where	NVAR acsrx=acsrx, bcsrx=bcsrx	Cursor /C=(0,0,0) A, $where, acsrx	Cursor /C=(0,0,0) B, $where, bcsrxEnd//------------------FUNCTIONS AND PROCEDURES FOR WAVE NOTES------------------//Function WriteWaveNote(theWave, theNote, theValue)	Wave theWave	String theNote, theValue	Variable start, first, last	String oldnote, newnote	oldnote=note(theWave)	start=strsearch(oldnote,theNote,0)	first=strsearch(oldnote,"=",start)	last=strsearch(oldnote,"\r", first)	if (start<0)		sprintf newnote, "%s=%s", theNote, theValue	else		sprintf newnote, "%s%s%s", oldnote[0,first], theValue,oldnote[last,strlen(oldnote)]		Note /K theWave	endif	Note theWave, newnoteEndFunction GetWaveNoteNumber(theWave, theNote)	Wave theWave	String theNote	Variable start, theValue	String oldnote, newnote//	String savDF=GetDataFolder(1)//	SetDataFolder root:	oldnote=note(theWave)	start=strsearch(oldnote,theNote,0)	if (start<0)		if (cmpstr(theNote,"BASELINE")==0)			Wavestats /Q/R=[0,100] theWave			theValue=V_avg		else			theValue=0		endif		sprintf newnote, "%s=%f", theNote, theValue		Note theWave, newnote	endif	theValue=NumberByKey(theNote, note(theWave), "=", "\r")	return theValue//	SetDataFolder savDFEndFunction /S GetWaveNoteString(theWave, theNote)	Wave theWave	String theNote	String savDF=GetDataFolder(1)	SetDataFolder root:	Variable start	String theValue, oldnote, newnote	oldnote=note(theWave)	start=strsearch(oldnote,theNote,0)	if (start<0)		sprintf newnote, "%s=0", theNote		Note theWave, newnote	endif	theValue=StringByKey(theNote, Note(theWave), "=", "\r")	SetDataFolder savDF	return theValueEndFunction/S GetPopupItems(flag)	String flag	String theFolderPath = "root:DP_ADCDACcontrol"	if (!DataFolderExists(theFolderPath))		return ""	endif	String dfSave = GetDataFolder(1)	SetDataFolder theFolderPath	String items, theString	theString="*_"+flag	items=WaveList(theString, ";", "")	SetDataFolder dfSave		return itemsEndFunction PanelExists(windowName)	String windowName	return (strlen(WinList(windowName,";","WIN:64"))>0)  // 64 is code for panelEndFunction GraphExists(windowName)	String windowName	return (strlen(WinList(windowName,";","WIN:1"))>0)  // 1 is code for graphEndFunction /S sprintf1d(templateString,i)	String templateString	Variable i		String outputString	sprintf outputString templateString i	return outputStringEndFunction /S sprintf1s(templateString,str)	String templateString	String str		String outputString	sprintf outputString templateString str	return outputStringEndFunction /S BrowserNameFromNumber(browserNumber)	Variable browserNumber	String browserName	sprintf browserName "DataProBrowser%d" browserNumber	return browserNameEndFunction /S MeasurePanelNameFromNumber(browserNumber)	Variable browserNumber	String measurePanelName	sprintf measurePanelName "MeasurePanel%d" browserNumber	return measurePanelNameEndFunction /S FitPanelNameFromNumber(browserNumber)	Variable browserNumber	String windowName	sprintf windowName "FitPanel%d" browserNumber	return windowNameEndFunction /S AveragePanelNameFromNumber(browserNumber)	Variable browserNumber	String windowName	sprintf windowName "AveragePanel%d" browserNumber	return windowNameEndFunction BrowserNumberFromName(browserName)	String browserName	String baseName, browserNumberAsString	SplitString /E="([a-zA-Z]*)([0-9]+)" browserName, baseName, browserNumberAsString	// Convert to a number (not a string) and return	Variable browserNumber=str2num(browserNumberAsString)  // will be nan if a non-number string	return browserNumberEndFunction /S BrowserTitleFromNumber(browserNumber)	Variable browserNumber	String browserTitle	sprintf browserTitle "DataProBrowser %d" browserNumber	return browserTitleEndFunction /S BrowserDFNameFromNumber(browserNumber)	Variable browserNumber	String browserDFName	sprintf browserDFName "root:DP_Browser_%d" browserNumber	return browserDFNameEndFunction /S AbsoluteVarName(DFName,localVarName)	String dfName, localVarName	String absVarName	sprintf absVarName "%s:%s" DFName, localVarName	return absVarNameEndFunction GetTopBrowserNumber()	//windowName=WinName(0,1)	String windowList=WinList("DataProBrowser*",";","WIN:1")	if (strlen(windowList)==0)		return NaN  // signals that there are no DataProBrowser windows	endif	String windowName, moreWindowNames	SplitString /E="([a-zA-Z0-9]*);(.*)" windowList, windowName, moreWindowNames	if (strlen(windowName)==0)		return NaN  // signals that there are no DataProBrowser windows	endif	Variable browserNumber=BrowserNumberFromName(windowName)	return browserNumberEndFunction DetermineBrowserNumberForNew()	String topwin, key, doit	Variable browserNumber	String windowName, windowNameCheck	Variable done=0	for (browserNumber=0;!done;browserNumber+=1)		sprintf windowName, "DataProBrowser%d", browserNumber		windowNameCheck=WinList(windowName,"","")		if (strlen(windowNameCheck)==0)			done=1			break  // don't wan't browserNumber incremented at end of this iteration		endif	endfor	// browserNumber is now the number of the next DataProBrowser window	return browserNumberEndFunction /S ChangeToBrowserDF(browserNumber)	Variable browserNumber	// Save the current DF, set the data folder to the appropriate one for this DataProBrowser instance	String savedDFName=GetDataFolder(1)	String browserDFName=BrowserDFNameFromNumber(browserNumber)	SetDataFolder browserDFName	return savedDFNameEnd