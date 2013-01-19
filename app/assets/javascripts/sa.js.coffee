#Warning: This code contains ugly this
#Warning: You have been warned about this 
#= require gui
#= require glue
#= require localstorage
#= require usecase

class Templates
  main: ->
    "Oh...Hai.
     This is sample app! :D"

class LocalStorage extends @LocalStorageClass

class UseCase extends @UseCaseClass

class Gui extends @GuiClass

class Glue extends @GlueClass
  constructor:  (@useCase, @gui, @storage, @app) ->
    super
#    LogAll(@useCase)
#    LogAll(@gui)

class @SampleApp
  fullname = "Sample Application"
  description = "Oh ... you just read app description."
  @fullname = fullname
  @description = description 
  constructor: (id) ->
    @id = id
    @fullname = fullname
    @description = description
    useCase      = new UseCase()
    templates    = new Templates()
    gui          = new Gui(templates)
    localStorage = new LocalStorage("desktopjs")
    
    #probably this under this line is temporary this because this isnt on the path of truth
    glue         = new Glue(useCase, gui, localStorage,this)
    #                                                  ^ this this is this ugly this

    useCase.start()

window.Desktopjs.app_add('sa',@SampleApp)