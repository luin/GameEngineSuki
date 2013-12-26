Suki.Entity.define 'Sprite', (imgURL, imgWidth, imgHeight, spriteX, spriteY, spriteWidth, spriteHeight) ->
  @width = spriteWidth
  @height = spriteHeight
  @css 'backgroundImage', "url(#{imgURL})"
  @css 'backgroundPosition', "-#{spriteX}px -#{spriteY}px"

