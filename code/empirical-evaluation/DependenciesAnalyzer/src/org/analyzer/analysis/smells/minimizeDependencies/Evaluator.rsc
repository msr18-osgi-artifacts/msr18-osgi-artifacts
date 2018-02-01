module org::analyzer::analysis::smells::minimizeDependencies::Evaluator

import Set;

import lang::csv::IO;

import org::analyzer::analysis::smells::Util;
import org::analyzer::models::OSGiModelBuilder;
import org::analyzer::models::helpers::ExtensionDiscoverer;
import org::analyzer::util::OSGiUtil;

//--------------------------------------------------------------------------------
// Metrics
//--------------------------------------------------------------------------------

// Reference
public int numberRequiredPackages(OSGiModel model)
	= size(getPackagesReqBundles(model));
	
	
// Used dependencies
public int numberUsedImportedPackages(OSGiModel model) 
	=size(getUsedImportedPackagesBundle(model));

public int numberUsedRequiredBundles(OSGiModel model) 
	= size(getUsedRequiredBundles(model));

public int numberUsedRequiredPackages(OSGiModel model) 
	= size(getUsedRequiredPackages(model));
	
public int numberUsedReexpReqBundlePackages(OSGiModel model) 
	= size(getUsedReexpReqBundlesPackages(model));


// Unused dependencies
public int numberUnusedImportedPackages(OSGiModel model) 
	= size(getUnusedImportedPackagesBundle(model));

public int numberUnusedRequiredBundles(OSGiModel model) 
	= size(getUnusedRequiredBundles(model));
	
public int numberUnusedRequiredPackages(OSGiModel model) 
	= size(getUnusedRequiredPackages(model));


//--------------------------------------------------------------------------------
// CSV
//--------------------------------------------------------------------------------

//TODO: Consider totals?
public rel[int,int,rel[loc,set[loc]]] csvUsedImportedPackages(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	usedImportedPackages = getUsedImportedPackagesBundle(model);
	rel[int usePkgs, tuple[loc,set[loc]] dependencies] relation = {
		<size(usedImportedPackages[bundle]), <bundle,usedImportedPackages[bundle]>>
		| bundle <- model.locations.logical};
	rel[int usePkgs, int noBundles, rel[loc,set[loc]] dependencies] frequencies = {
		<n, size(relation[n]), relation[n]> | n <- [0..(max(relation.usePkgs) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[int,int,rel[loc,set[loc]]] csvUsedPackagesReqBundles(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	requiredPackages = getUsedRequiredBundles(model);
	rel[int usePkgs, tuple[loc,set[loc]] dependencies] relation = { 
		<size(requiredPackages[bundle]), <bundle, requiredPackages[bundle]>>
		| bundle <- model.locations.logical};
	rel[int usePkgs, int noBundles, rel[loc,set[loc]] dependencies] frequencies = {
		<n, size(relation[n]), relation[n]> | n <- [0..(max(relation.usePkgs) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[int,int,rel[loc,set[loc]]] getUsedPackagesTransitiveReqBundlesDistribution(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	requiredPackages = getUsedReexpReqBundlesPackages(model);
	rel[int usePkgs, tuple[loc,set[loc]] dependencies] relation = { 
		<size(requiredPackages[bundle]), <bundle, requiredPackages[bundle]>>
		| bundle <- model.locations.logical};
	rel[int usePkgs, int noBundles, rel[loc,set[loc]] dependencies] frequencies = {
		<n, size(relation[n]), relation[n]> | n <- [0..(max(relation.usePkgs) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}


//--------------------------------------------------------------------------------
// Util
//--------------------------------------------------------------------------------

/*
 * Returns a relation with used imported packages. Extension 
 * bundles are included in the count.
 */
private rel[loc,loc] getUsedImportedPackagesBundle(OSGiModel model) {
	importedPackages = toBinaryRelation(model.importedPackages);
	exportedPackages = toBinaryRelation(model.exportedPackages);
	
	return { *({bundle} * ((importedPackages[bundle] & model.importedPackagesBC[bundle]) + 
		(importedPackages[bundle] & exportedPackages[bundle] & model.bundlePackagesBC[bundle])))
		| bundle <- model.locations.logical};
}

/*
 * Returns a relation with unused imported packages. Extension 
 * bundles are included in the count.
 */
private rel[loc,loc] getUnusedImportedPackagesBundle(OSGiModel model) {
	importedPackages = toBinaryRelation(model.importedPackages);
	exportedPackages = toBinaryRelation(model.exportedPackages);
	
	return { *({bundle} * (importedPackages[bundle] - 
		((importedPackages[bundle] & model.importedPackagesBC[bundle]) + 
		(importedPackages[bundle] & exportedPackages[bundle] & model.bundlePackagesBC[bundle]))))
		| bundle <- model.locations.logical};
}

/*
 * Returns a relation with used required bundle packages. 
 * Extension bundles are included in the count.
 */
public rel[loc,loc] getUsedRequiredBundles(OSGiModel model) {
	exportedPackages = toBinaryRelation(model.exportedPackages);
	return {<b,r> | <b,r,p> <- model.requiredBundles, 
		size(exportedPackages[r] & model.importedPackagesBC[b]) > 0};
}

/*
 * Returns a relation with used required bundle packages. 
 * Extension bundles are included in the count.
 */
public rel[loc,loc] getUnusedRequiredBundles(OSGiModel model) {
	exportedPackages = toBinaryRelation(model.exportedPackages);
	return {<b,r> | <b,r,p> <- model.requiredBundles, 
		size(exportedPackages[r] & model.importedPackagesBC[b]) == 0};
}

/*
 * Returns a relation with used required bundle packages. 
 * Extension bundles are included in the count.
 */
public rel[loc,loc] getUsedRequiredPackages(OSGiModel model) 
	 = getPackagesReqBundles(model) & model.importedPackagesBC;

/*
 * Returns a relation with used required bundle packages. 
 * Extension bundles are included in the count.
 */
public rel[loc,loc] getUnusedRequiredPackages(OSGiModel model) 
	= getPackagesReqBundles(model) - (getPackagesReqBundles(model) & model.importedPackagesBC);

/*
 * Returns a relation with used reexp required bundle
 * packages.
 */
private rel[loc,loc] getUsedReexpReqBundlesPackages(OSGiModel model) {		
	requiredPackages = getReexpReqBundlesPackages(model);
	return {*({bundle} * (requiredPackages[bundle] & model.importedPackagesBC[bundle])) 
		 | bundle <- model.locations.logical};
}