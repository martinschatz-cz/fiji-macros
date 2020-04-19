   print("\\Clear")
   dir = getDirectory("Vyber složku");
   setBatchMode(true);
   count = 0;
   countFiles(dir);
   n = 0;
   //processFiles(dir);
   print(count+" souborů ke zpracování");	
		   processFiles(dir);
		   print("");
		   print("");
		   print("");
		   print("Hotovo");
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
          if (endsWith(list[i], ".czi")) {
          	 path = dir+list[i];
             print(path);
             doSomething(dir,list[i]); 
             }
          else {
             print("Není .tif : "+dir+list[i]); 
          }
      }
  }


function doSomething(dir,file) {
	run("Bio-Formats Importer", "open=["+dir+file+"] autoscale color_mode=Default rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT series_2 c_begin_2=1 c_end_2=3 c_step_2=1");
	name=replace(file,".czi","");
	print(name);
	sdir=dir + "tiff2" + File.separator + file;
	saveAs("Tiff", sdir);
	run("Close All");
}


