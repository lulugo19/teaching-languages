import world as W
import image as I

# CONSTANTS
#--------------------
WIDTH = 288
HEIGHT = 512

EMPTY-SCENE = I.empty-scene(WIDTH, HEIGHT)

BIRD = I.image-url("https://raw.githubusercontent.com/samuelcust/flappy-bird-assets/master/sprites/bluebird-midflap.png")
BIRD-HALF-HEIGHT = I.image-height(BIRD) / 2
BIRD-HALF-WIDTH = I.image-width(BIRD) / 2
BIRD-X-POS = 50
BIRD-X-POS-LEFT = BIRD-X-POS - BIRD-HALF-WIDTH
BIRD-X-POS-RIGHT = BIRD-X-POS + BIRD-HALF-WIDTH

PIPE-BOTTOM = I.image-url("https://raw.githubusercontent.com/samuelcust/flappy-bird-assets/master/sprites/pipe-green.png")
PIPE-TOP = I.flip-vertical(PIPE-BOTTOM)
PIPE-HEIGHT = I.image-height(PIPE-BOTTOM)
PIPE-WIDTH = I.image-width(PIPE-BOTTOM)
PIPE-HALF-WIDTH = PIPE-WIDTH / 2

BACKGROUND-IMAGE = I.image-url("https://raw.githubusercontent.com/samuelcust/flappy-bird-assets/master/sprites/background-day.png")
BACKGROUND = I.place-image(BACKGROUND-IMAGE, WIDTH / 2, HEIGHT / 2, EMPTY-SCENE)

GAP-HEIGHT = 110
GAP-HALF-HEIGHT = GAP-HEIGHT / 2

PIPE-SPEED = -7.5
GRAVITY = 0.6

SCORE-TEXT-SIZE = 32
SCORE-Y-POS = 30
END-SCORE-TEXT-SIZE = 45
END-SCORE-Y-POS = 150

PLAY-AGAIN-BUTTON = I.overlay-align(
  "center",
  "center",
  I.text("Nochmal spielen", 28, "black"),
  I.rectangle(200, 50, "solid", "light-grey")
  ) ^
I.overlay-align("center", "center", I.empty-scene(200, 50), _)

PLAY-AGAIN-BUTTON-POS = I.point(WIDTH / 2, 250)

# DATA DEFINITIONS
#--------------------
data Bird:
  | flappy-bird(y :: Number, v :: Number, collided :: Boolean)
end

data Obstacle:
  | pipe-obstacle(x :: Number, y :: Number)
end

data World:
  | world-playing(bird :: Bird, pipe :: Obstacle, score :: Number)
  | world-game-over(pipe :: Obstacle, end-score :: Number) 
end

fun check-bird-pipe-collision(bird :: Bird, pipe :: Obstacle) -> Boolean:
  fun is-bird-inside-gap() -> Boolean:
    bird-top = bird.y - BIRD-HALF-HEIGHT
    bird-bot = bird.y + BIRD-HALF-HEIGHT
    gap-top = pipe.y - GAP-HALF-HEIGHT
    gap-bot = pipe.y + GAP-HALF-HEIGHT
    (bird-top > gap-top) and (bird-bot < gap-bot)
  end
  
  fun is-bird-between-pipes() -> Boolean:
    pipe-left = pipe.x - PIPE-HALF-WIDTH
    pipe-right = pipe.x + PIPE-HALF-WIDTH

    (BIRD-X-POS-RIGHT >= pipe-left) and (BIRD-X-POS-LEFT <= pipe-right)
  end
  
  is-bird-between-pipes() and not(is-bird-inside-gap())
where:
  bird-a = flappy-bird(30, 0, false)
  pipe-a = pipe-obstacle(BIRD-X-POS, 30)
  check-bird-pipe-collision(bird-a, pipe-a) is false
  
  bird-b = flappy-bird(30, 0, false)
  pipe-b = pipe-obstacle(BIRD-X-POS, 200)
  check-bird-pipe-collision(bird-b, pipe-b) is true
end

# INITIAL GAME STATE
#---------------
INIT-BIRD = flappy-bird(HEIGHT / 2, 0, false)
INIT-PIPE = new-random-pipe()

INIT-WORLD = world-playing(INIT-BIRD, INIT-PIPE, 0)

# HELPER FUNCTIONS
#--------------------
fun clamp(n :: Number, min :: Number, max :: Number) -> Number:
  num-max(min, num-min(max, n))
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


# UPDATE FUNCTIONS
#--------------------
fun update-bird(bird :: Bird, collision-detected :: Boolean) -> Bird:
  y = num-max(BIRD-HALF-HEIGHT, bird.y + bird.v)
  block:
    var v = bird.v + GRAVITY
    when bird.collided:
      v := num-max(15, v)
    end
    flappy-bird(y, v, bird.collided or collision-detected)
  end
