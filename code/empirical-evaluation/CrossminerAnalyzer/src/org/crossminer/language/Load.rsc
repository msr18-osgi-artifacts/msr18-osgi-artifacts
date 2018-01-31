module org::crossminer::language::Load

import org::crossminer::language::internal::IO;
import org::crossminer::language::Syntax;

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