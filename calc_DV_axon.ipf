#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// Measure the DV % for each point in the axon
function DV_quant()
	wave yaxon, xaxon
	wave yvent, xvent
	wave ydors, xdors
	
	duplicate/O yaxon perc 
	duplicate/o yaxon yaxon1
	yaxon1 = abs(yaxon - 2000)   // shifts these to 
	duplicate/o yvent yvent1
	yvent1= abs(yvent - 2000) 
	duplicate/o ydors ydors1
	ydors1= abs(ydors - 2000) 

	variable p, i
	p=numpnts(yaxon)
	
	variable av, dv     //av is difference between axon and ventral, dv is diff btn dorsal and ventral SC
	variable dx, d, v    // dx is the x value of the y point along the axon trace, which is then mapped onto dor and vent (d and a)
	for (i=0;i<p;i+=1)
		dx = xaxon[i]
		d = binarysearch(xdors, dx)
		v =  binarysearch(xvent,dx)
		av = yaxon1[i] - yvent1[v]
		dv = ydors1[d] - yvent1[v]
		perc[i]= av/dv
	endfor
	
	string folder = ""
	folder = Getdatafolder(0)
	string name = ""
	name = folder+"perc"
	string name2 = ""
	name2 = folder + "hist"
	
	make/o/n=100 perc_hist
	Histogram/B={0,0.01,100} perc, perc_Hist
	duplicate/O perc $name
	duplicate/O perc_Hist $name2
	killwaves ydors1, yvent1, yaxon1, perc, perc_hist
end

Function/S DoLoadMultipleFiles()
	Variable refNum
	String message = "Select one or more files"
	String outputPaths
	String fileFilters = "Data Files (*.txt,*.dat,*.csv):.txt,.dat,.csv;"
	fileFilters += "All Files:.*;"
 
	Open /D /R /MULT=1 /F=fileFilters /M=message refNum
	outputPaths = S_fileName
 
	if (strlen(outputPaths) == 0)
		Print "Cancelled"
	else
		Variable numFilesSelected = ItemsInList(outputPaths, "\r")
		Variable i
		for(i=0; i<numFilesSelected; i+=1)
			String path = StringFromList(i, outputPaths, "\r")
			Printf "%d: %s\r", i, path
			// Add commands here to load the actual waves.  An example command
			// is included below but you will need to modify it depending on how
			// the data you are loading is organized.
			LoadWave/D/J/W/K=0/V={" "," $",0,0}/L={0,2,0,0,0} path
		endfor
	endif

End

function Newnorm(input)
	wave input
	
	duplicate/o input n_input
	n_input = (input-wavemin(input))/( wavemax(input)-wavemin(input))
	string name = ""
	name = "N_"+Nameofwave(input)
	duplicate/O n_input $name
	
	killwaves n_input
end	

function xatpeak(wave0)
	wave wave0
	
	variable nn,cc
	nn = wavemax(wave0)
	FindLevel wave0, nn
	cc= v_levelx
	print cc
end

function DV_quantmulti(yaxon,xaxon,str)
	wave yaxon, xaxon
	string str
	wave yvent, xvent
	wave ydors, xdors
	
	duplicate/O yaxon perc 
	duplicate/o yaxon yaxon1
	yaxon1 = abs(yaxon - 2000)   // shifts these to 
	duplicate/o yvent yvent1
	yvent1= abs(yvent - 2000) 
	duplicate/o ydors ydors1
	ydors1= abs(ydors - 2000) 

	variable p, i
	p=numpnts(yaxon)
	
	variable av, dv     //av is difference between axon and ventral, dv is diff btn dorsal and ventral SC
	variable dx, d, v    // dx is the x value of the y point along the axon trace, which is then mapped onto dor and vent (d and a)
	for (i=0;i<p;i+=1)
		dx = xaxon[i]
		d = interp(dx, xdors, ydors1)
		v =  interp(dx,xvent, yvent1)
		//d = xdors(dx)
		//v =  xvent(dx)
		//av = yaxon1[i] - yvent1(dx)
		//dv = ydors1(dx)- yvent1(dx)
		av = yaxon1[i]-v
		dv = d- v
		perc[i]= av/dv
	endfor
	
	string folder = ""
	folder = Getdatafolder(0)
	string name = ""
	name = folder + "_" +str+"perc"
	string name2 = ""
	name2 =  folder + "_" +str+ "hist"
	
	make/o/n=100 perc_hist
	Histogram/B={0,0.01,100} perc, perc_Hist
	duplicate/O perc $name
	duplicate/O perc_Hist $name2
	killwaves ydors1, yvent1, yaxon1, perc, perc_hist
end