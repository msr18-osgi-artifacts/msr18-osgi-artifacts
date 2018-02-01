module org::analyzer::analysis::smells::useVersions::Evaluator

import Set;

import lang::csv::IO;

import org::analyzer::models::OSGiModelBuilder;
import org::analyzer::util::OSGiUtil;


//--------------------------------------------------------------------------------
// Metrics
//--------------------------------------------------------------------------------

// Required Bundles
public int numberUnversionedRequiredBundles(OSGiModel model) 
	= numberRequiredBundles("none", model);

public int numberStrictVersionRequiredBundles(OSGiModel model) 
	= numberRequiredBundles("strict", model);
	
public int numberRangeVersionRequiredBundles(OSGiModel model) 
	= numberRequiredBundles("range", model);

private int numberRequiredBundles(str versionSpec, OSGiModel model)
	= (0 | it + 1 | <bundle, reqBundle, params> <- model.requiredBundles, params["version-spec"] == versionSpec);	


// Imported Packages
public int numberUnversionedImportedPackages(OSGiModel model) 
	= numberImportedPackages("none", model);

public int numberStrictVersionImportedPackages(OSGiModel model) 
	= numberImportedPackages("strict", model);
	
public int numberRangeVersionImportedPackages(OSGiModel model) 
	= numberImportedPackages("range", model);

private int numberImportedPackages(str versionSpec, OSGiModel model)
	= (0 | it + 1 | <bundle, pkg, params> <- model.importedPackages, params["version-spec"] == versionSpec);
	

// Exported Packages
public int numberUnversionedExportedPackages(OSGiModel model) 
	= numberExportedPackages("none", model);

public int numberVersionedExportedPackages(OSGiModel model) 
	= numberExportedPackages("strict", model);

private int numberExportedPackages(str versionSpec, OSGiModel model)
	= (0 | it + 1 | <bundle, pkg, params> <- model.exportedPackages, params["version-spec"] == versionSpec);
		

//--------------------------------------------------------------------------------
// CSV
//--------------------------------------------------------------------------------
		
public rel[str,int] cvsRequiredBundlesVersion(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	rel[str category, tuple[loc,loc,map[str,str]] dependency] relation = {
		<params["version-spec"], <bundle, reqBundle, params>> 
		| <bundle, reqBundle, params> <- model.requiredBundles};
	rel[str category, int noDependencies] frequencies = {<n, size(relation[n])> | n <- relation.category};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[str,int] csvImportedPackagesVersion(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	rel[str category, tuple[loc,loc,map[str,str]] dependency] relation = {
		<params["version-spec"], <bundle, impPackage, params>> 
		| <bundle, impPackage, params> <- model.importedPackages};
	rel[str category, int noDependencies] frequencies = {<n, size(relation[n])> | n <- relation.category};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[str,int] csvExportedPackagesVersion(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	rel[str category, tuple[loc,loc,map[str,str]] dependency] relation = {
		<params["version-spec"], <bundle, expPackage, params>> | 
		<bundle, expPackage, params> <- model.exportedPackages};
	rel[str category, int noDependencies] frequencies = {<n, size(relation[n])> | n <- relation.category};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}