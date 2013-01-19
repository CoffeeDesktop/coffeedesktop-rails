class @GuiClass
  constructor: (@templates) -> 

  create_window: (title=false,id=false) =>
    rand=UUIDjs.randomUI48()
    id=UUIDjs.randomUI48() if !id #if undefined just throw sth random
    title = "You ARE LAZY" if !title #if undefined set sth stupid
    @div_id = id+"-"+rand
    @register_window(@div_id)
    $.newWindow({id:@div_id,title:title})
    $.updateWindowContent(@div_id,@templates.main());
    @element = $("##{@div_id}")
    @set_bindings()

  register_window: (id) ->

  close_all_windows: (windows_array) ->
    windows_array.every (window) =>
      close_window(window)

  close_window: (window) ->
    $.closeWindow(window)

  set_bindings: ->