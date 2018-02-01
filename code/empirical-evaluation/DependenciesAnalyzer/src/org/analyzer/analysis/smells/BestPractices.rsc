module org::analyzer::analysis::smells::BestPractices

import IO;
import List;
import Relation;
import Set;
import String;
import ValueIO;

import lang::csv::IO;
import lang::java::m3::Core;
import util::Math;

import org::analyzer::models::OSGiModelBuilder;
import org::analyzer::util::OSGiUtil;

//TODO: Delete once the refactoring is complete.

//--------------------------------------------------------------------------------
// IS IT FOLLOWED?
//--------------------------------------------------------------------------------

//B1------------------------------------------------------------------------------

/**
 * Best practice: Use Import-Package instead of Require-Bundle
 * Metric: Number of bundles with the Require-Bundle header
 * Scale: Ratio
 * Type: Direct 
 * Description: Returns the number of projects with the Require-Bundle 
 * header in the OSGi model.
 */
public real getRatioRequireBundleHeaderFreq(OSGiModel model)
	= (size(model.requiredBundles.bundle) + 0.0) / size(model.locations.logical);
	
/*
 * Best practice: Use Import-Package instead of Require-Bundle
 * Metric: Number of bundles with the Require-Bundle header
 * Scale: Ratio
 * Type: Direct 
 * Description: Returns the number of projects with the Import-Package 
 * header in the OSGi model.
 */
public real getImportPackageHeaderFreq(OSGiModel model) 
	= (size(model.importedPackages.bundle) + 0.0) / size(model.locations.logical);
	
/*
 * Best practice: Use Import-Package instead of Require-Bundle
 * Metric: Number of bundles with the Require-Bundle header
 * Scale: Absolute
 * Type: Direct 
 * Description: Returns the number of projects with the Require-Bundle 
 * and Import-Package headers in the OSGi model.
 */
public real getReqBundImpPackHeadersFreq(OSGiModel model)
	= (size(model.requiredBundles.bundle & model.importedPackages.bundle) + 0.0) / 
		size(model.locations.logical);


/*
 * Returns a relation setting the required bundles frequency in the first slot, number of bundles 
 * with that frequency in the second slot, and the set of related bundles symbolic names in the third 
 * slot. If csv is set to true the function generates a CSV file with the distribution.
 */
public rel[int,int,set[loc]] getRequireBundleDistribution(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH){
	rel[int noReqBundles, loc bundles] relation = {<size(model.requiredBundles[logical]), logical> | logical <- model.locations.logical};
	rel[int noReqBundles, int noBundles, set[loc] bundles] distribution = {<n, size(relation[n]), relation[n]> 
			| n <- [0..(max(relation.noReqBundles) + 1)]};
			   	
	if(csv) { writeCSV(distribution, pathCSV); }
	return distribution;
}

/*
 * Returns a relation setting the imported packages frequency in the first slot, number of bundles 
 * with that frequency in the second slot, and the set of related bundles symbolic names in the third 
 * slot. If csv is set to true the function generates a CSV file with the distribution. 
 */
public rel[int,int,set[loc]] getImportPackageDistribution(OSGiModel model, bool csv = true, loc pathCSV = RESULTS_PATH){
	rel[int noImpPackages, loc bundles] relation = {<size(model.importedPackages[logical]), logical> | logical <- model.locations.logical};
	rel[int noImpPkgs, int noBundles, set[loc] bundles] distribution = {<n, size(relation[n]), relation[n]> 
			| n <- [0..(max(relation.noImpPackages) + 1)]};
	
	if(csv) { writeCSV(distribution, pathCSV); }
	return distribution;
}

//B2------------------------------------------------------------------------------

public real getRatioVersionedRequiredBundles(OSGiModel model)
	= (0.0 | it + 1 | <bundle, reqBundle, params> <- model.requiredBundles, params["version-spec"] != "none") 
		/ size(model.requiredBundles);

public real getRatioVersionedImportedPackages(OSGiModel model)
	= (0.0 | it + 1 | <bundle, impPackage, params> <- model.importedPackages, params["version-spec"] != "none") 
		/ size(model.importedPackages);

public real getRatioVersionedExportedPackages(OSGiModel model)
	= (0.0 | it + 1 | <bundle, epPackage, params> <- model.exportedPackages, params["version-spec"] != "none") 
		/ size(model.exportedPackages);	
		
public real getRatioRangeVersionedRequiredBundles(OSGiModel model)
	= (0.0 | it + 1 | <bundle, reqBundle, params> <- model.requiredBundles, params["version-spec"] == "range") 
		/ (0.0 | it + 1 | <bundle, reqBundle, params> <- model.requiredBundles, params["version-spec"] != "none") ;

