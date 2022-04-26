using Godot;
using System;

public class Calc : Node
{
    public static Main(string[] args){
        LocateKing(1, new int[,] {{1,2,3,4,5}});
    }
    public override void _Ready()
    {
        
    } 

    private bool ToBool(int n){
        return Convert.ToBoolean(n);
    }
    public int[] LocateKing(int color, int[,] inp){
        GD.Print(inp[0,2]);
        for (int i = 0; i < 1; i++){
            for (int j = 0; i < 5; i++){
                GD.Print(inp[i, j].GetType());
                if (inp[i, j] == (ToBool(color) ? 0 : 6)){
                    return new int[] {i, j};
                }
            }
        }
                
        return new int[] {9, 9};
    }

    public int Testing(int[] inp){
        GD.Print(inp[1]);
        return 1;
    }
}
