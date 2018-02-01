# MSR 2018 OSGi Artifacts

The current repository hosts all the artifacts related to the article **An Empirical Evaluation of OSGi Dependencies Best Practices in the Eclipse IDE**, submitted to MSR 2018. Its content is structured as follows:

## code
This folder contains all the code that supports the current research. It is divided in two subdirectories: 

1. **systematic-review**: hosts the Java project employed during the automatic phases of the Systematic Review (SR). This project was built with the only purpose of supporting the authors with the selection and extraction phase of our SR resources (it is not yet plan to be reused by other projects).
2. **empirical-evaluation**: hosts two packages: one package with a Rascal/Java project meant to create the OSGi model from a given corpus of bundles and perform the correponding transformations (according to the presented best practices); and another package with the trackers (Eclipse plug-ins) used to get bundles classpath size and resolution time, as well as the standalone Equinox environment employed to run the research tests.

## corpora
This folder hosts the seven corpora used during our empirical evaluation. These corpora are the output of the transformations allocated in one of the *code/empirical-evaluation* projects.

1. **control**: initial corpus with 372 bundles without performing any transformation.
2. **requireBundle**: transformed corpus addressing best practice *Prefer package-level dependencies [B1]*.
3. **useVersions**: transformed corpus addressing best practice *Use versions when possible [B2]*.
4. **exportNeededPackages**: transformed corpus addressing best practice *Export only needed packages [B3]*.
5. **minimizeDependencies**: transformed corpus addressing best practice *Minimize dependencies [B4]*.
6. **neededPackages**: transformed corpus addressing best practice *Import all needed packages [B5]*.
7. **dynamicImport**: transformed corpus addressing best practice *Avoid DynamicImport-Package [B6]*.

## results
This folder contains all results related to our SR and empirical evaluation. It is also (unsurprisingly) divided in two directories:

1. **systematic-review**: contains the original files of the selected web resources, as well as a XSLX file (i.e. *results.xslx*) with the results obtained during the different phases of the SR study selection. 
2. **empirical-evaluation**: contains a folder per corpus (initial and transformed corpora) with the trackers generated results (CVS files). Each folder also tabulates all classpath size and resolution time results in a file named *comparison-[corpous-name].xlsx*. Final results of the whole study are gathered in the *results.xlsx* file. 
