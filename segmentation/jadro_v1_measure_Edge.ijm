			roiManager("reset");
			run("Remove Overlay");
			//run("Stack to Hyperstack...", "order=xyczt(default) channels=3 slices=1 frames=1 display=Composite");
			run("Stack to Hyperstack...", "order=xyczt(default) channels=3 slices=1 frames=1 display=Color");
			Stack.setChannel(1) 
Stime=getTime();
////////////////////Detekce
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
			
			setBatchMode(false);
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