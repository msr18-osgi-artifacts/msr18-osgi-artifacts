module org::analyzer::analysis::smells::Util

import Set;

import org::analyzer::models::OSGiModelBuilder;
import org::analyzer::util::OSGiUtil;


//--------------------------------------------------------------------------------
// Functions
//--------------------------------------------------------------------------------

/*
 * Returns a set of mandatory required bundles; i.e. required
 * bundles that export split packages or that are unresolved.
 */
public set[loc] getMandatoryRequiredBundles(loc bundle, OSGiModel model) 
	= {req | <req,params> <- model.requiredBundles[bundle], hasSplitPackages(req,model) 
	|| isUnresolved(params,model) || isSystemBundle(req)};
	
/*
 * Checks if a bundle exports split packages.
 */
private bool hasSplitPackages(loc bundle, OSGiModel model) {
	if(<pkg,params> <- model.exportedPackages[bundle], params["split"] != "none") {
		return true;
	}
	return false;
}

/*
 * Checks if a required bundle is unresolved.
 */
public bool isUnresolved(map[str,str] params, OSGiModel model) 
	= (params["resolved"] == "false") ? true : false;

/*
 * Checks if the bundle is the system bundle.
 */
public bool isSystemBundle(loc bundle) 
	= getBundleSymbolicName(bundle) == SYSTEM_BUNDLE_ALIAS 
	|| getBundleSymbolicName(bundle) == SYSTEM_BUNDLE_NAME;
	
/*
 * Returns the packages exported by required bundles.
 */
public rel[loc,loc] getPackagesReqBundles(OSGiModel model) 
	= toBinaryRelation(model.requiredBundles) o toBinaryRelation(model.exportedPackages);
	
/*
 * Returns a relation with transitive required bundles.
 */
public rel[loc,loc] getReexpRequiredBundles(OSGiModel model) {
	requiredBundles = toBinaryRelation(model.requiredBundles);
	reexpBundles = {<bundle, reqBundle> | <bundle, reqBundle, params> <- model.requiredBundles, params["visibility"] == "reexport"};
	return reexpBundles o requiredBundles;
}

/*
 * Returns the packages exported by transitive required 
 * bundles.
 */
public rel[loc,loc] getReexpReqBundlesPackages(OSGiModel model) 
	= getReexpRequiredBundles(model) o toBinaryRelation(model.exportedPackages);
	
/*
 * Returns the set of used required bundles. Considers required
 * packages.
 */
public set[loc] getUsedRequiredBundles(loc bundle, OSGiModel model) {
	exportedPackages = toBinaryRelation(model.exportedPackages);
	return {r | <r,p> <- model.requiredBundles[bundle], 
		size(exportedPackages[r] & model.importedPackagesBC[bundle]) > 0};
}
	