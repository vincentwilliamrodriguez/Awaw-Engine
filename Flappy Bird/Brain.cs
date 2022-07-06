using Godot;
using System;
using System.Collections.Generic;

public class Brain : Node
{
	int[] layers;
	float[][] neurons;
	float[][] biases;
	float[][][] weights;
	int[] activations;
	int fitness = 0;

	public void Init(int[] layers){
		this.layers = (int[]) layers.Clone();
		InitNeurons();
		InitBiases();
		InitWeights();
		
		for (int i = 0; i < layers.Length; i++){
			PrintArray(biases[i]);
		}
		GD.Print();
		for (int i = 0; i < layers.Length; i++){
			for (int j = 0; j < layers[i]; j++){
				GD.Print(i, " ", j);
				PrintArray(weights[i][j]);
			}
		}
	}

	private void InitNeurons(){
		List<float[]> res = new List<float[]>();
		
		for (int i = 0; i < layers.Length; i++){
			res.Add(new float[layers[i]]);
		}
		
		neurons = res.ToArray();
	}

	private void InitBiases(){
		List<float[]> res = new List<float[]>();
		
		for (int i = 0; i < layers.Length; i++){
			float[] bias_layer = new float[layers[i]];
			
			for (int j = 0; j < layers[i]; j++){
				bias_layer[j] = NextFloat((float) -0.5, (float) 0.5);
			}
			
			res.Add(bias_layer);
		}
		
		biases = res.ToArray();
	}

	private void InitWeights(){
		List<float[][]> res = new List<float[][]>();
		
		for (int i = 0; i < layers.Length; i++){
			List<float[]> weights_layer = new List<float[]>();
			int previous_neurons = (i != 0) ? layers[i - 1] : 0;
			
			for (int j = 0; j < layers[i]; j++){
				float[] weights_neuron = new float[previous_neurons];
				
				for (int k = 0; k < previous_neurons; k++){
					GD.Print(previous_neurons);
					weights_neuron[k] = NextFloat((float) -0.5, (float) 0.5);
				}
				
				weights_layer.Add(weights_neuron);
			}
			
			res.Add(weights_layer.ToArray());
		}
		
		weights = res.ToArray();
	}
	
	private static float NextFloat(float min, float max){
		Random random = new Random();
		return (float) random.NextDouble() * (max - min) + min;
	}
	
	private static void PrintArray(float[] array){
		string res = "";
		
		foreach (float item in array){
			res += string.Format("{0:N2}", item) + ' ';
		}
		
		GD.Print(res);
	}
}
