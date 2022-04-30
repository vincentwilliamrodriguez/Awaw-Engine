using Godot;
using System;

public class Chess: Node
{
    int[,] Pieces;
	bool[,] CastlingRules;
	int[] EnPassant;

	public Chess Init(int[,] pieces, bool[,] castlingrules, int[] enpassant){
		Pieces = pieces;
		CastlingRules = castlingrules;
		EnPassant = enpassant;
		return this;
	}

	public Chess Init2(Godot.Collections.Array<Godot.Collections.Array<int>> pieces,
						Godot.Collections.Array<Godot.Collections.Array<bool>> castlingrules,
						int[] enpassant){
		return Init(ToCS(pieces), ToCS(castlingrules), enpassant);
	}

	public static T[,] ToCS<T>(Godot.Collections.Array<Godot.Collections.Array<T>> inp){
		var m = inp.Count;
		var n = inp[0].Count;

        var res = new T[m, n];
        for(int i = 0; i < m; i++){
            for(int j = 0; j < n; j++){
                res[i, j] = inp[i][j];
            }
        }
        return res;
    }

    public int[] LocateKing(bool color){
        for (int i = 0; i < 8; i++){
            for (int j = 0; j < 8; j++){
                if (Pieces[i, j] == (color ? 0 : 6)){
                    return new int[] {i, j};
                }
            }
        }
                
        return new int[] {9, 9};
    }
}
