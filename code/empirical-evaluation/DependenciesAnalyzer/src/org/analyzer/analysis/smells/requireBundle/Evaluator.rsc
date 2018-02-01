module org::analyzer::analysis::smells::requireBundle::Evaluator

import Relation;
import Set;

import lang::csv::IO;

import org::analyzer::analysis::smells::Util;
import org::analyzer::models::OSGiModelBuilder;
import org::analyzer::models::helpers::ExtensionDiscoverer;
import org::analyzer::util::OSGiUtil;


//--------------------------------------------------------------------------------
// Metrics
//--------------------------------------------------------------------------------

//Relations
public int numberRequiredBundles(OSGiModel model) 
	= size(model.requiredBundles);
	
public int numberImportedPackages(OSGiModel model) 
	= size(model.importedPackages);
	
	
//Headers
public int numberRequireBundleHeaders(OSGiModel model)
	= size(model.requiredBundles.bundle);
	
public int numberImportPackageHeaders(OSGiModel model) 
	= size(model.importedPackages.bundle);
	
public int numberReqBundImpPackHeaders(OSGiModel model)
	= size(model.requiredBundles.bundle & model.importedPackages.bundle);

//Mandatory required bundles
public int numberExtensionBundles(OSGiModel model) {
	Extension ext = getExtensionBundles(model);
	return size(ext.extensions.bundle);
}

public int numberBundlesWithSplitPackages(OSGiModel model) 
	= size({bundle | <bundle,pkg,params> <- model.importedPackages, params["split"] != "none"});

public int numberExportedSplitPackages(OSGiModel model)
	= (0 | it + 1 | <bundle,pkg,params> <- model.exportedPackages, params["split"] != "none");
	

//--------------------------------------------------------------------------------
// CSV
//--------------------------------------------------------------------------------

public rel[int,int,set[loc]] csvRequiredBundles(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH){
	rel[int noReqBundles, loc bundles] relation = {
		<size(model.requiredBundles[logical]), logical> | logical <- model.locations.logical};
	rel[int noReqBundles, int noBundles, set[loc] bundles] frequencies = {
		<n, size(relation[n]), relation[n]> | n <- [0..(max(relation.noReqBundles) + 1)]};
			   	
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[int,int,set[loc]] csvImportedPackages(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH){
	rel[int noImpPackages, loc bundles] relation = {
		<size(model.importedPackages[logical]), logical> | logical <- model.locations.logical};
	rel[int noImpPkgs, int noBundles, set[loc] bundles] frequencies = {
		<n, size(relation[n]), relation[n]> | n <- [0..(max(relation.noImpPackages) + 1)]};
	
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[real,int,tuple[loc,loc]] csvRatioUsedPackagesReqBundles(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	rel[loc,loc] exportedPackages = toBinaryRelation(model.exportedPackages);
	rel[real useRatio, int impPkgs, tuple[loc,loc] dependency] relation = { 
		<(size(model.importedPackagesBC[bundle] & exportedPackages[reqBundle]) + 0.0) / 
		size(model.exportedPackages[reqBundle]), size(model.exportedPackages[reqBundle]),
		<bundle, reqBundle>> | <bundle, reqBundle, params> <- model.requiredBundles, size(model.exportedPackages[reqBundle]) != 0};
			   	
	if(csv) { writeCSV(relation, pathCSV); }
	return relation;
}

public rel[real,int,tuple[loc,loc]] csvRatioUsedPackagesReqBundlesReexp(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	rel[loc,loc] exportedPackages = toBinaryRelation(model.exportedPackages);
	rel[loc,loc] requiredBundles = getReexpRequiredBundles(model);
	
	rel[real useRatio, int impPkgs, tuple[loc,loc] dependency] relation = { 
		<(size(model.importedPackagesBC[bundle] & exportedPackages[reqBundle]) + 0.0) / 
		size(model.exportedPackages[reqBundle]), size(model.exportedPackages[reqBundle]),
		<bundle, reqBundle>> | <bundle, reqBundle> <- requiredBundles, size(model.exportedPackages[reqBundle]) != 0};
			   	
	if(csv) { writeCSV(relation, pathCSV); }
	return relation;
}

public rel[int,int,set[loc]] csvPackageExporters(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	invExportedPackages = invert(model.exportedPackages);
	
	rel[int to, loc from] relation = {
		<size(invExportedPackages[_,p]), p> | p <- model.exportedPackages.expPackage};
	rel[int noExporters, int noPackages, set[loc] packages] frequencies = {
		<n, size(relation[n]), relation[n]> | n <- [0..(max(relation.to) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[int,int,rel[loc,str,set[loc]]] csvVersionedPackageExporters(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	versExportedPackages = {<p, m["version"]> | <b, p, m> <- model.exportedPackages};
	rel[int noExporters, tuple[loc,str,set[loc]] dependencies] relation = {
		<size(getPackageExporters(p,v,model)), <p,v, getPackageExporters(p,v,model)>> | <p,v> <- versExportedPackages};
	rel[int noExporters, int noPackages, rel[loc,str,set[loc]] dependencies] frequencies = {
		<n, size(relation[n]), relation[n]> | n <- [0..(max(relation.noExporters) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

/*
 * 	Returns a seto of bundles exporting the given package with the related version.
 */
private set[loc] getPackageExporters(loc pkg, str version, OSGiModel model) {
	invExportedPackages = invert(model.exportedPackages);
	bundles = {};
	for(b <- invExportedPackages[_,pkg]) {
		bundles += {b | params <- model.exportedPackages[b,pkg], params["version"] == version};
	}
	return bundles;
}