package org.analyzer.analysis.modifiers;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Enumeration;
import java.util.jar.Attributes;
import java.util.jar.Attributes.Name;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import java.util.jar.JarOutputStream;
import java.util.jar.Manifest;

import org.rascalmpl.interpreter.IEvaluatorContext;
import io.usethesource.vallang.ISourceLocation;
import io.usethesource.vallang.IString;
import io.usethesource.vallang.IValueFactory;

public class JavaManifestModifier {
	
	public JavaManifestModifier(IValueFactory factory) {
	}
	
	public void changeManifest(ISourceLocation jarLoc, IString importPackage, IString dynamicImportPackage,
		IString exportPackage, IString requireBundle, IString modifyValue, IEvaluatorContext ctx) {
		JarFile jar = getJarFile(jarLoc);
		Manifest manifest;
		try {
			manifest = new Manifest(jar.getManifest());
			String modify = modifyValue.getValue();
			
			if(!importPackage.getValue().equals(modify)) {
				manifest = transformHeader(manifest, "Import-Package", importPackage, ctx);
			}
			if(!dynamicImportPackage.getValue().equals(modify)) {
				manifest = transformHeader(manifest, "DynamicImport-Package", dynamicImportPackage, ctx);
			}
			if(!exportPackage.getValue().equals(modify)) {
				manifest = transformHeader(manifest, "Export-Package", exportPackage, ctx);
			}
			if(!requireBundle.getValue().equals(modify)) {
				manifest = transformHeader(manifest, "Require-Bundle", requireBundle, ctx);
			}
			
			rewriteManifest(jarLoc, manifest, ctx);
		} 
		catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	private JarFile getJarFile(ISourceLocation jarLoc) {
		try {
			File file = new File (jarLoc.getPath());
			return new JarFile(file);
		} 
		catch (IOException e) {
			e.printStackTrace();
		}
		return null;
	}
	
	private Manifest transformHeader(Manifest manifest, String header, IString content, IEvaluatorContext ctx) {
		Attributes attributes = manifest.getMainAttributes();
		String newContent = content.getValue().trim();
				
		if(!newContent.isEmpty()) {
			attributes.put(new Name(header), newContent);
		}
		else {
			attributes.remove(new Name(header)); 
		} 
		
		return manifest;
	}
	
	//TODO: digest files are being removed to avoid loading problems. Correct in the future.
	private void rewriteManifest(ISourceLocation jarLoc, Manifest manifest, IEvaluatorContext ctx) {
		JarOutputStream outputStream = null;
		JarFile oldJar = null;
		
		try {	
			ctx.getStdOut().println("Starting Jar processing: " + jarLoc.getPath());
			File newFile = File.createTempFile("temp", ".jar");
			File oldFile = new File (jarLoc.getPath());
			oldJar = new JarFile(oldFile);
			
			//Copy files from previous Jar.
			outputStream = new JarOutputStream(new FileOutputStream(newFile), manifest);
			Enumeration<JarEntry> entries = oldJar.entries();
			
			while(entries.hasMoreElements()) {
				JarEntry entry = entries.nextElement();
				if (!entry.getName().equals("META-INF/MANIFEST.MF") && !entry.getName().endsWith(".SF") 
						&& !entry.getName().endsWith(".RSA") && !entry.getName().endsWith(".DSA")){
					InputStream inputStream = oldJar.getInputStream(entry);
					outputStream.putNextEntry(entry);
					
					byte[] buffer = new byte[1024];
					int read = 0;
					while((read = inputStream.read(buffer)) != -1) {
						outputStream.write(buffer, 0, read);
					}
				}
			}
			
			outputStream.close();
			oldJar.close();
			oldFile.delete();
			newFile.renameTo(oldFile);
		} 
		catch (IOException e) {
			ctx.getStdErr().println(e.getMessage());
			e.printStackTrace();
		}
	}
}
