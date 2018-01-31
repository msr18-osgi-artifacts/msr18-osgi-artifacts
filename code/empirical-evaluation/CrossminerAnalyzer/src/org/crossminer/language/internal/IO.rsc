module org::crossminer::language::internal::IO

import Prelude;
import IO;

@javaClass{org.crossminer.language.internal.ManifestIO}
@reflect{for debugging}
public java map[str, str] loadManifest(loc manifestLoc);