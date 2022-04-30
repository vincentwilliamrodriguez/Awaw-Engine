extends Node2D

onready var b = $board
onready var p = $pieces

func _ready():
	g.connect("engineNext", self, "update")
	update()

func update():
	for i in 8:
		for j in 8:
			b.set_cell(j,i,g.board[i][j])
			p.set_cell(j,i,g.MainChess.Pieces[i * 8 + j])
			

func _input(event):
	if event.is_action_released("click"):
		var pos = get_viewport().get_mouse_position()
		var index = p.world_to_map(pos)
		var i = index[1]
		var j = index[0]
		if g.checklimit(index):
			var piece = g.pieces[i][j]
			
			if g.selected:
				if g.lastPossibleMoves[i][j] == 1:
					g.nextTurn(i, j)
					
				g.sp = -1
				g.selected = false
				
				g.board = g.BOARD.duplicate(true)
				
				
			elif piece != -1 and g.getcolor(piece) == g.turn and g.turn and not g.gameOver:
#			elif piece != -1 and g.getcolor(piece) == g.turn and not g.gameOver:
				g.sp = piece
				g.lasti = i
				g.lastj = j
				g.lastPossibleMoves = g.possibleMoves(piece,i,j)
				
				g.highlightBoard(g.lastPossibleMoves)
				g.selected = true
					
			update()
