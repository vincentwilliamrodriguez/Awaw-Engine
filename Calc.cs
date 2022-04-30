using Godot;
using System;

public class Calc : Node
{
    public static void Main(string[] args){
    }

    public override void _Ready(){
        // int[] test = LocateKing(1, new int[,] {{1,2,3,4,5}});
        // GD.Print(test[0], ' ', test[1]);    
    } 

    public int[,] Test(){
        var test = new int[8,8];
        GD.Print(test);
        return test;
    }
    public static int[] LocateKing(bool color, int[,] inp){
        for (int i = 0; i < 8; i++){
            for (int j = 0; j < 8; j++){
                if (inp[i, j] == (color ? 0 : 6)){
                    return new int[] {i, j};
                }
            }
        }
                
        return new int[] {9, 9};
    }
}
