extends Node

signal engineNext
onready var thread = Thread.new()
var num: int

onready var CC = preload("res://Chess/Chess.cs")
onready var MainChess = CC.new()

func _ready():
	MainChess.InitZob()
	MainChess.Init2(PIECES, CASTLING, EN_PASSANT, true)
	
	if AWAW_ENGINE_ON and MainChess.Turn != PLAYER:
		thread.start(self, "AwawEngine", [])
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
const CASTLING = [[1, 1], [1, 1]]
const EN_PASSANT = [9, 9]

const AWAW_ENGINE_ON = true;
const AWAW_ENGINE_DEBUG = false;
const DEPTH = 3;
const PLAYER = true

var board = BOARD.duplicate(true)

var selected = false
var pickPromotion = false
var sp = -1 #Selected piece
var lasti = 7
var lastj = 7
var proi = 9
var proj = 9
var lastPossibleMoves = []

func gen2d(l,w,v = 0):
	var list = []
	list.resize(l)
	for i in range(l):
		list[i] = []
		list[i].resize(w)
		for j in range(w):
			list[i][j] = v
	return list

func checklimit(index):
	return index[0] >= 0 and index[0] <= 7 and index[1] >= 0 and index[1] <= 7
	
func highlight(i,j):
	var v = board[i][j]
	var res = v - 1 if v in [1,3] else v
	board[i][j] = res

func highlightBoard(inp):
	for i in 8:
		for  j in 8:
			if inp[i][j] == 1:
				highlight(i,j)
				
func getcolor(piece):
	return !bool(piece / 6)

func getUniquePiece(piece):
	return (piece - 6) if piece > 5 else piece
	
func nextTurn():
#	print("Aw aw, ", MainChess.Hash)
	MainChess.Test()
	
	var outcome = MainChess.Outcome
	
	match (outcome):
		1:
			print('Game Over, White wins!')
		2:
			print('Game Over, Black wins!')
		3:
			print('Game Over, Draw by Stalemate!')
		4:
			print('Game Over, Draw by Threefold Repetition!')
			
	if AWAW_ENGINE_ON and not (MainChess.Turn == PLAYER) and not outcome:
		if AWAW_ENGINE_DEBUG:
			AwawEngine([])
		else:
			thread.start(self, "AwawEngine", [])

func convertCS(Ch):
	var inp = ToGD(Ch.Pieces, 8, 8)
	var rules = [ToGD(Ch.CastlingRules, 2, 2), Array(Ch.EnPassant)]
	
	return [inp, rules]

func ToGD(inp, r, c):
	var res = gen2d(r, c)
	
	for i in r:
		for j in c:
			res[i][j] = inp[r * i + j]
	return res

#========== Awaw Engine ===========
func AwawEngine(_inputs: Array):
	var start = OS.get_ticks_msec()
	
	print('Thinking')
	
	var Res = MainChess.FindBestMove(MainChess.Turn, DEPTH)
	MainChess = Res
	
	var end = OS.get_ticks_msec()
	
	print('Done')
	print('Time: ' + String((float(end) - start) / 1000) + ' seconds\n')
	
#	MainChess.Test()
	
	nextTurn()
	
	call_deferred("AwawEngineDone")
	
	return 'awp'

func AwawEngineDone():
	thread.wait_to_finish()
	emit_signal("engineNext")
	
