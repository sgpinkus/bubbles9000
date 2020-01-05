package perceptrons;
import java.lang.Math;
import java.util.Random;

/**
 * A single perceptron.
 * The activation function can be changed, by default its sum() (pass through).
 * @author sam
 * @see ActivationFunction
 */
public class Perceptron {
  private float[] weights;
  private final float bias = -1;
  private float biasWeight = 0;
  private float c = 0.1f;
  private int trainCount = 0;
  private ActivationFunction act = new Sum();

  /**
   * Class allowing abstraction of various activation functions applied to weight sum of inputs.
   */
  abstract public static class ActivationFunction {
  	abstract public float activate(float value);
  };

  /**
   * Sign function. Range is [-1.0,1.0].
   */
  public static class Sign extends ActivationFunction {
    public float activate(float sum) {
      if (sum > 0.0)
      	return 1.0f;
      else if(sum == 0.0)
      	return 0.0f;
      else
      	return -1.0f;
    }
  }

  /**
   * Simply pass the sum through 1 to 1. Not useful in a network.
   */
  public static class Sum extends ActivationFunction {
    public float activate(float sum) {
    	return sum;
    }
  }

  /**
   * The very common continuous sigmoid activation function.
   */
  public static class Sigmoid extends ActivationFunction {
    public float activate(float sum) {
    	return (float)(1.0/(1.0+Math.exp(-sum)))-0.5f;
    }
  }

  /**
   * Create a perceptron with `n` inputs.
   * @param n
   */
  public Perceptron(int n) {
    weights = new float[n];
    initWeights();
  }

  /**
   * Create a perceptron, specifying, bias, and activation.
   * @param n
   * @param biasWeight
   * @param act
   */
  public Perceptron(int n, float biasWeight, ActivationFunction act) {
    weights = new float[n];
    this.biasWeight = biasWeight;
    this.act = act;
    initWeights();
  }
  
  /**
   * Create a perceptron, specifying, bias, and activation.
   * @param n
   * @param biasWeight
   * @param act
   * @param c the learning increment.
   */
  public Perceptron(int n, float biasWeight, ActivationFunction act, float c) {
    weights = new float[n];
    this.biasWeight = biasWeight;
    this.act = act;
    this.c = c;
    initWeights();
  }

  /**
   * Randomly init weights.
   */
  private void initWeights() {
  	Random r = new Random();
    for (int i = 0; i < weights.length; i++) {
      weights[i] = r.nextFloat()*2.0f - 1.0f;
    }
  }
  
  public void setWeights(float[] nWeights) {
    weights = nWeights.clone();
  }
  
  public float[] getWeights() {
	return weights.clone();
  }
  
  public void setLearningRate(float c) {
	this.c = c;
  }
  
  public float getLearningRate() {
	return c;
  }

  /**
   * Return an output based on inputs. AKA feed forward.
   */
  public float value(float[] inputs) {
    float sum = bias*biasWeight;
    for (int i = 0; i < weights.length; i++) {
      sum += inputs[i]*weights[i];
    }
    //switch(act)
    return act.activate(sum);
  }

  /**
   * Train the network against known data.
   */
  public void train(float[] inputs, float trueValue) {
    trainCount++;
    float guess = value(inputs);
    float error = guess - trueValue;
    if(error > 0.001 || error < -0.001) {
      for (int i = 0; i < weights.length; i++) {
        float adjustment = (-error * c * inputs[i]);
        //System.out.format("run=%d, e=%.2f, g=%.2f, tv=%.2f, w%d=%f, inp=%f, adj=%f\n", trainCount, error, guess, trueValue, i, weights[i], inputs[i], adjustment);
        weights[i] += adjustment;
      }
    }
  }

  public String toString() {
    String str = "[";
    String sep = "";
    for (int i = 0; i < weights.length; i++) {
      str += sep;
      str += String.format("%.2f", weights[i]);
      sep = ",";
    }
    str += "]";
    return str;
  }
}
