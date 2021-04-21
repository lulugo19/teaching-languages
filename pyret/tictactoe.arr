import image as I
import world as W
import lists as L

# CONSTANTS
# ---------------
WIDTH = 500
HEIGHT = 500
CENTER = WIDTH / 2
FIELD-SIZE = 100
FIELD-SIZE-HALF = FIELD-SIZE / 2

FIELD-SYMBOL-BORDER-SIZE = 20
FIELD-SYMBOL-SIZE = FIELD-SIZE - FIELD-SYMBOL-BORDER-SIZE

EMPTY-SCENE = I.empty-scene(WIDTH, HEIGHT)

X-COLOR = "red"
O-COLOR = "blue"

X-SYMBOL = I.add-line(I.add-line(
    I.empty-image,
    0, 0, FIELD-SYMBOL-SIZE, FIELD-SYMBOL-SIZE, X-COLOR),
  0, FIELD-SYMBOL-SIZE, FIELD-SYMBOL-SIZE, 0, X-COLOR)

O-SYMBOL = I.circle(FIELD-SYMBOL-SIZE / 2, "outline", O-COLOR)

FIELD = I.square(FIELD-SIZE, "outline", "light-steel-blue")

PLAY-AGAIN-BUTTON-WIDTH = 200
PLAY-AGAIN-BUTTON-HEIGHT = 50

PLAY-AGAIN-BUTTON = I.overlay-align(
  "center",
  "center",
  I.text("Nochmal spielen", 28, "black"),
  I.rectangle(PLAY-AGAIN-BUTTON-WIDTH, PLAY-AGAIN-BUTTON-HEIGHT, "solid", "light-grey")
  ) ^
I.overlay-align("center", "center", 
  I.empty-scene(PLAY-AGAIN-BUTTON-WIDTH, PLAY-AGAIN-BUTTON-HEIGHT), _)

PLAY-AGAIN-BUTTON-BOT-OFFSET = 50
PLAY-AGAIN-BUTTON-POS = I.point(CENTER, HEIGHT - PLAY-AGAIN-BUTTON-BOT-OFFSET)

TOP-TEXT-OFFSET = 50
GAME-OVER-FONT-SIZE = 54
PLAYERS-TURN-FONT-SIZE = 38


# DATA DEFINITIONS
# ----------------
data Player:
  | x-player
  | o-player
end

data Field:
  | field(player :: Option<Player>, index :: Number, pos :: I.Point)
end

data Tic-Tac-Toe:
  | tic-tac-toe(fields :: List<Field>, player :: Option<Player>, game-over :: Boolean)
end

# INITIALIZE GAME STATE
# ---------------------

# Berechne die Positionen für die Tic-Tac-Toe-Felder
# die in einem 3x3-Gitter angeordnet sind.
FIELD-POSITIONS = for map(pos from [list:
  I.point(-1,-1), I.point(0,-1), I.point(1,-1),
  I.point(-1, 0), I.point(0, 0), I.point(1, 0),
  I.point(-1, 1), I.point(0, 1), I.point(1, 1)
    ]):
  
  I.point(
    CENTER + (pos.x * FIELD-SIZE),
    CENTER + (pos.y * FIELD-SIZE)
    )
end

# Initialisiere die Felder aus den Positionen.
# Weise ihnen ihren Index und ihre Position zu.
INIT-FIELDS = for map_n(index from 0, pos from FIELD-POSITIONS):
  field(none, index, pos)
end

# Initialisiere den initialen Game-State. Der X-Spieler beginnt.
INIT-TIC-TAC-TOE = tic-tac-toe(INIT-FIELDS, some(x-player), false)

# HELPER-FUNCTIONS
# ----------------
fun is-game-over(t :: Tic-Tac-Toe) -> Boolean:
  t.game-over
end

#|
   Gibt zurück ob ein Punkt mit den Koordinaten 'px' und 'py',
   sich innerhalb (bzw. auf der Kante) eines Rechtecks befindet, welches
   den Mittelpunkt auf den Koordinaten 'rx' und 'ry' hat 
   und eine Weite von 'rw' und eine Höhe von 'rh' hat.
|#
fun is-point-inside-rect(
    px :: Number, py :: Number, 
    rx :: Number, ry :: Number, 
    rw :: Number, rh :: Number
 ) -> Boolean:
  w-half = rw / 2
  h-half = rh / 2
  
  l = rx - w-half
  r = rx + w-half
  t = ry - h-half
  b = ry + h-half
  
  (px >= l) and (px <= r) and (py >= t) and (py <= b)
where:
  is-point-inside-rect(10, 10, 10, 10, 20, 20) is true
  is-point-inside-rect(20, 2, 10, 2, 19, 1) is false
  is-point-inside-rect(20, 20, 0, 0, 20, 20) is true
end


# DRAW FUNCTIONS
#---------------
fun draw-player-symbol(p :: Player) -> I.Image:
  cases(Player) p:
    | x-player => X-SYMBOL
    | o-player => O-SYMBOL
  end
end

fun draw-field(f :: Field) -> I.Image:
  cases(Option<Player>) f.player:
    | some(p) => I.overlay(FIELD, draw-player-symbol(p))
    | none => FIELD
  end
end

fun draw-tic-tac-toe-fields(fields :: List<Field>) -> I.Image:
  for fold(scene from EMPTY-SCENE, f from fields):
    I.place-image(draw-field(f), f.pos.x, f.pos.y, scene)
  end
end

