module org::analyzer::analysis::smells::dynamicImport::Evaluator

import Relation;
import Set;
import String;

import lang::csv::IO;

import org::analyzer::models::OSGiModelBuilder;
import org::analyzer::util::OSGiUtil;


//--------------------------------------------------------------------------------
// Metrics
//--------------------------------------------------------------------------------

public int numberDynamicImportedPackages(OSGiModel model) 
	= size(model.dynamicImportedPackages);

public int numberDynamicImportedPackageHeaders(OSGiModel model) 
	= size(model.dynamicImportedPackages.bundle);
	
public int numberUnresolvedDynamicImportedPackages(OSGiModel model)
	= (0 | it + 1 | <bundle,pkg,params> <- model.dynamicImportedPackages, params["resolved"] == "false");
	
	
//--------------------------------------------------------------------------------
// CSV
//--------------------------------------------------------------------------------

public rel[int,int,rel[loc,set[loc]]] getDynamicImportedPackages(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	dynImportedPackages = toBinaryRelation(model.dynamicImportedPackages);
	
	rel[int to, tuple[loc,set[loc]] from] relation = {
		<size(model.dynamicImportedPackages[logical]), <logical, dynImportedPackages[logical]>> 
		| logical <- model.locations.logical};
	rel[int noPackages, int noBundles, rel[loc,set[loc]] packages] frequencies = {
		<n, size(relation[n]), relation[n]> | n <- [0..(max(relation.to) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[int,int,rel[loc,set[loc]]] getUnresolvedDynamicImportedPackages(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	unresDynImportedPackages = {<bundle, package> | <bundle, package, params> <- model.dynamicImportedPackages, 
			params["resolved"] == "false"};

	rel[int to, tuple[loc,set[loc]] from] relation = {
		<size(unresDynImportedPackages[logical]), <logical, unresDynImportedPackages[logical]>> 
		| logical <- unresDynImportedPackages.bundles};
	rel[int noPackages, int noBundles, rel[loc,set[loc]] packages] frequencies = {
		<n, size(relation[n]), relation[n]> | n <- [0..(max(relation.to) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}
