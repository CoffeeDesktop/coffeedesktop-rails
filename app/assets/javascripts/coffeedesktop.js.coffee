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
  desktop: ->"<div id='desktop' class='container'>
      <div id='loading_box'><h3>Loading CoffeeDesktop..</h3></div>
  <form id='run_dialog_form'><input type='text' id='command'></form>
  <div id='desktop_icons'></div>
  <ul id='dock' style='display:none'>
  </ul>
    </div>"
  list_object: (tag,label) ->
    "<li><a tabindex='-1' class='option_"+tag+"'>"+label+"</a></li>"
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
    "<li ><img  id='app"+uuid+"' src='/assets/icons/"+icon+"' alt='"+fullname+"' title='"+fullname+"' desktop_object_options='"+options+"'' desktop_object_run='"+name+"' desktop_object_fullname='"+fullname+"' desktop_object_icon='"+icon+"' class='dockItem i_wanna_be_a_desktop_object dock_app' /></li>"


class Request
  constructor: (@ajaxsettings) ->

class Backend
  #BACKEND DEVELOPER LOOK AT ME.... LOOK AT ME!
  constructor: ->
    @requetsqueue = []

    $( document ).ajaxError( (event, jqXHR, ajaxSettings, thrownError) =>
      if (jqXHR.status == 0) 
         msg = 'Not connect.\n Verify Network.'
      else if (jqXHR.status == 404) 
         msg = 'Requested page not found. [404]'
      else if (jqXHR.status == 500) 
         msg = 'Internal Server Error [500].'
      else if (exception == 'parsererror') 
         msg = 'Requested JSON parse failed.'
      else if (exception == 'timeout') 
         msg = 'Time out error.'
      else if (exception == 'abort') 
         msg = 'Ajax request aborted.'
      else 
         msg = 'Uncaught Error.\n' + jqXHR.responseText
      options = {
        title: 'Network Notification',
        text: "Can't send post request to #{ajaxSettings.url}.<br>Error:#{msg}",
        image: '/assets/icons/network-error.png'
      }
      request = new Request(ajaxSettings)
      @requetsqueue.push(request)
      CoffeeDesktop.notes.addnote(options)
    )

  fetch_app: (app) ->
    console.log("Fetching app " + app)
    $.get("/assets/"+app+".js")

  fetch_apps: ->
    apps = $.getJSON("/coffeedesktop/apps", (apps) =>
      apps.every (app) => 
        @fetch_app(app)
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

class UseCase
  constructor: (@storage,@gui) ->
    @desktop_objects =  @storage.getDesktopObjects()

  start: =>
    for desktop_object in @desktop_objects
      @gui.draw_desktop_object(
        desktop_object.fullname,
        desktop_object.icon,
        desktop_object.run,
        desktop_object.x,
        desktop_object.y,
        desktop_object.uuid,
        desktop_object.options
        )


  run_command: (app) =>

  add_to_desktop: (fullname,icon,run,x,y,uuid,options) ->
    desktop_object = new DesktopObject(fullname,icon,run,x,y,uuid,options)
    @desktop_objects.push(desktop_object)
    @storage.set('desktop_objects', @desktop_objects)

  remove_desktop_object: (uuid) ->
    for desktop_object in @desktop_objects
      if "#{desktop_object.uuid}" == "#{uuid}"
        @desktop_objects.remove(desktop_object)
    @storage.set('desktop_objects', @desktop_objects)

  desktop_object_move: (uuid,x,y) ->
    for desktop_object in @desktop_objects
      if "#{desktop_object.uuid}" == "#{uuid}"
        desktop_object.x = x
        desktop_object.y = y
    @storage.set('desktop_objects', @desktop_objects)



class Glue
  constructor: (@useCase, @gui, @storage,  @backend,@app)->
    Before(@useCase, 'start', => @gui.render_desk())
    Before(@app, 'app_add', (name,app,options) => @gui.dock_append(name,app,options))
    Before(@backend, 'fetch_app', (app) => @gui.log_fetch_app(app))
    Before(@gui, 'add_to_desktop', (fullname,icon,run,x,y,uuid,options) => @useCase.add_to_desktop(fullname,icon,run,x,y,uuid,options))
    Before(@gui, 'remove_desktop_object', (uuid) => @useCase.remove_desktop_object(uuid))

    After(@gui, 'desktop_object_move_sync', (id,x,y) => @useCase.desktop_object_move(id,x,y))
    After(@gui, 'render_desk', => @gui.show_loading())
    After(@gui, 'render_desk', => @gui.set_bindings())
    After(@useCase, 'start', => @backend.fetch_apps())
    After(@gui, 'run_command', (app) => @useCase.run_command(app))
    After(@useCase, 'run_command', => @gui.hide_run_dialog())
    After(@useCase, 'run_command', (app) => @app.app_run(app))
    After(@backend, 'fetch_apps', => @gui.hide_loading())

    LogAll(@useCase)
    LogAll(@gui)

class Gui
  constructor: (@templates) -> 

  show_loading: ->
    $("#loading_box").fadeIn()

  hide_loading: ->
    $("#loading_box").fadeOut()

  log_loading: (msg)->
    $("#loading_box").append("<li>"+msg+"</li>")

  log_fetch_app: (app) ->
    @log_loading("Fetching app: "+app)

  show_run_dialog: ->
    $("#run_dialog_form").fadeIn()
    $("#command").focus()

  hide_run_dialog: ->
    $("#run_dialog_form").fadeOut()

  run_command: (cmd) =>

  dock_start: ->
    $('#dock').jqDock(window.CoffeeDesktop.dock_settings)

  desktop_object_move: (e,ui) ->
    x=ui.position.left
    y= ui.position.top
    id = ui.helper[0].id.split("desktop_object_")[1]
    @desktop_object_move_sync(id,x,y)
    



  draw_desktop_object: (fullname,icon,run,x,y,uuid,options) ->
    options_html = false
    if options
      options_html =""
      options = eval("(#{options})");
      for option in Object.keys(options)
        options_html = options_html.concat(@templates.list_object(option.replace(/\s+/g, '_'),option))
      options_html= new Handlebars.SafeString(options_html)
    template = Handlebars.compile(@templates.desktop_object())
    data = {img: icon ,text:fullname, x:x, y:y, uuid:uuid, options:options_html}
    $(template(data)).appendTo("#desktop_icons").draggable({stop: (e,u) => @desktop_object_move(e,u)}).dblclick( => @run_command(run)).bind("contextmenu", -> $(@).find('.dropdown-menu').show(1,-> $(@).addClass('popup'));)
    if options
      #console.log options
      for option in Object.keys(options)
        $("#desktop_object_"+uuid+" .option_"+option.replace(/\s+/g, '_')).click(=> @run_command(options[option]))
    $("#desktop_object_"+uuid+" .run_app_link").click(=> @run_command(run))




    $("#desktop_object_"+uuid+" .remove_link").click(=> @remove_desktop_object(uuid))


  set_bindings: ->
    console.log("setting bindings")
    @log_loading("setting bindings")
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
        @add_to_desktop(fullname,icon,run,x,y,uuid,options)
      accept: ".i_wanna_be_a_desktop_object"
      })
    $(document).bind('keydown', 'alt+r', @show_run_dialog)
    $('#run_dialog_form').submit( () =>
      app =$("#command").val()
      $("#command").val("")
      @run_command(app)
      $('#command').blur()
      false
    )

  dock_append: (name,app,options) ->
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
      @run_command(name)
    )

  render_desk: ->
    window.oncontextmenu = => 
      $(".popup").hide().removeClass('popup')
      false
    window.onclick = =>
      $(".popup").hide().removeClass('popup')
    $(CoffeeDesktop_element).append(@templates.desktop())

  remove_desktop_object: (uuid) ->
    $("#desktop_object_"+uuid).remove()
  #aop shit
  desktop_object_move_sync: (id,x,y) ->
  add_to_desktop: (fullname,icon,run,x,y,uuid,options) ->
    @draw_desktop_object(fullname,icon,run,x,y,uuid,options)


