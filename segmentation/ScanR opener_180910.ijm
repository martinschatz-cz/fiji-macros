/* 
 *  version 180910 opening missing files will no longer stop the macro
 *  version 170521 also read acquistionLog.dat to get XYZT positions of series.
 *  version 170520	is able to basically process all data. Incomplete datasets are skipped.
 *  Version 170520: starting. I would like to retrieve all needed information and metadata
 *  via Bio-Formats.
 *  This macro is aimed to help convert big scan-R data to readable and accessable format
 *  such as tif is.
 *  
 *  edit line 124 for include macro for measurement.
 */
//difinition of global variables
//FLAGS
var incompletenessFLAG=false; //flag if all files in series are correctly loaded

//VARIABLES
var acqLogFile; //AcquisitionLog.dat as string

/**************************** MACRO ***************************************/
sTime=getTime();
setBatchMode(true);
print("\\Clear"); //clear log window
run("Bio-Formats Macro Extensions");
do { //ensure right file is picqued up
	id = File.openDialog("Choose experiment_descriptor.xml file");
} while (!endsWith(id, "experiment_descriptor.xml"));

baseDir=File.getParent(id); //parent folder
dataDir=baseDir+File.separator+"data"+File.separator;
RAWDir=baseDir+File.separator+"data RAW"+File.separator; //where to save just exported raw files
uprDir=baseDir+File.separator+"data upr"+File.separator; //where to save enhanced files
measDir=baseDir+File.separator+"data measurement"+File.separator; //where to store measurement image data
descriptorPath=baseDir+File.separator+"AcquisitionLog.dat"; //path to descriptorLog.dat file
acqLogFile=File.openAsString(descriptorPath); //open descriptorLog.dat file

if (!File.isDirectory(RAWDir)) File.makeDirectory(RAWDir); //create folder if not exist
if (!File.isDirectory(uprDir)) File.makeDirectory(uprDir); //create folder if not exist
if (!File.isDirectory(measDir)) File.makeDirectory(measDir); //create folder if not exist
//set ID of dataset
Ext.setId(id);
Ext.getSeriesCount(seriesCount); //get number of series in dataset
//print(seriesCount+" images is going to be processed");

