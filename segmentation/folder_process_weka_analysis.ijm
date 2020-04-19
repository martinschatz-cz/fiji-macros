   print("\\Clear")
   run("Close All");
   dir = getDirectory("Vyber složku");
   //setBatchMode(true);
   count = 0;
   countFiles(dir);
   n = 0;
   //processFiles(dir);
   print(count+" souborů ke zpracování");

		   print("-------------RGB:"+rgb+"---------------");
		   processFiles(dir);
		   print("");
		   print("");
		   print("");
		   print("Hotovo");

   setBatchMode(false);

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
          	 print("----------------------------");
             print(path);
             print("----------------------------");
             runAnalysis(dir,list[i]); }
          else {
             print("Není .tif : "+dir+list[i]); 
          }
      }
  }



  function runAnalysis(dir,file) {
  			open(dir+file);
  			roiManager("reset");

Stime=getTime();
////////////////////Detekce
////////////////////Zpracovani
setThreshold(1, 2);
run("Convert to Mask", "method=Default background=Dark black");
setThreshold(0, 2);
run("Convert to Mask", "method=Default background=Dark black");

run("Fill Holes", "slice");
//setTool("zoom");
run("Dilate", "slice");
run("Dilate", "slice");
run("Erode", "slice");
run("Erode", "slice");
run("Fill Holes", "slice");
run("Set Measurements...", "area centroid center fit shape limit display nan redirect=None decimal=5");
run("Analyze Particles...", "size=10-50 exclude add slice");
roiManager("Measure");

RlengthO=roiManager("count");
for (i = RlengthO-1; i > 0; i--) {
				circ = getResult("Circ.", i);
				area = getResult("Area", i);
				if (area < 10 || circ <= 0.5 || circ >= 0.90) {
					roiManager("Select", i);
					roiManager("Delete");
			}
}
print(replace(file,".tif","") + ": " + roiManager("count"));

////////////////////Vysledky
			print("-----" + getTime() + "-----");

		
now=getTime();
print("Čas: "+(now-Stime)/1000/60);		
saveAs("Results", dir+"/"+replace(file,".tif","")+"results_channel"+rgb+".txt");
//print("Res"+replace(file,".tif","")+".csv uloženo");
  }
