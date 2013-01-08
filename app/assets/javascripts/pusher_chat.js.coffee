#Warning: This code contains ugly this
#Warning: You have been warned about this 
class Templates
  main: ->
    "<form id='nick_form'>
    <h2>Pusher Chat</h2><hr>
    Choose your nickname: <input type='text' id='nick'> <input type='submit'>
    </form>
    <b>Warning</b>: Known bug. Try not to use 2 instances of Pusher chat"
  chat_window: ->
    "<table id='chat_window'>
    <tr><td class='pusher_chat_title'><h2>Pusher Chat</h2><hr style='margin-top: 0px;margin-bottom: -5px;'></td></tr>
    <tr><td><div id='chat'></div></td></tr>
    <tr><td class='msg_input_box'><hr style='margin-top: -5px;margin-bottom: 5px;'><form id='msg_input'>
    Msg:<input type='text' id='msg'><input type='submit'>
    </form>
    </td></tr>
    </table>"

class Backend 
  constructor: () ->

  post_data: (data) ->
    $.post("/desktopjs/pch_post", data );


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

  post_msg: (data) ->

  send_msg: (msg) ->
    @post_msg({'nick':@nick, 'msg',msg})

  start_chat: (@nick) ->

  constructor: ->
    
  start: =>
    

class Glue
  constructor: (@useCase, @gui, @storage, @app, @templates, @backend,@pusher)->
    Before(@useCase, 'start', => @gui.create_window(@app.fullname,"main",@templates.main(),@app)) #create main window
    

    After(@gui, 'create_window', => @gui.set_bindings())
    After(@gui, 'start_chat', => @gui.set_window_content('main',@templates.chat_window(),@app))
    After(@gui, 'start_chat', => @gui.set_chat_bindings())
    After(@gui, 'start_chat', (nick) => @useCase.start_chat(nick))
    After(@gui, 'send_msg', (msg) => @useCase.send_msg(msg))
    After(@useCase, 'post_msg', (data) => @backend.post_data(data))
    After(@pusher, 'update', (data) => @gui.append_msg(data))
    LogAll(@useCase)
    LogAll(@gui)

class Gui
  constructor: ->


  create_window: (title=false,id=false,template,app) =>
    rand=UUIDjs.randomUI48()
    id=UUIDjs.randomUI48() if !id #if undefined just throw sth random
    title = "You ARE LAZY" if !title #if undefined set sth stupid
    divid = id+"-"+rand
    app.windows[id] = divid
    $.newWindow({id:divid,title:title, width:640, height:400})
    $.updateWindowContent(divid,template);

  start_chat: (nick) ->


  set_window_content: (id,template,app) ->
    $.updateWindowContent(app.windows[id],template);

  send_msg: (msg) ->

  set_chat_bindings: ->
    $("#msg_input").submit( () =>
      msg = $("#msg").val()
      @send_msg(msg)
      $("#msg").val("")
      false
    )

  set_bindings: ->
    $("#nick_form").submit( () =>
      nick = $("#nick").val()
      @start_chat(nick)
      false
    )
  append_msg: (data) ->
    $("#chat").append("<span><b>"+data.nick+"</b>(@"+data.date+"): "+data.msg+"<hr>")


class PusherBindings 
  update: (data) ->

  constructor: (key) ->
    pusher = new Pusher(key);
    channel = pusher.subscribe('pusher_chat');
    channel.bind('data-changed', (data) =>
      console.log(data)
      @update(data)
    )


class @PusherChatApp
  fullname = "Pusher Chat"
  description = "Pusher Chat"
  @fullname = fullname
  @description = description 
  constructor: (id) ->
    @id = id
    @windows = {}
    @fullname = fullname
    @description = description
    pusher = new PusherBindings('dc82e8733c54f74df8d3')
    useCase      = new UseCase()
    gui          = new Gui()
    localStorage = new LocalStorage("desktopjs")
    templates    = new Templates()
    backend      = new Backend()
    #probably this under this line is temporary this because this isnt on the path of truth
    glue         = new Glue(useCase, gui, localStorage,this,templates,backend,pusher)
    #                                                  ^ this this is this ugly this

    useCase.start()

window.Desktopjs.app_add('pch',@PusherChatApp)



