import world as W
import image as I
import shared-gdrive("positioned-image.arr", "1bnu9qW1_8qxHkxtOcy5w7A7DlXk-4Zuj") as P-IMG

# CONSTANTS
#---------------------
WIDTH = 400
HEIGHT = 500
CENTER = WIDTH / 2

EMPTY-SCENE = I.empty-scene(WIDTH, HEIGHT)

HEART-IMAGE = I.scale(1.8, I.image-url("https://opengameart.org/sites/default/files/heart_4.png"))
BROCCOLI-IMAGE = I.scale(0.08, I.image-url("https://www.jing.fm/clipimg/detail/173-1733544_broccoli-png-image-free-broccoli-pictures-download-broccoli.png"))
CAKE-IMAGE = I.scale(0.18, I.image-url("https://64.media.tumblr.com/b5271ea3c7f791befb683ab8238ac846/tumblr_orzia8ijU21ucpx1qo4_r2_500.png"))
PET-IMAGE = I.image-url("https://opengameart.org/sites/default/files/styles/medium/public/megu21.png")
PET-SICK-IMAGE = I.image-url("https://opengameart.org/sites/default/files/035%20small0002_0.png")
PET-SLEEPY-IMAGE = I.scale(2, I.image-url("https://opengameart.org/sites/default/files/44small0001.png"))
TOMBSTONE-IMAGE = I.image-url("https://pixelartmaker-data-78746291193.nyc3.digitaloceanspaces.com/image/52c306f0214cb6d.png")

SYMBOL-Y-POS = 150
HEART = P-IMG.pos-image(I.point(100, SYMBOL-Y-POS), HEART-IMAGE)
BROCCOLI = P-IMG.pos-image(I.point(200, SYMBOL-Y-POS), BROCCOLI-IMAGE)
CAKE = P-IMG.pos-image(I.point(300, SYMBOL-Y-POS), CAKE-IMAGE)

PET-POS = I.point(WIDTH / 2, 350)
PET-HEALTHY = P-IMG.pos-image(PET-POS, PET-IMAGE)
PET-SICK = P-IMG.pos-image(PET-POS, PET-SICK-IMAGE)
PET-ASLEEP = P-IMG.pos-image(PET-POS, PET-SLEEPY-IMAGE)
TOMBSTONE = P-IMG.pos-image(PET-POS, TOMBSTONE-IMAGE)

PLAY-AGAIN-BUTTON = I.overlay-align(
  "center",
  "center",
  I.text("Nochmal spielen", 28, "black"),
  I.rectangle(200, 50, "solid", "light-grey")
  ) ^
I.overlay-align("center", "center", I.empty-scene(200, 50), _) ^
P-IMG.pos-image(I.point(CENTER, HEIGHT - 30), _)

MAX-BAR-LENGTH = 350
BAR-HEIGHT = 25
BAR-LEFT-X-POS = (WIDTH - MAX-BAR-LENGTH) / 2
BAR-TEXT-SIZE = 20

LOVE-BAR-Y-POS = 20
LOVE-BAR-COLOR = "red"
ENERGY-BAR-Y-POS = 50
ENERGY-BAR-COLOR = "yellow"

FPS = 28
ONE-PER-SECOND = 1 / FPS

NORMAL-ENERGY-CHANGE = -1 * ONE-PER-SECOND
NORMAL-LOVE-CHANGE = -1 * ONE-PER-SECOND

ASLEEP-DURATION = FPS * 10
ASLEEP-ENERGY-CHANGE = 2 * ONE-PER-SECOND

SICK-DURATION = FPS * 15
SICK-ENERGY-CHANGE = -4 * ONE-PER-SECOND

START-LOVE = 50
START-ENERGY = 50

HEART-LOVE-CHANGE = 10
HEART-ENERGY-CHANGE = -20

BROCCOLI-LOVE-CHANGE = -15
BROCCOLI-ENERGY-CHANGE = 10

