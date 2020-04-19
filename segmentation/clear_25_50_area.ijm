   print("\\Clear")
   dir = getDirectory("Vyber složku");
   setBatchMode(true);
   count = 0;
   countFiles(dir);
   n = 0;
   //processFiles(dir);
   print(count+" souborů ke zpracování");
    subDir=dir+File.separator+"selected"+File.separator; //where to save just exported subset
	if (!File.isDirectory(subDir)) File.makeDirectory(subDir); //create folder if not exist

   processFiles(dir);
   print("");
   print("");
   print("");
   print("Hotovo");
   setBatchMode(false);

   
   selectWindow("Log");  //select Log-window 
	saveAs("Text", dir+"log.txt"); 
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

  function runAnalysis(dir,file) {
  			open(dir+file);
			setAutoThreshold("Default");
			setThreshold(1, 139);
			run("Threshold...");
			run("Convert to Mask", "method=Default background=Light black");
			run("Measure");
			
			area = getResult("%Area", 0);
			print(file+" has area: "+area);
			
			Table.deleteRows(0, 1);
			run("Close All");
			if (area > 25 && area < 60) {
				File.copy(dir+file, dir+"selected"+File.separator+file);
				print(file+" moved");
			}
			
  }