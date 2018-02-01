module org::analyzer::analysis::metrics::CountingMetrics

import Set;

import org::analyzer::language::Syntax;
import org::analyzer::models::OSGiModelBuilder;


//--------------------------------------------------------------------------------
// Functions
//--------------------------------------------------------------------------------

/*
 * Returns the number of projects or bundles in the OSGi model.
 */
public int getBundlesSize(OSGiModel model) 
	= size(model.locations);

/*
 * Returns the number of unique projects or bundles in the OSGi model.
 * Different versions of the same bundle may exist in the corpus.
 */
public int getUniqueBundlesSize(OSGiModel model)
	= size(model.locations.logical);

/*
 * Returns the number of required bundle relations in the OSGi model.
 */
public int getRequiredBundlesSize(OSGiModel model)
	= size(model.requiredBundles);
	
/*
 * Returns the number of unique required bundles in the OSGi model.
 */
public int getUniqueRequiredBundlesSize(OSGiModel model)
	= size(model.requiredBundles.reqBundle);

/*
 * Returns the number of projects with the Require-Bundle header in the OSGi model.
 */
public int getRequireBundleHeaderFreq(OSGiModel model)
	= size(model.requiredBundles.bundle);

/*
 * Returns the number of projects with the Import-Package header in the OSGi model.
 */
public int getImportPackageHeaderFreq(OSGiModel model) 
	= size(model.importedPackages.bundle);

/*
 * Returns the number of projects with the Export-Package header in the OSGi model.
 */
public int getExportPackageHeaderFreq(OSGiModel model)
	= size(model.exportedPackages.bundle);

/*
 * Returns the number of projects with the Require-Bundle and Import-Package headers in 
 * the OSGi model.
 */
public int getReqBundImpPackHeadersFreq(OSGiModel model)
	= size(model.requiredBundles.bundle & model.importedPackages.bundle);