CAKE-ENERGY-CHANGE = 15
CAKE-SICK-PROBABILITY = 30 # in Prozent

# DATA-DEFINITIONS
#---------------------
data Tamagochi-Debuff:
  | debuff-sick
  | debuff-asleep
end

data Tamagochi-Status:
  | status-normal
  | status-dead
  | status-debuff(debuff :: Tamagochi-Debuff, remaining-duration :: Number)
end

NEW-SICK-STATUS = status-debuff(debuff-sick, SICK-DURATION)
NEW-SLEEP-STATUS = status-debuff(debuff-asleep, ASLEEP-DURATION)

fun identity(x :: Any) -> Any: x end

data Tamagochi-Symbol:
  | tama-symbol(
      img :: P-IMG.Positioned-Image,
      love-change :: Number, 
      energy-change :: Number, 
      status-update :: (Tamagochi-Status -> Tamagochi-Status))
end

HEART-SYMBOL = tama-symbol(HEART, 20, -10, identity)
BROCCOLI-SYMBOL = tama-symbol(BROCCOLI, -10, 10, identity)
CAKE-SYMBOL = tama-symbol(CAKE, 0, 20, 
  lam(s): 
    if num-random(100) < CAKE-SICK-PROBABILITY: NEW-SICK-STATUS 
    else: s end 
  end)

SYMBOLS = [list: HEART-SYMBOL, BROCCOLI-SYMBOL, CAKE-SYMBOL]

data Tamagochi:
  | tama-pet(love :: Number, energy :: Number, status :: Tamagochi-Status, life-time :: Number)
end

INIT-PET = tama-pet(START-LOVE, START-ENERGY, status-normal, 0)

# HELPER FUNCTIONS
#--------------------
fun clamp(n :: Number, min :: Number, max :: Number) -> Number:
  num-max(min, num-min(max, n))
end

fun has-pet-debuff(pet, debuff):
  status = pet.status
  is-status-debuff(status) and (status.debuff == debuff)
end

# UPDATE FUNCTIONS
#---------------------
fun update-pet-status(pet :: Tamagochi) -> Tamagochi-Status:
  status = pet.status
  if pet.love == 0:
    status-dead
  else:
    pet-is-asleep = has-pet-debuff(pet, debuff-asleep)

    if not(pet-is-asleep) and (pet.energy <= 10):
      NEW-SLEEP-STATUS
    else:
      cases(Tamagochi-Status) status:
        | status-debuff(debuff, rem-dur) =>
          if rem-dur == 0: status-normal 
          else: status-debuff(debuff, rem-dur - 1) end
        | else => status
      end
    end
  end
end

fun update-pet-love(pet :: Tamagochi) -> Number:
  clamp(pet.love + NORMAL-LOVE-CHANGE, 0, 100)
end

fun update-pet-energy(pet :: Tamagochi) -> Number:
  energy-change = cases(Tamagochi-Status) pet.status:
    | status-normal => NORMAL-ENERGY-CHANGE
    | status-dead => 0
    | status-debuff(d, _) => cases(Tamagochi-Debuff) d:
        | debuff-sick => SICK-ENERGY-CHANGE
        | debuff-asleep => ASLEEP-ENERGY-CHANGE
      end
  end
  
  pet.energy + energy-change
end

fun update-pet(pet :: Tamagochi) -> Tamagochi:
  if is-status-dead(pet.status):
    pet
  else:
    updated-status = update-pet-status(pet)
    updated-love = update-pet-love(pet)
    updated-energy = update-pet-energy(pet)
    updated-life-time = pet.life-time + 1
    tama-pet(updated-love, updated-energy, updated-status, updated-life-time)
  end
end

# DRAW FUNCTIONS
#---------------------
fun draw-symbols(scene :: I.Image, pet :: Tamagochi):
  if has-pet-debuff(pet, debuff-asleep):
    scene
  else:  
    heart-and-broccoli = scene ^
    HEART.draw(_) ^
    BROCCOLI.draw(_)

    should-draw-cake = not(has-pet-debuff(pet, debuff-sick))

    if should-draw-cake:
      CAKE.draw(heart-and-broccoli)
    else:
      heart-and-broccoli
    end
  end
