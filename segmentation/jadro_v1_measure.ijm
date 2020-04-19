			roiManager("reset");
			//run("Stack to Hyperstack...", "order=xyczt(default) channels=3 slices=1 frames=1 display=Composite");
			run("Stack to Hyperstack...", "order=xyczt(default) channels=3 slices=1 frames=1 display=Color");
			Stack.setChannel(3) 
Stime=getTime();
			setBatchMode(true);
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
			run("Analyze Particles...", "size=5-30 circularity=0.40-1.00 display exclude clear add");

			run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack limit display nan redirect=None decimal=5");
			selectWindow(title);
			roiManager("Show None");
			roiManager("Show All");
			//roiManager("save", file-path)
			Rlength=roiManager("count");
			print(Rlength);
			for (i = 0; i < Rlength; i++) {
				//roiManager("Select", i);
				//run("Make Band...", "band=0.8");
				//roiManager("Update");		
				makeBand(0,Rlength);
			}
			roiManager("Show All");
			roiManager("Measure");
			setBatchMode(false);
now=getTime();
print((now-Stime)/1000/60);			
			//run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack limit display nan redirect="+title+" decimal=5");
			//roiManager("Measure");
			
			//close();

			//selectWindow(title);
			//run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack limit display nan decimal=5");
			//roiManager("Measure");



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