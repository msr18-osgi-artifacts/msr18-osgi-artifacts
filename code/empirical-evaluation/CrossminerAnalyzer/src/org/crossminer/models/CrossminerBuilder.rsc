module org::crossminer::models::CrossminerBuilder

import IO;
import Set;
import Relation;
import ValueIO;
import lang::java::m3::Core;

import org::crossminer::language::Load;
import org::crossminer::language::Syntax;
import org::crossminer::models::resolvers::BundleResolver;
import org::crossminer::models::resolvers::M3Resolver;
import org::crossminer::models::resolvers::PackageResolver;
import org::crossminer::util::CrossminerUtil;


//--------------------------------------------------------------------------------
// Model
//--------------------------------------------------------------------------------

/*
 * - locations: maps from the logical location of a bundle to its physical location.
 * - requiredBundles: maps from the logical location of a bundle to one of its required 
 * bundles logical location. Header related parameters are included.
 * - importedPackages: maps from the logical location of a bundle to one of its imported 
 * packages logical location. Header related parameters are included.
 * - exportedPackages: maps from the logical location of a bundle to one of its exported 
 * packages logical location. Header related parameters are included.
 * - dynamicImportedPackages: maps from the logical location of a bundle to one of its 
 * dynamically imported packages logical location. Header related parameters are included.
 * - importedPackagesBC: maps from the logical location of a bundle to the logical location 
 * of packages used in the bytecode (cf. M3). 
 * - bundlePackagesBC: maps from the logical location of a bundle to the logical location 
 * of packages of the bundle (cf. M3). 
 * - manifests: maps from the logical location of a bundle to a set with the parsed headers 
 * of its manifest.
 */
data CrossminerModel = crossminerModel (
	loc id,
	rel[loc logical, loc physical, map[str,str] params] locations = {},								
	rel[loc bundle, loc reqBundle, map[str,str] params] requiredBundles = {},	
	rel[loc bundle, loc impPackage, map[str,str] params] importedPackages = {},
	rel[loc bundle, loc expPackage, map[str,str] params] exportedPackages = {},
	rel[loc bundle, loc dynImpPackage, map[str,str] params] dynamicImportedPackages = {},
	rel[loc bundle, loc impPackage] importedPackagesBC = {},
	rel[loc bundle, loc package] bundlePackagesBC = {},
	rel[loc bundle, set[Header] headers] manifests = {}
);


//--------------------------------------------------------------------------------
// Functions
//--------------------------------------------------------------------------------

/*
 * Returns an CrossminerModel with the information of all JAR files present in the given
 * directory.
 */
public CrossminerModel createCrossminerModelFromDirectory (loc directory, bool m3=false, loc m3Path=M3_PATH) {
	CrossminerModel model = crossminerModel(directory);
	model = addCrossminerModelMetadataRelations(model);
	model = addCrossminerModelM3Relations(model, m3, m3Path);
	return model;
}

/*
 * Adds metadata relations to  a CrossminerModel with the information of all 
 * JAR files present in the given directory (model.id).
 */
public CrossminerModel addCrossminerModelMetadataRelations (CrossminerModel model) {
	println("Creating bundle location and manifest relations...");
	model = setCrossminerModelLocs(model.id, model);
	
	println("Creating required bundle and exported package relations...");
	model = setCrossminerModelReqBundlesExpPackages(model);	
	
	println("Creating imported and dynamic imported package relations...");
	model = setCrossminerModelImpPackages(model);
	
	return model;
}

/*
 * Creates a CrossminerModel from a binary value file.
 */
public CrossminerModel createCrossminerModelFromBinaryFile(loc file) 
	= readBinaryValueFile(#CrossminerModel, file);
	
/*
 * Returns the model received as parameter with the locations and manifests relations.
 */
private CrossminerModel setCrossminerModelLocs(loc directory, CrossminerModel model) {
	jars = getJarsLoc(directory);
	
	for(loc jar <- jars) {
		println(jar);
		start[Manifest] pm = parseManifest(jar);
		heads = {h | /Header h := pm};
		tuple[loc logical, loc physical, map[str,str] params] location = getBundleLocation(jar, pm);
		
		model.locations += {location};
		model.manifests += {<location.logical, heads>};
	}
	
	return model;
}

/*
 * Returns the model received as parameter with the requiredBundles and exportedPackages 
 * relations.
 */
public CrossminerModel setCrossminerModelReqBundlesExpPackages(CrossminerModel model) {
	for(location <- model.locations) {
		model.requiredBundles += getRequiredBundles(location.logical, model);
		model.exportedPackages += getExportPackages(location.logical, model);
	}
	return model;
}

/*
 * Returns the model received as parameter with the importedPackages relation.
 */
public CrossminerModel setCrossminerModelImpPackages(CrossminerModel model) {	
	for(location <- model.locations) {
		model.importedPackages += getImportPackages(location.logical, model);
		model.dynamicImportedPackages += getDynamicImportPackages(location.logical, model);
	}
	return model;
}

/*
 * Adds M3 relations to  a CrossminerModel with the information of all 
 * JAR files present in the given directory (model.id).
 */
public CrossminerModel addCrossminerModelM3Relations(CrossminerModel model, bool m3Models, loc m3Path) {	
	if(m3Models){
		println("Creating M3 models from Jar files...");
		createCrossminerModelM3s(model, m3Path);
	}
	
	println("Creating M3 imported and bundle package relations...");
	model = setCrossminerModelM3Relations(model, m3Path);
	
	return model;
}

/*
 * Creates M3 models as binary files given the loc of the CrossminerModel folder.
 */
private void createCrossminerModelM3s(CrossminerModel model, loc m3Path) {
	jars = getJarsLoc(model.id);
	i = 0;
	for(loc jar <- jars){
		println("<i>: <jar>");
		logical = getOneFrom(invert(model.locations)[_,jar]);
		writeBinaryValueFile(m3Path + "/<logical.path>", createM3FromJar(jar));
		i+=1;
	}
}

/*
 * Returns the model received as parameter with the bytecode imported and bundle
 * packages relations.
 */
private CrossminerModel setCrossminerModelM3Relations(CrossminerModel model, loc m3Path) {
	i=0;
	for(logical <- model.locations.logical) {
		println(i);
		m3Model = readBinaryValueFile(#M3, m3Path + "/<logical.path>");
		model.importedPackagesBC += getImportedPackagesBC(logical, m3Model);
		model.bundlePackagesBC += getBundlePackagesBC(logical, m3Model);
		i+=1;
	}
	return model;
}

/*
 * Serializes a Crossminer model in a binary value file.
 */
public void serializeCrossminerModel(CrossminerModel model, loc file=CROSSMINER_MODEL_PATH)
	= writeBinaryValueFile(file, model);

/*
 * Returns the list of Jar files located in the given location.
 */
private list[loc] getJarsLoc(loc directory) {
	content = listEntries(directory);
	return [directory + "/<l>" | str l <- content, isFile(directory + l), l[-3..] == JAR_EXTENSION];
}