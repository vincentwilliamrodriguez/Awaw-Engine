using Godot;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

static class Auxilliary
{
	public static readonly int[] PIECESVALUES = new int[] {400, 900, 300, 300, 500, 100};
	public static List<long> zob;

	public static void InitZob(){
		var ran = new Random(81141418);
		zob = new List<long>();

		for(int i = 0; i < 781; i++){
			byte[] buf = new byte[8];
			ran.NextBytes(buf);
			zob.Add(BitConverter.ToInt64(buf, 0));
		}
	}

	public static bool In<T>(this T obj, params T[] args){
		return args.Contains(obj);
	}
}

public class Chess: Node
{
	int[,] Pieces;
	int[,] CastlingRules;
	int[] EnPassant;
	int[] range9;
	bool Turn;
	long Hash;
	List<long> Log;
	int Outcome;

	public void Test(){
		// foreach (long val in Log){
		// 	GD.Print(val);
		// }

		// GD.Print((from temp in Log where temp.Equals(Hash) select temp).Count());
		// GD.Print(Outcome);
	}

	public void InitZob(){
		Auxilliary.InitZob();
	}

	public Chess Init(int[,] pieces, int[,] castlingrules, 
						int[] enpassant, bool turn, List<long> log){
		
		range9 = Enumerable.Range(0, 9).ToArray();

		Pieces = (int[,]) pieces.Clone();
		CastlingRules = (int[,]) castlingrules.Clone();
		EnPassant = (int[]) enpassant.Clone();
		Turn = turn;
		Log = new List<long>(log);

		return this;
	}

	public Chess Init2(Godot.Collections.Array<Godot.Collections.Array<int>> pieces,
						Godot.Collections.Array<Godot.Collections.Array<int>> castlingrules,
						int[] enpassant, bool turn){

		Log = new List<long>();
		var Res = Init(ToCS(pieces), ToCS(castlingrules), enpassant, turn, Log);

		UpdateHash();
		UpdateOutcome();

		return Res;
	}

	public void UpdateHash(){
		long Res = 0;

		//Piece
		for(int i = 0; i < 8; i++){
			for(int j = 0; j < 8; j++){
				var Piece = Pieces[i, j];

				if (Piece != -1){
					Res = Res ^ Auxilliary.zob[8*12*i + 12*j + Piece];
				}
			}
		}

		//Turn is black
		if (!Turn){
			Res = Res ^ Auxilliary.zob[768]; 
		}

		//Castling rules
		for(int i = 0; i < 2; i++){
			for(int j = 0; j < 2; j++){
				if (CastlingRules[i, j] == 1){
					Res = Res ^ Auxilliary.zob[769 + 2*i + j];
				}
			}
		}

		//En passant
		for(int j = 0; j < 8; j++){
			if (EnPassant[1] == j){
				Res = Res ^ Auxilliary.zob[773 + j];
			}
		}

		Hash = Res;
		Log.Add(Hash);
	}

	public int CheckOutcome(){
		var repetition = (from temp in Log where temp.Equals(Hash) select temp).Count();

		if (repetition >= 3){
			return 4; // Threefold repetition
		}

		foreach (bool color in new bool[] {true, false}){
			if (!CanMove(!color)){ // if enemy can't move
				var k = LocateKing(!color); // enemy king location
				var total = TotalCovered(color); // total covered of color
				
				if (total[8 * k[0] + k[1]]){ // if enemy is in check
					if (color){
						return 1; // White checkmates black
					}
					else{
						return 2; // Black checkmates white
					}
				}
				else{
					return 3; // Stalemate
				}
			}
		}
		return 0;
	}

