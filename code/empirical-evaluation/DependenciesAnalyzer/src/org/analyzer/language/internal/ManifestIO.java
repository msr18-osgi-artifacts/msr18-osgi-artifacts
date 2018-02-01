package org.analyzer.language.internal;


import java.io.IOException;
import java.io.InputStream;
import java.util.jar.Manifest;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import org.rascalmpl.interpreter.IEvaluatorContext;
import org.rascalmpl.interpreter.utils.RuntimeExceptionFactory;
import org.rascalmpl.uri.URIResolverRegistry;

import io.usethesource.vallang.IMap;
import io.usethesource.vallang.IMapWriter;
import io.usethesource.vallang.ISourceLocation;
import io.usethesource.vallang.IValueFactory;

/**
 * Notes to self:
 *   - Where to retrieve .jar/.MF identified by
 *     Bundle-SymbolicName "remotely"?
 *     (e.g. Tycho / p2 / Maven / whatever)
 */
public class ManifestIO {
	
	private final static String MANIFEST_RELATIVE_PATH = "META-INF/MANIFEST.MF";
	private final IValueFactory factory;
	private URIResolverRegistry registry;
	
	public ManifestIO(IValueFactory factory) {
		this.factory = factory;
		this.registry = URIResolverRegistry.getInstance();
	}

	public IMap loadManifest(ISourceLocation loc, IEvaluatorContext ctx) {
		IMapWriter mWriter = factory.mapWriter();
		try {
			InputStream is = registry.getInputStream(loc);
	        ZipInputStream jarStream = new ZipInputStream(is);
	        ZipEntry entry = jarStream.getNextEntry();
	        boolean found = false;

	        while (entry != null && !found) {
	        	    //ctx.getStdErr().println(entry.getName());
	        		if(entry.getName().equalsIgnoreCase(MANIFEST_RELATIVE_PATH)) {
	        			Manifest mf = new Manifest(jarStream);
	        			
	        			mf.getMainAttributes()
	        			.forEach((k, v) -> {
	        				String key = k.toString();
	        				String val = v.toString() + "\n";
	        				
	        				mWriter.put(
	        					factory.string(key),
	        					factory.string(val)
	        				);
	        			});
	        			found = true;
	        		}
	            entry = jarStream.getNextEntry();
	        }

			return mWriter.done();
		} 
		catch (IOException e) {
			throw RuntimeExceptionFactory.io(factory.string(e.getMessage()), null, null);
		}
	}
}
