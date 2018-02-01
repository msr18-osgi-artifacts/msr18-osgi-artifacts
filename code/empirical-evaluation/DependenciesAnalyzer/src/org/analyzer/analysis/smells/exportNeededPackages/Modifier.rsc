module org::analyzer::analysis::smells::exportNeededPackages::Modifier

import IO;
import Set;
import String;

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
 * Changes the manifest by removing unused exported
 * packages. 
 */
public void modifyManifests(OSGiModel model) {
	uniqueImportedPackages = {<pkg, params["lower-version"], params["upper-version"]> | 
		<bundle,pkg,params> <- model.importedPackages};
	exp = {};	
	for(<logical,physical,prams> <- model.locations) {
		impExpPackages = getImportedExportPackages(logical,uniqueImportedPackages,model);
		exportedPackagesString = exportPackageToStr(logical,impExpPackages,model);
		changeManifest(physical,exportPackage=exportedPackagesString);
	}
}

/*
 * Returns a relation with the set of exported packages
 * that have at least one import.
 */
private rel[loc,str] getImportedExportPackages(loc bundle, rel[loc,str,str] uniqueImportedPackages, OSGiModel model) {
	importedExpPackages = {};
	rel[loc,str] exportedPackages = {<pkg, params["version"]> | <pkg, params> <- model.exportedPackages[bundle]};
	
	for(<loc pkg,str version> <- exportedPackages) {
		// At least one import.
		for(<lv, uv> <- uniqueImportedPackages[pkg]) {
			lvComparison = lessThanVersion(substring(lv,1), version, versionIsInclusive(lv));
			uvComparison = lessThanVersion(version, substring(uv,1), versionIsInclusive(uv));
			if(lvComparison && uvComparison) {
				importedExpPackages += <pkg,version>;
				continue;
			}
		}
	}
	return importedExpPackages;
}

/*
 * Creates a string from exported packages.
 */
private str exportPackageToStr(loc bundle, rel[loc,str] exportedPackages, OSGiModel model) {
	m = getOneFrom(model.manifests[bundle]);
	string = "";
	if(/HeaderExportPackage h := m) {
		for(/ExportPackage p := h) {
			pkg = createPackageLogicalLoc(getExportedPackageQualifiedName(p));
			ver = "0.0.0";
			if(/ExportPackageParameter v := p, v is version) {
				ver = (/(SimpleVersion)`<QuotedVersion q>` := v) ? "<q>"[1..-1] : "<v>";
			}
			
			if(size(exportedPackages[pkg]) > 0 && ver in exportedPackages[pkg]) {
				string += ",<trim("<p>")>";
			}
		}
	}
	return (string != "") ? substring(string,1) : string;
}
