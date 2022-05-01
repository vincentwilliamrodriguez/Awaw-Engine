using Godot;
using System;
using System.Collections;

public class Chess: Node
{
    int[,] Pieces;
	int[,] CastlingRules;
	int[] EnPassant;
	GDScript global;
	Godot.Object g;

	public override void _Ready(){
    	
	}

	public Chess Init(int[,] pieces, int[,] castlingrules, int[] enpassant){
		global = (GDScript) GD.Load("res://global.gd");
		g = (Godot.Object) global.New();

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

	public void Testing(){
		GD.Print(g.Call("totalCovered", true, g.Get("pieces"), g.Get("gameRules")));

		var Bits = new BitArray(64);
		GD.Print(Bits);

		var t = new int[64];
		Bits.CopyTo(t, 0);
		// g.Call("Test", t);
	}

	// rays' 9th and 10th paramater removed
	public BitArray rays(BitArray Res, int[] dir, int i, int j, bool color, 
							int lim, int uniquePiece, bool t){
		return Res;
	}

	// PossibleMoves' 5th and 6th parameter removed
	public BitArray PossibleMoves(int piece, int i, int j, bool total){
		var Res = new BitArray(64);
		return Res;
	}

	// TotalCovered's 2nd and 3rd parameter removed
	public BitArray TotalCovered(bool color){
		var Res = new BitArray(64);

		for(int i = 0; i < 8; i++){
			for(int j = 0; j < 8; j++){
				var Piece = Pieces[i, j];

				if (Piece != -1  &&  GetColor(Piece) == color){
					var PieceMoves = PossibleMoves(Piece, i, j, true);
					Res.Or(PieceMoves);
				}
			}
		}
		return Res;
	}

	// WillCheck's 7th and 8th parameter removed
	public bool WillCheck(int piece, int i, int j, int ti, int tj, bool color){
		return true;
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
