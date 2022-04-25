extends Node

signal engineNext
onready var thread = Thread.new()
var num: int

func _ready():
	pass

const BOARD = [
[3,1,3,1,3,1,3,1],
[1,3,1,3,1,3,1,3],
[3,1,3,1,3,1,3,1],
[1,3,1,3,1,3,1,3],
[3,1,3,1,3,1,3,1],
[1,3,1,3,1,3,1,3],
[3,1,3,1,3,1,3,1],
[1,3,1,3,1,3,1,3],
]
const PIECES = [
[10, 9, 8, 7, 6, 8, 9, 10], 
[11, 11, 11, 11, 11, 11, 11, 11], 
[-1, -1, -1, -1, -1, -1, -1, -1], 
[-1, -1, -1, -1, -1, -1, -1, -1], 
[-1, -1, -1, -1, -1, -1, -1, -1], 
[-1, -1, -1, -1, -1, -1, -1, -1], 
[5, 5, 5, 5, 5, 5, 5, 5], 
[4, 3, 2, 1, 0, 2, 3, 4]]

const PIECESVALUES = [400, 900, 300, 300, 500, 100]

var pieces = PIECES.duplicate(true)
var board = BOARD.duplicate(true)

var selected = false
var sp = -1 #Selected piece
var lasti = 7
var lastj = 7
var lastPossibleMoves = []
var gameOver = false

#var castlingRules = [[true, true], [true, true]] #[[Black QS, Black KS], [White QS, White KS]]
#var enPassant = [9, 9] # 1 square behind last pawn moved
var gameRules = [ [[true, true], [true, true]], #Castling rules
				[9, 9]] #En Passant
var turn = 1

func gen2d(l,w,v = 0):
	var list = []
	list.resize(l)
	for i in range(l):
		list[i] = []
		list[i].resize(w)
		for j in range(w):
			list[i][j] = v
	return list

func getindex(inp, index):
	return inp[index[0]][index[1]]

func getcolor(piece):
	return 1 - floor(piece / 6)

func locateking(color, inp = pieces.duplicate(true)):
	for i in 8:
		for j in 8:
			if inp[i][j] == (0 if color else 6):
				return Vector2(i, j)
	return 'bruh'

func combine2d(inp1: Array, inp2: Array) -> Array:
	for i in inp1.size():
		for j in inp1.size():
			inp1[i][j] = 1 if inp1[i][j] == 1 or inp2[i][j] == 1 else 0
			
	return inp1
	
func highlight(i,j):
	var v = board[i][j]
	var res = v - 1 if v in [1,3] else v
	board[i][j] = res

func highlightBoard(inp):
	for i in 8:
		for  j in 8:
			if inp[i][j] == 1:
				highlight(i,j)
				
func checklimit(index):
	return true if index[0] >= 0 and index[0] <= 7 and index[1] >= 0 and index[1] <= 7 else false

func toVector(inp: int) -> Vector2:
	var r = floor(float(inp) / 3) - 1
	var c = (inp % 3) - 1
	return Vector2(r,c)
	
func search(inp: Array, val: int) -> bool:
	for i in 8:
		for j in 8:
			if inp[i][j] == val:
				return true
	return false
	
func getUniquePiece(piece):
	return piece - 6 if piece > 5 else piece
	
func nextTurn(i = 9, j = 9):
	var temp = g.move(g.sp, g.lasti, g.lastj, i, j)
	g.pieces = temp[0]
	g.gameRules = temp[1]
		
	g.turn = 1 - g.turn
	
	var score = g.evaluate()
	if score == 32000:
		print('Game Over, White wins!')
		gameOver = true
		
	elif score == -32000:
		print('Game Over, Black wins!')
		gameOver = true
		
	if not turn:
		thread.start(self, "AwawEngine", [pieces.duplicate(true), gameRules.duplicate(true), turn])
	
func rays(res, dir, i, j, color, lim = 9, special = -1, t = false, 
			inp = pieces.duplicate(true), rules = gameRules.duplicate(true)):
	var enPassant = rules[1]
	
	for d in dir:
		if d == 4:
			continue
		var cur = Vector2(i,j)
		var vector = toVector(d)
		var n = 0
		
		while true:
			if n >= lim:
				break
			
			if special == 5 and d in [0, 2, 6, 8] and n == 1:
				break
				
			cur += vector
			n += 1
					
			if not checklimit(cur):
				break
