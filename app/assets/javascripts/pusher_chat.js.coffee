#Warning: This code contains ugly this
#Warning: You have been warned about this
#= require gui
#= require glue
#= require localstorage
#= require usecase

fullname = "Pusher Chat"
description = "Pusher Chat"

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

  postData: (data) ->
    $.post("/coffeedesktop/pch_post", data );

class PusherAdapter 
  update: (data) ->
    #console.warn(data)

  constructor: (key) ->
    pusher = new Pusher(key);
    channel = pusher.subscribe('pusher_chat');
    channel.bind('data-changed', (data) =>
      #console.log(data)
      @update(data)
    )

class LocalStorage extends @LocalStorageClass

class UseCase extends @UseCaseClass
  constructor: (@gui, @backend) ->
    super

  sendMsg: (msg) ->
    @backend.postData({'nick':@nick, 'msg',msg})

  startChat: (@nick) ->
    @gui.setChatWindowContent()

  newMsgReceived:(data) -> 
    @gui.appendMsg(data.nick, data.msg, data.date)

class Glue extends @GlueClass
  constructor:  (@useCase, @gui, @storage, @app, @pusher) ->
    super
    After(@gui, 'startChat', (nick) => @useCase.startChat(nick))
    After(@gui, 'sendMsg', (msg) => @useCase.sendMsg(msg))
    After(@pusher, 'update', (data) => @useCase.newMsgReceived(data))
    #LogAll(@useCase)
    #LogAll(@gui)

class Gui extends @GuiClass
  setChatWindowContent: () ->
    $.updateWindowContent(@div_id, @templates.chat_window());
    @setChatBindings()

  setBindings: ->
    $("#"+ @div_id+ " #nick_form").submit( () =>
      nick = $("#"+ @div_id+ " #nick").val()
      @startChat(nick)
      false
    )

  setChatBindings: () ->
    msg_element = @element.find("#msg_input")
    msg_input = msg_element.find("#msg")
    msg_element.submit( () =>
      msg = msg_input.val()
      @sendMsg(msg)
      msg_input.val("")
      false
    )

  appendMsg: (nick, msg, date) ->
    $("#"+@div_id+ " #chat").append("<span><b>"+nick+"</b>(@"+date+"): "+msg+"<hr>")

  #aop shit
  sendMsg: (msg) ->
  startChat: (nick) ->


class @PusherChatApp
  @fullname = fullname
  @description = description 
  @icon = "xchat.png"
  constructor: (id) ->
    @id = id
    @fullname = fullname
    @description = description
    pusher       = new PusherAdapter('dc82e8733c54f74df8d3')
    templates    = new Templates()
    gui          = new Gui(templates)
    localStorage = new LocalStorage("CoffeeDesktop")
    backend      = new Backend()
    useCase      = new UseCase(gui, backend)
    #probably this under this line is temporary this because this isnt on the path of truth
    glue         = new Glue(useCase, gui, localStorage,@, pusher)
    #                                                  ^ this this is this ugly this

    useCase.start()

window.pusher_chat = {}
window.pusher_chat.UseCase = UseCase
window.pusher_chat.Gui = Gui
window.pusher_chat.Templates = Templates
window.pusher_chat.PusherChatApp = PusherChatApp


window.CoffeeDesktop.appAdd('pch',@PusherChatApp)