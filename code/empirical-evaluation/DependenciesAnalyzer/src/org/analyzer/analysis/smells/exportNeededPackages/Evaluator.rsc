module org::analyzer::analysis::smells::exportNeededPackages::Evaluator

import IO;
import Relation;
import Set;
import String;

import lang::csv::IO;

import org::analyzer::models::OSGiModelBuilder;
import org::analyzer::util::OSGiUtil;


//--------------------------------------------------------------------------------
// Metrics
//--------------------------------------------------------------------------------

public int numberImportedExpPkgs(OSGiModel model) {
	invImportedPackages = invert(model.importedPackages);
	return (0 | it + 1 | p <- model.exportedPackages.expPackage, size(invImportedPackages[_,p]) > 0);
}

public int numberUniqueVersionedImportedExpPkgs(OSGiModel model) {
	versExportedPackages = {<p, m["version"]> | <b, p, m> <- model.exportedPackages};
	return (0 | it + 1 | <p,v> <- versExportedPackages, size(getPackageImporters(p,v,model)) > 0);
}

public int numberVersionedImportedExpPkgs(OSGiModel model) 
	= (0 | it + 1 | <b, p, m> <- model.exportedPackages, size(getPackageImporters(p,m["version"],model)) > 0);
	
public int numberVersionedImportedRequiredExpPkgs(OSGiModel model) 
	= (0 | it + 1 | <b, p, m> <- model.exportedPackages, 
	(size(getPackageImporters(p,m["version"],model)) > 0 || size(model.requiredBundles[_,b]) > 0));


//--------------------------------------------------------------------------------
// CSV
//--------------------------------------------------------------------------------

public rel[int,int,rel[loc,set[loc]]] csvImportersExpPkgs(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	invImportedPackages = invert(model.importedPackages);

	rel[int to, tuple[loc,set[loc]] from] relation = {
		<size(invImportedPackages[_,p]), <p, invImportedPackages[_,p]>> 
		| p <- model.exportedPackages.expPackage};
	rel[int noImporters, int noPackages, rel[loc,set[loc]] packages] frequencies = {
		<n, size(relation[n]), relation[n]> | n <- [0..(max(relation.to) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[int,int,rel[loc,str,set[loc]]] csvVersionedImportersExpPkgs(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	versExportedPackages = {<p, m["version"]> | <b, p, m> <- model.exportedPackages};
	
	rel[int noImporters, tuple[loc,str,set[loc]] dependencies] relation = {
		<size(getPackageImporters(p,v,model)), <p,v, getPackageImporters(p,v,model)>> 
		| <p,v> <- versExportedPackages};
	rel[int noImporters, int noPackages, rel[loc,str,set[loc]] dependencies] frequencies = {
		<n, size(relation[n]), relation[n]> | n <- [0..(max(relation.noImporters) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}


//--------------------------------------------------------------------------------
// Util
//--------------------------------------------------------------------------------

/*
 * Returns a set of bundles importing the given package 
 * with the related version.
 */
private set[loc] getPackageImporters(loc pkg, str version, OSGiModel model) {
	invImportedPackages = invert(model.importedPackages);
	bundles = {};
	for(b <- invImportedPackages[_,pkg]) {
		bundles += {b | params <- model.importedPackages[b,pkg], 
			lessThanVersion(substring(params["lower-version"],1), version, versionIsInclusive(params["lower-version"])),
			lessThanVersion(version, substring(params["upper-version"],1), versionIsInclusive(params["upper-version"]))};
	}
	return bundles;
}