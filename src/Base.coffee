class Suki.Base
  @include: (obj) ->
    for own key, value of obj::
      if key isnt 'constructor'
        @::[key] = value

    obj.included?.apply @

  @getter: (prop, get) ->
    Object.defineProperty @::, prop, {get, configurable: yes}

  @setter: (prop, set) ->
    Object.defineProperty @::, prop, {set, configurable: yes}

  UUID: ->
    unless Suki.Base.UUID
      Suki.Base.UUID = 1
    "SUKI_#{Suki.Base.UUID++}"
