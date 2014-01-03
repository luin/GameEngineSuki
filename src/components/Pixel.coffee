Suki.Entity.define 'Pixel', (imageURL) ->
  @include 'Image'
  @img = imageURL
  img.src = imageURL
  canvas = document.createElement 'canvas'
  context = canvas.getContext '2d'
  context.drawImage img, 0, 0
  context.getImageData(x, y, 1, 1).data
