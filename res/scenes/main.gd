extends Node2D

onready var b = $board
onready var p = $pieces

func _ready():
	var _connect = g.connect("engineNext", self, "update")
	update()

func update():
	for i in 8:
		for j in 8:
			# Flip board when black
			var i1 = i if g.PLAYER else (7 - i)
			var j1 = j if g.PLAYER else (7 - j)
			
			b.set_cell(j1,i1,g.board[i][j])
			p.set_cell(j1,i1,g.MainChess.Pieces[i * 8 + j])
			

func _input(event):
	if event.is_action_released("click"):
		var pos = get_viewport().get_mouse_position()
		var index = p.world_to_map(pos)
		
		var i = index[1] if g.PLAYER else (7 - index[1])
		var j = index[0] if g.PLAYER else (7 - index[0])
		
		if g.checklimit(index):
			var piece = g.MainChess.Pieces[8 * i + j]
			
			if g.selected:
				if g.lastPossibleMoves[i][j] == 1:
					g.MainChess = g.MainChess.Move(g.lasti, g.lastj, i, j, false)
					g.nextTurn()
					
				g.sp = -1
				g.selected = false
				
				g.board = g.BOARD.duplicate(true)
				
				
			elif piece != -1 and g.getcolor(piece) == g.turn and not g.gameOver and !(!(g.turn == g.PLAYER) and g.AWAW_ENGINE_ON):
				g.sp = piece
				g.lasti = i
				g.lastj = j
				
				g.lastPossibleMoves = g.ToGD(g.MainChess.PossibleMovesInt(piece, i, j, false), 8, 8)
				
				g.highlightBoard(g.lastPossibleMoves)
				g.selected = true
					
			update()