fun draw-game-over-text(t :: Tic-Tac-Toe%(is-game-over)) -> I.Image:
  cases(Option<Player>) t.player:
    | some(p) => cases(Player) p:
        | x-player => I.text("X gewinnt!", GAME-OVER-FONT-SIZE, X-COLOR)
        | o-player => I.text("O gewinnt!", GAME-OVER-FONT-SIZE, O-COLOR)
      end
    | none => I.text("Unentschieden", GAME-OVER-FONT-SIZE, "black")
  end
end

fun draw-players-turn-text(t :: Tic-Tac-Toe) -> I.Image:
  cases(Option<Player>) t.player:
    | some(p) => cases(Player) p:
        | x-player => I.text("X ist dran!", PLAYERS-TURN-FONT-SIZE, X-COLOR)
        | o-player => I.text("O ist dran!", PLAYERS-TURN-FONT-SIZE, O-COLOR)
      end
    | none => raise("Es muss ein Spieler dran sein")
  end
end

fun draw(t :: Tic-Tac-Toe) -> I.Image:
  background = draw-tic-tac-toe-fields(t.fields)
  if t.game-over:
    background ^ 
    I.place-image(draw-game-over-text(t),CENTER, TOP-TEXT-OFFSET, _) ^
    I.place-image(PLAY-AGAIN-BUTTON, PLAY-AGAIN-BUTTON-POS.x, PLAY-AGAIN-BUTTON-POS.y, _)
  else:
    background ^
    I.place-image(draw-players-turn-text(t),CENTER, TOP-TEXT-OFFSET, _)
  end
end

# UPDATE FUNCTIONS
#-----------------

#|
  Wird aufgerufen wenn ein Tic-Tac-Toe-Feld gesetzt wird.
  Erstellt den neuen Tic-Tac-Toe-State mit dem gesetzten Feld.
  Evaluiert ob der Spieler, der das Feld klickt gewonnen hat oder,
  ob Unentschieden ist.
|#
fun set-field(t :: Tic-Tac-Toe, f :: Field) -> Tic-Tac-Toe:
  # Setze den Spieler, der gerade dran ist auf das Feld
  new-f = field(t.player, f.index, f.pos)
  # Update die Felder
  new-fields = L.set(t.fields, f.index, new-f)
  
  # Überprüfe ob das Spiel vorbei ist und updatet den Spieler.
  {game-over; next-p} = if check-player-won(new-fields, t.player):
    # Der Spieler der gewonnen hat, wird zurückgegeben
    {true; t.player}
  else if check-full(new-fields):
     # Unentschieden, deshalb wird 'none' als Spieler zurückgegeben
    {true; none}
  else:
     # Der nächste Spieler ist dran
    {false; alternate-player(t.player)}
  end
  
  tic-tac-toe(new-fields, next-p, game-over)
end

fun check-player-won(fields :: List<Field>, player :: Option<Player>) -> Boolean:
  WINNING-INDICES = [list: 
    # Horizontalen
    [list: 0, 1, 2], 
    [list: 3, 4, 5],
    [list: 6, 7, 8],
    # Vertikalen
    [list: 0, 3, 6],
    [list: 1, 4, 7],
    [list: 2, 5, 8],
    # Diagonalen
    [list: 0, 4, 8],
    [list: 2, 4, 6]
  ]
  
  for any(indices from WINNING-INDICES):
    for L.all(index from indices):
      L.get(fields, index).player == player
    end
  end
end

fun check-full(fields :: List<Field>) -> Boolean:
  for L.all(f from fields):
    is-some(f.player)
  end
end
  
fun alternate-player(o :: Option<Player>) -> Option<Player>:
  cases(Option<Player>) o:
    | some(p) => cases(Player) p:
        | x-player => some(o-player)
        | o-player => some(x-player)
      end
    | none => none
  end
end


# EVENT-HANDLERS
# --------------

#| 
   Es wird überprüft, ob der Replay-Button gedrückt wurde.
   Wenn er gedrückt wurde wird das Spiel neu gestartet,
   indem das initiale Tic-Tac-Toe-Spiel zurückgegeben wird.
|#
fun on-click-replay-button(t :: Tic-Tac-Toe, mx :: Number, my :: Number) -> Tic-Tac-Toe:
  if is-point-inside-rect(
          mx, my, 
          PLAY-AGAIN-BUTTON-POS.x, 
          PLAY-AGAIN-BUTTON-POS.y,
          I.image-width(PLAY-AGAIN-BUTTON),
          I.image-height(PLAY-AGAIN-BUTTON)):
        
    INIT-TIC-TAC-TOE
  else:
    t
  end
end

fun on-click-field(t :: Tic-Tac-Toe, mx :: Number, my :: Number) -> Tic-Tac-Toe:
  # Finde ein leers Feld, auf das mit der Maus geklickt wurde
  clicked-field = for find(f from t.fields):
     is-none(f.player) and 
     is-point-inside-rect(mx, my, f.pos.x, f.pos.y, FIELD-SIZE, FIELD-SIZE)
  end
    
  cases(Option<Field>) clicked-field:
    | some(f) => set-field(t, f)
    | none => t
  end
end

fun on-mouse(t :: Tic-Tac-Toe, mx :: Number, my :: Number, event :: String) -> Tic-Tac-Toe:
  if event == "button-down":
    if t.game-over:
      on-click-replay-button(t, mx, my)
    else:
      on-click-field(t, mx, my)
    end
  else:
    t
  end
end

# create world
W.big-bang(INIT-TIC-TAC-TOE, [list:
    W.to-draw(draw), # Installiere den Draw-Handler
    W.on-mouse(on-mouse)]) # Installiere den Mouse-Update-Handler