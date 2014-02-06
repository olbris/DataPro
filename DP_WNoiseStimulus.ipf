#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function /WAVE WNoiseGetParamNames()
	Variable nParameters=4
	Make /T /FREE /N=(nParameters) parameterNames
	parameterNames[0]="delay"
	parameterNames[1]="duration"
	parameterNames[2]="mu"
	parameterNames[3]="sigma"
	return parameterNames
End

Function /WAVE WNoiseGetDefaultParams()
	Variable nParameters=4
	Make /FREE /N=(nParameters) parametersDefault
	parametersDefault[0]=10
	parametersDefault[1]=50
	parametersDefault[2]=0
	parametersDefault[3]=1	
	return parametersDefault
End

Function WNoiseFillFromParams(w,parameters)
	Wave w
	Wave parameters

	Variable delay=parameters[0]
	Variable duration=parameters[1]
	Variable mu=parameters[2]
	Variable sigma=parameters[3]
	
	w=(mu+gnoise(sigma))*unitPulse(x-delay,duration)
End

Function /S WNoiseGetSignalType()
	return "DAC"
End
