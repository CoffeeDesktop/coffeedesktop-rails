class @GlueClass
  constructor: (@useCase, @gui, @storage, @app)->
    Before(@useCase, 'start', => @gui.createWindow(@app.fullname,"main")) #create main window
    After(@gui, 'registerWindow', (id) => @useCase.registerWindow(id))
    After(@useCase, 'closeAllWindows', (windows) -> @gui.closeWindows(windows))
