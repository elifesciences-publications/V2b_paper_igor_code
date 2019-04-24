#pragma rtGlobals=3		// Use modern global access method and strict wave access.
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
// Operates on displayed trace to evaluate spike height, width at half-height, and AHP

Function spikeshape()
	Variable APht, APhw, AHP
	Variable peak_amp, peak_loc
	Variable inflection_amp, inflection_loc
	Variable AHP_amp, AHP_loc
	Variable APhh, APhht1, APhht2

	Variable dVthresh = 10000		// 10 V/s
	
	String toplist = WaveList("*",";","WIN:")
	
	Variable i
	
	For (i = 0; i < ItemsInList(toplist); i += 1)
		Duplicate/O $StringFromList(i, toplist), sswave
		
		Wavestats/Q sswave
		peak_amp = v_max
		peak_loc = v_maxloc
		
		Differentiate ssWave/D=ssWave_diff
		Smooth/B=1 9, ssWave_diff
		
		FindLevel/Q sswave_diff, dVthresh
		If (V_flag ==1)
			print "error! no crossings found 1"
			abort
		endif	
			
		inflection_loc = V_LevelX
		inflection_amp = ssWave(inflection_loc)	
		
		APht = peak_amp - Inflection_amp
		
		APhh = inflection_amp + 0.5*APht		// AP half height
		FindLevel/Q/EDGE=1 ssWave, APhh		// rising edge
		If (V_flag ==1)
			print "error! no crossings found 2"
			abort
		endif	
		
		APhht1 = V_LevelX
		
		FindLevel/Q/EDGE=2 ssWave, APhh		// rising edge
		If (V_flag ==1)
			print "error! no crossings found 3"
			abort
		endif	
		APhht2 = V_LevelX
		
		APhw = APhht2 - APhht1
		
		WaveStats/Q/R=(peak_loc, (peak_loc + 0.004)) ssWave
		AHP_amp = v_min
		AHP = AHP_amp - inflection_amp
		
		String spikePointsWavename, spikeTImesWavename
		spikePointswavename = StringFromList(i, toplist) + "_spikePts"
		spikeTimesWavename = StringFromList(i, toplist) + "_spikeTms"
		
		Make/O/N=3 $spikePointsWavename = {inflection_amp, peak_amp, AHP_amp, APhh, APhw}
		Make/O/N=3 $spikeTimesWaveName = {inflection_loc, peak_loc, v_minloc, APhht1, 0}

		Display $StringFromList(i, toplist)	
		AppendtoGraph $spikePointsWavename vs $spikeTimesWaveName
		ModifyGraph mode($spikePointsWavename)=3,marker($spikePointsWavename)=19
		ModifyGraph rgb($spikePointsWavename)=(16385,16388,65535)
		
		if (i==0)
			Edit
		endif
		AppendToTable $spikePointsWaveName	

	Endfor
	
End
