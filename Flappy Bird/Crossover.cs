using Godot;
using System;
using System.Collections.Generic;

public class Crossover : Node
{
	float time_score_sum;
	float best_time_score;
	float fitness_sum;
	
	static Random random = new Random();
	
	public void Run(Godot.Collections.Array<Node> inp, Godot.Object main){
		time_score_sum = 0;
		best_time_score = 0;
		fitness_sum = 0;
		
		foreach (Node bird in inp){
			time_score_sum += (float) bird.Get("timeScore");
			best_time_score = Math.Max(best_time_score, (float) bird.Get("timeScore"));
		}
		
		foreach (Node bird in inp){
			bird.Set("fitness", Math.Pow((float) bird.Get("timeScore") / time_score_sum, 4));
			fitness_sum += (float) bird.Get("fitness");
			bird.Set("fitnessCu", fitness_sum);
		}
		
		for (int n = 0; n < inp.Count; n++){
			List<Node> parents = new List<Node>();
			
			for (int p = 0; p < 2; p++){
				var r = (float) random.NextDouble() * fitness_sum;
				foreach (Node bird in inp){
					if (r < (float) bird.Get("fitnessCu")){
						parents.Add(bird);
						break;
					}
				}
			}
			
			var old_brain_1 = (Node) parents[0].Get("brain");
			var old_brain_2 = (Node) parents[1].Get("brain");
			var new_brain = (Node) old_brain_1.Call("CrossoverWith", old_brain_2);
			var new_bird = (Node) main.Call("AddBird", n, false);
			new_brain.Call("Mutate");
			new_bird.Set("brain", new_brain);
		}
//
		foreach (Node bird in inp){
			var brain = (Node) bird.Get("brain");
			brain.Call("queue_free");
			bird.Call("queue_free");
		}
	}
}