end

fun update-playing-world(world :: World) -> World:
  collision-detected = check-bird-pipe-collision(world.bird, world.pipe)
  bird = update-bird(world.bird, collision-detected)
  pipe-x = world.pipe.x + PIPE-SPEED
  is-pipe-outside = pipe-x < (PIPE-HALF-WIDTH * -1)
  pipe = if is-pipe-outside:
    new-random-pipe()
  else:
    pipe-obstacle(pipe-x, world.pipe.y)
  end
  
  score = if is-pipe-outside and not(bird.collided):
    world.score + 1
  else:
    world.score
  end
  
  game-over = (bird.y + BIRD-HALF-HEIGHT) > HEIGHT
  if game-over:
    world-game-over(pipe, score)
  else:
    world-playing(bird, pipe, score)
  end
end

fun update-world(world :: World) -> World:
  if is-world-playing(world):
    update-playing-world(world)
  else:
    world
  end
end

fun new-random-pipe() -> Obstacle:
  half-height = HEIGHT / 2
  quarter-height = HEIGHT / 4
  y = half-height + (num-random(half-height) - quarter-height)
  pipe-obstacle(WIDTH + PIPE-WIDTH, y)
end

# DRAW FUNCTIONS
#---------------
fun draw-bird(scene :: I.Image, bird :: Bird) -> I.Image:
  angle = -90 * clamp(bird.v / 20, -1, 1)
  rotated-bird = I.rotate(angle, BIRD)
  I.place-image(rotated-bird, BIRD-X-POS, bird.y, scene)
end
    
fun draw-pipe(scene :: I.Image, pipe :: Obstacle) -> I.Image:
  scene ^
  I.place-image-align(PIPE-TOP, pipe.x, pipe.y - GAP-HALF-HEIGHT, "center", "bottom", _) ^
  I.place-image-align(PIPE-BOTTOM, pipe.x, pipe.y + GAP-HALF-HEIGHT, "center", "top", _)
end

fun draw-score(scene :: I.Image, score :: Number) -> I.Image:
  score-str = "Score: " + num-to-string(score)
  score-text = I.text(score-str, SCORE-TEXT-SIZE, "black")
  I.place-image(score-text, WIDTH / 2, SCORE-Y-POS, scene)
end

fun draw-playing-world(world :: World) -> I.Image:
  BACKGROUND ^ 
  draw-pipe(_, world.pipe) ^ 
  draw-bird(_, world.bird) ^
  draw-score(_, world.score)
end

fun draw-end-score(scene :: I.Image, score :: Number) -> I.Image:
  score-str = "Score: " + num-to-string(score)
  score-text = I.text(score-str, END-SCORE-TEXT-SIZE, "black")
  I.place-image(score-text, WIDTH / 2, END-SCORE-Y-POS, scene)
end

fun draw-play-again-button(scene :: I.Image) -> I.Image:
  I.place-image(PLAY-AGAIN-BUTTON, PLAY-AGAIN-BUTTON-POS.x, PLAY-AGAIN-BUTTON-POS.y, scene)
end

fun draw-game-over-world(world :: World%(is-world-game-over)) -> I.Image:
  BACKGROUND ^
  draw-pipe(_, world.pipe) ^
  draw-end-score(_, world.end-score) ^
  draw-play-again-button
end

fun draw-world(world :: World) -> I.Image:
  if is-world-playing(world):
    draw-playing-world(world)
  else:
    draw-game-over-world(world)
  end
end

# EVENT HANDLERS
# --------------
fun on-key(world :: World, key :: String) -> World:
  if (key == " ") and not(world.bird.collided):
    bird = flappy-bird(world.bird.y, -7, false)
      world-playing(bird, world.pipe, world.score)
  else:
    world
  end
end

fun on-click-replay(world :: World, mx :: Number, my :: Number) -> World:
  if is-point-inside-rect(mx, my, 
      PLAY-AGAIN-BUTTON-POS.x, 
      PLAY-AGAIN-BUTTON-POS.y,
      I.image-width(PLAY-AGAIN-BUTTON),
      I.image-height(PLAY-AGAIN-BUTTON)):
    
    INIT-WORLD
  else:
    world
  end
end

fun on-mouse(world :: World, mx :: Number, my :: Number, event :: String) -> World:
  if (event == "button-down") and is-world-game-over(world):
    on-click-replay(world, mx, my)
  else:
    world
  end
end

# create world
W.big-bang(INIT-WORLD, [list: 
    W.to-draw(draw-world),
    W.on-tick(update-world),
    W.on-key(on-key),
    W.on-mouse(on-mouse)
  ]
)