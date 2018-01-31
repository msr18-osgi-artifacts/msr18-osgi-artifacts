module org::crossminer::analysis::smells::requireBundle::Modifier

import IO;
import Set;
import String;

import org::crossminer::analysis::modifiers::ManifestModifier;
import org::crossminer::analysis::smells::Util;
import org::crossminer::language::Syntax;
import org::crossminer::language::Util;
import org::crossminer::models::CrossminerBuilder;
import org::crossminer::models::helpers::ExtensionDiscoverer;
import org::crossminer::util::CrossminerUtil;


//--------------------------------------------------------------------------------
// Functions
//--------------------------------------------------------------------------------

/*
 * Changes the manifest by removing a subset of required bundles
 * and adding only the used imported packages.
 */
public void modifyManifests(CrossminerModel model) {
	Extension ext = getExtensionBundles(model);
	nonExtensionBundles = getComplementExtensionReqBundles(model,ext);
	
	for(<logical,physical,params> <- model.locations, size(nonExtensionBundles[logical]) > 0) {
		mandatoryReqBundles = getMandatoryRequiredBundles(logical,model);
		importedPackages = bundleToPackageDependencies(logical,mandatoryReqBundles,model);
		
		mandatoryReqBundlesStr = requireBundleToStr(logical,mandatoryReqBundles,model);
		importedPackagesStr = importPackageToStr(logical,importedPackages,model);
		changeManifest(physical,importPackage=importedPackagesStr,requireBundle=mandatoryReqBundlesStr);
	}
}

/*
 * Transforms optional required bundles into used imported
 * packages.
 */ 
private set[loc] bundleToPackageDependencies(loc bundle, set[loc] mandatoryReqBundles, CrossminerModel model) {
	flatExportedPackages = toBinaryRelation(model.exportedPackages);
	flatImportedPackages = toBinaryRelation(model.importedPackages);
	importedPackages = {	*((flatExportedPackages[b] & model.importedPackagesBC[bundle]) 
		- flatImportedPackages[bundle]) | <b,p> <- model.requiredBundles[bundle], b notin mandatoryReqBundles};
	return importedPackages;
}

/*
 * Creates a string from imported packages.
 * NOTE: no versions or other additional parameters are considered.
 */
private str importPackageToStr(loc bundle, set[loc] importedPackages, CrossminerModel model) {	
	manifest = getOneFrom(model.manifests[bundle]);
	string = "";
	for(m <- manifest) {
		if(/HeaderImportPackage h := m) {
			string += ("" | it + ",<trim("<p>")>" | /ImportPackage p := h);
			break;
		}
	}
	string += ("" | it + ",<getPackageQualifiedName(p)>" | p <- importedPackages);

	return (string != "") ? substring(string,1) : string;
}

/*
 * Creates a string from mandatory required bundles.
 */
private str requireBundleToStr(loc bundle, set[loc] mandatoryRequiredBundles, CrossminerModel model) {
	manifest = getOneFrom(model.manifests[bundle]);
	string = "";
	for(m <- manifest) {
		if(/HeaderRequireBundle h := m) {
			string += ("" | it + ",<r>"| /RequireBundle r := h, 
				isMandatoryRequiredBundle(r, mandatoryRequiredBundles));
			break;
		}
	}
	return (string != "") ? substring(string,1) : string;
}

/*
 * Checks if a given bundle is mandatory (only considers its 
 * symbolic name).
 */
private bool isMandatoryRequiredBundle(RequireBundle requireBundle, set[loc] mandatoryRequiredBundles) {
	if(b <- mandatoryRequiredBundles, "<requireBundle.symbolicName>" == getBundleSymbolicName(b)) {
		return true;
	}
	return false;
}