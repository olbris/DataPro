#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function PulseBuilderViewConstructor() : Graph
	//BuilderModelConstructor("Pulse")
	String savedDF=GetDataFolder(1)
	SetDataFolder root:DP_PulseBuilder
	WAVE theWave
	WAVE parameters
	Variable delay=parameters[0]
	Variable duration=parameters[1]
	//Variable pulseRate=parameters[2]				
	//Variable pulseDuration=parameters[3]			
	Variable baseLevel=parameters[2]
	Variable amplitude=parameters[3]			
	// These are all in pixels
	Variable xOffset=105
	Variable yOffset=200
	Variable width=705
	Variable height=400
	// Convert dimensions to points
	Variable pointsPerPixel=72/ScreenResolution
	Variable xOffsetInPoints=pointsPerPixel*xOffset
	Variable yOffsetInPoints=pointsPerPixel*yOffset
	Variable widthInPoints=pointsPerPixel*width
	Variable heightInPoints=pointsPerPixel*height
	Display /W=(xOffsetInPoints,yOffsetInPoints,xOffsetInPoints+widthInPoints,yOffsetInPoints+heightInPoints) /K=1 /N=PulseBuilderView theWave as "Pulse Builder"
	ModifyGraph /W=PulseBuilderView /Z grid(left)=1
	Label /W=PulseBuilderView /Z bottom "Time (ms)"
	Label /W=PulseBuilderView /Z left "Signal (pure)"
	ModifyGraph /W=PulseBuilderView /Z tickUnit(bottom)=1
	ModifyGraph /W=PulseBuilderView /Z tickUnit(left)=1
	ControlBar 80

	SetVariable delaySV,win=PulseBuilderView,pos={15,15},size={110,15},proc=BuilderContSVTwiddled,title="Delay (ms)"
	SetVariable delaySV,win=PulseBuilderView,limits={0,200000,1},value= _NUM:delay

	SetVariable durationSV,win=PulseBuilderView,pos={15,45},size={125,15},proc=BuilderContSVTwiddled,title="Duration (ms)"
	SetVariable durationSV,win=PulseBuilderView,limits={1,inf,1},value= _NUM:duration

	//SetVariable pulseRateSV,win=PulseBuilderView,pos={155,15},size={150,15},proc=BuilderContSVTwiddled,title="Pulse Rate (Hz)"
	//SetVariable pulseRateSV,win=PulseBuilderView,limits={0.001,inf,10},value= _NUM:pulseRate

	//SetVariable pulseDurationSV,win=PulseBuilderView,pos={155,45},size={140,15},proc=BuilderContSVTwiddled,title="Pulse Duration (ms)"
	//SetVariable pulseDurationSV,win=PulseBuilderView,limits={0.001,inf,1},value= _NUM:pulseDuration

	SetVariable baseLevelSV,win=PulseBuilderView,pos={165,15},size={110,15},proc=BuilderContSVTwiddled,title="Base Level"
	SetVariable baseLevelSV,win=PulseBuilderView,limits={-10000,10000,1},value= _NUM:baseLevel

	SetVariable amplitudeSV,win=PulseBuilderView,pos={165,45},size={110,15},proc=BuilderContSVTwiddled,title="Amplitude"
	SetVariable amplitudeSV,win=PulseBuilderView,limits={-10000,10000,10},value= _NUM:amplitude
	
	Button saveAsTTLButton,win=PulseBuilderView,pos={601,10},size={90,20},proc=BuilderContSaveAsButtonPressed,title="Save As..."
	//Button saveAsTTLButton,win=PulseBuilderView,pos={601,30},size={90,20},proc=BuilderContSaveAsButtonPressed,title="Save As TTL..."
	Button importButton,win=PulseBuilderView,pos={601,45},size={90,20},proc=BuilderContImportButtonPressed,title="Import..."
	SetDataFolder savedDF
End

//Function PulseBuilderModelInitialize()
//	// Called from the constructor, so DF already set.
//	SVAR builderType
//	Variable nParameters=StimulusGetNumOfParamsFromType(builderType)
//	Redimension /N=(nParameters) parametersDefault
//	parametersDefault[0]=20		// ms
//	parametersDefault[1]=100		// ms
//	parametersDefault[2]=0
//	parametersDefault[3]=10
//	Redimension /N=(nParameters) parameters
//	parameters=parametersDefault
//End
//
//Function fillPulseFromParamsBang(w,dt,nScans,parameters,parameterNames)
//	Wave w
//	Variable dt,nScans
//	Wave parameters
//	Wave /T parameterNames
//
//	Variable delay=parameters[0]
//	Variable duration=parameters[1]
//	Variable baseLevel=parameters[2]				
//	Variable amplitude=parameters[3]
//
//       // Somewhat controversial, but in the common case that pulse starts are sample-aligned, and pulse durations are
//       // an integer multiple of dt, this ensures that each pulse is exactly pulseDuration samples long
//	Variable delayTweaked=delay-dt/2
//
//	//Variable pulseDutyCycle=max(0,min((pulseDuration/1000)*pulseRate,1))		// pure
//	w=baseLevel+amplitude*unitPulse(x-delayTweaked,duration)
//End