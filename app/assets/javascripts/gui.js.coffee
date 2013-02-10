class @GuiClass
  constructor: (@templates) -> 

  createWindow: (title=false,id=false) =>
    rand=UUIDjs.randomUI48()
    id=UUIDjs.randomUI48() if !id #if undefined just throw sth random
    title = "You ARE LAZY" if !title #if undefined set sth stupid
    @div_id = id+"-"+rand
    @registerWindow(@div_id)
    $.newWindow({id:@div_id,title:title})
    $.updateWindowContent(@div_id,@templates.main());
    @element = $("##{@div_id}")
    @setBindings()

  registerWindow: (id) ->

  closeAllWindows: (windows_array) ->
    windows_array.every (window) =>
      closeWindow(window)

  closeWindow: (window) ->
    $.closeWindow(window)

  setBindings: ->