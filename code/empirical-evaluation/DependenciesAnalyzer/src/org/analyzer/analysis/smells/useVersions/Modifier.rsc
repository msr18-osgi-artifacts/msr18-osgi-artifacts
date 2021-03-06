module org::analyzer::analysis::smells::useVersions::Modifier

import IO;
import Set;
import String;

import org::analyzer::analysis::modifiers::ManifestModifier;
import org::analyzer::language::Syntax;
import org::analyzer::language::Util;
import org::analyzer::models::OSGiModelBuilder;
import org::analyzer::util::OSGiUtil;


//--------------------------------------------------------------------------------
// Functions
//--------------------------------------------------------------------------------

/*
 * Changes the manifest by adding strict versions to unversioned
 * imported packages and required bundles.
 */
public void modifyManifests(OSGiModel model) {
	for(<logical,physical,prams> <- model.locations) {
		unversionedImpPackages = getUnversionedImpPackages(logical,model);		
		importedPackagesStr = importPackageToStr(logical,unversionedImpPackages,model);
		requiredBundlesStr = requiredBundleToStr(logical,model);
		changeManifest(physical,importPackage=importedPackagesStr,requireBundle=requiredBundlesStr);
	}
}

/*
 * Returns a relation with unversioned imported packages and their 
 * suggested version (highest version in exported packages).
 */
private rel[loc,str] getUnversionedImpPackages(loc bundle, OSGiModel model) {
	unversionedImpPackages = getUnversionedImpPackagesSet(bundle,model);
	impPackages = {};
	for(p <- unversionedImpPackages) {
		versions = {params["version"] | params <- model.exportedPackages[_,p]};
		maxVersion = highestVersion(versions);
		impPackages += <p,maxVersion>;
	}
	return impPackages;
}

/*
 * Returns a set with unversioned but resolved imported packages.
 */
private set[loc] getUnversionedImpPackagesSet(loc bundle, OSGiModel model)
	= {pkg | <pkg, params> <- model.importedPackages[bundle], 
		params["version-spec"] == "none", params["resolved"] == "true"};
	
/*
 * Creates a string from imported packages (with version changes).
 */
private str importPackageToStr(loc bundle, rel[loc,str] unversionedImpPackages, OSGiModel model) {
	string = "";
	m = getOneFrom(model.manifests[bundle]);
	
	if(/HeaderImportPackage h := m) {
		for(/ImportPackage p := h) {
			pkgLogical = createPackageLogicalLoc(getImportedPackageQualifiedName(p));
			if(size(unversionedImpPackages[pkgLogical]) == 0) {
				string += ",<trim("<p>")>";
			}
			else {
				v = getOneFrom(unversionedImpPackages[pkgLogical]);
				string += ",<trim("<p>")>;version=\"[<v>,<v>]\"";
			}
		}
	}
	
	return (string != "") ? substring(string,1) : string;
}

/*
 * Creates a string from required bundles (with version changes).
 */
private str requiredBundleToStr(loc bundle, OSGiModel model) {
	string = "";
	m = getOneFrom(model.manifests[bundle]);
	
	if(/HeaderRequireBundle h := m) {
		for(/RequireBundle r := h) {
			if(reqBundleHasVersion(r) || getRequiredBundleQualifiedName(r) == SYSTEM_BUNDLE_ALIAS) {
				string += ",<trim("<r>")>";
			}
			else {
				// During the model generation the version is suggested and is included as part of the loc.
				for(<reqBund,params> <- model.requiredBundles[bundle], params["resolved"] == "true", 
					getBundleSymbolicName(reqBund) == getRequiredBundleQualifiedName(r)) {
					v = getBundleVersion(reqBund);
					string += ",<trim("<r>")>;bundle-version=\"[<v>,<v>]\"";
				}
			}
		}
	}
	
	return (string != "") ? substring(string,1) : string;
}