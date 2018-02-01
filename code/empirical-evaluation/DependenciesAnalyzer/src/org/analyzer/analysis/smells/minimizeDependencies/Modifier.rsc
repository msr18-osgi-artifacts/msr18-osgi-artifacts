module org::analyzer::analysis::smells::minimizeDependencies::Modifier

import IO;
import Set;
import String;

import org::analyzer::analysis::modifiers::ManifestModifier;
import org::analyzer::analysis::smells::Util;
import org::analyzer::language::Syntax;
import org::analyzer::language::Util;
import org::analyzer::models::OSGiModelBuilder;
import org::analyzer::models::helpers::ExtensionDiscoverer;
import org::analyzer::util::OSGiUtil;


//--------------------------------------------------------------------------------
// Functions
//--------------------------------------------------------------------------------

/*
 * Changes the manifest by removing unused dependencies (both required 
 * bundles and imported packages).
 */
public void modifyManifests(OSGiModel model) {
	Extension ext = getExtensionBundles(model);
	nonExtensionBundles = getComplementExtensionReqBundles(model,ext);
	t = 0;
	for(<logical,physical,prams> <- model.locations, size(nonExtensionBundles[logical]) > 0) {
		usedImportedPackages = getUsedImportedPackages(logical,model); 
		mandatoryReqBundles = getMandatoryRequiredBundles(logical,model);
		usedRequiredBundles = getUsedRequiredBundles(logical,model) + mandatoryReqBundles;
		
		t += size(usedImportedPackages);
		usedImportedPackagesStr = importPackageToStr(logical,usedImportedPackages,model);
		usedRequiredBundlesStr = requireBundleToStr(logical,usedRequiredBundles,model);
		//changeManifest(physical,importPackage=usedImportedPackagesStr,requireBundle=usedRequiredBundlesStr);
	}
	println(t);
}

/*
 * Returns the set of used imported packages. Considers own
 * packages.
 */
private set[loc] getUsedImportedPackages(loc bundle, OSGiModel model) {
	importedPackages = {impPackage | <impPackage, params> <- model.importedPackages[bundle]};
	exportedPackages = {expPackage | <expPackage, params> <- model.exportedPackages[bundle]};
	return (importedPackages & model.importedPackagesBC[bundle]) + 
		(importedPackages & exportedPackages & model.bundlePackagesBC[bundle]);
}

/*
 * Creates a string from imported packages.
 */
private str importPackageToStr(loc bundle, set[loc] importedPackages, OSGiModel model) {
	m = getOneFrom(model.manifests[bundle]);
	importedPackagesStr = "";
	if(/HeaderImportPackage h := m) {
		importedPackagesStr = ("" | it + ",<trim("<p>")>" | /ImportPackage p := h, 
			createPackageLogicalLoc(getImportedPackageQualifiedName(p)) in importedPackages); 
	}
	return (importedPackagesStr != "") ? substring(importedPackagesStr,1) : importedPackagesStr;
}

/*
 * Creates a string from required bundles.
 */
private str requireBundleToStr(loc bundle, set[loc] requiredBundles, OSGiModel model) {
	m = getOneFrom(model.manifests[bundle]);
	string = "";
	
	if(/HeaderRequireBundle h := m) {
		for(/RequireBundle r := h) {
			string += ("" | it + ",<trim("<r>")>" | b <- requiredBundles, 
				getBundleSymbolicName(b) == getRequiredBundleQualifiedName(r));
		}
	}
		
	return (string != "") ? substring(string,1) : string;
}