class Notes
  constructor:  ->
    @notes = []


  addnote: (options) ->
      unique_id = $.gritter.add(options)



class @CoffeeDesktopApp
  state = "online"
  get_state: ->
    state
  set_state: (i) ->
    #0 online 1 offline
    if i
      state="offline"
    else
      state="online"

  app_add: (name,app,options) ->
    console.log("adding "+name)
    @app[name] = app
    @apps.add(name)

  app_run: (app) ->
    console.log("starting "+app)
    @process_id+=1
    if app.split(" ").length > 1
      console.log("oh cool we have some fucks to give")
      args = app.split(" ")
      name = args.shift()
      @process[@process_id] = new @app[name](@process_id,args)
    else
      @process[@process_id] = new @app[app](@process_id)

  constructor: (@element="body") ->
    @apps = new Array()
    @app = {}
    @process = {}
    @process_id = 0
    @dock_settings =   {labels: 'tc'}
    @notes = new Notes()
    templates    = new Templates()
    localStorage = new LocalStorage("CoffeeDesktop")
    gui          = new Gui(templates)
    useCase      = new UseCase(localStorage,gui)
    templates    = new Templates()
    
    

    @backend      = new Backend()
    glue         = new Glue(useCase, gui, localStorage, @backend,this)
    useCase.start()



jQuery.extend({
    CoffeeDesktop: CoffeeDesktopApp
  })