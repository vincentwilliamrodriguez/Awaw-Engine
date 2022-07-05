extends Node2D

onready var b = $board
onready var p = $pieces

func _ready():
	update()
	
	var _connect = g.connect("engineNext", self, "update")

func update():
	for i in 8:
		for j in 8:
			# Flip board when black
			var i1 = i if g.PLAYER else (7 - i)
			var j1 = j if g.PLAYER else (7 - j)
			
			b.set_cell(j1,i1,g.board[i][j])
			p.set_cell(j1,i1,g.MainChess.Pieces[i * 8 + j])
			
func showPromotions(color, j):
	var promotionList = VBoxContainer.new()
	var bg = ColorRect.new()
	j = j if g.PLAYER else 7 - j
	
	for piece in [1, 2, 3, 4] if color else [7, 8, 9, 10]:
		var pieceNode = TextureRect.new()
		pieceNode.texture = load("res://res/assets/pcs/" + String(piece) + ".png")
		pieceNode.connect("gui_input", self, "onPromotionPressed", [piece])
		promotionList.add_child(pieceNode)
	
	bg.add_child(promotionList)
	
	bg.name = "promotionList"
	bg.rect_position.x = 320 * j
	bg.rect_size = Vector2(320, 320 * 4)
	
	add_child(bg)

func onPromotionPressed(event, piece):
	if event.is_action_released("click"):
		g.MainChess = g.MainChess.Move(g.lasti, g.lastj, g.proi, g.proj, false, piece)
		g.nextTurn()
		
		update()

func removePromotions():
	var pl = get_node_or_null("promotionList")
	if pl:
		pl.queue_free()

func _input(event):
	if event.is_action_released("click"):
		var player_turn = (g.MainChess.Turn == g.PLAYER) or !g.AWAW_ENGINE_ON
		
		var pos = get_viewport().get_mouse_position()
		var index = p.world_to_map(pos)
		
		var i = index[1] if g.PLAYER else (7 - index[1])
		var j = index[0] if g.PLAYER else (7 - index[0])
		
		if g.checklimit(index):
			var piece = g.MainChess.Pieces[8 * i + j]
			
			removePromotions()
				
			if g.selected:
				if g.lastPossibleMoves[i][j] == 1:
					if g.getUniquePiece(g.MainChess.Pieces[8*g.lasti + g.lastj]) == 5 and i in [7, 0]:
						showPromotions(g.MainChess.Turn, j)
						g.proi = i
						g.proj = j
					else:
						g.MainChess = g.MainChess.Move(g.lasti, g.lastj, i, j, false, -1)
						g.nextTurn()
					
				g.sp = -1
				g.selected = false
				
				g.board = g.BOARD.duplicate(true)
				
				
			elif piece != -1 and g.getcolor(piece) == g.MainChess.Turn and not g.MainChess.Outcome and player_turn and !get_node_or_null("promotionList"):
				g.sp = piece
				g.lasti = i
				g.lastj = j
				
				g.lastPossibleMoves = g.ToGD(g.MainChess.PossibleMovesInt(piece, i, j, false), 8, 8)
				
				g.highlightBoard(g.lastPossibleMoves)
				g.selected = true
				
			update()

