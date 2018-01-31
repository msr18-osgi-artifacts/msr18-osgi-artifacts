module org::crossminer::models::helpers::RandomClassesDiscoverer

import IO;
import Relation;
import Set;
import String;
import ValueIO;

import lang::csv::IO;
import lang::java::m3::Core;

import org::crossminer::models::CrossminerBuilder;
import org::crossminer::util::CrossminerUtil;


//--------------------------------------------------------------------------------
// Model
//--------------------------------------------------------------------------------

/*
 * - classesPerBundle: random classes per bundle (per package)
 * - classesPerPackage: random classes per package of a bundle. Thus, a
 * a package may have more than one ocurrence (e.g. different versions)
 */
data RandomClasses = randomClasses (
	rel[loc bundle, loc class] classesPerBundle = {},
	rel[loc package, loc class] classesPerPackage = {}
);


//--------------------------------------------------------------------------------
// Functions
//--------------------------------------------------------------------------------

/*
 * Creates a RandomClasses model from a CrossminerModel and a 
 * set of M3 models.
 */
public RandomClasses createRandomClasses(CrossminerModel model, loc m3Path=M3_PATH) {
	RandomClasses modelRC = randomClasses();
	i = 0; 
	for(logical <- model.locations.logical) {
		modelRC = generateClassesPerBundle(logical,m3Path,model,modelRC);
		println(i);
		i+= 1;
	}
	return modelRC;
}

/*
 * Updates a random classes model with a bundle mapping its logical 
 * path to related classes.
 */
private RandomClasses generateClassesPerBundle(loc logical, loc m3Path, CrossminerModel model, RandomClasses modelRC) {
	m3Model = readBinaryValueFile(#M3, m3Path + "/<logical.path>");
	
	//Need all info of exportedPackages
	for(<pkg,params> <- model.exportedPackages[logical]) {
		packageClasses = generateClassesPerPackage(pkg,m3Model);
		modelRC.classesPerPackage += packageClasses;
		modelRC.classesPerBundle += {<logical,pkg>} o packageClasses;
	}
	
	//If the bundle does not have exported packages, we need at least one class
	if(size(model.exportedPackages[logical]) == 0) {
		if(<pkg,cu> <- m3Model.containment, isPackage(pkg), isCompilationUnit(cu)) {
		println("Entra");
		modelRC.classesPerBundle += {<logical,pkg>} o generateClassesPerPackage(pkg,m3Model);}else{println(logical);}
	}
	return modelRC;
}

/*
 * Generates a tuple <pkg,class> per package based on
 * the information of an M3 model.
 */
private rel[loc,loc] generateClassesPerPackage(loc logical, M3 m3Model) {
	packageClasses = {};
	if(cu <- m3Model.containment[logical], isCompilationUnit(cu)) {
		if(c <- m3Model.containment[cu], isClass(c)) {
			packageClasses += <logical, c>;
		}
	}
	return packageClasses;
}

/*
 * Writes a properties file from the classesPerPackage 
 * relation. E.g.: bundSymName_bundVers=classPath 
 */ 
public void writeClassesPerBundleProperties(loc pathCSV, RandomClasses modelRC) {
	val = "";
	for(bundle <- modelRC.classesPerBundle.bundle) {
		clazz = getOneFrom(modelRC.classesPerBundle[bundle]);
		val += replaceAll("<getBundleSymbolicName(bundle)>_<getBundleVersion(bundle)>=<substring(clazz.path,1)>","/",".") + "\n";
	}
	writeFile(pathCSV,val);
}