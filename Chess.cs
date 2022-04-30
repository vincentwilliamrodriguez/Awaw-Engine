using Godot;
using System;

public class Chess: Node
{
    int[,] Pieces;
	int[,] CastlingRules;
	int[] EnPassant;

	public Chess Init(int[,] pieces, int[,] castlingrules, int[] enpassant){
		Pieces = (int[,]) pieces.Clone();
		CastlingRules = (int[,]) castlingrules.Clone();
		EnPassant = (int[]) enpassant.Clone();
		return this;
	}

	public Chess Init2(Godot.Collections.Array<Godot.Collections.Array<int>> pieces,
						Godot.Collections.Array<Godot.Collections.Array<int>> castlingrules,
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

	private bool GetColor(int piece){
		return !Convert.ToBoolean(piece / 6);
	}

	// Move's 1st, 6th, 8th parameter removed
	public Chess Move(int i, int j, int ti, int tj, bool checking){
		var Res = new Chess();
		Res = Res.Init(Pieces, CastlingRules, EnPassant);
		
		var piece = Res.Pieces[i, j];
		var color = GetColor(piece);
		
		Res.Pieces[i, j] = -1;
		Res.Pieces[ti, tj] = piece;
		
		// #Castling
		
		// if not checking:
		// 	if piece in [0, 6]: #If king moved
		// 		castlingRules[int(color)] = [false, false]
		// 	elif piece in [4, 10]: #If rook moved
		// 		if j in [0, 7]:
		// 			castlingRules[int(color)][1 if j == 7 else 0] = false
					
		// if piece in [0, 6] and j == 4 and abs(tj - j) == 2:
		// 	var temp = move(10 - 6 * int(color), i, 0 if tj == 2 else 7, ti, 3 if tj == 2 else 5, inp, false, rules) #moving rook
		// 	inp = temp[0]
		// 	castlingRules = temp[1][0]
		// 	enPassant = temp[1][1]
		
		// #En Passant
		// if piece in [5, 11] and [ti, tj] == enPassant:
		// 	inp[ti + (1 if color else -1)][tj] = -1 #captures pawn
			
		// if not checking:
		// 	enPassant = [9, 9] #resets en passant
		// 	if piece in [5, 11]:
		// 		if abs(ti - i) == 2:
		// 			enPassant = [ti + (1 if color else -1), tj] #sets en passant
		
		// #Promotion
		// if piece in [5, 11] and ti == (7 if !color else 0):
		// 	inp[ti][tj] = 1 if color else 7
			
		// return [inp, [castlingRules, enPassant]]}
		return Res;
	}
}
