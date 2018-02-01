module org::analyzer::util::OSGiExporter

import lang::csv::IO;
import lang::json::IO;

import org::analyzer::models::OSGiModelBuilder;
import org::analyzer::util::OSGiUtil;


public void generateRequiredBundlesCSV(OSGiModel model, loc pathCSV=OSGI_MODEL_CSV_PATH + "requiredBundles.csv") 
	= writeCSV(model.requiredBundles, pathCSV);

public void generateImportedPackagesCSV(OSGiModel model, loc pathCSV=OSGI_MODEL_CSV_PATH + "importedPackages.csv") 
	= writeCSV(model.importedPackages, pathCSV);
	
public void generateExportedPackagesCSV(OSGiModel model, loc pathCSV=OSGI_MODEL_CSV_PATH + "exportedPackages.csv") 
	= writeCSV(model.exportedPackages, pathCSV);
	
public void generateImportedPackagesBCCSV(OSGiModel model, loc pathCSV=OSGI_MODEL_CSV_PATH + "importedPackagesBC.csv") 
	= writeCSV(model.importedPackagesBC, pathCSV);
	
public void generateBundlePackagesBCCSV(OSGiModel model, loc pathCSV=OSGI_MODEL_CSV_PATH + "bundlePackagesBC.csv") 
	= writeCSV(model.bundlePackagesBC, pathCSV);
	
public void generateRequiredBundlesJSON(OSGiModel model, loc pathJSON=OSGI_MODEL_CSV_PATH + "requiredBundles.json") 
	= writeJSON(pathJSON, model.requiredBundles);

public void generateImportedPackagesJSON(OSGiModel model, loc pathJSON=OSGI_MODEL_CSV_PATH + "importedPackages.json") 
	= writeJSON(pathJSON, model.importedPackages);
	
public void generateExportedPackagesJSON(OSGiModel model, loc pathJSON=OSGI_MODEL_CSV_PATH + "exportedPackages.json") 
	= writeJSON(pathJSON, model.exportedPackages);
	
public void generateImportedPackagesBCJSON(OSGiModel model, loc pathJSON=OSGI_MODEL_CSV_PATH + "importedPackagesBC.json") 
	= writeJSON(pathJSON, model.importedPackagesBC);
	
public void generateBundlePackagesBCJSON(OSGiModel model, loc pathJSON=OSGI_MODEL_CSV_PATH + "bundlePackagesBC.json") 
	= writeJSON(pathJSON, model.bundlePackagesBC);