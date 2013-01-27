#Warning: This code contains ugly this
#Warning: You have been warned about this 
#= require localstorage
#= require usecase
#= require glue
#= require gui

class LocalStorage extends @LocalStorageClass

class UseCase extends @UseCaseClass

class Glue
  constructor: (@useCase, @gui, @storage, @app)->
    Before(@useCase, 'start', => @gui.create_window(@app.fullname)) #create main window
#    LogAll(@useCase)
#    LogAll(@gui)


class Gui extends @GuiClass
  create_window: (title=false,id=false,template) =>
    rand=UUIDjs.randomUI48()
    id=UUIDjs.randomUI48() if !id #if undefined just throw sth random
    title = "You ARE LAZY" if !title #if undefined set sth stupid
    divid = rand+"-"+id
    $.newWindow({id:divid,title:title,type:"iframe", width:647, height:400})
    $.updateWindowContent(divid,'<iframe src="http://webchat.freenode.net?channels=CoffeeDesktop&uio=d4" width="647" height="400"></iframe>');
  constructor: ->

class @IrcGatewayApp
  fullname = "Irc Gateway"
  description = "Irc Gateway to freenode"
  @icon = "qwebircsmall.png"
  @fullname = fullname
  @description = description
  constructor: (id, params)->
    @id = id
    @fullname = fullname
    @description = description
    @fullname = "Irc Gateway"
    @description = "Irc Gateway to freenode"
    useCase      = new UseCase()
    gui          = new Gui()
    localStorage = new LocalStorage("CoffeeDesktop")
    #probably this under this line is temporary this because this isnt on the path of truth
    glue         = new Glue(useCase, gui, localStorage,this)
    #                                                  ^ this this is this ugly this

    useCase.start()

window.CoffeeDesktop.app_add('irc',@IrcGatewayApp)