using Godot;
using Array = Godot.Collections.Array;
using System;
public class Bar : Node
{
    public override void _Ready(){
    }
    
    public Bar(){

    }
    public static int Test(Godot.Collections.Array<Godot.Collections.Array<int>> inp){
        return inp[1][1];
    }
}
