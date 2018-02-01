module org::analyzer::analysis::smells::neededPackages::Modifier

import IO;
import Set;
import String;

import org::analyzer::analysis::modifiers::ManifestModifier;
import org::analyzer::analysis::smells::Util;
import org::analyzer::language::Syntax;
import org::analyzer::models::OSGiModelBuilder;
import org::analyzer::models::helpers::ExtensionDiscoverer;
import org::analyzer::util::OSGiUtil;


//--------------------------------------------------------------------------------
// Functions
//--------------------------------------------------------------------------------

/*
 * Changes the manifest by adding used but undeclared dependencies
 * (i.e. imported packages).
 * TODO: manage packages from fragment host bundles!
 */
public void modifyManifests(OSGiModel model) {
	for(<logical,physical,prams> <- model.locations) {
		candidatePackages = getUsedUnimportedPackages(logical,model);
		usedUnimportedPackages = getAvailablePackages(candidatePackages,model);
		importedPackagesStr = importPackageToStr(logical,usedUnimportedPackages,model);
		changeManifest(physical,importPackage=importedPackagesStr);
	}
}

/*
 * Returns a set with the used unimported packages of a 
 * given bundle (both required bundles and imported packages
 * are considered).
 */
private set[loc] getUsedUnimportedPackages(loc bundle, OSGiModel model) {
	importedPackages = {pkg | <pkg, params> <- model.importedPackages[bundle]};
	requiredPackages = getPackagesReqBundles(bundle,model);
	return model.importedPackagesBC[bundle] - importedPackages - requiredPackages - model.bundlePackagesBC[bundle];
}

/*
 * Returns the packages exported by required bundles of
 * a given bundle.
 */
private set[loc] getPackagesReqBundles(loc bundle, OSGiModel model) 
	= getPackagesReqBundles(model)[bundle];

/*
 * Returns a subset of used unimported packages that are 
 * available in the corpus.
 */
private set[loc] getAvailablePackages(set[loc] candidatePackages, OSGiModel model) 
	= {p | p <- candidatePackages, size(model.exportedPackages[_,p]) > 0};

/*
 * Creates a string from imported packages, including used
 * unimported packages (no versions or other parameter are set).
 */
private str importPackageToStr(loc bundle, set[loc] usedUnimportedPackages, OSGiModel model) {
	m = getOneFrom(model.manifests[bundle]);
	string = "";
	
	if(/HeaderImportPackage h := m) {
		string = ("" | it + ",<trim("<p>")>" | /ImportPackage p := h); 
	}
	string += ("" | it + ",<getPackageQualifiedName(p)>" | p <- usedUnimportedPackages);
	
	return (string != "") ? substring(string,1) : string;
}
