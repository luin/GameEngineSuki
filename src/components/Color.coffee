Suki.Entity.define 'Color', (backgroundColor) ->
  @color = (backgroundColor) ->
    @css 'backgroundColor', backgroundColor
  if backgroundColor
    @color backgroundColor
