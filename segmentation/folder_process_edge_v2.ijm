   print("\\Clear")
   dir = getDirectory("Vyber složku");
   setBatchMode(true);
   count = 0;
   countFiles(dir);
   n = 0;
   //processFiles(dir);
   print(count+" souborů ke zpracování");
   var rgb = 1;

   for (rgb = 1; rgb <= 3; rgb++) {
		var nal = 0;
		var odstr = 0;
		var zprac = 0;
		var zra = 0;
		var nezra = 0; 
		
		   processFiles(dir);
		   print("");
		   print("");
		   print("");
		   print("Hotovo");
		   setBatchMode(false);
		
		
					print("------------RGB_"+ rgb +"-------------");
					print("Nalezených: " + nal);
					print("Odstraněných: " + odstr);
					print("Zpracovaných: " + zprac);
					print("Zralých: " + zra);
					print("Nezralých: " + nezra);
		
		   
		   
   }
   setBatchMode(false);
   print("Finis");
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
      list = getFileList(dir);
      for (i=0; i<list.length; i++) {
          if (endsWith(list[i], ".tif")) {
          	 path = dir+list[i];
             print(path);
             runAnalysis(dir,list[i]); }
          else {
             print("Není .tif : "+dir+list[i]); 
          }
      }
  }

  function makeBand(iROI,Rlength) {
	roiManager("Show None");
	roiManager("Select", iROI);
	run("Make Inverse");
	roiManager("Add");
	roiManager("Select", iROI);
	run("Enlarge...", "enlarge=0.80");
	roiManager("Update");
	roiManager("Select", newArray(iROI,Rlength));
	roiManager("AND");
	roiManager("Update");
	roiManager("Select", Rlength);
	roiManager("Delete");
	roiManager("Add");
}

  function runAnalysis(dir,file) {
  			open(dir+file);
  			roiManager("reset");
			run("Remove Overlay");
			//run("Stack to Hyperstack...", "order=xyczt(default) channels=3 slices=1 frames=1 display=Composite");

			run("Split Channels");
			run("Images to Stack", "name="+replace(file,".tif","")+" title=[] use");
			
			run("Stack to Hyperstack...", "order=xyczt(default) channels=3 slices=1 frames=1 display=Color");
			Stack.setChannel(rgb) ;
Stime=getTime();
////////////////////Detekce
			//setBatchMode(true);
			run("Select None");
			title=getTitle();	
			selectWindow(title);
			run("Duplicate...", "duplicate channels=2");
			setAutoThreshold("Mean");
			run("Create Selection");
			roiManager("Add");
			roiManager("select", roiManager("count")-1);
			roiManager("Rename", "mask");
			//close();
			selectWindow(title);
			run("Duplicate...", "duplicate channels=1");
			median=getTitle();
			run("Invert");
			run("16-bit");
			run("Subtract Background...", "rolling=20");
			run("Median...", "radius=3");
			run("Gaussian Blur...", "sigma=2.50");
			setAutoThreshold("Moments dark");
			roiManager("Select", roiManager("count")-1);
			run("Find Maxima...", "prominence=2 exclude above output=[Segmented Particles]");
			run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack limit display nan redirect="+title+" decimal=5");
			
////////////////////Analyza
			run("Analyze Particles...", "size=5-30 circularity=0.40-1.00 display exclude clear add");

			run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack limit display nan redirect=None decimal=5");
			selectWindow(title);
			roiManager("Show None");
			roiManager("Show All");
			//roiManager("save", file-path)
////////////////////Preprocessing
			RlengthO=roiManager("count");
			
			setResult("Diff", 0, -1);
			setResult("Zraly", 0, -1);
			for (i = RlengthO-1; i > 0; i--) {
				circ = getResult("Circ.", i);
				feret = getResult("Feret", i);
				perim = getResult("Perim.", i);
					roiManager("Select", i);
					run("Enlarge...", "enlarge=0.40");
					roiManager("Update");
				if (feret > 6 || (1-circ) < 0.2 || perim > 14 ) {
					roiManager("Select", i);
					roiManager("Delete");
				}
				
			}
			
			Table.deleteRows(0, RlengthO-1);

			title=getTitle();	
			selectWindow(title);
			run("Duplicate...", "duplicate");
			
			run("Find Edges", "slice");

			
			roiManager("Measure");
			Rlength=roiManager("count");
			selectWindow(title);
////////////////////Zpracovani

			for (i = 0; i < Rlength; i++) {
				setResult("Zraly", i, 0);
			}
			
			//setBatchMode(false);
			run("Stack to Hyperstack...", "order=xyczt(default) channels=3 slices=1 frames=1 display=Composite");
			roiManager("Show All with labels");
			roiManager("Show All without labels");

			zraly = newArray();
			for (i = 0; i < Rlength; i++) {
				val=getResult("Max", i);
				if (val>80) {
					zraly = Array.concat(i,zraly);
					setResult("Zraly", i, 1);
				}
			}
			//Array.print(zraly);

			for (i = 0; i < zraly.length ; i++) {
				roiManager("Select", zraly[i]);
				roiManager("Delete");
			}
////////////////////Vysledky
			print("-----" + getTime() + "-----");
			print("Nalezených: " + (RlengthO));
			print("Odstraněných: " + (RlengthO - Rlength));
			print("Zpracovaných: " + Rlength);
			print("Zralých: " + zraly.length);
			print("Nezralých: " + (Rlength-zraly.length));
			nal = nal + RlengthO;
			odstr = odstr + (RlengthO - Rlength);
			zprac = zprac + Rlength;
			zra = zra + zraly.length;
			nezra = nezra + (Rlength-zraly.length);
			
		
now=getTime();
print("Čas: "+(now-Stime)/1000/60);		
run("Input/Output...", "jpeg=85 gif=-1 file=.csv use_file copy_column copy_row save_column save_row");
saveAs("Results", dir+"/ResEdge_"+replace(file,".tif","")+"cbannel"+rgb+".csv");
print("ResEdge_"+replace(file,".tif","")+".csv uloženo");
selectWindow("Log");  //select Log-window 
saveAs("Text", dir+replace(file,".tif","")+"_Edgelog_channel_"+rgb+".txt"); 
run("Close All");
			//run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack limit display nan redirect="+title+" decimal=5");
			//roiManager("Measure");
			
			//close();

			//selectWindow(title);
			//run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack limit display nan decimal=5");
			//roiManager("Measure");
  }
