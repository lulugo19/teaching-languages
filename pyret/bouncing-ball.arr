import world as W
import image as I

# 1. Konstanten
WIDTH = 500
HEIGHT = 300
SCENE = I.empty-scene(WIDTH, HEIGHT)
RADIUS = 10
BALL = I.circle(RADIUS, "solid", "red")
SPEED-X = 10
SPEED-Y = 10

# 2. Datentypen
data Ball:
  ball(x :: Number, y :: Number, vx :: Number, vy :: Number)
end

# 3. Initialer Weltzustand
INIT_BALL = ball(WIDTH / 2, HEIGHT / 2, SPEED-X, SPEED-Y)

# 4. Hilfefunktionen
fun clamp(n :: Number, min :: Number, max :: Number) -> Number:
  num-max(min, num-min(max, n))
end

# 5. Zeichenfunktion
fun draw(b :: Ball) -> I.Image:
  I.place-image(BALL, b.x, b.y, SCENE)
end

# 6. Updatefunktion
fun update(b :: Ball) -> Ball:
  vx = if (b.x <= RADIUS) or (b.x >= (WIDTH - RADIUS)): 
  b.vx * -1 else: b.vx end
  
  vy = if (b.y <= RADIUS) or (b.y >= (HEIGHT - RADIUS)): 
  b.vy * -1 else: b.vy end
  
  x = clamp(b.x + vx, RADIUS, WIDTH - RADIUS)
  y = clamp(b.y + vy, RADIUS, HEIGHT - RADIUS)
  
  ball(x, y, vx, vy)
end

# 7. Event-Handlers
# keine Event-Handler

# 8. Welten-Erstellung
W.big-bang(INIT_BALL, [list:
    W.on-tick(update),
    W.to-draw(draw)
  ])