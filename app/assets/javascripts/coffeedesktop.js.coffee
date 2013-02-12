#= require jquery-1.8.3.min
#= require jquery-ui-1.10.0.custom.min
#= require jquery.json-2.3.min
#= require jquery.windows-engine
#= require jquery.jqdock
#= require jquery.hotkeys
#= require jquery.gritter.min
#= require uuid
#= require jstorage.min
#= require underscore
#= require sugar-1.3.min
#= require handlebars-1.0.0.beta.6
#= require YouAreDaBomb
#= require utils
class Templates
  desktop: ->
    "<div id='desktop' class='container'>
      <div id='loading_box'><h3>Loading CoffeeDesktop..</h3></div>
      <form id='run_dialog_form'><input type='text' id='command'></form>
      <div id='desktop_icons'></div>
      <ul id='dock' style='display:none'>
      </ul>
    </div>"
  list_object: (tag,label) ->
    "<li><a tabindex='-1' class='option_#{tag}'>#{label}</a></li>"
  desktop_object: ->
    "<div id='desktop_object_{{uuid}}' class='desktop_object' style='left:{{x}}px;top:{{y}}px'>
      <img style='width:48px;'' src='/assets/icons/{{img}}'>
      <div style='text-align:center'>{{text}}</div>
      <ul class='dropdown-menu' role='menu' aria-labelledby='drop2'>
        <li><a tabindex='-1' class='run_app_link' href='#'>Run App</a></li>
       {{#if options}}
        <li class='divider'></li>
          {{options}}
        {{/if}}        
        <li class='divider'></li>
        <li><a tabindex='-1' class='remove_link'>Remove This link</a></li>
      </ul>

      </div>       
      "
  dock_object: (uuid,icon,fullname,name,options) ->
    "<li ><img  id='app#{uuid}' src='/assets/icons/#{icon}' alt='#{fullname}' title='#{fullname}' desktop_object_options='#{options}' desktop_object_run='#{name}' desktop_object_fullname='#{fullname}' desktop_object_icon='#{icon}' class='dockItem i_wanna_be_a_desktop_object dock_app app_#{name}' />"
  dock_drop_up: ->
         "<ul class='dropup dropdown-menu' role='menu' aria-labelledby='drop2'>
          <li></li>
         <li class='divider'></li> 
        <li><a tabindex='-1' class='run_app_link' href='#'>Open New Instance</a></li>
        <li class='divider'></li>
        <li><a tabindex='-1' class='remove_link'>Close All</a></li>
      </ul></li>      "


class Request
  constructor: (@ajaxsettings) ->

class Backend
  #BACKEND DEVELOPER LOOK AT ME.... LOOK AT ME!
  constructor: ->
    @requetsqueue = []
    window.addEventListener('online', (e) ->
      options = {
        title: 'Network Notification',
        text: "You are online!",
        image: '/assets/icons/network-transmit-receive.png'
      }
      CoffeeDesktop.notes.addNote(options)
    , false)

    window.addEventListener('offline', (e) ->

      options = {
        title: 'Network Notification',
        text: "You are offline",
        image: '/assets/icons/network-error.png'
      }
      CoffeeDesktop.notes.addNote(options)
    , false);
    $( document ).ajaxError( (event, jqXHR, ajaxSettings, thrownError) =>
      if (jqXHR.status == 0) 
         msg = 'Not connect.\n Verify Network.'
      else if (jqXHR.status == 404) 
         msg = 'Requested page not found. [404]'
      else if (jqXHR.status == 500) 
         msg = 'Internal Server Error [500].'
      else if (thrownError == 'parsererror') 
         msg = 'Requested JSON parse failed.'
      else if (thrownError == 'timeout') 
         msg = 'Time out error.'
      else if (thrownError == 'abort') 
         msg = 'Ajax request aborted.'
      else 
         msg = 'Uncaught Error.\n' + thrownError
      options = {
        title: 'Network Notification',
        text: "Can't send post request to #{ajaxSettings.url}.<br>Error:#{msg}",
        image: '/assets/icons/network-error.png'
      }
      request = new Request(ajaxSettings)
      @requetsqueue.push(request)
      CoffeeDesktop.notes.addNote(options)
    )

  fetchApp: (app) ->
    console.log("Fetching app " + app)
    $.get("/assets/"+app+".js")

  fetchApps: ->
    apps = $.getJSON("/coffeedesktop/apps", (apps) =>
      apps.every (app) => 
        @fetchApp(app)
    )

  post:(url,json) ->
    $.post(url, json, (data) =>
      return data
    )

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

  getDesktopObjects: =>
    if(!@get("desktop_objects"))
      return []
    @desktop_objects = @get("desktop_objects").map( (DesktopObjectData) =>
        desktop_object = new DesktopObject(DesktopObjectData.fullname, DesktopObjectData.icon, DesktopObjectData.run, DesktopObjectData.x, DesktopObjectData.y,DesktopObjectData.uuid,DesktopObjectData.options)
        return desktop_object
    )


#Models
class DesktopObject
  constructor: (@fullname,@icon,@run,@x,@y,@uuid,@options) ->

class DesktopProcess
  constructor: (@id,@name,@app) ->

class UseCase
  constructor: (@storage,@gui) ->
    @desktop_objects =  @storage.getDesktopObjects()

  start: =>
    for desktop_object in @desktop_objects
      @gui.drawDesktopObject(
        desktop_object.fullname,
        desktop_object.icon,
        desktop_object.run,
        desktop_object.x,
        desktop_object.y,
        desktop_object.uuid,
        desktop_object.options
        )


  runCommand: (app) =>

  addToDesktop: (fullname,icon,run,x,y,uuid,options) ->
    desktop_object = new DesktopObject(fullname,icon,run,x,y,uuid,options)
    @desktop_objects.push(desktop_object)
    @storage.set('desktop_objects', @desktop_objects)

  removeDesktopObject: (uuid) ->
    for desktop_object in @desktop_objects
        console.log desktop_object.uuid #uncomment for jasmine
      if "#{desktop_object.uuid}" == "#{uuid}"
        @desktop_objects.remove(desktop_object)
    @storage.set('desktop_objects', @desktop_objects)

  desktopObjectMove: (uuid,x,y) ->
    for desktop_object in @desktop_objects
      if "#{desktop_object.uuid}" == "#{uuid}"
        desktop_object.x = x
        desktop_object.y = y
    @storage.set('desktop_objects', @desktop_objects)

class Glue
  constructor: (@useCase, @gui, @storage,  @backend,@app)->
    Before(@useCase, 'start', => @gui.renderDesk())
    Before(@app, 'appAdd', (name,app,options) => @gui.dockAppend(name,app,options))
    Before(@backend, 'fetchApp', (app) => @gui.logFetchApp(app))
    Before(@gui, 'addToDesktop', (fullname,icon,run,x,y,uuid,options) => @useCase.addToDesktop(fullname,icon,run,x,y,uuid,options))
    Before(@gui, 'removeDesktopObject', (uuid) => @useCase.removeDesktopObject(uuid))

    After(@gui, 'desktopObjectMoveSync', (id,x,y) => @useCase.desktopObjectMove(id,x,y))
    After(@gui, 'renderDesk', => @gui.showLoading())
    After(@gui, 'renderDesk', => @gui.setBindings())
    After(@useCase, 'start', => @backend.fetchApps())
    After(@gui, 'runCommand', (app) => @useCase.runCommand(app))
    After(@useCase, 'runCommand', => @gui.hideRunDialog())
    After(@useCase, 'runCommand', (app) => @app.appRun(app))
    After(@backend, 'fetchApps', => @gui.hideLoading())

    LogAll(@useCase)
    LogAll(@gui)

class Gui
  constructor: (@templates) -> 

  showLoading: ->
    $("#loading_box").fadeIn()

  hideLoading: ->
    $("#loading_box").fadeOut()

  logLoading: (msg)->
    $("#loading_box").append("<li>"+msg+"</li>")

  logFetchApp: (app) ->
    @logLoading("Fetching app: "+app)

  showRunDialog: ->
    $("#run_dialog_form").fadeIn()
    $("#command").focus()

  hideRunDialog: ->
    $("#run_dialog_form").fadeOut()

  runCommand: (cmd) =>

  dockStart: ->
    $('#dock').jqDock(window.CoffeeDesktop.dock_settings)

  desktopObjectMove: (e,ui) ->
    x=ui.position.left
    y= ui.position.top
    id = ui.helper[0].id.split("desktop_object_")[1]
    @desktopObjectMoveSync(id,x,y)
    



  drawDesktopObject: (fullname,icon,run,x,y,uuid,options) ->
    options_html = false
    if options
      options_html =""
      options = eval("(#{options})");
      for option in Object.keys(options)
        options_html = options_html.concat(@templates.list_object(option.replace(/\s+/g, '_'),option)) #Slug
      options_html= new Handlebars.SafeString(options_html)
    template = Handlebars.compile(@templates.desktop_object())
    data = {img: icon ,text:fullname, x:x, y:y, uuid:uuid, options:options_html}
    $(template(data)).appendTo("#desktop_icons").draggable({stop: (e,u) => @desktopObjectMove(e,u)}).dblclick( => @runCommand(run)).bind("contextmenu", -> $(@).find('.dropdown-menu').show(1,-> $(@).addClass('popup'));)
    if options
      #console.log options
      for option in Object.keys(options)
        $("#desktop_object_"+uuid+" .option_"+option.replace(/\s+/g, '_')).click(=> @runCommand(options[option]))
    $("#desktop_object_"+uuid+" .run_app_link").click(=> @runCommand(run))




    $("#desktop_object_"+uuid+" .remove_link").click(=> @removeDesktopObject(uuid))


  setBindings: ->
    console.log("setting bindings")
    @logLoading("setting bindings")
    $("#desktop_icons").droppable({
      drop: (event, ui) =>
        uuid = UUIDjs.randomUI48()
        element = ui.draggable[0]
        fullname = element.getAttribute('desktop_object_fullname')
        icon =  element.getAttribute('desktop_object_icon')
        run =  element.getAttribute('desktop_object_run')
        options =  element.getAttribute('desktop_object_options')
        x = event.clientX
        y = event.clientY
        @addToDesktop(fullname,icon,run,x,y,uuid,options)
      accept: ".i_wanna_be_a_desktop_object"
      })
    $(document).bind('keydown', 'alt+r', @showRunDialog)
    $('#run_dialog_form').submit( () =>
      app =$("#command").val()
      $("#command").val("")
      @runCommand(app)
      $('#command').blur()
      false
    )

  dockAppend: (name,app,options) ->
    uuid = UUIDjs.randomUI48()
    icon = app.icon
    icon = "app.png" if !icon
    options = "" if !options 
    
    html = @templates.dock_object(uuid,icon,app.fullname,name,options)
    $('#dock').jqDock('destroy')
    $('#dock').append(html)
    $('.dock_app').draggable(
      helper: "clone",
      revert: "invalid",
    )

    $('#dock').jqDock(window.CoffeeDesktop.dock_settings);
    $("#app"+uuid).click(() =>
      @runCommand(name)
    )

  renderDesk: ->
    window.oncontextmenu = => 
      $(".popup").hide().removeClass('popup')
      false
    window.onclick = =>
      $(".popup").hide().removeClass('popup')
    $(CoffeeDesktop_element).append(@templates.desktop())

  removeDesktopObject: (uuid) ->
    $("#desktop_object_"+uuid).remove()
  #aop shit
  desktopObjectMoveSync: (id,x,y) ->
  addToDesktop: (fullname,icon,run,x,y,uuid,options) ->
    #prevent endless loop between usecase and gui
    @drawDesktopObject(fullname,icon,run,x,y,uuid,options)

class Notes
  constructor:  ->
    @notes = []


  addNote: (options) ->
      unique_id = $.gritter.add(options)

class @CoffeeDesktopApp
  #This is just online status sketch ...
  state = "online"
  getState: ->
    state
  setState: (i) ->
    #0 online 1 offline
    if i
      state="offline"
    else
      state="online"

  appAdd: (name,app,options) ->
    console.log("adding "+name)
    @app[name] = app
    @apps.add(name)

  
  appRun: (app) ->
    console.log("starting "+app)
    @process_id+=1
    if app.split(" ").length > 1
      console.log("oh cool we have some fucks to give")
      args = app.split(" ")
      name = args.shift()
      process = new @app[name](@process_id,args)
    else
      process= new @app[app](@process_id)
      name = app
    @processes.push(new DesktopProcess(@process_id,name,process))  
    $(".app_#{name}").parent().append(@templates.dock_drop_up())
    $(".app_#{name}").effect("bounce", { times:3 }, 500)
    $(".app_#{name}").addClass('running_app')
    console.log @templates.dock_drop_up()
    $(".app_#{name}").bind("contextmenu", -> $(@).parent().find('.dropdown-menu').show(1,-> $(@).addClass('popup')))
  
  getProcessByID: (id) ->
    for process in @processes
      if "#{process.id}" == "#{id}"
        return process


  processKill: (id) ->
    console.log "Killing #{id}"
    process = @getProcessByID(id)
    if (@processes.indexOf(process)) > -1
      @processes.splice(@processes.indexOf(process), 1)
    still_exist = 0
    name = process.name
    for process in @processes
      if "#{process.name}" == "#{name}"
        still_exist = 1
    if !still_exist
      $(".app_#{name}").removeClass('running_app')

  constructor: (@element="body") ->
    @apps = new Array()
    @app = {}
    @processes = []
    @process_id = 0
    @dock_settings =   {labels: 'tc'}
    @notes = new Notes()
    @templates    = new Templates()
    localStorage = new LocalStorage("CoffeeDesktop")
    gui          = new Gui(@templates)
    useCase      = new UseCase(localStorage,gui)
    templates    = new Templates()
    
    

    @backend      = new Backend()
    glue         = new Glue(useCase, gui, localStorage, @backend,this)
    useCase.start()


#jasmine shit
window.coffeedesktop = {}
window.coffeedesktop.UseCase = UseCase
window.coffeedesktop.Gui = Gui
window.coffeedesktop.Templates = Templates
window.coffeedesktop.DesktopObject = DesktopObject
window.coffeedesktop.CoffeeDesktopApp = CoffeeDesktopApp


jQuery.extend({
    CoffeeDesktop: CoffeeDesktopApp
  })