class @GuiClass
  create_window: (title=false,id=false,template) =>
    rand=UUIDjs.randomUI48()
    id=UUIDjs.randomUI48() if !id #if undefined just throw sth random
    title = "You ARE LAZY" if !title #if undefined set sth stupid
    divid = id+"-"+rand
    @register_window(divid)
    $.newWindow({id:divid,title:title})
    $.updateWindowContent(divid,template);


  register_window: (id) ->

  close_all_windows: (windows_array) ->
    windows_array.every (window) =>
      close_window(window)

  close_window: (window) ->
    $.closeWindow(window)


  constructor: ->