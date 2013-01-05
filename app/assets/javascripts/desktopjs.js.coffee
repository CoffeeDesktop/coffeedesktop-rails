# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#= require jquery-1.8.3.min
#= require jquery.json-2.3.min
#= require jquery.windows-engine
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
  <form id='run_dialog_form'><input type='text' id='command'></form><div id='desktop_icons'></div></div>"



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
  constructor: (@useCase, @gui, @storage, @templates, @backend)->
    Before(@useCase, 'start', => @gui.render_desk(@templates.desktop))

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

  set_bindings: ->
    console.log("setting bindings")
    $(document).bind('keydown', 'alt+r', @show_run_dialog)
    $('#run_dialog_form').submit( () =>
      app =$("#command").val()
      $("#command").val("")
      @run_command(app)
      false
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
    useCase      = new UseCase()
    gui          = new Gui()
    localStorage = new LocalStorage("desktopjs")
    templates    = new Templates()
    backend      = new Backend()
    glue         = new Glue(useCase, gui, localStorage,templates, backend)
    useCase.start()



jQuery.extend({
    desktopjs: DesktopjsApp
  })