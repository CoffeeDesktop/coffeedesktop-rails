#= require gui
#= require glue
#= require localstorage
#= require usecase

class Templates
  main: ->
    "Oh ... look at me<br>
    I'm made my first coffee for desktopjs!"

class LocalStorage extends @LocalStorageClass

class UseCase extends @UseCaseClass

class Gui extends @GuiClass

class Glue extends @GlueClass
  constructor:  (@useCase, @gui, @storage, @app, @templates) ->
    super
#    LogAll(@useCase) # unhash if you want debug
#    LogAll(@gui)

class @MyApp
  fullname = "My Application"
  description = "Oh ... you just read app description."
  @fullname = fullname
  @description = description 
  constructor: (id) ->
    @id = id
    @fullname = fullname
    @description = description
    useCase      = new UseCase()
    gui          = new Gui()
    localStorage = new LocalStorage("myapp")
    templates    = new Templates()
#probably this under this line is temporary this because this isnt on the path of truth
    glue         = new Glue(useCase, gui, localStorage,this,templates)
    #                                                  ^ this this is this ugly this

    useCase.start()

window.Desktopjs.app_add('ma',@MyApp)