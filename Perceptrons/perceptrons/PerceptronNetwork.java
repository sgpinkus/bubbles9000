package perceptrons;

import java.util.Arrays;
import java.util.Iterator;

/**
 * A set of perceptrons. Each perceptron acts independently on the same input vector.
 * The ith perceptron generates the ith output.
 * The network is trained with an input vector, exemplar vector pair.
 * The ith pereptron is taught against the ith value.
 * The bias weight setting of each perceptron is not accessible ad set to 0 - the default.
 * @author sam
 */
public class PerceptronNetwork implements Iterable<Perceptron>
{
	public final int nIn;
	public final int nOut;
	public final int nWeights;
	private Perceptron[] perceptrons;
	private Perceptron.ActivationFunction act = new Perceptron.Sum();

	public PerceptronNetwork(int nIn, int nOut) {
		this.nIn = nIn;
		this.nOut = nOut;
		this.nWeights = nIn*nOut;
		perceptrons = new Perceptron[nOut];
		for(int i = 0; i < nOut; i++) {
			perceptrons[i] = new Perceptron(nIn, 0, act);
		}
	}

	public PerceptronNetwork(int nIn, int nOut, Perceptron.ActivationFunction act) {
		this.nIn = nIn;
		this.nOut = nOut;
		this.nWeights = nIn*nOut;
		perceptrons = new Perceptron[nOut];
		for(int i = 0; i < nOut; i++) {
			perceptrons[i] = new Perceptron(nIn, 0, act);
		}
	}
	
	public PerceptronNetwork(int nIn, int nOut, Perceptron.ActivationFunction act, float c) {
		this.nIn = nIn;
		this.nOut = nOut;
		this.nWeights = nIn*nOut;
		perceptrons = new Perceptron[nOut];
		for(int i = 0; i < nOut; i++) {
			perceptrons[i] = new Perceptron(nIn, 0, act, c);
		}
	}
	
	/**
	 * Set weights. Length of arrays must match nOut by nIn.
	 * @param weights
	 */
	public void setWeights(float[][] weights) {
		for(int i = 0; i < perceptrons.length; i++) {
			perceptrons[i].setWeights(weights[i]);
		}
	}
	
	/**
	 * Set weights. Length of arrays must match nOut*nIn.
	 * @param weights
	 */
	public void setWeights(float[] weights) {
		for(int i = 0; i < nOut; i++) {
			perceptrons[i].setWeights(Arrays.copyOfRange(weights, i*nOut, i*nOut+nIn));
		}
	}
	
	/**
	 * Get weights as flat array nOut*nIn.
	 * @return
	 */
	public float[] getWeights() {
		float[] weights = new float[nIn*nOut];
		for(int i = 0; i < nOut; i++) {
			float[] pWeights = perceptrons[i].getWeights();
			for(int j = 0; j < nIn; j++) {
				weights[(i*nOut)+j] = pWeights[j];
			}
		}
		return weights;
	}	

	public float[] value(float[] inputs) {
		float[] outputs = new float[nOut];
		for(int i = 0; i < nOut; i++) {
			outputs[i] = perceptrons[i].value(inputs);
		}
		return outputs;
	}

	public void train(float[] inputs, float[] trueValue) {
		for(int i = 0; i < nOut; i++) {
			perceptrons[i].train(inputs, trueValue[i]);
		}
	}

	public String toString() {
		String str = "";
		String sep = "";
		for(int i = 0; i < nOut; i++) {
			str += sep;
			str += perceptrons[i];
			sep = ",";
		}
		return str;
	}

	@Override
	public Iterator<Perceptron> iterator() {
	  return Arrays.asList(perceptrons).iterator();
	}
}
