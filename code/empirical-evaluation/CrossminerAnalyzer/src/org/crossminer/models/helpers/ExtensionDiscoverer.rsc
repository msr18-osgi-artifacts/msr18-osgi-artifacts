module org::crossminer::models::helpers::ExtensionDiscoverer

import IO;
import lang::xml::DOM;
import Relation;
import Set;

import org::crossminer::models::CrossminerBuilder;


//--------------------------------------------------------------------------------
// Model
//--------------------------------------------------------------------------------

/*
 * - extensionPoints: bundles exposing extension points in their plugin.xml
 * - extensions: bundles offering an extension related to an extension point.
 */
data Extension = extension (
	rel[loc bundle, str extensionPoint] extensionPoints = {},
	rel[loc bundle, str extension] extensions = {}
);


//--------------------------------------------------------------------------------
// Functions
//--------------------------------------------------------------------------------

/*
 * Returns an extension model.
 */
public Extension getExtensionBundles(CrossminerModel model) {
	set[Extension] extensions = {};
	for(<l,p,m> <- model.locations) {
		p.scheme = "jar+<p.scheme>";
		p.path = p.path + "!";
		plugin = getPluginFile(p);
		if(exists(plugin) && plugin != |file:///|) {
			extensions += getExtensionModels(m["symbolic-name"],l,plugin);
		}
	}
	return composeExtensionModels(extensions);
}

/*
 * Returns the loc pointing to the plugin.xml file.
 */
private loc getPluginFile(loc jar) {
	try 
		return find("plugin.xml", [jar]);
		
	catch: 
		files = jar.ls;
		plugin = |file:///|;
		for(f <- files, plugin == |file:///|, isDirectory(f)) {
			plugin = getPluginFile(f);
			return plugin;
		}
		return plugin;
}

/*
 * Composes multiple Extension models.
 */ 
public Extension composeExtensionModels(set[Extension] models) {
	m = extension();
	m.extensions = {*model.extensions | model <- models};
	m.extensionPoints = {*model.extensionPoints | model <- models};
	return m;
}

/*
 * Creates the relations of a given Extension model.
 */
public Extension getExtensionModels(str symbolicName, loc logical, loc file) {
	dom = parseXMLDOM(readFile(file));
	e = extension();	
	e.extensions += {*getExtensionTuple(logical, n) | /Node n:element(_,"extension",_) := dom};
	e.extensionPoints += {*getExtensionPointTuple(symbolicName, logical, n) | /Node n:element(_,"extension-point",_) := dom};
	return e;
}

/*
 * Creates an extension tuple.
 */
private rel[loc,str] getExtensionTuple(loc logical, Node n)
	= (/Node a:attribute(_,"point",_) := n) ? {<logical, a.text>} : {};

/*
 * Creates an extension point tuple.
 */
private rel[loc,str] getExtensionPointTuple(str symbolicName, loc logical, Node n) 
	= (/Node a:attribute(_,"id",_) := n) ? {<logical, "<symbolicName>.<a.text>">} : {};

/*
 * Gets the intersection between required bundles and extension
 * tuples.
 */
public rel[loc,loc] getExtensionReqBundles(CrossminerModel c, Extension e) {
	flatE = e.extensions o invert(e.extensionPoints);
	flatRB = {<b,r> | <b,r,p> <- c.requiredBundles};
	return flatE & flatRB;
}

/*
 * Gets the complement of the intersection between required bundles 
 * and extension tuples.
 */
public rel[loc,loc] getComplementExtensionReqBundles(CrossminerModel c, Extension e) {
	flatE = e.extensions o invert(e.extensionPoints);
	flatRB = {<b,r> | <b,r,p> <- c.requiredBundles};
	return flatRB - (flatE & flatRB);
}