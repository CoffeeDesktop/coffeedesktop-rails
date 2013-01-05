#Warning: This code contains ugly this
#Warning: You have been warned about this 

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
  constructor: (@useCase, @gui, @storage, @app)->
    Before(@useCase, 'start', => @gui.create_window("main",@app.fullname)) #create main window


    #After(@gui, 'create_window', => @gui.window_set("main"))
    LogAll(@useCase)
    LogAll(@gui)

class Gui
  create_window: (id=false,title=false) =>
    id=UUIDjs.randomUI48() if !id? #if undefined just throw sth random
    title = "You ARE LAZY" if !title? #if undefined set sth stupid
    $.newWindow({id:@id+"-"+id,title:title})

  constructor: ->

class @SampleApp
  constructor: (id)->
    @id = id
    @windows = []
    @fullname = "Sample Application"
    @description = "Oh ... you just read app description."
    useCase      = new UseCase()
    gui          = new Gui()
    localStorage = new LocalStorage("desktopjs")
    #probably this under this line is temporary this because this isnt on the path of truth
    glue         = new Glue(useCase, gui, localStorage,this)
    #                                                  ^ this this is this ugly this

    useCase.start()

window.Desktopjs.app_add('sa',@SampleApp)