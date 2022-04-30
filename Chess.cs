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
		int colorVal = Convert.ToInt16(color);
		
		Res.Pieces[i, j] = -1;
		Res.Pieces[ti, tj] = piece;
		
		// Castling
		if (!checking){
			if (piece == 0 || piece == 6){ //If king moved
				for(int side = 0; j < 2; j++){
					Res.CastlingRules[colorVal, side] = 0;
				}
			}
			else if (piece == 4 || piece == 10){ //If rook moved
				Res.CastlingRules[colorVal, Convert.ToInt16(j == 7)] = 0;
			}
		}

		//Check if the move is Castling
		if ((piece == 0 || piece == 6) && j == 4 && Math.Abs(tj - j) == 2){
			Res = Res.Move(i, tj == 2 ? 0:7, ti, tj == 2 ? 3:5, false); //Moving Rook
		}

		// En Passant
		if ((piece == 5 || piece == 11) && tj == EnPassant[1]){
			Res.Pieces[ti + (color ? 1:-1), tj] = -1; //Captures Pawn
		}

		//Updates En Passant
		if (!checking){
			Res.EnPassant = new int[] {9, 9}; //Resets en passant
			//Check if elligible for En Passant
			if ((piece == 5 || piece == 11) && Math.Abs(ti - i) == 2){
				Res.EnPassant = new int[] {ti + (color ? 1:-1), tj};
			}
		}

		//Promotion
		if ((piece == 5 || piece == 11) && ti == (!color ? 7:0)){
			Res.Pieces[ti, tj] = color ? 1:7;
		}
		
		return Res;
	}
}
