module org::analyzer::analysis::modifiers::ManifestModifier


private str DONT_MODIFY = "DONT_MODIFY";

@javaClass{org.analyzer.analysis.modifiers.JavaManifestModifier}
@reflect{for debugging}
public java void changeManifest(loc jarLoc, str importPackage=DONT_MODIFY, str dynamicImportPackage=DONT_MODIFY,
	str exportPackage=DONT_MODIFY, str requireBundle=DONT_MODIFY, str modifyValue=DONT_MODIFY);