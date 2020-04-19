   print("\\Clear")
   dir = getDirectory("Vyber složku");
   setBatchMode(true);
   count = 0;
   countFiles(dir);
   n = 0;
   //processFiles(dir);
   print(count+" souborů ke zpracování");


   processFiles(dir);



   //////////////////////////////
   function countFiles(dir) {
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], "/"))
              countFiles(""+dir+list[i]);
          else
              count++;
      }
  }

  function processFiles(dir) {
  	//setBatchMode(true);
	//print("\\Clear"); //clear log window
	run("Bio-Formats Macro Extensions");
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], ".czi")) {
          	 path = dir+list[i];
             print(path);
             runAnalysis(dir,list[i]); }
          else {
             print("Není .czi : "+dir+list[i]); 
          }
      }
  }

    function runAnalysis(dir,file) {
			//baseDir=File.getParent(path); //parent folder
			name=replace(file,".czi","");
			print(name);
			var cropDir=dir+File.separator+"croped10_"+name+File.separator; //where to save croped images

			if (!File.isDirectory(cropDir)) File.makeDirectory(cropDir); //create folder if not exist

			//check file//
			spfile=dir+file;
			//print(spfile);
			Ext.setId(spfile);
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
			Ext.closeFileOnly();
			cpX=1;
			cpY=10;
			maxSizeX=sizeX/cpX;
			maxSizeY=sizeY/cpY;
			
			if (cpX >= 1 || cpY >= 1) {
				count=1;
				sTime=getTime();
				for (xc = 0; xc <= cpX-1; xc++) {
					//for (yc = 0; yc <= cpY-1; yc++) {
					for (yc = 0; yc <= 0; yc++) {
						xcoo=xc*maxSizeX;            //coordinates origin
						ycoo=yc*maxSizeY;			  
						xcoe=(xc+1)*maxSizeX;		  //coordinates end
						ycoe=(yc+1)*maxSizeY;
			
						xcut=maxSizeX;               // size of final image
						ycut=maxSizeY;
			
						if (xcoe > sizeX) {
							xcoe = sizeX;
							xcut = sizeX-xcoo;
						}
						if (ycoe > sizeY) {
							ycoe = sizeY;
							ycut = sizeY-ycoo;
						}
						
						print("coord start "+xcoo+", "+ycoo+"; coord end "+xcoe+", "+ycoe+"; cut "+xcut+", "+ycut);
						run("Bio-Formats Importer", "open=["+spfile+"] autoscale color_mode=Default crop rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT series_1 c_begin_1=1 c_end_1="+sizeC+" c_step_1=1 x_coordinate_1="+xcoo+" y_coordinate_1="+ycoo+" width_1="+xcoe+" height_1="+ycoe);
						fname=name+"_"+count+"--"+xc+"-"+yc;
						rename(fname);
						print(fname);
						//run("Images to Stack", "name=Stack title=["+name+"] use");
						run("Stack to Hyperstack...", "order=xyczt(default) channels=3 slices=1 frames=1 display=Color");
						run("Properties...", "unit=um pixel_width="+parseFloat(psizeX)+" pixel_height="+parseFloat(psizeY)+" voxel_depth="+parseFloat(psizeZ));
						saveAs("Tiff", cropDir+File.separator+fname);
						run("Close All");
					}
				}
			}
			Ext.close();
			setBatchMode(false);
			print("finito");
    }



function getStrNum(value, numbers) { //value = numeric value, numbers=number of numeros
	index=10;
	Val=toString(value);
	while (lengthOf(Val)<numbers) {
		Val="0"+Val;
	}
	return Val; //i.e. 000005
}