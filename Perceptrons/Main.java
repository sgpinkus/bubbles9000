import java.lang.Math;
import java.util.Random;
import perceptrons.*;

/**
 * Teach a single unit perceptron.
 */
public class Main
{
  public static float[][] generatePlane(float slope, float bias) {
    Random r = new Random();
    float[][] data = new float[200][];
    for(int i = 0; i < 200; i++) {
      // y = ax+b
      float x = r.nextFloat()*2.0f-1.0f;
      float y = r.nextFloat()*2.0f-1.0f;
      float value = slope*x+bias;
      float error = value - y;
      data[i] = new float[] {x,y,-error};
      //data[i] = new float[] {x,value,0}; // Also works.
    }
    return data;
  }

  public static float[][] generateOneToOne() {
    Random r = new Random();
    float[][] data = new float[200][];
    for(int i = 0; i < 200; i++) {
      float x = r.nextFloat()*2.0f-1.0f;
      float y = r.nextFloat()*2.0f-1.0f;
      data[i] = new float[] {x,y,x,y};
    }
    return data;
  }

  public static void testSingle() {
  	float trueValue  = 3.7f;
    Perceptron p = new Perceptron(2,0,new Perceptron.Sum());
    float[][] data = generatePlane(trueValue, 0);
    // for(float[] i : data) { System.out.format("%.2f %.2f %.2f\n", i[0], i[1], i[2]); }
    System.out.println("Training");
    System.out.println(p);
    for(float[] i : data) {
    	float[] point = {i[0], i[1]};
    	p.train(point, i[2]);
    	System.out.println(p);
    }
    System.out.format("Result = %.2f, TrueValue = %.2f", -1.0*(p.getWeights()[0])/p.getWeights()[1], trueValue);
  }

  public static void testOneToOne() {
    PerceptronNetwork pn = new PerceptronNetwork(2,2);
    float[][] data = generateOneToOne();
    // for(float[] i : data) { System.out.format("%.2f %.2f %.2f\n", i[0], i[1], i[2]); }
    System.out.println("Training");
    System.out.println(pn);
    for(float[] i : data) {
    	float[] point = {i[0], i[1]};
    	float[] lesson = {i[2], i[3]};
    	pn.train(point, lesson);
    	System.out.println(pn);
    }
  }
  
  public static void testGetSetWeights() {
	  PerceptronNetwork pn = new PerceptronNetwork(4,4);
	  float[] w = pn.getWeights();
	  for(int i = 0; i < w.length; i++) {
		  System.out.print(w[i] + ",");
	  }
  	  System.out.println("");
	  float[] nw = {0.91771173f,-0.011502385f,-0.17990649f,0.37370646f,
			  -0.6191504f,-0.35140657f,0.7098838f,-0.26950908f,
			  -0.26984072f,0.051948905f,0.16374183f,-0.4684553f,
			  0.85675335f,-0.61833596f,0.96019375f,-0.28460658f
	  };
	  pn.setWeights(nw);
	  w = pn.getWeights();
	  for(int i = 0; i < w.length; i++) {
		  System.out.print(w[i] + ",");
	  }
  	  System.out.println("");
  }

  public static void main(String[] args) {
  	//testSingle();
  	//testOneToOne();
	testGetSetWeights();
  }
}
