module org::analyzer::language::internal::IO

import Prelude;
import IO;

@javaClass{org.analyzer.language.internal.ManifestIO}
@reflect{for debugging}
public java map[str, str] loadManifest(loc manifestLoc);