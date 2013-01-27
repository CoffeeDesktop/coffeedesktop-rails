#Warning: This code contains ugly this
#Warning: You have been warned about this 
#= require gui
#= require glue
#= require localstorage
#= require usecase

class Templates
  main: ->
    "<div id='tabs'>
  <ul>
    <li><a href='#tabs-1'>About</a></li>
    <li><a href='#tabs-2'>Desktop Icons</a></li>
    <li><a href='#tabs-3'>Notifications</a></li>
  </ul>
  <div id='tabs-1'>
    <p>Hi, Welcome to sample application.</p>
    <p>You can find here some examples what you can do with CoffeeDesktop!</p>
    <p>Checkout other tabs!... NOW!</p>
    <p>shoo...shoo go to other tabs and checkout cool features!</p>
    </div>
  <div id='tabs-2'>
    <p>You can create awesome links with coffeedesktop ... just put objects in cart</p>
    <p>This is example:</p>
    <img src='/assets/icons/app.png' desktop_object_options='' desktop_object_run='sa link' desktop_object_fullname='SA Show hidden' desktop_object_icon='app.png' class=' i_wanna_be_a_desktop_object sa_drag_button'>DRAG THIS ON DESKTOP PLIZ
  </div>
  <div id='tabs-3'>
    <p>You can do shiny awesome notifications with CoffeeDesktop... just puting json to CoffeeDesktop.notes.add(json) and have fun
    <p style='text-align:center'><button class='notify_try_button'>TRY ME</button></p>
    <p>Also there is notifications about network errors</p>
    <p style='text-align:center'><button class='notify_error_try_button'>Send Something stupid</button></p>

   
  </div>
</div>"
  secret: ->
    "YAY ... you just found secret link
    <img src='http://25.media.tumblr.com/tumblr_m9a3bqANob1retw4jo1_500.gif'>"
  link: ->
    "Yay you are amazing... you just tested creating desktop icons
    <img src='http://images.wikia.com/creepypasta/images/3/38/Adventure-time-with-finn-and-jake.jpg'>"

class Backend 
  constructor: () ->

  stupid_post:  ->
      console.log "dupa"
      $.post("/coffeedesktop/stupid_post" );

class LocalStorage extends @LocalStorageClass

class UseCase extends @UseCaseClass
    constructor: (@gui) ->
      

    start: (args) =>
      switch 
        when /secret/i.test(args)
          options = {
            title: 'Secret undiscovered',
            text: 'Someone here discover secret! :D<br>
            He or She must love adventures!',
            image: 'http://img-cache.cdn.gaiaonline.com/cfc29eb51f1f53134577339fb5af37e9/http://i1063.photobucket.com/albums/t501/TedBenic/Icons/Avatars/CAR_ATM_FINN2.jpg'
          }
          CoffeeDesktop.notes.addnote(options)
          @gui.create_window("Sample Application (secret)","secret")
        when /link/i.test(args)
          @gui.create_window("Sample Application link","link")
        else
          @gui.create_window("Sample Application","main")

class Gui extends @GuiClass
  constructor: (@templates) -> 

  create_window: (title=false,template="main") =>
    rand=UUIDjs.randomUI48()
    id=UUIDjs.randomUI48() if !id #if undefined just throw sth random
    @div_id = id+"-"+rand
    $.newWindow({id:@div_id,title:title,width:500,height:350})
    $.updateWindowContent(@div_id,@templates[template]());
    @element = $("##{@div_id}")
    @set_bindings()

  set_bindings: ->
    $( "##{@div_id} #tabs" ).tabs()
    $( "##{@div_id} .sa_drag_button" ).button()
    $( "##{@div_id} .notify_try_button").click( =>
      options = {
        title: 'Woohoo! You did it!',
        text: 'You just clicked notification testing button!',
        image: 'http://24.media.tumblr.com/avatar_cebb9d5a6d1d_128.png'
      }
      CoffeeDesktop.notes.addnote(options)
      )
    $( "##{@div_id} .notify_error_try_button").click( => @sent_stupid_post())
    $( "##{@div_id} .sa_drag_button" ).draggable(
      helper: "clone",
      revert: "invalid",
      appendTo: 'body' 
      start: ->  
        $(this).css("z-index", 999999999)
    )

  sent_stupid_post: ->
    #aop event
    

class Glue extends @GlueClass
  constructor:  (@useCase, @gui, @storage, @app, @backend) ->
    After(@gui, 'register_window', (id) => @useCase.register_window(id))
    After(@useCase, 'close_all_windows', (windows) -> @gui.close_windows(windows))
    After(@gui, 'sent_stupid_post', => @backend.stupid_post()) # this is only once shortcut because it's stupid to do stupid post over usecase

#    LogAll(@useCase)
#    LogAll(@gui)

class @SampleApp
  fullname = "Sample Application"
  description = "Oh ... you just read app description."
  @fullname = fullname
  @description = description 
  constructor: (id, args) ->
    console.log("OH COOL ... I have just recived new shining fucks to take") if args
    @id = id
    @fullname = fullname
    @description = description

    templates    = new Templates()
    backend    = new Backend()
    gui          = new Gui(templates)
    useCase      = new UseCase(gui)


    localStorage = new LocalStorage("CoffeeDesktop")
    
    #probably this under this line is temporary this because this isnt on the path of truth
    glue         = new Glue(useCase, gui, localStorage,this,backend)
    #                                                  ^ this this is this ugly this

    useCase.start(args)

window.CoffeeDesktop.app_add('sa',@SampleApp, '{"Im not a secret button":"sa secret"}')