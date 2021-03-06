module org::analyzer::models::helpers::ResourceAccessDiscoverer

import lang::java::m3::Core;
import Relation;
import Set;
import ValueIO;

import org::analyzer::models::OSGiModelBuilder;

public set[loc] getBundlesWithResourceAccess(OSGiModel model, loc m3Path) {
	bundles = {};
	resourceLoc = |java+method:///org/osgi/framework/Bundle/getResources(java.lang.String)|;
	for(l <- model.locations.logical) {
		M3 m3 = readBinaryValueFile(#M3, m3Path + "/<l.path>");
		if(size(invert(m3.methodInvocation)[resourceLoc]) > 0) {
			bundles += l;
		}
	}
	
	return bundles;
}