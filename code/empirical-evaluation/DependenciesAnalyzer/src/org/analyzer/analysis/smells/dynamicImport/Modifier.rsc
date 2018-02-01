module org::analyzer::analysis::smells::dynamicImport::Modifier

import IO;
import Set;
import String;

import org::analyzer::analysis::smells::Util;
import org::analyzer::analysis::modifiers::ManifestModifier;
import org::analyzer::language::Syntax;
import org::analyzer::language::Util;
import org::analyzer::models::OSGiModelBuilder;
import org::analyzer::models::helpers::ExtensionDiscoverer;
import org::analyzer::util::OSGiUtil;


//--------------------------------------------------------------------------------
// Functions
//--------------------------------------------------------------------------------

/*
 * Changes the manifest by removing resolved dynamic 
 * imported packages.
 */
public void modifyManifests(OSGiModel model) {
	for(<logical,physical,prams> <- model.locations) {
		dynamicImportedPackages = getDynamicImportedPackages(logical,model); 
		dynamicToImportedPackages = getDynamicToImportedPackages(logical,model);
		importedPackagesStr = importPackageToStr(logical,dynamicToImportedPackages,model);
		dynamicImportedPackagesStr = dynamicImportPackageToStr(logical,dynamicImportedPackages,model);
		changeManifest(physical,importPackage=importedPackagesStr,dynamicImportPackage=dynamicImportedPackagesStr);
	}
}

/*
 * Returns the set of dynamic imported packages that
 * are unresolved, or that are resolved but they are 
 * already required in the Import-Package header.
 */
private set[loc] getDynamicImportedPackages(loc bundle, OSGiModel model) 
	= {pkg | <pkg,params> <- model.dynamicImportedPackages[bundle], isUnresolved(params,model) 
		|| (isUnresolved(params,model) == false && size(model.importedPackages[bundle,pkg]) > 0)};

/*
 * Returns the set of dynamic imported packages that
 * are resolved.
 */
private set[loc] getDynamicToImportedPackages(loc bundle, OSGiModel model) 
	= {pkg | <pkg,params> <- model.dynamicImportedPackages[bundle], 
		isUnresolved(params,model) == false, size(model.importedPackages[bundle,pkg]) == 0};

/*
 * Creates a string from imported packages.
 * NOTE: no versions are managed (dynamic imported packages).
 */
private str importPackageToStr(loc bundle, set[loc] dynamicToImportedPackages, OSGiModel model) {
	m = getOneFrom(model.manifests[bundle]);
	string = "";
	
	if(/HeaderImportPackage h := m) {
		string += ("" | it + ",<trim("<p>")>" | /ImportPackage p := h); 
	}
	string += ("" | it + ",<getPackageQualifiedName(p)>" | p <- dynamicToImportedPackages);
	
	return (string != "") ? substring(string,1) : string;
}

/*
 * Creates a string from dynamic imported packages.
 */
private str dynamicImportPackageToStr(loc bundle, set[loc] dynamicImportedPackages, OSGiModel model) {
	m = getOneFrom(model.manifests[bundle]);
	string = "";
	
	if(/HeaderDynamicImportPackage h := m) {
		for(/DynamicImportDescription p := m) {
			string += ("" | it + ",<trim("<p>")>" | /QualifiedName name := p, 
				createPackageLogicalLoc("<name>") in dynamicImportedPackages);
		}		
	}
	return (string != "") ? substring(string,1) : string;
}