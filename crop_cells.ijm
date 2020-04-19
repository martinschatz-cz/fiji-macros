orig=getTitle();
run("RGB Color");
//makeRectangle(2232, 936, 6408, 7320);
//run("Crop");
run("Median...", "radius=2");
RGB=getTitle();
//selectImage(orig); close();
// Color Thresholder 2.0.0-rc-68/1.52i
// Autogenerated macro, single images only!
selectImage(RGB);
min=newArray(3);
max=newArray(3);
filter=newArray(3);
run("Duplicate...", "title=RGB-2");
run("Duplicate...", "title=mask-1");
a=getTitle();
run("HSB Stack");
run("Convert Stack to Images");
selectWindow("Hue");
rename("0");
selectWindow("Saturation");
rename("1");
selectWindow("Brightness");
rename("2");
min[0]=157;
max[0]=221;
filter[0]="stop";
min[1]=26;
max[1]=255;
filter[1]="pass";
min[2]=0;
max[2]=221;
filter[2]="pass";
for (i=0;i<3;i++){
  selectWindow(""+i);
  setThreshold(min[i], max[i]);
  run("Convert to Mask");
  if (filter[i]=="stop")  run("Invert");
}
imageCalculator("AND create", "0","1");
imageCalculator("AND create", "Result of 0","2");
for (i=0;i<3;i++){
  selectWindow(""+i);
  close();
}
selectWindow("Result of 0");
close();
selectWindow("Result of Result of 0");
rename(a);
// Colour Thresholding-------------

run("Create Selection");
setBackgroundColor(0, 0, 0);
selectImage("RGB-2");
run("Restore Selection");
run("Clear", "slice");
// Color Thresholder 2.0.0-rc-68/1.52i
// Autogenerated macro, single images only!
min=newArray(3);
max=newArray(3);
filter=newArray(3);
a=getTitle();
run("HSB Stack");
run("Convert Stack to Images");
selectWindow("Hue");
rename("0");
selectWindow("Saturation");
rename("1");
selectWindow("Brightness");
rename("2");
min[0]=154;
max[0]=225;
filter[0]="pass";
min[1]=22;
max[1]=255;
filter[1]="pass";
min[2]=0;
max[2]=255;
filter[2]="pass";
for (i=0;i<3;i++){
  selectWindow(""+i);
  setThreshold(min[i], max[i]);
  run("Convert to Mask");
  if (filter[i]=="stop")  run("Invert");
}
imageCalculator("AND create", "0","1");
imageCalculator("AND create", "Result of 0","2");
for (i=0;i<3;i++){
  selectWindow(""+i);
  close();
}
selectWindow("Result of 0");
close();
selectWindow("Result of Result of 0");
rename(orig);
// Colour Thresholding-------------
run("Set Measurements...", "area center bounding shape limit display nan redirect=None decimal=3");
roiManager("reset");
run("Analyze Particles...", "size=18.40-Infinity show=Nothing display clear include add");
//clean up 
close();
selectWindow("mask-1"); close();
selectWindow(RGB); close();
roiManager("Show All without labels");

