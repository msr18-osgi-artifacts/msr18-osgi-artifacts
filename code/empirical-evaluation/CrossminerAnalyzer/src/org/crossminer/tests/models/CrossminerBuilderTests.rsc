module org::crossminer::tests::models::CrossminerBuilderTests

import IO;
import List;
import Map;
import Node;
import Set;
import ValueIO;
import org::crossminer::models::CrossminerBuilder;
import org::crossminer::util::CrossminerUtil;
 
 
//--------------------------------------------------------------------------------
// Tests
//--------------------------------------------------------------------------------

/*
 * Checks if the test model has the same information as the expected or
 * reference Crossminer model.
 */
public test bool eclipseModelRemainedTheSame() 
    = compareCrossminerModels(|project://CrossminerAnalyzer/tests/data/crossminer_model/crossminer-model|, 
    		|project://CrossminerAnalyzer/tests/data/corpus_bytecode/|, getEclipseModel);


//--------------------------------------------------------------------------------
// Functions
//--------------------------------------------------------------------------------

/*
 * Creates a Crossminer model based on the test data. M3 models are not
 * generated again.
 */
private CrossminerModel getEclipseModel(loc corpus) 
	= createCrossminerModelFromDirectory(corpus, m3=false, m3Path=M3_PATH);

/*
 * Compares the reference model against the test model. The reference model
 * is read from a binary file.
 */
private bool compareCrossminerModels(loc refModel, loc corpus, CrossminerModel (loc) builder)
	= compareCrossminerModels(
		readBinaryValueFile(#CrossminerModel, refModel),
		builder(corpus)
	);

/*
 * Compares all relations and values of the reference and test models.
 * Based on |rascal/src/org/rascalmpl/library/lang/rascal/tests/library/lang/java/m3/BasicM3Tests.rsc|
 * compareM3s(M3 a, M3 b) function.
 */
private bool compareCrossminerModels(CrossminerModel m1, CrossminerModel m2) {
	map[str,value] m1Keys = getKeywordParameters(m1);
	map[str,value] m2Keys = getKeywordParameters(m2);
	
	for(k <- m1Keys) {
		//Missing keyword parameter in the test model
		if(!(k in m2Keys)) {
			throw "<k> is missing in the test model.";
		}
		
		if(m1Keys[k] != m2Keys[k] && set[value] set1 := m1Keys[k] && set[value] set2 := m2Keys[k]) {
			//Different sizes
			if(size(set1) != size(set2)) {
				println("Missing elements: <set1 - set2>");
				println("Additional elements: <set2 - set1>");
				throw "The size of <k> in the reference model is <size(set1)>, 
					while in the test model is <size(set2)>.";
			}
			//Different values
			else{
				sortM1 = sort(toList(set1));
				sortM2 = sort(toList(set2));
				if(sortM1 != sortM2) {
					diff = {<sortM1[i], sortM2[i]> | i <- [0..size(sortM1)], sortM1[i] != sortM2[i]};
					println("Different values: <diff>");
					throw "In <k> there are <size(diff)> different values between 
						the reference and test models";
				}
			}
		}
	}
	
	for(k <- m2Keys) {
		//Missing keyword parameter in the reference model
		if(!(k in m1Keys)) {
			throw "<k> is missing in the reference model.";
		}
	}
	
	return true;
}