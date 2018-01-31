module org::crossminer::analysis::smells::neededPackages::Evaluator

import Set;
import String;

import lang::csv::IO;

import org::crossminer::analysis::smells::Util;
import org::crossminer::models::CrossminerBuilder;
import org::crossminer::util::CrossminerUtil;


//--------------------------------------------------------------------------------
// Metrics
//--------------------------------------------------------------------------------

public int numberUsedUnimportedPackages(CrossminerModel model)
	= size(getUsedUnimportedPackages(model));
	
public int numberBundlesWithUUPkgs(CrossminerModel model) {
	rel[loc bundle, loc pkg] usedUnimportedPackages = getUsedUnimportedPackages(model);
	return size(usedUnimportedPackages.bundle);
}

public int numberUniqueUUPkgs(CrossminerModel model) {
	rel[loc bundle, loc pkg] usedUnimportedPackages = getUsedUnimportedPackages(model);
	return size(usedUnimportedPackages.pkg);
}


//--------------------------------------------------------------------------------
// CSV
//--------------------------------------------------------------------------------

/*
 * Returns a relation whose first element represents bundles' logical locations and the second element
 * the number of related used unimported packages. If writeCSV is set to true the function generates a 
 * CSV file setting the number of unused imported packages in the first slot, number of bundles with 
 * that frequency in the second slot, and the set of related bundles symbolic names in the third slot.
 */
public rel[int,int,int,tuple[loc,set[loc]]] csvUsedUnimportedPackages(CrossminerModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	usedUnimportedPackages = getUsedUnimportedPackages(model);
	requiredPackages = getPackagesReqBundles(model);
	
	rel[int usedPacks, int impPacks, int reqPacks, tuple[loc,set[loc]] dependency] relation = {
			<size(usedUnimportedPackages[logical]), size(model.importedPackages[logical]), 
			size(requiredPackages[logical]), <logical, usedUnimportedPackages[logical]>> 
			| logical <- model.locations.logical};
												  										
	if(csv) { writeCSV(relation, pathCSV); }
	return relation;
}


//--------------------------------------------------------------------------------
// Util
//--------------------------------------------------------------------------------

/*
 * Returns a set with the used unimported packages of a 
 * given bundle (both required bundles and imported packages
 * are considered).
 */
public rel[loc,loc] getUsedUnimportedPackages(CrossminerModel model) {
	importedPackages = toBinaryRelation(model.importedPackages);
	requiredPackages = getPackagesReqBundles(model);
	return model.importedPackagesBC - importedPackages - requiredPackages - model.bundlePackagesBC;
}