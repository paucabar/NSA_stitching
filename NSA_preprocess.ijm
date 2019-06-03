//script parameters
#@ File(label="Directory", style="directory") dir
#@ String (visibility=MESSAGE, value="Enter a postfix to tag the output folder") msg
//#@ String (label="Postfix") postfix

print("\\Clear");
original=File.getName(dir);
list=getFileList(dir);
Array.sort(list);
outputFlatField=File.getParent(dir)+File.separator+original+"_flat-field";
outputCorrected=File.getParent(dir)+File.separator+original+"_corrected";

//check if the folder contains tif files
tifFiles=0;
for (i=0; i<list.length; i++) {
	if (endsWith(list[i], "tif")==true) {
		tifFiles++;
	}
}

//error message
if (tifFiles==0) {
	exit("No tif files found in "+original);
}

//create a an array containing only the names of the tif files in the folder
tifArray=newArray(tifFiles);
count=0;
for (i=0; i<list.length; i++) {
	if (endsWith(list[i], "tif")) {
		tifArray[count]=list[i];
		count++;
	}
}

//count the number of wells
nWells=1;
well=newArray(tifFiles);
well0=substring(tifArray[0],0,6);
for (i=0; i<tifFiles; i++) {
	well[i]=substring(tifArray[i],0,6);
	well1=substring(tifArray[i],0,6);
	if (well1!=well0) {
		nWells++;
		well0=substring(tifArray[i],0,6);
	}
}

wellName=newArray(nWells);
fieldsxwell = (tifFiles/nWells);

for (i=0; i<nWells; i++) {
	wellName[i]=well[i*fieldsxwell];
}

fields=newArray(fieldsxwell);
for (i=0; i<fieldsxwell; i++) {
	fieldNumber=d2s(i+1, 0);
	while (lengthOf(fieldNumber)<2) {
		fieldNumber="0"+fieldNumber;
	}
	fields[i]=fieldNumber;
}

//create the output folder
File.makeDirectory(outputFlatField);
File.makeDirectory(outputCorrected);

setBatchMode(true);
for (i=0; i<fieldsxwell; i++) {
	name="stack_"+fields[i];
	run("Image Sequence...", "open="+dir+" file=[(fld "+fields[i]+")] sort");
	rename(name);
	run("BaSiC ", "processing_stack="+name+" flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate flat-field only (ignore dark-field)] setting_regularisationparametes=Automatic temporal_drift=Ignore correction_options=[Compute shading only] lambda_flat=0.50 lambda_dark=0.50");
	selectWindow("Flat-field:"+name);
	saveAs("tif", outputFlatField+File.separator+"flat-field_"+fields[i]);
	run("Close All");
}

setBatchMode(false);