
//run("Threshold...");
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
print("Num: " + roiManager("count"));