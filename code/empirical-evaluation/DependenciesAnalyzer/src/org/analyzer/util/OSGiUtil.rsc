module org::analyzer::util::OSGiUtil

import Boolean;
import IO;
import List;
import Relation;
import Set;
import String;

import org::analyzer::language::Syntax;

//--------------------------------------------------------------------------------
// Constants
//--------------------------------------------------------------------------------

public str SYSTEM_BUNDLE_ALIAS = "system.bundle";

public str SYSTEM_BUNDLE_NAME = "org.eclipse.osgi";

/*
 * Path of the generated analysis files.
 */
public loc ANALYSIS_FILES_PATH = |project://DependenciesAnalyzer/data/analysis|;

/*
 * Path of the program binary files.
 */
public loc BINARY_FILES_PATH = |project://DependenciesAnalyzer/data|;

/*
 * Path of the bundle-bundle logical locations relation based on the import package header.
 */
public loc OSGI_MODEL_PATH = BINARY_FILES_PATH + "osgi-model";

public loc M3_PATH = BINARY_FILES_PATH + "m3";

public loc M3_TEST_PATH = |project://DependenciesAnalyzer/tests/data/m3|;

/*
 * Path of the folder in the file system containing all the studied Eclipse bundles.
 */
public loc ECLIPSE_BUNDLES_PATH = |file:///Users/Documents/data/p2_repos/4.6/plugins|; 

/*
 * Extension of a JAR file.
 */
public str JAR_EXTENSION = "jar";

/*
 * Relative path in all bundles to get the correpsonding MANIFEST.MF file.
 */
public str MANIFEST_RELATIVE_PATH = "META-INF/MANIFEST.MF";

public loc RESULTS_PATH = ANALYSIS_FILES_PATH + "results.csv";


//--------------------------------------------------------------------------------
// Functions
//--------------------------------------------------------------------------------

/*
 * Creates the bundle logical location based on its symbolic name and version if
 * it exists. The URI follows the form: 
 * |bundle://<forge>/<symbolicName>/<version>| or |bundle://<forge>/<symbolicName>|.
 */
public loc createBundleLogicalLoc(str symbolicName, str version="0.0.0")
	= |bundle://eclipse| + "/<symbolicName>/<version>";

/*
 * Returns the value of the "symbolic-name" parameter of a given bundle logical location.
 */
public str getBundleSymbolicName(loc logical) 
	= split("/", logical.path)[1];

/*
 * Returns the value of the version from a bundle logical location.
 */
public str getBundleVersion(loc logical)
	= split("/", logical.path)[2];

/*
 * Returns the qualified name from a bundle logical location.
 */
public str getPackageQualifiedName(loc logical)
	= replaceAll(substring(logical.path,1),"/",".");

/*
 * Creates the package logical location based on its name. It conforms to the M3 
 * specification: |package://<package-path>|.
 */
public loc createPackageLogicalLoc(str name)
	= |java+package:///| + "<replaceAll(name, ".", "/")>";

/*
 * This method only considers major and minor version values as suggested by 
 * the OSGi specification R.6. Each version follows the grammar: 
 * ("("|"[") major(.minor(.micro(.qualifier)?)?)?
 */
public bool versionExists(list[str] vers, str lowerVersion, str upperVersion) {
	lVersion = substring(lowerVersion, 1);
	uVersion = substring(upperVersion, 1);
	found = false;
	
	for(v <- vers, !found) {
		lInclusive = (startsWith(lowerVersion, "(")) ? false: true;
		uInclusive = (startsWith(upperVersion, "(")) ? false: true;
		found = (equalToVersion(lVersion, v) || (equalToVersion(uVersion, v)) 
			|| (lessThanVersion(lVersion, v, lInclusive) && lessThanVersion(v, uVersion, uInclusive))) 
			? true : false;
	}
	return found;
}

/*
 * Returns a boolean stating if the first version (refVersion) is equal to another 
 * version (version). A version can look like "1.1.12.qualif234".
 */
public bool equalToVersion(str refVersion, str version) {
	refVArray = split(".", refVersion);
	vArray = split(".", version);
	
	refVArray = (size(refVArray) >= 2) ? refVArray[0..2] : refVArray + "0";
	vArray = (size(vArray) >= 2) ? vArray[0..2] : vArray + "0";
	
	if(toInt(refVArray[0]) == toInt(vArray[0]) && toInt(refVArray[1]) == toInt(vArray[1])) {
		return true;
	}
	return false;
}

/*
 * Returns a boolean stating if the first version (refVersion) is less than another 
 * version (version). Major, minor, and micro slots are considered. A version can 
 * look like "1.1.12.qualif234".
 */
public bool lessThanVersion(str refVersion, str version, bool inclusive) {
	refVArray = split(".", refVersion);
	vArray = split(".", version);
	
	if (size(refVArray) == 1 && refVArray[0] == "-1") {
		return false;
	}
	if (size(vArray) == 1 && vArray[0] == "-1") {
		return true;
	}
	
	refIntArray = normalizeVersion(refVArray);
	vIntArray = normalizeVersion(vArray);
	
	for(i <- [0..size(refIntArray)]) {
		if(refIntArray[i] < vIntArray[i]) {
			return true;
		}
		else if(refIntArray[i] > vIntArray[i]) {
			return false;
		}
	}
	return inclusive;
}

/*
 * Creates a version with three integer slots (i.e. macro, minor, micro).
 */
private list[int] normalizeVersion(list[str] versionArray) 
	= (size(versionArray) > 2) ? versionToInts(versionArray[0..3]) 
		: (size(versionArray) == 2) ? versionToInts(versionArray + "0") 
		: versionToInts(versionArray + ["0","0"]);

/*
 * Transforms a string version array to an integer version array.
 */
private list[int] versionToInts(list[str] versionArray) 
	= [toInt(s) | s <- versionArray];

/*
 * Detects if a version is inclusive. A version can look like "(1.1.12".
 */
public bool versionIsInclusive(str version)
	= (startsWith(version, "(")) ? false: true;

/*
 * Returns the highest version of a set of versions.
 */
public str highestVersion(set[str] versions) {
	str maxVersion = "0.0.0";
	for(v <- versions) {
		maxVersion = (lessThanVersion(maxVersion,v,true)) ? v : maxVersion;
	}
	return maxVersion;
}

/*
 * Returns the highest version of a set of versions, by considering
 * lower and upper boundary versions.
 */
public str highestVersionWithBounds(set[str] versions, str lowerVersion, str upperVersion) {
	str maxVersion = "0.0.0";
	lInclusive = (startsWith(lowerVersion, "(")) ? false: true;
	uInclusive = (startsWith(upperVersion, "(")) ? false: true;
	
	for(v <- versions) {
		maxVersion = (lessThanVersion(maxVersion,v,true) 
			&& lessThanVersion(substring(lowerVersion, 1),v,lInclusive)
			&& lessThanVersion(v,substring(upperVersion, 1),uInclusive)) 
			? v : maxVersion;
	}
	return maxVersion;
}

/*
 * Transformas a ternary relation into a binary relation.
 * The last slot of the original relation has a map.
 */
public rel[loc,loc] toBinaryRelation(rel[loc,loc,map[str,str]] relation) 
	= {<x,y> | <x,y,z> <- relation};

/*
 * Transforms a binary relation into a set. The last slot 
 * of the original relation has a map.
 */
public set[loc] binaryRelationToSet(rel[loc,map[str,str]] relation) 
	= {x | <x,y> <- relation};