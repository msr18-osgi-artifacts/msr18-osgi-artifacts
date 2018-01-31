module org::crossminer::analysis::smells::useVersions::Evaluator

import Set;

import lang::csv::IO;

import org::crossminer::models::CrossminerBuilder;
import org::crossminer::util::CrossminerUtil;


//--------------------------------------------------------------------------------
// Metrics
//--------------------------------------------------------------------------------

// Required Bundles
public int numberUnversionedRequiredBundles(CrossminerModel model) 
	= numberRequiredBundles("none", model);

public int numberStrictVersionRequiredBundles(CrossminerModel model) 
	= numberRequiredBundles("strict", model);
	
public int numberRangeVersionRequiredBundles(CrossminerModel model) 
	= numberRequiredBundles("range", model);

private int numberRequiredBundles(str versionSpec, CrossminerModel model)
	= (0 | it + 1 | <bundle, reqBundle, params> <- model.requiredBundles, params["version-spec"] == versionSpec);	


// Imported Packages
public int numberUnversionedImportedPackages(CrossminerModel model) 
	= numberImportedPackages("none", model);

public int numberStrictVersionImportedPackages(CrossminerModel model) 
	= numberImportedPackages("strict", model);
	
public int numberRangeVersionImportedPackages(CrossminerModel model) 
	= numberImportedPackages("range", model);

private int numberImportedPackages(str versionSpec, CrossminerModel model)
	= (0 | it + 1 | <bundle, pkg, params> <- model.importedPackages, params["version-spec"] == versionSpec);
	

// Exported Packages
public int numberUnversionedExportedPackages(CrossminerModel model) 
	= numberExportedPackages("none", model);

public int numberVersionedExportedPackages(CrossminerModel model) 
	= numberExportedPackages("strict", model);

private int numberExportedPackages(str versionSpec, CrossminerModel model)
	= (0 | it + 1 | <bundle, pkg, params> <- model.exportedPackages, params["version-spec"] == versionSpec);
		

//--------------------------------------------------------------------------------
// CSV
//--------------------------------------------------------------------------------
		
public rel[str,int] cvsRequiredBundlesVersion(CrossminerModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	rel[str category, tuple[loc,loc,map[str,str]] dependency] relation = {
		<params["version-spec"], <bundle, reqBundle, params>> 
		| <bundle, reqBundle, params> <- model.requiredBundles};
	rel[str category, int noDependencies] frequencies = {<n, size(relation[n])> | n <- relation.category};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[str,int] csvImportedPackagesVersion(CrossminerModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	rel[str category, tuple[loc,loc,map[str,str]] dependency] relation = {
		<params["version-spec"], <bundle, impPackage, params>> 
		| <bundle, impPackage, params> <- model.importedPackages};
	rel[str category, int noDependencies] frequencies = {<n, size(relation[n])> | n <- relation.category};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[str,int] csvExportedPackagesVersion(CrossminerModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	rel[str category, tuple[loc,loc,map[str,str]] dependency] relation = {
		<params["version-spec"], <bundle, expPackage, params>> | 
		<bundle, expPackage, params> <- model.exportedPackages};
	rel[str category, int noDependencies] frequencies = {<n, size(relation[n])> | n <- relation.category};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}