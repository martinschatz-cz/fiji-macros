

iROI = 0;
//function makeBand(iROI) {
	roiManager("Select", iROI);
	run("Make Inverse");
	roiManager("Add");
	roiManager("Select", iROI);
	run("Enlarge...", "enlarge=0.80");
	roiManager("Update");
	roiManager("Select", newArray(iROI,iROI+1));
	roiManager("AND");
	roiManager("Add");

	roiManager("Select", iROI);
	roiManager("Delete");

//}