end

fun draw-bar(scene :: I.Image, y :: Number, value :: Number, value-desc :: String, color :: String)
  -> I.Image:
  
  background = I.empty-scene(MAX-BAR-LENGTH, BAR-HEIGHT)
  
  width = (value / 100) * MAX-BAR-LENGTH
  fill = I.rectangle(width, BAR-HEIGHT, "solid", color)
  
  text-str = num-to-string(num-round(value)) + " % " + value-desc
  text = I.text(text-str, BAR-TEXT-SIZE, "black") 
  
  bar = background ^
  I.overlay-align("left", "center", fill, _) ^
  I.overlay-align("center", "center", text, _)
  
  I.place-image-align(bar, BAR-LEFT-X-POS, y, "left", "center", scene)
end

fun draw-bars(scene :: I.Image, pet :: Tamagochi) -> I.Image:
  scene ^
  draw-bar(_, LOVE-BAR-Y-POS, pet.love, "Liebe", LOVE-BAR-COLOR) ^
  draw-bar(_, ENERGY-BAR-Y-POS, pet.energy, "Energie", ENERGY-BAR-COLOR)
end

fun draw-tombstone-with-life-time(scene :: I.Image, life-time :: Number) -> I.Image:
  life-time-in-seconds = num-round(life-time / FPS)
  tomb-text = I.text(num-to-string(life-time-in-seconds) + " s", 33, "black")
  TOMBSTONE.draw(scene) ^
  I.overlay-onto-offset(tomb-text, "center", "center", 0, -30, _, "center", "center")
end

fun draw-pet(scene :: I.Image, pet :: Tamagochi) -> I.Image:
  if is-status-dead(pet.status):
    draw-tombstone-with-life-time(scene, pet.life-time)
  else:
    pet-img = cases(Tamagochi-Status) pet.status:
    | status-normal => PET-HEALTHY
    | status-debuff(d, _) => cases(Tamagochi-Debuff) d:
        | debuff-sick => PET-SICK
        | debuff-asleep => PET-ASLEEP
      end
    end
    pet-img.draw(scene)
  end
end

fun draw-game-over-when-pet-is-dead(scene :: I.Image, pet :: Tamagochi) -> I.Image:
  if is-status-dead(pet.status):
    PLAY-AGAIN-BUTTON.draw(scene)
  else:
    scene
  end
end
  
fun draw(pet :: Tamagochi) -> I.Image:
  EMPTY-SCENE ^
  draw-symbols(_, pet) ^
  draw-bars(_, pet) ^
  draw-pet(_, pet) ^
  draw-game-over-when-pet-is-dead(_, pet)
end

# EVENT HANDLERS
#---------------------
fun on-mouse(pet :: Tamagochi, mx :: Number, my :: Number, event :: String):
  if event == "button-down":
    mouse-pos = I.point(mx, my)
    
    if is-status-dead(pet.status):
      if PLAY-AGAIN-BUTTON.contains-point(mouse-pos):
        INIT-PET
      else:
        pet
      end
    else if not(has-pet-debuff(pet, debuff-asleep)):
      clicked-symbol = SYMBOLS.find(lam(x): x.img.contains-point(mouse-pos) end)

      cases (Option<Tamagochi-Symbol>) clicked-symbol:
        | some(symbol) =>
          block:
            new-health = clamp(pet.love + symbol.love-change, 0, 100)
            new-energy = clamp(pet.energy + symbol.energy-change, 0, 100)
            new-status = symbol.status-update(pet.status)

            tama-pet(new-health, new-energy, new-status, pet.life-time)
          end
        | none => pet
      end
    end
  else:
    pet
  end
end

# create world
W.big-bang(INIT-PET, [list:
    W.on-tick(update-pet),
    W.to-draw(draw),
    W.on-mouse(on-mouse)
  ])