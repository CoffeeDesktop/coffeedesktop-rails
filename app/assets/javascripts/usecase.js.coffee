class @UseCaseClass
  constructor: ->
    @windows = []

  start: =>
  
  register_window: (id) ->
    @windows.add(id)

  exit: ->
    close_all_windows(@windows)

  close_all_windows: (windows) ->