module org::analyzer::language::Load

import org::analyzer::language::internal::IO;
import org::analyzer::language::Syntax;

import IO;
import ParseTree;


//--------------------------------------------------------------------------------
// Functions
//--------------------------------------------------------------------------------

/*
 *
 */
public start[Manifest] parseManifest (loc manifestFile) {
	map[str, str] manifestMap = loadManifest(manifestFile);
	str manifest = "<for (k <- manifestMap) {><k>: <manifestMap[k]><}>";
	return parse(#start[Manifest], manifest, allowAmbiguity=false);
}