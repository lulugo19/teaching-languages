include image
include world

provide:
  type Positioned-Image,
  pos-image,
  pos-image-contains-point,
  pos-image-draw
end

data Positioned-Image:
  | _pos-image(
      pos :: Point, 
      img :: Image, 
      contains-point :: (Positioned-Image -> Boolean),
      draw :: (Positioned-Image, Image -> Image))
end

fun pos-image-contains-point(pos-img :: Positioned-Image, p :: Point) -> Boolean:
  img = pos-img.img
  pos = pos-img.pos
  w-half = image-width(img) / 2
  h-half = image-height(img) / 2
  
  l = pos.x - w-half
  r = pos.x + w-half
  t = pos.y - h-half
  b = pos.y + h-half
  
  (p.x >= l) and (p.x <= r) and (p.y >= t) and (p.y <= b)
end

METHOD-CONTAINS-POINT = method(self :: Positioned-Image, p :: Point) -> Boolean: 
  pos-image-contains-point(self, p) 
end

fun pos-image-draw(pos-img :: Positioned-Image, scene :: Image) -> Image:
  img = pos-img.img
  pos = pos-img.pos
  place-image(img, pos.x, pos.y, scene)
end

METHOD-DRAW = method(self :: Positioned-Image, scene :: Image) -> Image:
  pos-image-draw(self, scene)
end

fun pos-image(pos :: Point, img :: Image) -> Positioned-Image:
  _pos-image(pos, img, METHOD-CONTAINS-POINT, METHOD-DRAW)
end

check:
  pos-img = pos-image(point(10, 10), square(10, "solid", "red"))
  pos-img.contains-point(point(5, 5)) is true
  pos-img.contains-point(point(15, 15)) is true
  pos-img.contains-point(point(0, 5)) is false
  pos-img.contains-point(point(15, 0)) is false
end