#Warning: This code contains ugly this
#Warning: You have been warned about this 
class Templates
  main: ->
    "Oh...Hai.
     This is sample app! :D"

class LocalStorage
  constructor: (@namespace) ->

  set: (key, value) =>
    console.log(value)
    $.jStorage.set("#{@namespace}/#{key}", value)

  get: (key) =>
    $.jStorage.get("#{@namespace}/#{key}")

  remove: (key) =>
    $.jStorage.deleteKey("#{@namespace}/#{key}")

  flush: =>
    for key in $.jStorage.index()
      if key.match("^#{@namespace}")
        $.jStorage.deleteKey(key)


class UseCase
  constructor: ->
    
  start: =>
    

class Glue
  constructor: (@useCase, @gui, @storage, @app, @templates)->
    Before(@useCase, 'start', => @gui.create_window(@app.fullname,"main",@templates.main())) #create main window


    #After(@gui, 'create_window', => @gui.window_set("main"))
    LogAll(@useCase)
    LogAll(@gui)

class Gui
  create_window: (title=false,id=false,template) =>
    rand=UUIDjs.randomUI48()
    id=UUIDjs.randomUI48() if !id #if undefined just throw sth random
    title = "You ARE LAZY" if !title #if undefined set sth stupid
    divid = id+"-"+rand
    $.newWindow({id:divid,title:title})
    $.updateWindowContent(divid,template);

  constructor: ->

class @SampleApp
  fullname = "Sample Application"
  description = "Oh ... you just read app description."
  @fullname = fullname
  @description = description 
  constructor: (id) ->
    @id = id
    @windows = []
    @fullname = fullname
    @description = description
    useCase      = new UseCase()
    gui          = new Gui()
    localStorage = new LocalStorage("desktopjs")
    templates    = new Templates()
    #probably this under this line is temporary this because this isnt on the path of truth
    glue         = new Glue(useCase, gui, localStorage,this,templates)
    #                                                  ^ this this is this ugly this

    useCase.start()

window.Desktopjs.app_add('sa',@SampleApp)