	public void UpdateOutcome(){
		this.Outcome = CheckOutcome();
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

	private static bool GetColor(int piece){
		return !Convert.ToBoolean(piece / 6);
	}

	private static int GetUniquePiece(int piece){
		return piece > 5  ?  piece - 6:piece;
	}

	private static bool CheckLimit(int[] index){
		return index[0] >= 0 && index[0] <= 7 && index[1] >= 0 && index[1] <= 7;
	}

	private static bool CheckLimit(int i, int j){
		return i >= 0 && i <= 7 && j >= 0 && j <= 7;
	}

	public static int[] BitToInt(BitArray inp){
		int[] IntRes = new int[64];

		for(int m = 0; m < 64; m++){
			IntRes[m] = Convert.ToInt16(inp[m]);
		}

		return IntRes;
	}

	public int[] PossibleMovesInt(int piece, int i, int j, bool total){
		return BitToInt(PossibleMoves(piece, i, j, total));
	}

	public int[] TotalCoveredInt(bool color){
		return BitToInt(TotalCovered(color));
	}

	// rays' 9th and 10th paramater removed
	public BitArray rays(BitArray Res, int[] dir, int i, int j, bool color, 
							int lim, int uniquePiece, bool t){
		var piece = uniquePiece + 6 * Convert.ToInt16(!color);
		
		foreach (int d in dir){
			if (d == 4){
				continue;
			}
			var cur = new int[] {i,j};

			var r = d / 3 - 1;
			var c = (d % 3) - 1;
			var direction = new int[] {r, c};
			var n = 0;
			
			while (true){
				if (n >= lim){
					break;
				}
				var testing = Auxilliary.In(d, 0, 2, 6, 8);
				if (uniquePiece == 5 && Auxilliary.In(d, 0, 2, 6, 8) && n == 1){
					break;
				}

				cur[0] += direction[0];
				cur[1] += direction[1];

				n += 1;
						
				if (!CheckLimit(cur)){
					break;
				}

				if (Pieces[cur[0], cur[1]] == -1){ //If square is empty
					if (uniquePiece == 5){
						if (!t && Auxilliary.In(d, 0, 2, 6, 8)){
							if (!(cur[0] == EnPassant[0] && cur[1] == EnPassant[1])){
								break;
							}
						}
						if (t && Auxilliary.In(d, 1, 7)){
							break;
						}
					}

					//Check if move will lead to king check
					if (t || (!t && !WillCheck(piece, i, j, cur[0], cur[1], color))){
						Res[8 * cur[0] + cur[1]] = true;
					}
						
					continue;
				}

				else{ // Square has piece
					// Check if total and not (Piece is pawn and d is forward)
					if (t && !(uniquePiece == 5 && Auxilliary.In(d, 1, 7))){
						Res[8 * cur[0] + cur[1]] = true;
						break;
					}
					if (color != GetColor(Pieces[cur[0], cur[1]])){ // If piece is opposite color
						if (uniquePiece == 5 && Auxilliary.In(d, 1, 7)){
							break;
						}

						//Check if move will lead to king check
						if (t || (!t && !WillCheck(piece, i, j, cur[0], cur[1], color))){
							Res[8 * cur[0] + cur[1]] = true;
						}
					}
					break;
				}
			}
		}
		return Res;
	}

	// PossibleMoves' 5th and 6th parameter removed
	public BitArray PossibleMoves(int piece, int i, int j, bool total){
		var Res = new BitArray(64);

		var unique_piece = GetUniquePiece(piece);
		var color = GetColor(piece);
		
		switch (unique_piece){
			case 0: //King
				Res = rays(Res, range9, i, j, color, 1, unique_piece, total);
				break;
			
			case 1: //Queen
				Res = rays(Res, range9, i, j, color, 9, unique_piece, total);
				break;
			
			case 2: //Bishop
				Res = rays(Res, new int[] {0, 2, 6, 8}, i, j, color, 9, unique_piece, total);
				break;
			
			case 3: //Knight
				foreach (int m in (Enumerable.Range(-2, 5).ToArray())){ //range from -2 to 2
					foreach (int n in (Enumerable.Range(-2, 5).ToArray())){
						if (m * n != 0 && Math.Abs(m) != Math.Abs(n)){
							var x = m + i;
							var y = n + j;
							if (CheckLimit(x, y)){
								if (Pieces[x, y] == -1 || color != GetColor(Pieces[x, y])){
									if (total || (!total && !WillCheck(piece, i, j, x, y, color))){
										Res[8 * x + y] = true;
									}
								}
							}
						}
					}
				}
				break;
			
			case 4: //Rook
				Res = rays(Res, new int[] {1, 3, 5, 7}, i, j, color, 9, unique_piece, total);
				break;
			
			case 5: //Pawn
				var front = color  ?  new int[] {0, 1, 2}:new int[] {6, 7, 8};
				
				Res = rays(Res, front, i, j, color, (i == 1 || i == 6) ? 2:1, unique_piece, total);
				break;
		}
		
		if (!total){
			//Castling
			if (unique_piece == 0){
				var t = TotalCovered(!color);
				var kinglocation = LocateKing(color);
				
				if (!t[8 * kinglocation[0] + kinglocation[1]]){ //If king is not check
					for(int side = 0; side < 2; side ++){
						if (Convert.ToBoolean(CastlingRules[Convert.ToInt16(color), side])){
							var castlingallowed = true;
							foreach (int n in Convert.ToBoolean(side) ? new int[] {5, 6}:new int[] {2, 3}){ //for y in kingside else queenside
								if (Pieces[i, n] != -1 || t[8 * i + n]){ //if (square is not empty) or check
									castlingallowed = false;
									break;
								}
							}
							if (castlingallowed){
								Res[8 * i + j + (Convert.ToBoolean(side) ? 2:-2)] = true;
							}
						}
					}
				}
			}
		}
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

	// CanMove's 2nd and 3rd removed
	public bool CanMove(bool color){
		for(int i = 0; i < 8; i++){
			for(int j = 0; j < 8; j++){
				var Piece = Pieces[i, j];
				
				if (Piece != -1 && GetColor(Piece) == color){
					var p = PossibleMoves(Piece, i, j, false);
					if (p.Cast<bool>().Contains(true)){
						return true;
					}
				}
			}
		}
		return false;
	}

	// WillCheck's 7th and 8th parameter removed
	public bool WillCheck(int piece, int i, int j, int ti, int tj, bool color){
		Chess NextPos = Move(i, j, ti, tj, true);

		var total = NextPos.TotalCovered(!color);
		var k = NextPos.LocateKing(color); //king location

		NextPos.Free();

		return total[8 * k[0] + k[1]] == true;
	}

	// Move's 1st, 6th, 8th parameter removed
	public Chess Move(int i, int j, int ti, int tj, 
						bool checking, int promotion = -1){
		
		var Res = new Chess();
		Res = Res.Init(Pieces, CastlingRules, EnPassant, !Turn, Log);
		
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
			Res.Turn = !this.Turn;
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
			Res.Pieces[ti, tj] = promotion;
		}

		if (!checking){
			//Initialize Hash after moves
			Res.UpdateHash();

			//Update game outcome
			Res.UpdateOutcome();
		}

		return Res;
	}

	//Minimax' 1st and 2nd parameters removed
	public int MiniMax(bool color, int depth, 
		int alpha = int.MinValue, int beta = int.MaxValue){		

		var optimalScore = color ? int.MinValue:int.MaxValue;
		
		var score = Evaluate();

		if (depth == 0 || Outcome > 0){
			if (score == 0)
				return 0;
			
			optimalScore = score - (depth * (color ? 1:-1));
			return optimalScore;
		}
		
		for(int i = 0; i < 8; i++){
			for(int j = 0; j < 8; j++){
				var Piece = Pieces[i, j];

				if (Piece != -1 && GetColor(Piece) == color){
					var PieceMoves = PossibleMoves(Piece, i, j, false);
					
					for(int m = 0; m < 8; m++){
						for(int n = 0; n < 8; n++){
							if (PieceMoves[8 * m + n]){
								// Promotions list for pawn
								var Promotions = (GetUniquePiece(Piece)==5 && Auxilliary.In(m, 0, 7)) ?
													(color ? (new int[] {1, 2, 3, 4}) : //Promotion and white
													(new int[] {7, 8, 9, 10})) : //Promotion and black
													(new int[] {-1}); //Not promotion

								foreach (int PromotionPiece in Promotions){
									var ChildCh = Move(i, j, m, n, false, PromotionPiece);
									
									var childScore = ChildCh.MiniMax(!color, depth - 1, alpha, beta);
									ChildCh.Free();

									if (color){
										optimalScore = Math.Max(optimalScore, childScore);
										alpha = Math.Max(alpha, childScore);
									}
									else{
										optimalScore = Math.Min(optimalScore, childScore);
										beta = Math.Min(beta, childScore);
									}
									
									if (beta <= alpha){
										break;
									}
								}
							}
						}
					}
				}
			}
		}
		
		return optimalScore;
	}

	public Chess FindBestMove(bool color, int depth){
		// GD.Print("Before: ", Hash);

		Chess optimalCh = this;

		var score = Evaluate();
		var optimalScore = color ? int.MinValue:int.MaxValue;

		if (depth == 0 || Outcome > 0){
			return optimalCh;
		}
		
		for(int i = 0; i < 8; i++){
			for(int j = 0; j < 8; j++){
				var Piece = Pieces[i, j];

				if (Piece != -1 && GetColor(Piece) == color){
					var PieceMoves = PossibleMoves(Piece, i, j, false);
					
					for(int m = 0; m < 8; m++){
						for(int n = 0; n < 8; n++){
							if (PieceMoves[8 * m + n]){
								// Promotions list for pawn
								var Promotions = (GetUniquePiece(Piece)==5 && Auxilliary.In(m, 0, 7)) ?
													(color ? (new int[] {1, 2, 3, 4}) : //Promotion and white
													(new int[] {7, 8, 9, 10})) : //Promotion and black
													(new int[] {-1}); //Not promotion

								foreach (int PromotionPiece in Promotions){
									var ChildCh = Move(i, j, m, n, false, PromotionPiece);
									
									var childScore = ChildCh.MiniMax(!color, depth - 1);
				
									if (color   ?   (childScore > optimalScore) : (childScore < optimalScore)){
										optimalCh = ChildCh;
										optimalScore = childScore;
									}
								}
							}
						}
					}
				}
			}
		}

		GD.Print("Optimal Score: " , optimalScore);
		// GD.Print("After: ", optimalCh.Hash);
		return optimalCh;
	}

	public int Evaluate(){
		var materialValue = 0;
		
		switch (Outcome){
			case 1:
				return 32000;

			case 2:
				return -32000;

			case 3: case 4:
				return 0;
		}

		for(int i = 0; i < 8; i++){
			for(int j = 0; j < 8; j++){
				var Piece = Pieces[i, j];
				if (Piece != -1){
					var color = GetColor(Piece);
					// Add white pieces value, subtract black pieces value
					materialValue += Auxilliary.PIECESVALUES[GetUniquePiece(Piece)] * (color ? 1:-1);
				}
			}
		}
		
		return materialValue;
	}
}
