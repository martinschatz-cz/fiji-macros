path= File.openDialog("Choose .czi file");
macroName = File.openDialog("Choose segmenting .ijm");
//alternatively run through batch
roiManager("reset");
cropAndAnalyze(path, macroName);


/**************************** MACRO ***************************************/
function cropAndAnalyze(path, macroName) {
setBatchMode(true);
print("\\Clear"); //clear log window
run("Bio-Formats Macro Extensions");

name=File.getName(path);

baseDir=File.getParent(path); //parent folder
subDir=baseDir+File.separator+"dataRAW"+File.separator; //where to save just exported subset
var cropDir=baseDir+File.separator+"croped"+File.separator; //where to save croped images

if (!File.isDirectory(subDir)) File.makeDirectory(subDir); //create folder if not exist
if (!File.isDirectory(cropDir)) File.makeDirectory(cropDir); //create folder if not exist

Ext.setId(path);
Ext.getSeriesCount(seriesCount); //get number of series in dataset

//Ext.setSeries(s); //set active series
	Ext.getSeriesName(sN);
	print(sN); 
	Ext.getImageCount(imageCount);
	Ext.getSizeX(sizeX);
	print(sizeX+" size X");
	Ext.getSizeY(sizeY);
	print(sizeY+" size Y");
	Ext.getSizeC(sizeC);
	Ext.getSizeZ(sizeZ);
	Ext.getSizeT(sizeT);
	Ext.getPixelsPhysicalSizeX(psizeX);
	Ext.getPixelsPhysicalSizeY(psizeY);
	Ext.getPixelsPhysicalSizeZ(psizeZ);
cpX=1;
cpY=1;
maxSize=5000;
if (sizeX >= maxSize || sizeY >= maxSize) { //if image size is too big
	partX = sizeX/maxSize;				//part it to size I am comfortable with
	partY = sizeY/maxSize;

	if ((partX % 1) > 0){
	cpX = floor(partX)+1;
	}
	print("divide image in "+cpX+ " parts in X");
	
	if ((partY % 1) > 0){
	cpY = floor(partY)+1;
	}
	print("divide image in "+cpY+ " parts in Y");
}

if (cpX > 1 || cpY > 1) {
	count=1;
	sTime=getTime();
	for (xc = 0; xc <= cpX-1; xc++) {
		for (yc = 0; yc <= cpY-1; yc++) {
			xcoo=xc*maxSize;            //coordinates origin
			ycoo=yc*maxSize;			  
			xcoe=(xc+1)*maxSize;		  //coordinates end
			ycoe=(yc+1)*maxSize;

			xcut=maxSize;               // size of final image
			ycut=maxSize;

			if (xcoe > sizeX) {
				xcoe = sizeX;
				xcut = sizeX-xcoo;
			}
			if (ycoe > sizeY) {
				ycoe = sizeY;
				ycut = sizeY-ycoo;
			}
			
			print("coord start "+xcoo+", "+ycoo+"; coord end "+xcoe+", "+ycoe+"; cut "+xcut+", "+ycut);
			channel=newArray(sizeC);
			for (c=0; c<sizeC; c++) {
				Ext.openSubImage("X: "+xc+"; Y: "+yc, c, xcoo, ycoo, xcut, ycut);
				channel[c]=getTitle();
			}
			//exit();
			//run("Merge Channels...", "c1=["+channel[0]+"] c2=["+channel[1]+"] c3=["+channel[2]+"] create");
			run("Images to Stack", "name=Stack title=[] use");
			run("Stack to Hyperstack...", "order=xyczt(default) channels=3 slices=1 frames=1 display=Composite");
			run("Properties...", "unit=um pixel_width="+parseFloat(psizeX)+" pixel_height="+parseFloat(psizeY)+" voxel_depth="+parseFloat(psizeZ));
			//name=name+"_"+count;
			print(name);
			//runMacro(macroName);
			runMacro(macroName);
			//save if needed
			saveAs("Tiff", subDir+name+"_"+count+"--"+xc+"-"+yc+".tif"); //save RAW files, xc part in x, yc part in y
			//crop image according to roiManager
			rmCount=roiManager("count");
			if (rmCount>0) {
				cropROIs(1.05); //crop 5% bigger bounding box;
				roiManager("deselect");
				roiManager("save", subDir+name+"--"+xc+"-"+yc+".zip");
				selectWindow("Results");
				saveAs("Results", subDir+name+"--"+xc+"-"+yc+".txt");
			}
			//
			Ext.closeFileOnly();
			selectWindow(name+"_"+count+"--"+xc+"-"+yc+".tif"); close();
			now=getTime();
			print("Estimated time is: "+(((now-sTime)/count)*(cpX*cpY-count))/1000/60+" min.");
			showStatus("Estimated time is: "+(((now-sTime)/count)*(cpX*cpY-count))/1000/60+" min.");
			count=count+1;
		}
	}
}
Ext.close();
setBatchMode(false);
print("finito");
//label=getMetadata("Label");
//name=substring(label, 0, indexOf(label, "--"));

//saveAs("Tiff", RAWDir+name+"--"+xc+"-"+yc+".tif"); //save RAW files, xc part in x, yc part in y
} //end of cropAndanalyze

function cropROIs(enlargeFactor){
	title=getTitle();
	name=replace(title, ".tif", "");
	name=replace(name, ".czi", "");
	rmCount=roiManager("count");
	rmList=newArray(rmCount);
	//if (rmCount>0) {
		for (r=0; r<rmCount; r++) {
			selectImage(title);
			roiManager("select", r);
			run("To Bounding Box");
			getSelectionBounds(x, y, bwidth, bheight);

			if (bwidth>bheight) {
				enlargeFactor=abs(bheight-150);
			}
			if (bwidth<bheight) {
				enlargeFactor=abs(bwidth-150);
			}
			print("Enlarged by "+enlargeFactor);
			//enlargeFactor=maxOf(round((bwidth*enlargeFactor)-bwidth), round((bheight*enlargeFactor)-bheight));
			run("Enlarge...", "enlarge="+enlargeFactor+" pixel");
			//run("Enlarge...", "enlarge=25 pixel");
			roiManager("Add");
			rmList[r]=r;
			//roiManager("select", r);
			index=getStrNum(r, 5);
			iname=name+"_"+index+".tif";
			run("Duplicate...", "title="+iname+" duplicate");
			saveAs("Tiff", cropDir+iname);
			print(cropDir+iname);
			close();
		}
	//}
roiManager("select", rmList);
roiManager("delete");
} //end of function

function getStrNum(value, numbers) { //value = numeric value, numbers=number of numeros
	index=10;
	Val=toString(value);
	while (lengthOf(Val)<numbers) {
		Val="0"+Val;
	}
	return Val; //i.e. 000005
}