class @GlueClass
  constructor: (@useCase, @gui, @storage, @app, @templates)->
    Before(@useCase, 'start', => @gui.create_window(@app.fullname,"main",@templates.main())) #create main window
    After(@gui, 'register_window', (id) => @useCase.register_window(id))
    After(@useCase, 'close_all_windows', (windows) -> @gui.close_windows(windows))
