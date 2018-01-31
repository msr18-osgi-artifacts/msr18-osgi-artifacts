module org::crossminer::analysis::metrics::CountingMetrics

import Set;

import org::crossminer::language::Syntax;
import org::crossminer::models::CrossminerBuilder;


//--------------------------------------------------------------------------------
// Functions
//--------------------------------------------------------------------------------

/*
 * Returns the number of projects or bundles in the Crossminer model.
 */
public int getBundlesSize(CrossminerModel model) 
	= size(model.locations);

/*
 * Returns the number of unique projects or bundles in the Crossminer model.
 * Different versions of the same bundle may exist in the corpus.
 */
public int getUniqueBundlesSize(CrossminerModel model)
	= size(model.locations.logical);

/*
 * Returns the number of required bundle relations in the Crossminer model.
 */
public int getRequiredBundlesSize(CrossminerModel model)
	= size(model.requiredBundles);
	
/*
 * Returns the number of unique required bundles in the Crossminer model.
 */
public int getUniqueRequiredBundlesSize(CrossminerModel model)
	= size(model.requiredBundles.reqBundle);

/*
 * Returns the number of projects with the Require-Bundle header in the Crossminer model.
 */
public int getRequireBundleHeaderFreq(CrossminerModel model)
	= size(model.requiredBundles.bundle);

/*
 * Returns the number of projects with the Import-Package header in the Crossminer model.
 */
public int getImportPackageHeaderFreq(CrossminerModel model) 
	= size(model.importedPackages.bundle);

/*
 * Returns the number of projects with the Export-Package header in the Crossminer model.
 */
public int getExportPackageHeaderFreq(CrossminerModel model)
	= size(model.exportedPackages.bundle);

/*
 * Returns the number of projects with the Require-Bundle and Import-Package headers in 
 * the Crossminer model.
 */
public int getReqBundImpPackHeadersFreq(CrossminerModel model)
	= size(model.requiredBundles.bundle & model.importedPackages.bundle);
