module org::crossminer::analysis::smells::minimizeDependencies::Evaluator

import Set;

import lang::csv::IO;

import org::crossminer::analysis::smells::Util;
import org::crossminer::models::CrossminerBuilder;
import org::crossminer::models::helpers::ExtensionDiscoverer;
import org::crossminer::util::CrossminerUtil;

//--------------------------------------------------------------------------------
// Metrics
//--------------------------------------------------------------------------------

// Reference
public int numberRequiredPackages(CrossminerModel model)
	= size(getPackagesReqBundles(model));
	
	
// Used dependencies
public int numberUsedImportedPackages(CrossminerModel model) 
	=size(getUsedImportedPackagesBundle(model));

public int numberUsedRequiredBundles(CrossminerModel model) 
	= size(getUsedRequiredBundles(model));

public int numberUsedRequiredPackages(CrossminerModel model) 
	= size(getUsedRequiredPackages(model));
	
public int numberUsedReexpReqBundlePackages(CrossminerModel model) 
	= size(getUsedReexpReqBundlesPackages(model));


// Unused dependencies
public int numberUnusedImportedPackages(CrossminerModel model) 
	= size(getUnusedImportedPackagesBundle(model));

public int numberUnusedRequiredBundles(CrossminerModel model) 
	= size(getUnusedRequiredBundles(model));
	
public int numberUnusedRequiredPackages(CrossminerModel model) 
	= size(getUnusedRequiredPackages(model));


//--------------------------------------------------------------------------------
// CSV
//--------------------------------------------------------------------------------

//TODO: Consider totals?
public rel[int,int,rel[loc,set[loc]]] csvUsedImportedPackages(CrossminerModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	usedImportedPackages = getUsedImportedPackagesBundle(model);
	rel[int usePkgs, tuple[loc,set[loc]] dependencies] relation = {
		<size(usedImportedPackages[bundle]), <bundle,usedImportedPackages[bundle]>>
		| bundle <- model.locations.logical};
	rel[int usePkgs, int noBundles, rel[loc,set[loc]] dependencies] frequencies = {
		<n, size(relation[n]), relation[n]> | n <- [0..(max(relation.usePkgs) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[int,int,rel[loc,set[loc]]] csvUsedPackagesReqBundles(CrossminerModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	requiredPackages = getUsedRequiredBundles(model);
	rel[int usePkgs, tuple[loc,set[loc]] dependencies] relation = { 
		<size(requiredPackages[bundle]), <bundle, requiredPackages[bundle]>>
		| bundle <- model.locations.logical};
	rel[int usePkgs, int noBundles, rel[loc,set[loc]] dependencies] frequencies = {
		<n, size(relation[n]), relation[n]> | n <- [0..(max(relation.usePkgs) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[int,int,rel[loc,set[loc]]] getUsedPackagesTransitiveReqBundlesDistribution(CrossminerModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
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
private rel[loc,loc] getUsedImportedPackagesBundle(CrossminerModel model) {
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
private rel[loc,loc] getUnusedImportedPackagesBundle(CrossminerModel model) {
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
public rel[loc,loc] getUsedRequiredBundles(CrossminerModel model) {
	exportedPackages = toBinaryRelation(model.exportedPackages);
	return {<b,r> | <b,r,p> <- model.requiredBundles, 
		size(exportedPackages[r] & model.importedPackagesBC[b]) > 0};
}

/*
 * Returns a relation with used required bundle packages. 
 * Extension bundles are included in the count.
 */
public rel[loc,loc] getUnusedRequiredBundles(CrossminerModel model) {
	exportedPackages = toBinaryRelation(model.exportedPackages);
	return {<b,r> | <b,r,p> <- model.requiredBundles, 
		size(exportedPackages[r] & model.importedPackagesBC[b]) == 0};
}

/*
 * Returns a relation with used required bundle packages. 
 * Extension bundles are included in the count.
 */
public rel[loc,loc] getUsedRequiredPackages(CrossminerModel model) 
	 = getPackagesReqBundles(model) & model.importedPackagesBC;

/*
 * Returns a relation with used required bundle packages. 
 * Extension bundles are included in the count.
 */
public rel[loc,loc] getUnusedRequiredPackages(CrossminerModel model) 
	= getPackagesReqBundles(model) - (getPackagesReqBundles(model) & model.importedPackagesBC);

/*
 * Returns a relation with used reexp required bundle
 * packages.
 */
private rel[loc,loc] getUsedReexpReqBundlesPackages(CrossminerModel model) {		
	requiredPackages = getReexpReqBundlesPackages(model);
	return {*({bundle} * (requiredPackages[bundle] & model.importedPackagesBC[bundle])) 
		 | bundle <- model.locations.logical};
}