import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;

import org.json.*;

import evolver.*;


/**
 * This class is intended to be used with the Processing application Bubbles9000.
 * This class performs evolution on a set of <config,score> pairs, producing the set winning configs.
 * A list of pairs is read from a file, and the results are written to another file.
 * Both the input and output files have the same form:
 * 	{ configs: [ { config: [[]], configId: <int>, score: <float>, runs: <int> } ], index: <int> }
 * `score` and `runs`, are optional and not set on output. `configId` is currently not copied over. Instead its regenerated. 
 * @author sam
 */
public class ShipEvolver
{
	public final String outFileName = "config-pool.json";
	private File inFile;
	private File outFile;
	
	public ShipEvolver(File resultFile) throws IOException
	{
		this.inFile = resultFile;
		this.outFile = new File(resultFile.getParent() + outFileName);
		System.out.format("Results from %s\nWriting to %s\n", resultFile.getAbsolutePath(), outFile.getAbsolutePath());
		Evolver evo = new Evolver();
		ArrayList<Tuple<Float,float[]>> population = readPopulation();
		ArrayList<Tuple<Float,float[]>> generation = evo.generate(population);
		Evolver.printPopulation(population);
		Evolver.printPopulation(generation);
		writeGeneration(generation);
	}	
	
	/**
	 * Convert JSON text in file to an array list of pairs fit for Evolver.     
	 * @throws IOException
	 */
	private ArrayList<Tuple<Float,float[]>> readPopulation() throws IOException
	{
		ArrayList<Tuple<Float,float[]>> population = new ArrayList<Tuple<Float,float[]>>();
		String text = new String(Files.readAllBytes(inFile.toPath())); // 1.7 (=7) only.
		JSONArray resultsJson = new JSONArray(text); 
		
		for(Object obj : resultsJson) {
			JSONObject resultJson = (JSONObject)obj;
			float score = (float)resultJson.getDouble("score");
			JSONArray configJson = resultJson.getJSONArray("config");
			float[] config = new float[configJson.length()];
			for(int j = 0; j < configJson.length(); j++) {
				config[j] = (float)configJson.getDouble(j);
			}
			population.add(new Tuple<Float,float[]>(score, config));
		}
		return population;
	}
	
	/**
	 * 
	 * @param generation
	 */
	private void writeGeneration(ArrayList<Tuple<Float,float[]>> generation) throws IOException
	{
		JSONObject obj = new JSONObject();
		JSONArray configs = new JSONArray();
		// Make array of config objects.
		for(int i = 0; i < generation.size(); i++) {
			Tuple<Float,float[]> result = generation.get(i);
			JSONArray resultJson = new JSONArray(Arrays.asList(result.second));
			JSONObject item = new JSONObject();
			item.put("config", resultJson);
			item.put("configId", i);
			item.put("runs", i);
			item.put("score", 0);
			configs.put(item);
		}
		obj.put("configs", configs);
		obj.put("index", 0);
		System.out.println("Writing " + obj.toString());
		Files.write(Paths.get("/dev/tty"), obj.toString().getBytes());
	}

	public static void main(String[] args) throws IOException
	{
		if(args.length != 1) {
			System.out.format("Usage: ShipEvolver <results-file>\n");
			System.exit(1);
		}
		File file = new File(args[0]);
		if(!file.exists()) {
			System.out.println("Require a results file in '" + args[1] + "'. Existing");
			System.exit(1);
		}
		new ShipEvolver(file);
	}
}
