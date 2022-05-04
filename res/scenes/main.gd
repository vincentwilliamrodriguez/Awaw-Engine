extends Node2D

onready var b = $board
onready var p = $pieces

func _ready():
	var _connect = g.connect("engineNext", self, "update")
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
			var piece = g.MainChess.Pieces[8 * i + j]
			
			if g.selected:
				if g.lastPossibleMoves[i][j] == 1:
					g.nextTurn(i, j)
					
				g.sp = -1
				g.selected = false
				
				g.board = g.BOARD.duplicate(true)
				
				
			elif piece != -1 and g.getcolor(piece) == g.turn and not g.gameOver and !(!g.turn and g.AWAW_ENGINE_ON):
				g.sp = piece
				g.lasti = i
				g.lastj = j
				
#				var temp = g.convertCS(g.MainChess)
#				g.lastPossibleMoves = g.possibleMoves(piece,i,j,false,temp[0],temp[1])
				
				g.lastPossibleMoves = g.ToGD(g.MainChess.PossibleMovesInt(piece, i, j, false), 8, 8)
				
				g.highlightBoard(g.lastPossibleMoves)
				g.selected = true
					
			update()
