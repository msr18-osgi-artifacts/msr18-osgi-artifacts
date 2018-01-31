module org::crossminer::language::Util

import org::crossminer::language::Syntax;


//TODO: refactor
public str getExportedPackageQualifiedName(ExportPackage package) {
	if(/QualifiedName name := package) {
		return "<name>";
	}
	return "";
}

public str getImportedPackageQualifiedName(ImportPackage package) {
	if(/QualifiedName name := package) {
		return "<name>";
	}
	return "";
}

public str getRequiredBundleQualifiedName(RequireBundle bundle) {
	if(/QualifiedName name := bundle) {
		return "<name>";
	}
	return "";
}

public bool reqBundleHasVersion(RequireBundle bundle) 
	= (/QuotedHybridVersion v := bundle) ? true : false;
