#Warning: This code contains ugly this
#Warning: You have been warned about this
#= require gui
#= require glue
#= require localstorage
#= require usecase

class Templates
  main: ->
    "<form id='nick_form'>
    <h2>Pusher Chat</h2><hr>
    Choose your nickname: <input type='text' id='nick'> <input type='submit'>
    </form>
   "
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

class LocalStorage extends @LocalStorageClass

class UseCase extends @UseCaseClass
  post_msg: (data) ->

  send_msg: (msg) ->
    @post_msg({'nick':@nick, 'msg',msg})

  start_chat: (@nick) ->
    @set_chat_in_window(@windows[0])

  set_chat_in_window: (window) ->

  new_msg:(data) ->
    @new_message_in_chat_window(@windows[0], data.nick, data.msg, data.date)

  new_message_in_chat_window: (window, nick, msg, date) ->

  bindings: ->
    @set_bindings(@windows[0])

  set_bindings: (window) ->

class Glue extends @GlueClass
  constructor:  (@useCase, @gui, @storage, @app, @templates, @backend,@pusher) ->
    super
    Before(@useCase, 'set_chat_in_window', (window) => @gui.set_chat_window_content(window,@templates.chat_window()))
    After(@gui, 'create_window', => @useCase.bindings())
    After(@useCase, 'set_bindings',(window) => @gui.set_bindings(window))
    After(@useCase, 'set_chat_in_window', (window) => @gui.set_chat_bindings(window))
    After(@gui, 'start_chat', (nick) => @useCase.start_chat(nick))
    After(@gui, 'send_msg', (msg) => @useCase.send_msg(msg))
    After(@useCase, 'post_msg', (data) => @backend.post_data(data))
    After(@pusher, 'update', (data) => @useCase.new_msg(data))
    After(@useCase, 'new_message_in_chat_window', (window, nick, msg,date) => @gui.append_msg(window, nick, msg,date))
#    LogAll(@useCase)
#    LogAll(@gui)

class Gui extends @GuiClass
  start_chat: (nick) ->

  set_chat_window_content: (window,template) ->
    $.updateWindowContent(window,template);

  send_msg: (msg) ->

  set_chat_bindings: (window) ->
    $("#"+window+" #msg_input").submit( () =>
      msg = $("#"+window+" #msg").val()
      @send_msg(msg)
      $("#"+window+" #msg").val("")
      false
    )

  set_bindings: (window) ->
    $("#"+ window+ " #nick_form").submit( () =>
      nick = $("#"+ window+ " #nick").val()
      @start_chat(nick)
      false
    )
  append_msg: (window, nick, msg, date) ->
    $("#"+ window+ " #chat").append("<span><b>"+nick+"</b>(@"+date+"): "+msg+"<hr>")

class PusherBindings 
  update: (data) ->

  constructor: (key) ->
    pusher = new Pusher(key);
    channel = pusher.subscribe('pusher_chat');
    channel.bind('data-changed', (data) =>
      #console.log(data)
      @update(data)
    )

class @PusherChatApp
  fullname = "Pusher Chat"
  description = "Pusher Chat"
  @fullname = fullname
  @description = description 
  constructor: (id) ->
    @id = id
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



