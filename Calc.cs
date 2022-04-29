using Godot;
using System;

public class Calc : Node
{
    public static void Main(string[] args){
    }

    public override void _Ready(){
        int[] test = LocateKing(1, new int[,] {{1,2,3,4,5}});
        GD.Print(test[0], ' ', test[1]);    
    } 

    private static bool ToBool(int n){
        return Convert.ToBoolean(n);
    }
    public static int[] LocateKing(int color, int[,] inp){
        GD.Print(inp[0,2]);
        for (int i = 0; i < 1; i++){
            for (int j = 0; j < 5; j++){
                GD.Print(inp[i, j].GetType());
                if (inp[i, j] == (ToBool(color) ? 0 : 6)){
                    return new int[] {i, j};
                }
            }
        }
                
        return new int[] {9, 9};
    }

    public void Testing(int[,] inp){
        GD.Print("test ", inp[0,1]);
    }
}
