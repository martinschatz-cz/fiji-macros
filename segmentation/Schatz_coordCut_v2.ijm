/**************************** MACRO ***************************************/

setBatchMode(true);
print("\\Clear"); //clear log window
run("Bio-Formats Macro Extensions");

	id = File.openDialog("Choose .czi file");

baseDir=File.getParent(id); //parent folder
subDir=baseDir+File.separator+"dataRAW"+File.separator; //where to save just exported subset

if (!File.isDirectory(subDir)) File.makeDirectory(subDir); //create folder if not exist

Ext.setId(id);
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
cpX=1;
cpY=1;
if (sizeX >= 20000 || sizeY >= 20000) { //if image size is too big
	partX = sizeX/20000;				//part it to size I am comfortable with
	partY = sizeY/20000;

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
			xcoo=xc*20000;            //coordinates origin
			ycoo=yc*20000;			  
			xcoe=(xc+1)*20000;		  //coordinates end
			ycoe=(yc+1)*20000;

			xcut=20000;               // size of final image
			ycut=20000;

			if (xcoe > sizeX) {
				xcoe = sizeX;
				xcut = sizeX-xcoo;
			}
			if (ycoe > sizeY) {
				ycoe = sizeY;
				ycut = sizeY-ycoo;
			}
			
			print("coord start "+xcoo+", "+ycoo+"; coord end "+xcoe+", "+ycoe+"; cut "+xcut+", "+ycut);
			//Ext.openSubImage("X: "+xc+"; Y: "+yc, 0, xcoo, ycoo, xcut, ycut);
			name="im"+count;
			print(name);
			
			run("Bio-Formats Importer", "open=["+id+"] autoscale color_mode=Default crop rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT series_1 c_begin_1=1 c_end_1="+sizeC+" c_step_1=1 x_coordinate_1="+xcoo+" y_coordinate_1="+ycoo+" width_1="+xcut+" height_1="+ycut+"");
			saveAs("Tiff", subDir+name+"--"+xc+"-"+yc+".tif"); //save RAW files, xc part in x, yc part in y
			close();
			//Ext.closeFileOnly();
			now=getTime();
			print("Estimated time is: "+(((now-sTime)/count)*(cpX*cpY-count))/1000/60+" min.");
			count=count+1;
		}
	}
}
Ext.close();
print("finito");
//label=getMetadata("Label");
//name=substring(label, 0, indexOf(label, "--"));

//saveAs("Tiff", RAWDir+name+"--"+xc+"-"+yc+".tif"); //save RAW files, xc part in x, yc part in y