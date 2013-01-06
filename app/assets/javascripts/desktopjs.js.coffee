# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#= require jquery-1.8.3.min
#= require jquery.json-2.3.min
#= require jquery.windows-engine
#= require jquery.jqdock
#= require jquery.hotkeys
#= require uuid
#= require jstorage.min
#= require underscore
#= require sugar-1.3.min
#= require handlebars-1.0.0.beta.6
#= require YouAreDaBomb
#= require utils
class Templates
  constructor: ->
    @desktop ="<div id='desktop' class='container'>
  <form id='run_dialog_form'><input type='text' id='command'></form>
  <div id='desktop_icons'></div>
  <ul id='dock' style='display:none'>
  </ul>
    </div>"



class Backend
  #BACKEND DEVELOPER LOOK AT ME.... LOOK AT ME!
  constructor: ->

  fetch_apps: ->
    apps = $.getJSON("/desktopjs/apps", (apps) =>
      apps.every (app)-> 
        console.log("Fetching app " + app)
        $.get("/assets/"+app+".js")
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


class UseCase
  constructor: ->
    
  start: =>
    window.apps = new Array()

  fetch_apps: =>
    #/assets/sa.js
    $.get("/assets/sa.js");

  run_command: (app) =>
    window.Desktopjs.app_run(app)

class Glue
  constructor: (@useCase, @gui, @storage, @templates, @backend,@app)->
    Before(@useCase, 'start', => @gui.render_desk(@templates.desktop))
    Before(@app, 'app_add', (name,app) => @gui.dock_append(name,app))

    After(@gui, 'render_desk', => @gui.set_bindings())
    After(@useCase, 'start', => @backend.fetch_apps())
    After(@gui, 'run_command', (app) => @useCase.run_command(app))
    After(@useCase, 'run_command', => @gui.hide_run_dialog())

    LogAll(@useCase)
    LogAll(@gui)

class Gui
  constructor: ->

  show_run_dialog: ->
    $("#run_dialog_form").fadeIn()
    $("#command").focus()

  hide_run_dialog: ->
    $("#run_dialog_form").fadeOut()

  run_command: (cmd) =>

  dock_start: ->
    $('#dock').jqDock(window.Desktopjs.dock_settings)

  set_bindings: ->
    console.log("setting bindings")
    $(document).bind('keydown', 'alt+r', @show_run_dialog)
    $('#run_dialog_form').submit( () =>
      app =$("#command").val()
      $("#command").val("")
      @run_command(app)
      false
    )

  dock_append: (name,app) ->
    uuid = UUIDjs.randomUI48()
    icon = app.icon
    icon = "app.png" if !icon
    html = "<li><img id='app"+uuid+"' src='/assets/icons/"+icon+"' alt='"+app.fullname+"' title='"+app.fullname+"' class='dockItem' /></li>"
    $('#dock').jqDock('destroy')
    $('#dock').append(html)
    $('#dock').jqDock(window.Desktopjs.dock_settings);
    $("#app"+uuid).click(() =>
      @run_command(name)
    )

  render_desk: (template) ->
    $(Desktopjs_element).append(template)

  render_template: (element,template) ->
    $(element).append(template)


class @DesktopjsApp
  app_add: (name,app) ->
    console.log("adding "+name)
    @app[name] = app
    @apps.add(name)

  app_run: (app) ->
    console.log("starting "+app)
    @process_id+=1
    @process[@process_id] = new @app[app](@process_id)

  constructor: (element="body") ->
    @element = element
    @apps = new Array()
    @app = {}
    @process = {}
    @process_id = 0
    @dock_settings =   {labels: 'tc'}
    useCase      = new UseCase()
    gui          = new Gui()
    localStorage = new LocalStorage("desktopjs")
    templates    = new Templates()
    backend      = new Backend()
    glue         = new Glue(useCase, gui, localStorage,templates, backend,this)
    useCase.start()



jQuery.extend({
    desktopjs: DesktopjsApp
  })