module org::crossminer::util::CrossminerExporter

import lang::csv::IO;
import lang::json::IO;

import org::crossminer::models::CrossminerBuilder;
import org::crossminer::util::CrossminerUtil;


public void generateRequiredBundlesCSV(CrossminerModel model, loc pathCSV=CROSSMINER_MODEL_CSV_PATH + "requiredBundles.csv") 
	= writeCSV(model.requiredBundles, pathCSV);

public void generateImportedPackagesCSV(CrossminerModel model, loc pathCSV=CROSSMINER_MODEL_CSV_PATH + "importedPackages.csv") 
	= writeCSV(model.importedPackages, pathCSV);
	
public void generateExportedPackagesCSV(CrossminerModel model, loc pathCSV=CROSSMINER_MODEL_CSV_PATH + "exportedPackages.csv") 
	= writeCSV(model.exportedPackages, pathCSV);
	
public void generateImportedPackagesBCCSV(CrossminerModel model, loc pathCSV=CROSSMINER_MODEL_CSV_PATH + "importedPackagesBC.csv") 
	= writeCSV(model.importedPackagesBC, pathCSV);
	
public void generateBundlePackagesBCCSV(CrossminerModel model, loc pathCSV=CROSSMINER_MODEL_CSV_PATH + "bundlePackagesBC.csv") 
	= writeCSV(model.bundlePackagesBC, pathCSV);
	
public void generateRequiredBundlesJSON(CrossminerModel model, loc pathJSON=CROSSMINER_MODEL_CSV_PATH + "requiredBundles.json") 
	= writeJSON(pathJSON, model.requiredBundles);

public void generateImportedPackagesJSON(CrossminerModel model, loc pathJSON=CROSSMINER_MODEL_CSV_PATH + "importedPackages.json") 
	= writeJSON(pathJSON, model.importedPackages);
	
public void generateExportedPackagesJSON(CrossminerModel model, loc pathJSON=CROSSMINER_MODEL_CSV_PATH + "exportedPackages.json") 
	= writeJSON(pathJSON, model.exportedPackages);
	
public void generateImportedPackagesBCJSON(CrossminerModel model, loc pathJSON=CROSSMINER_MODEL_CSV_PATH + "importedPackagesBC.json") 
	= writeJSON(pathJSON, model.importedPackagesBC);
	
public void generateBundlePackagesBCJSON(CrossminerModel model, loc pathJSON=CROSSMINER_MODEL_CSV_PATH + "bundlePackagesBC.json") 
	= writeJSON(pathJSON, model.bundlePackagesBC);