#
#			if not t and special == 0 and total[cur[0]][cur[1]] == 1:
#				break
				
			if getindex(inp, cur) == -1:
				if special == 5:
					if (not t and d in [0, 2, 6, 8]):
						if not (cur[0] == enPassant[0] and cur[1] == enPassant[1]):
							break
							
					if (t and d in [1, 7]):
						break
				
				res[cur[0]][cur[1]] = 1
				continue
			else:
				if t and not (special == 5 and d in [1, 7]):
					res[cur[0]][cur[1]] = 1
					break
					
				if color != getcolor(inp[cur[0]][cur[1]]):
					if special == 5 and d in [1, 7]:
						break
						
					res[cur[0]][cur[1]] = 1
				break
	return res

#Possible moves of piece as array
func possibleMoves(piece: int, i: int, j: int, total = false, 
					inp1 = pieces.duplicate(true), rules1 = gameRules.duplicate(true)) -> Array:
	var inp = inp1.duplicate(true)
	var rules = rules1.duplicate(true)
	
	var castlingRules = rules[0]
	
	var res = gen2d(8,8)
	var unique_piece = getUniquePiece(piece)
	var color = getcolor(piece)
	
	match unique_piece:
		0: #King
			res = rays(res, range(9), i, j, color, 1, unique_piece, total, inp, rules)
		1: #Queen
			res = rays(res, range(9), i, j, color, 9, unique_piece, total, inp, rules)
		2: #Bishop
			res = rays(res, [0, 2, 6, 8], i, j, color, 9, unique_piece, total, inp, rules)
		3: #Knight
			for m in range(-2,3): #range from -2 to 2
				for n in range(-2,3):
					if m * n != 0 and m != n and m != -n:
						var x = m + i
						var y = n + j
						if checklimit([x,y]):
							if inp[x][y] == -1:
								res[x][y] = 1
							elif color != getcolor(inp[x][y]):
								res[x][y] = 1
		4: #Rook
			res = rays(res, [1, 3, 5, 7], i, j, color, 9, unique_piece, total, inp, rules)
		5: #Pawn
			var front = [0, 1, 2] if color else [6, 7, 8]
			
			res = rays(res, front, i, j, color, 2 if i in [1, 6] else 1, unique_piece, total, inp, rules)
	
	#Check possible moves if king will be checked
	if not total:
		for x in 8:
			for y in 8:
				if res[x][y] == 1 and willCheck(piece, i, j, x, y, color, inp, rules):
					res[x][y] = 0
		#Castling
		if unique_piece == 0:
			var t = totalCovered(1 - color, inp, rules)
			var kinglocation = locateking(color)
			
			if getindex(t, kinglocation) == 0: #If king is not check
				for side in 2:
					if castlingRules[color][side]:
						var castlingallowed = true
						for n in [5, 6] if side else [2, 3]: #for y in kingside else queenside
							if inp[i][n] != -1 or t[i][n] == 1: #if (square is not empty) or check
								castlingallowed = false
								break
						
						if castlingallowed:
							res[i][j + (2 if side else -2)] = 1
	return res

func totalCovered(color, inp = pieces.duplicate(true), rules = gameRules.duplicate(true)):
	var res = gen2d(8, 8)
	for i in 8:
		for j in 8:
			if inp[i][j] != -1 and getcolor(inp[i][j]) == color:
				res = combine2d(res, possibleMoves(inp[i][j], i, j, true, inp, rules))
	return res

func canMove(color, inp1 = pieces.duplicate(true), rules1 = gameRules.duplicate(true)) -> bool:
	var inp = inp1.duplicate(true)
	var rules = rules1.duplicate(true)
	
	for i in 8:
		for j in 8:
			if inp[i][j] != -1 and getcolor(inp[i][j]) == color:
					var p = possibleMoves(inp[i][j], i, j, false, inp, rules)
					if search(p, 1):
						return true
	return false

#func checkGameOver(color, inp = pieces.duplicate(true), rules = gameRules.duplicate(true)):

		
func willCheck(piece, i, j, ti, tj, color, inp = pieces.duplicate(true), rules = gameRules.duplicate(true)) -> bool:
	var temp = move(piece, i, j, ti, tj, inp, true, rules)
	var tpieces = temp[0]
	var trules = temp[1]
	var total = totalCovered(1 - color, tpieces, trules)
	var kinglocation = locateking(color, tpieces)
	if getindex(total, kinglocation) == 1:
		return true
	return false
	
