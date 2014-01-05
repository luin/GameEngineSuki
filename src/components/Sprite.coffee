Suki.Entity.define 'Sprite', (data) ->
  @sprite = (data) ->
    @width = data.width
    @height = data.height
    @css 'backgroundImage', "url(#{data.image})"
    @css 'backgroundPosition', "-#{data.x}px -#{data.y}px"
  if data
    @sprite data