public real getRatioRangeVersionedImportedPackages(OSGiModel model)
	= (0.0 | it + 1 | <bundle, impPackage, params> <- model.importedPackages, params["version-spec"] == "range") 
		/ (0.0 | it + 1 | <bundle, impPackage, params> <- model.importedPackages, params["version-spec"] != "none") ;

public rel[int,int] getRatioVersionedRequiredBundlesCategorical(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	rel[int category, tuple[loc,loc,map[str,str]] dependency] relation = {
			<((params["version-spec"] == "none") ? 0 : 1), <bundle, reqBundle, params>> | 
			<bundle, reqBundle, params> <- model.requiredBundles};
	rel[int category, int noDependencies] frequencies = {<n, size(relation[n])> | n <- relation.category};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[int,int] getRatioVersionedImportedPackagesCategorical(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	rel[int category, tuple[loc,loc,map[str,str]] dependency] relation = {
			<((params["version-spec"] == "none") ? 0 : 1), <bundle, impPackage, params>> | 
			<bundle, impPackage, params> <- model.importedPackages};
	rel[int category, int noDependencies] frequencies = {<n, size(relation[n])> | n <- relation.category};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[int,int] getRatioVersionedEportedPackagesCategorical(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	rel[int category, tuple[loc,loc,map[str,str]] dependency] relation = {
			<((params["version-spec"] == "none") ? 0 : 1), <bundle, expPackage, params>> | 
			<bundle, expPackage, params> <- model.exportedPackages};
	rel[int category, int noDependencies] frequencies = {<n, size(relation[n])> | n <- relation.category};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[int,int] getRatioRangeVersionedRequiredBundlesCategorical(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	rel[int category, tuple[loc,loc,map[str,str]] dependency] relation = {
			<((params["version-spec"] != "range") ? 0 : 1), <bundle, reqBundle, params>> | 
			<bundle, reqBundle, params> <- model.requiredBundles, params["version-spec"] != "none"};
	rel[int category, int noDependencies] frequencies = {<n, size(relation[n])> | n <- relation.category};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[int,int] getRatioRangeVersionedImportedPackagesCategorical(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	rel[int category, tuple[loc,loc,map[str,str]] dependency] relation = {
			<((params["version-spec"] != "range") ? 0 : 1), <bundle, impPackage, params>> | 
			<bundle, impPackage, params> <- model.importedPackages, params["version-spec"] != "none"};
	rel[int category, int noDependencies] frequencies = {<n, size(relation[n])> | n <- relation.category};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

//B3------------------------------------------------------------------------------

public real getRatioImportedExpPkgs(OSGiModel model) {
	invImportedPackages = invert(model.importedPackages);
	return (0.0 | it + 1 | p <- model.exportedPackages.expPackage, size(invImportedPackages[_,p]) > 0) 
		/ size(model.exportedPackages.expPackage);
}

public real getRatioVersionedImportedExpPkgs(OSGiModel model) {
	versExportedPackages = {<p, m["version"]> | <b, p, m> <- model.exportedPackages};
	println("EXP PKGS: <size(versExportedPackages)>");
	println("IMP PKGS: <(0.0 | it + 1 | <p,v> <- versExportedPackages, size(getPackageImporters(p,v,model)) > 0)>");
	return (0.0 | it + 1 | <p,v> <- versExportedPackages, size(getPackageImporters(p,v,model)) > 0) 
		/ size(versExportedPackages);
}

public rel[int,int,rel[loc,set[loc]]] getImportersExpPkgs(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	invImportedPackages = invert(model.importedPackages);
	invImportedPackagesBC = invert(model.importedPackagesBC);
	
	rel[int to, tuple[loc,set[loc]] from] relation = {<size(invImportedPackages[_,p]), <p, invImportedPackages[_,p] & invImportedPackagesBC[p]>> 
			| p <- model.exportedPackages.expPackage};
	rel[int noImporters, int noPackages, rel[loc,set[loc]] packages] frequencies = {<n, size(relation[n]), relation[n]> 
			| n <- [0..(max(relation.to) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[int,int,rel[loc,str,set[loc]]] getVersionedImportersExpPkgs(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	versExportedPackages = {<p, m["version"]> | <b, p, m> <- model.exportedPackages};
	
	rel[int noImporters, tuple[loc,str,set[loc]] dependencies] relation = {<size(getPackageImporters(p,v,model)), <p,v, getPackageImporters(p,v,model)>> 
			| <p,v> <- versExportedPackages};
	rel[int noImporters, int noPackages, rel[loc,str,set[loc]] dependencies] frequencies = {<n, size(relation[n]), relation[n]> 
			| n <- [0..(max(relation.noImporters) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

//B4------------------------------------------------------------------------------

public real getRatioUsedImportedPackages(OSGiModel model) 
	= (0.0 | it + size(getUsedImportedPackagesBundle(bundle,model)) | bundle <- model.locations.logical) /
			size(model.importedPackages);

public real getRatioUsedRequiredBundlePackages(OSGiModel model) {		
	requiredPackages = getFlatPackagesReqBundles(model);
	return (0.0 | it + size(requiredPackages[bundle] & model.importedPackagesBC[bundle]) | bundle <- model.locations.logical) /
			size(requiredPackages);
}

public real getRatioUsedTransitiveRequiredBundlePackages(OSGiModel model) {		
	requiredPackages = getFlatPackagesTransitiveReqBundles(model);
	return (0.0 | it + size(requiredPackages[bundle] & model.importedPackagesBC[bundle]) | bundle <- model.locations.logical) /
			size(requiredPackages);
}

private set[loc] getUsedImportedPackagesBundle(loc bundle, OSGiModel model) {
	importedPackages = {impPackage | <impPackage, params> <- model.importedPackages[bundle]};
	exportedPackages = {expPackage | <expPackage, params> <- model.exportedPackages[bundle]};
	return (importedPackages & model.importedPackagesBC[bundle]) + (importedPackages & exportedPackages & model.bundlePackagesBC[bundle]);
}

public rel[int,int,rel[loc,set[loc]]] getUsedImportedPackagesDistribution(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	requiredPackages = getFlatPackagesReqBundles(model);
	rel[int usePkgs, tuple[loc,set[loc]] dependencies] relation = { <size(getUsedImportedPackagesBundle(bundle,model)), 
		<bundle, getUsedImportedPackagesBundle(bundle,model)>> | bundle <- model.locations.logical};
	rel[int usePkgs, int noBundles, rel[loc,set[loc]] dependencies] frequencies = {<n, size(relation[n]), relation[n]> 
			| n <- [0..(max(relation.usePkgs) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[int,int,rel[loc,set[loc]]] getUsedPackagesReqBundlesDistribution(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	requiredPackages = getFlatPackagesReqBundles(model);
	rel[int usePkgs, tuple[loc,set[loc]] dependencies] relation = { <size(requiredPackages[bundle] & model.importedPackagesBC[bundle]), 
		<bundle, (requiredPackages[bundle] & model.importedPackagesBC[bundle])>> | bundle <- model.locations.logical};
	rel[int usePkgs, int noBundles, rel[loc,set[loc]] dependencies] frequencies = {<n, size(relation[n]), relation[n]> 
			| n <- [0..(max(relation.usePkgs) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[int,int,rel[loc,set[loc]]] getUsedPackagesTransitiveReqBundlesDistribution(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	requiredPackages = getFlatPackagesTransitiveReqBundles(model);
	rel[int usePkgs, tuple[loc,set[loc]] dependencies] relation = { <size(requiredPackages[bundle] & model.importedPackagesBC[bundle]), 
		<bundle, (requiredPackages[bundle] & model.importedPackagesBC[bundle])>> | bundle <- model.locations.logical};
	rel[int usePkgs, int noBundles, rel[loc,set[loc]] dependencies] frequencies = {<n, size(relation[n]), relation[n]> 
			| n <- [0..(max(relation.usePkgs) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

//B6------------------------------------------------------------------------------

public real getRatioImpPackagesSplit(OSGiModel model) 
	= (0.0 | it + 1 | logical <- model.importedPackages, logical.params["split"] != "none") /
			size(model.importedPackages);	

public real getRatioExpPackagesSplit(OSGiModel model) {
	println((0.0 | it + 1 | logical <- model.exportedPackages, logical.params["split"] != "none"));
	println(size(model.exportedPackages));
	return (0.0 | it + 1 | logical <- model.exportedPackages, logical.params["split"] != "none") /
			size(model.exportedPackages);	
}

public rel[int,int,rel[loc,rel[loc,str]]] getImpPackagesSplit(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	importers = {<logical.bundle, logical.impPackage, logical.params["split"]> | 
			logical <- model.importedPackages, logical.params["split"] != "none"};
	rel[int noSplitImp, tuple[loc,rel[loc,str]] dependencies] relation = 
			{<size(importers[bundle]), <bundle, importers[bundle]>> | <bundle, impPackage, params> <- importers};	
	rel[int noSplitImp,int noBundles, rel[loc,rel[loc,str]] dependencies] frequencies = 
			{<n, size(relation[n]), relation[n]> | n <- [0..(max(relation.noSplitImp) + 1)]};
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[int,int,rel[loc,rel[loc,str]]] getExpPackagesSplit(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	exporters = {<logical.bundle, logical.expPackage, logical.params["split"]> | 
			logical <- model.exportedPackages, logical.params["split"] != "none"};
	rel[int noSplitExp, tuple[loc,rel[loc,str]] dependencies] relation = 
			{<size(exporters[bundle]), <bundle, exporters[bundle]>> | <bundle, expPackage, params> <- exporters};	
	rel[int noSplitExp,int noBundles, rel[loc,rel[loc,str]] dependencies] frequencies = 
			{<n, size(relation[n]), relation[n]> | n <- [0..(max(relation.noSplitExp) + 1)]};					   		   
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

//--------------------------------------------------------------------------------
// ARGUMENTS
//--------------------------------------------------------------------------------

//B1------------------------------------------------------------------------------

/*
 * Best practice: Use Import-Package instead of Require-Bundle
 * Metric: Number of required bundles per bundle
 * Scale: Absolute
 * Type: Direct 
 * Description: Returns the number of required bundles per bundle listed 
 * in the Require-Bundle header.
 * Distribution: Returns a relation setting the required bundles frequency 
 * in the first slot, number of bundles with that frequency in the second slot, 
 * and the set of related bundles symbolic names in the third slot. 
 */
public rel[int,int,set[loc]] getRequireBundleDistribution(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH){
	rel[int to, loc from] frequencies = {<size(model.requiredBundles[logical]), logical> | logical <- model.locations.logical};
	rel[int noReqBundles, int noBundles, set[loc] bundles] relations = {<n, size(frequencies[n]), frequencies[n]> 
			| n <- [0..(max(frequencies.to) + 1)]};

	if(csv) { writeCSV(relations, pathCSV); }
	return relations;
}

/*
 * Best practice: Use Import-Package instead of Require-Bundle
 * Metric: Number of imported packages per bundle
 * Scale: Absolute
 * Type: Direct 
 * Description: Returns the number of imported packages per bundle listed 
 * in the Import-Package header.
 * Distribution: Returns a relation setting the imported packages frequency 
 * in the first slot, number of bundles with that frequency in the second slot, 
 * and the set of related bundles symbolic names in the third slot. 
 */
public rel[int,int,set[loc]] getImportPackageDistribution(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH){
	rel[int to, loc from] frequencies = {<size(model.importedPackages[logical]), logical> | logical <- model.locations.logical};
	rel[int noImpPkgs, int noBundles, set[loc] bundles] relations = {<n, size(frequencies[n]), frequencies[n]> 
			| n <- [0..(max(frequencies.to) + 1)]};
	
	if(csv) { writeCSV(relations, pathCSV); }
	return relations;
}

/*
 * Best practice: Use Import-Package instead of Require-Bundle
 * Metric: Ratio of unused packages (obtain from the Require-Bundle header) 
 * per bundle
 * Scale: Ratio
 * Type: Indirect 
 * Description: Returns the number of required bundles per bundle listed 
 * in the Require-Bundle header.
 * Distribution: Returns a relation setting the required bundles frequency 
 * in the first slot, number of bundles with that frequency in the second slot, 
 * and the set of related bundles symbolic names in the third slot. 
 */
public rel[real,int,tuple[loc,loc]] getRatioUsedPackagesReqBundles(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	rel[loc,loc] exportedPackages = getFlatExportedPackages(model);
	rel[real useRatio, int impPkgs, tuple[loc,loc] dependency] relation = { 
			<(size(model.importedPackagesBC[bundle] & exportedPackages[reqBundle]) + 0.0) / 
			size(model.exportedPackages[reqBundle]), size(model.exportedPackages[reqBundle]),
			<bundle, reqBundle>> | <bundle, reqBundle, params> <- model.requiredBundles, size(model.exportedPackages[reqBundle]) != 0};
			   	
	if(csv) { writeCSV(relation, pathCSV); }
	return relation;
}

/*
 * Best practice: Use Import-Package instead of Require-Bundle
 * Metric: Ratio of unused packages (obtain from the Require-Bundle header) 
 * per bundle. Reexport cases are considered.
 * Scale: Ratio
 * Type: Indirect 
 * Description: Returns the number of required bundles per bundle listed 
 * in the Require-Bundle header. Reexport cases are considered.
 * Distribution: Returns a relation setting the required bundles frequency 
 * in the first slot, number of bundles with that frequency in the second slot, 
 * and the set of related bundles symbolic names in the third slot. 
 */
public rel[real,int,tuple[loc,loc]] getRatioUsedPackagesReqBundlesReexp(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	rel[loc,loc] exportedPackages = getFlatExportedPackages(model);
	rel[loc,loc] requiredBundles = getReexpRequiredBundles(model);
	
	rel[real useRatio, int impPkgs, tuple[loc,loc] dependency] relation = { 
			<(size(model.importedPackagesBC[bundle] & exportedPackages[reqBundle]) + 0.0) / 
			size(model.exportedPackages[reqBundle]), size(model.exportedPackages[reqBundle]),
			<bundle, reqBundle>> | <bundle, reqBundle> <- requiredBundles, size(model.exportedPackages[reqBundle]) != 0};
			   	
	if(csv) { writeCSV(relation, pathCSV); }
	return relation;
}

/*
 * Best practice: Use Import-Package instead of Require-Bundle
 * Metric: Ratio of unused packages (obtain from the Require-Bundle header) 
 * per bundle. Reexport cases are considered.
 * Scale: Ratio
 * Type: Indirect 
 * Description: Returns the number of required bundles per bundle listed 
 * in the Require-Bundle header. Reexport cases are considered.
 * Distribution: Returns a relation setting the required bundles frequency 
 * in the first slot, number of bundles with that frequency in the second slot, 
 * and the set of related bundles symbolic names in the third slot. 
 */
public rel[int,int,set[loc]] getPkgExporters(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	invExportedPackages = invert(model.exportedPackages);
	rel[int to, loc from] relation = {<size(invExportedPackages[_,p]), p> 
			| p <- model.exportedPackages.expPackage};
	rel[int noExporters, int noPackages, set[loc] packages] frequencies = {<n, size(relation[n]), relation[n]> 
			| n <- [0..(max(relation.to) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

/*
 * Best practice: Use Import-Package instead of Require-Bundle
 * Metric: Ratio of unused packages (obtain from the Require-Bundle header) 
 * per bundle. Reexport cases are considered.
 * Scale: Ratio
 * Type: Indirect 
 * Description: Returns a relation setting the location of the exported package 
 * in the first slot, the number of bundles exporting that package in the second 
 * slot, and the set of related bundles symbolic names in the third slot. 
 * Versions are considered.
 */
public rel[int,int,rel[loc,str,set[loc]]] getVersionedPkgExporters(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	versExportedPackages = {<p, m["version"]> | <b, p, m> <- model.exportedPackages};
	rel[int noExporters, tuple[loc,str,set[loc]] dependencies] relation = {<size(getPackageExporters(p,v,model)), <p,v, getPackageExporters(p,v,model)>> | <p,v> <- versExportedPackages};
	rel[int noExporters, int noPackages, rel[loc,str,set[loc]] dependencies] frequencies = {<n, size(relation[n]), relation[n]> 
			| n <- [0..(max(relation.noExporters) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}


//B2------------------------------------------------------------------------------

public rel[real,int,loc] getRatioVersionedImportedPackagesDistr(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	rel[real versionedRatio, int impPackages, loc bundle] relation = {
			<((size(getVersionedImportedPackages(bundle,model)) + 0.0) / size(model.importedPackages[bundle])),
			size(model.importedPackages[bundle]), bundle> | bundle <- model.locations.logical, size(model.importedPackages[bundle]) != 0};

	if(csv) { writeCSV(relation, pathCSV); }
	return relation;
}

public rel[real,int,loc] getRatioVersionedExportedPackagesDistr(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	rel[real versionedRatio, int expPackages, loc bundle] relation = {
			<((size(getVersionedExportedPackages(bundle,model)) + 0.0) / size(model.exportedPackages[bundle])),
			size(model.exportedPackages[bundle]), bundle> | bundle <- model.locations.logical, size(model.exportedPackages[bundle]) != 0};

	if(csv) { writeCSV(relation, pathCSV); }
	return relation;
}

public rel[real,int,loc] getRatioVersionedRequiredBundlesDistr(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	rel[real versionedRatio, int reqBundles, loc bundle] relation = {
			<((size(getVersionedRequiredBundles(bundle,model)) + 0.0) / size(model.requiredBundles[bundle])),
			size(model.requiredBundles[bundle]), bundle> | bundle <- model.locations.logical, size(model.requiredBundles[bundle]) != 0};

	if(csv) { writeCSV(relation, pathCSV); }
	return relation;
}

public rel[real,int,loc] getRatioRangeVersionedImportedPackagesDistr(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	rel[real versionedRatio, int impPackages, loc bundle] relation = {
			<((size(getImportedPackagesPerVersSpec(bundle,"range",model)) + 0.0) / size(model.importedPackages[bundle])),
			size(model.importedPackages[bundle]), bundle> | bundle <- model.locations.logical, size(model.importedPackages[bundle]) != 0};

	if(csv) { writeCSV(relation, pathCSV); }
	return relation;
}

public rel[real,int,loc] getRatioRangeVersionedExportedPackagesDistr(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	rel[real versionedRatio, int expPackages, loc bundle] relation = {
			<((size(getExportedPackagesPerVersSpec(bundle,"range",model)) + 0.0) / size(model.exportedPackages[bundle])),
			size(model.exportedPackages[bundle]), bundle> | bundle <- model.locations.logical, size(model.exportedPackages[bundle]) != 0};

	if(csv) { writeCSV(relation, pathCSV); }
	return relation;
}

public rel[real,int,loc] getRatioRangeVersionedRequiredBundlesDistr(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	rel[real versionedRatio, int reqBundles, loc bundle] relation = {
			<((size(getRequiredBundlesPerVersSpec(bundle,"range",model)) + 0.0) / size(model.requiredBundles[bundle])),
			size(model.requiredBundles[bundle]), bundle> | bundle <- model.locations.logical, size(model.requiredBundles[bundle]) != 0};

	if(csv) { writeCSV(relation, pathCSV); }
	return relation;
}

public rel[real,real,real,int,loc] getRatioImportedPackagesPerVersSpecDistr(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	rel[real vRangeRatio, real vStrictRatio, real vNoneRatio, int impPackages, loc bundle] relation = {
			<((size(getImportedPackagesPerVersSpec(bundle,"range",model)) + 0.0) / size(model.importedPackages[bundle])),
			((size(getImportedPackagesPerVersSpec(bundle,"strict",model)) + 0.0) / size(model.importedPackages[bundle])),
			((size(getImportedPackagesPerVersSpec(bundle,"none",model)) + 0.0) / size(model.importedPackages[bundle])),
			size(model.importedPackages[bundle]), bundle> | bundle <- model.locations.logical, size(model.importedPackages[bundle]) != 0};

	if(csv) { writeCSV(relation, pathCSV); }
	return relation;
}

public rel[real,real,real,int,loc] getRatioExportedPackagesPerVersSpecDistr(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	rel[real vRangeRatio, real vStrictRatio, real vNoneRatio, int expPackages, loc bundle] relation = {
			<((size(getExportedPackagesPerVersSpec(bundle,"range",model)) + 0.0) / size(model.exportedPackages[bundle])),
			((size(getExportedPackagesPerVersSpec(bundle,"strict",model)) + 0.0) / size(model.exportedPackages[bundle])),
			((size(getExportedPackagesPerVersSpec(bundle,"none",model)) + 0.0) / size(model.exportedPackages[bundle])),
			size(model.exportedPackages[bundle]), bundle> | bundle <- model.locations.logical, size(model.exportedPackages[bundle]) != 0};

	if(csv) { writeCSV(relation, pathCSV); }
	return relation;
}

public rel[real,real,real,int,loc] getRatioRequiredBundlesPerVersSpecDistr(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	rel[real vRangeRatio, real vStrictRatio, real vNoneRatio, int reqBundles, loc bundle] relation = {
			<((size(getRequiredBundlesPerVersSpec(bundle,"range",model)) + 0.0) / size(model.requiredBundles[bundle])),
			((size(getRequiredBundlesPerVersSpec(bundle,"strict",model)) + 0.0) / size(model.requiredBundles[bundle])),
			((size(getRequiredBundlesPerVersSpec(bundle,"none",model)) + 0.0) / size(model.requiredBundles[bundle])),
			size(model.requiredBundles[bundle]), bundle> | bundle <- model.locations.logical, size(model.requiredBundles[bundle]) != 0};

	if(csv) { writeCSV(relation, pathCSV); }
	return relation;
}

//B3------------------------------------------------------------------------------

public rel[int,int,rel[loc,set[loc]]] getImportersUsedExpPkgs(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	invImportedPackages = invert(model.importedPackages);
	invImportedPackagesBC = invert(model.importedPackagesBC);

	rel[int to, tuple[loc,set[loc]] from] relation = {<size(invImportedPackages[_,p] & invImportedPackagesBC[p]), <p, invImportedPackages[_,p] & invImportedPackagesBC[p]>> 
			| p <- model.exportedPackages.expPackage};
	rel[int noImporters, int noPackages, rel[loc,set[loc]] packages] frequencies = {<n, size(relation[n]), relation[n]> 
			| n <- [0..(max(relation.to) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[int,int,rel[loc,str,set[loc]]] getVersionedImportersUsedExpPkgs(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	versExportedPackages = {<p, m["version"]> | <b, p, m> <- model.exportedPackages};
	
	rel[int noImporters, tuple[loc,str,set[loc]] dependencies] relation = {<size(getUsedPackageImporters(p,v,model)), <p,v, getUsedPackageImporters(p,v,model)>> 
			| <p,v> <- versExportedPackages};
	rel[int noImporters, int noPackages, rel[loc,str,set[loc]] dependencies] frequencies = {<n, size(relation[n]), relation[n]> 
			| n <- [0..(max(relation.noImporters) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

//B4------------------------------------------------------------------------------

public rel[real,int,tuple[loc,loc]] getRatioUsedImportedPackages(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {		
	importedPackages = getFlatImportedPackages(model);
	rel[real useRatio, int impPkgs, tuple[loc,loc] dependency] relation = { 
			<(size(model.importedPackagesBC[bundle] & importedPackages[bundle]) + 0.0) / 
			size(model.importedPackages[bundle]), size(model.importedPackages[bundle]),
			<bundle, impPackage>> | <bundle, impPackage, params> <- model.importedPackages, size(model.importedPackages[bundle]) != 0};
			   	
	if(csv) { writeCSV(relation, pathCSV); }
	return relation;
}

//B5------------------------------------------------------------------------------

/*
 * Returns a relation whose first element represents bundles' logical locations and the second element
 * the number of related used unimported packages. If writeCSV is set to true the function generates a 
 * CSV file setting the number of unused imported packages in the first slot, number of bundles with 
 * that frequency in the second slot, and the set of related bundles symbolic names in the third slot.
 */
public rel[int,int,int,tuple[loc,set[loc]]] getUsedUnimportedPackages(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	importedPackages = getFlatImportedPackages(model);
	requiredPackages = getFlatPackagesReqBundles(model);
	
	rel[int usedPacks, int impPacks, int reqPacks, tuple[loc,set[loc]] dependency] relation = {
			<size(computeUsedUnimportedPackages(model.importedPackagesBC[logical], model.bundlePackagesBC[logical], 
			importedPackages[logical], requiredPackages[logical])), 
			size(model.importedPackages[logical]), size(requiredPackages[logical]),
			<logical, computeUsedUnimportedPackages(model.importedPackagesBC[logical], model.bundlePackagesBC[logical], 
			importedPackages[logical], requiredPackages[logical])>> | 
			logical <- model.locations.logical};
												  										
	if(csv) { writeCSV(relation, pathCSV); }
	return relation;
}

//B6------------------------------------------------------------------------------

public rel[real,int,rel[loc,loc]] getRatioSplitPackagesExporters(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	rel[loc,loc,str] importers = {<logical.impPackage, logical.bundle, logical.params["split"]> | 
			logical <- model.importedPackages, logical.params["split"] != "none"};
	rel[loc,loc,str] exporters = {<logical.expPackage, logical.bundle, logical.params["split"]> | 
			logical <- model.exportedPackages, logical.params["split"] != "none"};
	
	rel[real expRatio, tuple[loc,loc] dependency] relation = { 
			<(size(importers[pkg,bundle]) + 0.0) / size(exporters[pkg]),
			<bundle, pkg>> | <loc pkg, loc bundle, str split> <- importers, size(exporters[pkg]) != 0};
	rel[real expRatio, int splitPkgs, rel[loc,loc] dependencies] frequencies = {
			<n, size(relation[n]), relation[n]> | n <- relation.expRatio};		
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
	
}

//B7------------------------------------------------------------------------------

public rel[int,int,rel[loc,set[loc]]] getDynamicImportedPackages(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	flatDynImportedPackages = {<bundle, package> | <bundle, package, params> <- model.dynamicImportedPackages};
	
	rel[int to, tuple[loc,set[loc]] from] relation = {<size(model.dynamicImportedPackages[logical]), <logical, flatDynImportedPackages[logical]>> 
			| logical <- model.locations.logical};
	rel[int noPackages, int noBundles, rel[loc,set[loc]] packages] frequencies = {<n, size(relation[n]), relation[n]> 
			| n <- [0..(max(relation.to) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

public rel[int,int,rel[loc,set[loc]]] getUnresolvedDynamicImportedPackages(OSGiModel model, bool csv=true, loc pathCSV=RESULTS_PATH) {
	rel[loc bundles, loc packages] flatUnresDynImportedPackages = {<bundle, package> | <bundle, package, params> <- model.dynamicImportedPackages, 
			params["resolved"] == "false"};

	rel[int to, tuple[loc,set[loc]] from] relation = {<size(flatUnresDynImportedPackages[logical]), <logical, flatUnresDynImportedPackages[logical]>> 
			| logical <- flatUnresDynImportedPackages.bundles};
	rel[int noPackages, int noBundles, rel[loc,set[loc]] packages] frequencies = {<n, size(relation[n]), relation[n]> 
			| n <- [0..(max(relation.to) + 1)]};
			
	if(csv) { writeCSV(frequencies, pathCSV); }
	return frequencies;
}

//--------------------------------------------------------------------------------
// Util
//--------------------------------------------------------------------------------

private rel[loc,loc] getFlatExportedPackages(OSGiModel model)
	= {<bundle, flatPackageLoc(pkg)> | <bundle, pkg, params> <- model.exportedPackages}; 
	
private rel[loc,loc] getFlatImportedPackages(OSGiModel model)
	= {<bundle, flatPackageLoc(pkg)> | <bundle, pkg, params> <- model.importedPackages}; 

/*
 * Returns a package logical location that conforms to an M3 location. Version is not considered.
 * @param loc logical location of an OSGi Model package location
 * @return loc flatten package location  
 */
 //TODO
private loc flatPackageLoc(loc logical) {
	logical.path = replaceAll(logical.path, ".", "/");
	return logical;
}

private rel[loc,loc] getReexpRequiredBundles(OSGiModel model) {
	requiredBundles = {<bundle, reqBundle> | <bundle, reqBundle, params> <- model.requiredBundles};
	transReexpBundles = {<bundle, reqBundle> | <bundle, reqBundle, params> <- model.requiredBundles, params["visibility"] == "reexport"};
	for(t <- transReexpBundles) {
		requiredBundles += {t} o requiredBundles;
	}
	return requiredBundles;
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

/*
 * 	Returns a seto of bundles importing the given package with the related version.
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

/*
 * 	Returns a set of bundles importing the given package with the related version.
 */
private set[loc] getUsedPackageImporters(loc pkg, str version, OSGiModel model) {
	invImportedPackages = invert(model.importedPackages);
	invImportedPackagesBC = invert(model.importedPackagesBC);
	candidateBundles = invImportedPackages[_,pkg] & invImportedPackagesBC[pkg];
	bundles = {};
	for(b <- candidateBundles) {
		bundles += {b | params <- model.importedPackages[b,pkg], 
				lessThanVersion(substring(params["lower-version"],1), version, versionIsInclusive(params["lower-version"])),
				lessThanVersion(version, substring(params["upper-version"],1), versionIsInclusive(params["upper-version"]))};
	}
	return bundles;
}

private rel[loc,loc] getFlatPackagesReqBundles(OSGiModel model) {
	rel[loc,loc] requiredBundles = {<bundle, reqBundle> | <bundle, reqBundle, params> <- model.requiredBundles}; 
	rel[loc,loc] exportedPackages = {<bundle, pkg> | <bundle, pkg, params> <- model.exportedPackages}; 
	return {<bundle, flatPackageLoc(pkg)> | <bundle, pkg> <- (requiredBundles o exportedPackages)};
}

private rel[loc,loc] getFlatPackagesTransitiveReqBundles(OSGiModel model) {
	rel[loc,loc] requiredBundles = getReexpRequiredBundles(model);
	rel[loc,loc] exportedPackages = {<bundle, pkg> | <bundle, pkg, params> <- model.exportedPackages}; 
	return {<bundle, flatPackageLoc(pkg)> | <bundle, pkg> <- (requiredBundles o exportedPackages)};
}

private set[loc] computeUsedUnimportedPackages(set[loc] importedPackagesBC, set[loc] bundlePackagesBC, 
	set[loc] importedPackages, set[loc] requiredPackages) 
	= importedPackagesBC - importedPackages - requiredPackages - bundlePackagesBC;

private set[loc] getVersionedImportedPackages(loc bundle, OSGiModel model)
	= {pkg |<pkg, params> <- model.importedPackages[bundle], params["version-spec"] != "none"};
	
private set[loc] getImportedPackagesPerVersSpec(loc bundle, str versionSpec, OSGiModel model)
	= {pkg |<pkg, params> <- model.importedPackages[bundle], params["version-spec"] == versionSpec};
	
private set[loc] getVersionedExportedPackages(loc bundle, OSGiModel model)
	= {pkg |<pkg, params> <- model.exportedPackages[bundle], params["version-spec"] != "none"};
	
private set[loc] getExportedPackagesPerVersSpec(loc bundle, str versionSpec, OSGiModel model)
	= {pkg |<pkg, params> <- model.exportedPackages[bundle], params["version-spec"] == versionSpec};
	
private set[loc] getVersionedRequiredBundles(loc bundle, OSGiModel model)
	= {pkg |<pkg, params> <- model.requiredBundles[bundle], params["version-spec"] != "none"};
	
private set[loc] getRequiredBundlesPerVersSpec(loc bundle, str versionSpec, OSGiModel model)
	= {pkg |<pkg, params> <- model.requiredBundles[bundle], params["version-spec"] == versionSpec};