func move(piece, i, j, ti, tj, inp1 = pieces.duplicate(true), checking = false, rules1 = gameRules.duplicate(true)):
	var inp = inp1.duplicate(true)
	var rules = rules1.duplicate(true)
	
	var castlingRules = rules[0]
	var enPassant = rules[1]
	
	var color = getcolor(piece)
	
	inp[i][j] = -1
	inp[ti][tj] = piece
	
	#Castling
	
	if not checking:
		if piece in [0, 6]: #If king moved
			castlingRules[color] = [false, false]
		elif piece in [4, 10]: #If rook moved
			if j in [0, 7]:
				castlingRules[color][1 if j == 7 else 0] = false
				
	if piece in [0, 6] and j == 4 and abs(tj - j) == 2:
		var temp = move(10 - 6 * color, i, 0 if tj == 2 else 7, ti, 3 if tj == 2 else 5, inp, false, rules) #moving rook
		inp = temp[0]
		castlingRules = temp[1][0]
		enPassant = temp[1][1]
	
	#En Passant
	if piece in [5, 11] and [ti, tj] == enPassant:
		inp[ti + (1 if color else -1)][tj] = -1 #captures pawn
		
	if not checking:
		enPassant = [9, 9] #resets en passant
		if piece in [5, 11]:
			if abs(ti - i) == 2:
				enPassant = [ti + (1 if color else -1), tj] #sets en passant
	
	#Promotion
	if piece in [5, 11] and ti == (7 if 1 - color else 0):
		inp[ti][tj] = 1 if color else 7
		
	return [inp, [castlingRules, enPassant]]

#========== Awaw Engine ===========
func AwawEngine(inputs: Array):
	var inp = inputs[0].duplicate(true)
	var rules = inputs[1].duplicate(true)
	var color = inputs[2]
	
	print('Thinking')
	var temp = miniMax(inp, rules, color, 2)
	pieces = temp[0]
	gameRules = temp[1]
	print('Done ' + String(num))
	print('Optimal Score: '+String(temp[2]))
	
	g.turn = 1 - g.turn
	
	call_deferred("AwawEngineDone")
	
	return 'awp'

func AwawEngineDone():
	thread.wait_to_finish()
	emit_signal("engineNext")
	
func miniMax(inp1, rules1, color, depth, alpha = -INF, beta = INF):
	num += 1
	
	var inp = inp1.duplicate(true)
	var rules = rules1.duplicate(true)
	
	var score = evaluate(inp, rules)
	var optimalScore = -INF if color else INF
	var optimalPos: Array
	var optimalRules: Array
	
	if depth == 0 or score == 32000 or score == -32000:
		return [inp, rules, score - (depth * (2 * color - 1))]
	
	
	for i in 8:
		for j in 8:
			var piece = inp[i][j]
			if piece != -1 and getcolor(piece) == color:
				var pieceMoves = possibleMoves(piece, i, j, false, inp, rules)
				
				for m in 8:
					for n in 8:
						if pieceMoves[m][n] == 1:
							var temp = move(piece, i, j, m, n, inp, false, rules)
							var childPos = temp[0]
							var childRules = temp[1]
							
							var childMiniMax = miniMax(childPos, childRules, 1 - color, depth - 1, alpha, beta)
							var childScore = childMiniMax[2]
							
							if childPos[4][7] == 7:
								prints(childScore, inp, childPos, color, depth, alpha, beta)
							
							if (childScore > optimalScore) if color else (childScore < optimalScore):
								optimalPos = childPos.duplicate(true)
								optimalRules = childRules.duplicate(true)
								
							if color:
								optimalScore = max(optimalScore, childScore)
								alpha = max(alpha, childScore)
							else:
								optimalScore = min(optimalScore, childScore)
								beta = min(beta, childScore)
							
							
							if beta <= alpha:
								break
							
	return [optimalPos, optimalRules, optimalScore]
	
func evaluate(inp1 = pieces, rules1 = gameRules):
	var inp = inp1.duplicate(true)
	var rules = rules1.duplicate(true)
	
	var materialValue: int
	
	for color in 2:
		if not canMove(color, inp, rules):
			var kingpos = locateking(color, inp)
			if getindex(totalCovered(1 - color, inp, rules), kingpos):
				if 1 - color:
					return 32000
				else:
					return -32000
			else:
				return 0
			
	for i in 8:
		for j in 8:
			var piece = inp[i][j]
			if piece != -1:
				var color = getcolor(piece)
				materialValue += PIECESVALUES[getUniquePiece(piece)] * (2 * color - 1) # Add white pieces value, subtract black pieces value
	return materialValue