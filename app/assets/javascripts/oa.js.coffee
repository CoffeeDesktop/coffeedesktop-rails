#Warning: This code contains ugly this
#Warning: You have been warned about this 
#= require gui
#= require glue
#= require localstorage
#= require usecase

class Templates
  main: ->
    "You can test here coffeedesktop wrapper<br>
    Pluginstatus: <div class='plugin_status'></div><br>
    Server status: <div class='server_status'></div><br>
    <button class='start_server_button'>Start localserver</button>
      <object id='plugin0' type='application/x-cdw' width='0' height='0'>

      </object>
        "

class Backend 
  constructor: () ->

  stupidPost:  ->
      $.post("/coffeedesktop/stupid_post" );

class LocalStorage extends @LocalStorageClass

class UseCase extends @UseCaseClass
    constructor: (@gui) ->
      @windows = []
      @status = false

    startServer: () ->
      console.log "Starting local server"
      @gui.plugin_object.startServer()

    exitSignal: ->
      @gui.closeMainWindow()

    checkStatus: ->
      jQuery.ajax(
        type: 'GET'
        url: "http://127.0.0.1:8080/www/js/status.json"
        no_error: false
        dataType:"jsonp"
        error:(event, jqXHR, ajaxSettings, thrownError) =>
          if event.status == 200
            @status=true
          else
            @status=false
        xhrFields: 
          withCredentials: false 
        
      )
      @gui.setServerStatus(@status)


    start: (args) =>
      @gui.createWindow("Sample Application","main")
      @status_int= setInterval((=> @checkStatus()) ,1000)



    pluginStatus: ->
      @gui.setPluginStatus(@gui.plugin_object.valid)

class Gui extends @GuiClass
  constructor: (@templates) -> 

  createWindow: (title=false,template="main") =>
    rand=UUIDjs.randomUI48()
    id=UUIDjs.randomUI48() if !id #if undefined just throw sth random
    div_id = id+"-"+rand
    $.newWindow({id:div_id,title:title,width:500,height:350})
    $.updateWindowContent(div_id,@templates[template]())
    @div_id = div_id
    @element = $("##{@div_id}")   
    $("##{div_id} .window-closeButton").click( =>
      @exitApp()
    ) 
    @plugin_object= document.getElementById('plugin0');
    console.log @plugin_object
    


    @setBindings(template,div_id)

  
  closeWindow: (id) ->
    console.log "closing window #{id}"
    $.closeWindow(id)
    @removeWindow(id)

  updateChild: (id) ->
    $.updateWindowContent(id,@templates.updated_child())
    @setBindings('updated_child',id)

  setBindings: (template,div_id) ->
    if template == "main"
      $( "##{div_id} .sa_drag_button" ).button()
      $( "##{div_id} .start_server_button").click( => @startServer())

    
  closeMainWindow: ->
    $("##{@div_id} .window-closeButton").click()

  setPluginStatus: (status)->
    if status
      $( "##{@div_id} .plugin_status").text("OK")
    else
      $( "##{@div_id} .plugin_status").text("NOT OK")

  setServerStatus: (status)->
    if status
      $( "##{@div_id} .server_status").text("OK")
    else
      $( "##{@div_id} .server_status").text("NOT OK")

  #aop events
  startServer: ->
  exitApp: ->

class Glue extends  @GlueClass
  constructor:  (@useCase, @gui, @storage, @app, @backend) ->
    After(@gui, 'exitApp', => @app.exitApp())
    After(@gui, 'createWindow', => @useCase.pluginStatus())
    After(@gui, 'startServer', => @useCase.startServer())
    After(@app, 'exitSignal', => @useCase.exitSignal())

#    LogAll(@useCase)
#    LogAll(@gui)

class @OfflineApp
  fullname = "Offline Application"
  description = "Testing Coffeedesktop npapi wrapper"
  @fullname = fullname
  @description = description

  exitSignal: ->

  exitApp: ->
    CoffeeDesktop.processKill(@id) 
  getDivID: ->
    @gui.div_id
  constructor: (@id, args) ->
    @fullname = fullname
    @description = description

    templates    = new Templates()
    backend    = new Backend()
    @gui          = new Gui(templates)
    useCase      = new UseCase(@gui)


    localStorage = new LocalStorage("CoffeeDesktop")
    
    #probably this under this line is temporary this because this isnt on the path of truth
    glue         = new Glue(useCase, @gui, localStorage,this,backend)
    #                                                  ^ this this is this ugly this

    useCase.start(args)

window.oa = {}
window.sa.UseCase = UseCase
window.sa.Gui = Gui
window.sa.Templates = Templates
window.sa.SampleApp = SampleApp

window.CoffeeDesktop.appAdd('oa',@OfflineApp, )