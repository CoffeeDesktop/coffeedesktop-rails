class @UseCaseClass
  constructor: ->
    @windows = []

  start: =>
  
  registerWindow: (id) ->
    @windows.add(id)

  exit: ->
    closeAllWindows(@windows)

  closeAllWindows: (windows) ->