//for each series do
//for (seriesNum=0; seriesNum<seriesCount; seriesNum++) {
eTime=getTime();
print("Initializtion took "+eTime-sTime+" ms");
for (s=0; s<seriesCount; s++) {
	showProgress(s/seriesCount-1);
	Ext.setSeries(s); //set active series
	Ext.getSeriesName(sN);
	print(sN); 
	Ext.getImageCount(imageCount);
	Ext.getSizeX(sizeX);
	Ext.getSizeY(sizeY);
	Ext.getSizeC(sizeC);
	Ext.getSizeZ(sizeZ);
	Ext.getSizeT(sizeT);
	expectedDataSize=imageCount; //+1;
	//expectedDataSize=sizeC*sizeZ*sizeT;
	Ext.getDimensionOrder(dimOrder); //dimension order
	dimOrder=toLowerCase(dimOrder);
	if (dimOrder=="xyczt") dimOrder="xyczt(default)";
	Ext.getMetadataValue("conversion factor um/pixel", pixelSize);
	//Ext.getPixelsPhysicalSizeZ(calZ);
	Ext.getMetadataValue("slices distance", calZ);
	//Ext.getPixelsTimeIncrement(calT);
	//timeloop delay [ms]	1200000
	Ext.getMetadataValue("timeloop delay [ms]", calT);
	calT=parseInt(calT)/1000; //convert to seconds
	
	well=parseInt(substring(sN, lastIndexOf(sN, "Well ")+5, indexOf(sN, ",")));
	pos=parseInt(substring(sN, lastIndexOf(sN, "Field ")+6, indexOf(sN, " (")));
	fileMask="W"+getStrNum(well,5)+"--P"+getStrNum(pos,5);
	//get position coordinates
	//getPositionCoordinates(W, P, T, Z)
	position=getPositionCoordinates(well, pos, 0, 0);
	posX=position[0]; //stage X position in um
	posY=position[1]; //stage Y position in um
	posZ=position[2]; //stage first Z postion in um
	posT=position[3]; //stage position acquistion time since experiment start in seconds
	print("stage position "+posX+" ; "+posY);

	//opening
	IJ.redirectErrorMessages();
	run("Image Sequence...", "open=["+dataDir+"] file="+fileMask+" sort"); //open image series
	//in case dataset is completely missing, here has to be error statement....
	if (nImages>0) {
	realDataSize=nSlices; //get lodaded stack size for control
	if (expectedDataSize==realDataSize) { //control of dataset completeness
		run("Properties...", "unit=µm pixel_width="+pixelSize+" pixel_height="+pixelSize+" voxel_depth="+calZ+" frame=["+calT+" sec] origin="+posX+";"+posY+";"+posZ+";"+posT);
		if (realDataSize>1)	run("Stack to Hyperstack...", "order="+dimOrder+" channels="+sizeC+" slices="+sizeZ+" frames="+sizeT+" display=Color");
		
		//renaming
		//Stack.setPosition(channel, slice, frame)
		if (Stack.isHyperstack) Stack.setPosition(1, 1, 1);
		label=getMetadata("Label");
		name=substring(label, 0, indexOf(label, "--"));
		rename(name+"--"+fileMask);
		//print(name);
		for (ch=1; ch<=sizeC; ch++) {
			if (Stack.isHyperstack) {
				Stack.setPosition(ch, 1, 1);
				
			}
			resetMinAndMax();
			label=getMetadata("Label");
			channelName=substring(label, lastIndexOf(label, "--")+2, indexOf(label, "."));
			print(name+"--"+fileMask+"--"+channelName);
			if (channelName=="Dapi") run("Blue");
			if (channelName=="GFP") run("Green");
			if (channelName=="Red")	run("Red");
			if (channelName=="Transmission") run("Grays");
			//other channel names and their respective LUTs has to be define here...	
		}
		//saving
		Stack.setDisplayMode("composite");
		saveAs("Tiff", RAWDir+name+"--"+fileMask+".tif"); //save RAW files
		imgID=getImageID();

		//run measurement
		/*
		 * here can be code for some kind of analysis or start another macro file.
		 */
		 runMacro("/media/schebique/Anton/ScanR DATA/Barbora Kalouskova/Imunoligand_BC_20x_002/measurement.ijm");
	} //end of dataSize is ok.
	else {
		print("Loaded data are incomplete. "+expectedDataSize-realDataSize+" planes are missing!");
		print("Skipping "+sN);
		incompletenessFLAG=true;
		imgID=getImageID();
		//here could be code to try save incomplete dataset anyway.
	} //end of else - dataSize not ok.
	//closing stack.
	if (isOpen(imgID)) {
		selectImage(imgID);
		close();
	}
	}//else from if nImages>0
}
setBatchMode(false);
selectWindow("Log");
saveAs("Text", baseDir+"Conversion_log_file.txt");
print("macro finished all "+seriesCount+" files conversion.");
/*print("in "+seriesNum+" series");
Ext.getImageCount(imageCount);
print("with "+imageCount+" planes in each series");
baseDir=File.getParent(id);
//print(baseDir);
destDir=baseDir+File.separator+"export"+File.separator;
Ext.getSizeX(sizeX);
Ext.getSizeY(sizeY);
Ext.getSizeC(sizeC);
Ext.getSizeZ(sizeZ);
Ext.getSizeT(sizeT);
print("Channels: "+sizeC);
print("Z-layers: "+sizeZ);
Ext.setSeries(149);
Ext.getSeriesName(seriesName);
print(seriesName);
print("Timepoints: "+sizeT);
*/

/**************************** FUNCTIONS ***************************************/
function getStrNum(value, numbers) { //value = numeric value, numbers=number of numeros
	index=10;
	Val=toString(value);
	while (lengthOf(Val)<numbers) {
		Val="0"+Val;
	}
	return Val; //i.e. 000005
}
//****************************
function getPositionCoordinates(W, P, T, Z) {
	//this function returns position coordinates acordint to acquistion log
	//X, Y, Z, T order
	index=indexOf(acqLogFile, "W="+W+"\tP="+P+"\tT="+T+"\tZ="+Z);
	if (index!=-1) {
		tempString=substring(acqLogFile, index);
		lines=split(tempString, "\n");
		line=lines[0];
		tabs=split(line, "\t");
		tabX=split(tabs[4],"="); X=parseFloat(tabX[1]);
		tabY=split(tabs[5],"="); Y=parseFloat(tabY[1]);
		tabZ=split(tabs[6],"="); Z=parseFloat(tabZ[1]);
		tabT=split(tabs[7],"="); T=parseFloat(tabT[1]);
	}
	else {X=0; Y=0; Z=0; T=-1;}
	//tempString=substring(acqLogFile, indexOf(acqLogFile, "//t"));
	
	//print(tempString);
	return newArray(X,Y,Z,T);
}
