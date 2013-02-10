# use require to load any .js file available to the asset pipeline


#= require coffeedesktop

$ ->
    $.jStorage.flush()
	  

describe "CoffeeDesktop", ->

  #Testing if jasmine is ok ... don't look at me!!!
  it "Has to be absolute truth! ... NO EXCEPTIONS!!!11!", ->
  	expect(true).toEqual(true);

 #It's uncool that CoffeeDesktop done a lot of stuff on start and i can't test for example downloading apps
 #Meh ... i will fix it later
 #Todo ... make CoffeeDesktop not to load all stuff automagically at start


  window.CoffeeDesktop_element = "#coffeedesktop_sandbox";

  describe "Usecase"  , ->
    beforeEach ->
      stubMethod = (obj, method, fn = ((args...) =>)) ->
        obj[method] = fn
        spyOn(obj, method).andCallThrough()

      @fakeStorage = {}
      @fakeGui = {}
      stubMethod(@fakeStorage, 'getDesktopObjects',  => [])
      stubMethod(@fakeStorage, 'set', (args...) => )
      @usecase = new coffeedesktop.UseCase(@fakeStorage, @fakeGui)

    it "Fetch desktop objects", ->
      expect(@fakeStorage.getDesktopObjects).toHaveBeenCalled()   

    it "Desktop objects array should be empty", ->
      expect(@usecase.desktop_objects.length).toEqual(0)
      expect(@usecase.desktop_objects).toEqual([])

    it "Add to desktop should append object to array and update localstorage", ->
      @usecase.addToDesktop("test",'icon','test',100,50,'uuid','options')
      expect(@usecase.desktop_objects.length).toEqual(1)
      desktop_object = new coffeedesktop.DesktopObject("test",'icon','test',100,50,'uuid','options')
      expect(@fakeStorage.set).toHaveBeenCalledWith('desktop_objects', [desktop_object])

    it "Should remove desktop object", ->
      @usecase.addToDesktop("test",'icon','test',100,50,'uuid','options')
      @usecase.removeDesktopObject('uuid')
      expect(@usecase.desktop_objects.length).toEqual(0)
    
    it "Should remove good desktop object", ->
      @usecase.addToDesktop("test",'icon','test',100,50,'uuid1','options')
      @usecase.addToDesktop("test",'icon','test',100,50,'uuid2','options')
      @usecase.addToDesktop("test",'icon','test',100,50,'uuid3','options')
      @usecase.addToDesktop("test",'icon','test',100,50,'uuid4','options')
      expect(@usecase.desktop_objects.length).toEqual(4)
      expect(@usecase.desktop_objects[2].uuid).toEqual("uuid3")
      console.log @usecase.desktop_objects[2]
      @usecase.removeDesktopObject("uuid3")
      console.log @usecase.desktop_objects[2]
   #   expect(@usecase.desktop_objects[2].uuid).toEqual("uuid4")
    # expect(@usecase.desktop_objects.length).toEqual(3)

    it "Should move desktop object and update localstorage", ->
      @usecase.addToDesktop("test",'icon','test',100,50,'uuid1','options')
      desktop_object = @usecase.desktop_objects[0]
      expect(desktop_object.x).toEqual(100)
      expect(desktop_object.y).toEqual(50)
      @usecase.desktopObjectMove('uuid1', 200, 250)
      expect(@usecase.desktop_objects[0].x).toEqual(200)
      expect(@usecase.desktop_objects[0].y).toEqual(250)
      desktop_object.x =200
      desktop_object.y =250
      expect(@fakeStorage.set).toHaveBeenCalledWith('desktop_objects', [desktop_object])

  describe "Gui", ->

    beforeEach ->
      $("body").append("<div id='coffeedesktop_sandbox'></div>")
      @element = $(CoffeeDesktop_element)[0]
      @templates = new coffeedesktop.Templates()
      @gui = new coffeedesktop.Gui(@templates)
      @gui.renderDesk()

    afterEach ->
      $(@element).remove()

    it "Should render desktop", ->
      expect(@element.innerHTML).toContain("Loading CoffeeDesktop..")

    it "should show loading", ->
      expect($(@element).find("#loading_box")).toBeHidden()
      @gui.showLoading()
      expect($(@element).find("#loading_box")).toBeVisible()

    it "should hide loading", ->
      expect($(@element).find("#loading_box")).toBeHidden()
      @gui.showLoading()
      expect($(@element).find("#loading_box")).toBeVisible()
      @gui.hideLoading()
      expect($(@element).find("#loading_box").css('opacity')).toEqual('0')
    
    it "should append html to log", ->
        @gui.logLoading("This is random text")
        expect($(@element).find("#loading_box")[0].innerHTML).toContain("This is random text")

    it "should append log message about app", ->
        @gui.logFetchApp("APPNAME")
        expect($(@element).find("#loading_box")[0].innerHTML).toContain("Fetching app: APPNAME")        

    it "should show run dialog and set focus", ->
        expect($(@element).find("#run_dialog_form")).toBeHidden()
        @gui.showRunDialog()
        expect($(@element).find("#run_dialog_form")).toBeVisible()
        expect($(@element).find("#command")).toBeFocused()

    it "should hide run dialog", ->
        expect($(@element).find("#run_dialog_form")).toBeHidden()
        @gui.showRunDialog()
        expect($(@element).find("#run_dialog_form")).toBeVisible()
        @gui.hideRunDialog()
        expect($(@element).find("#run_dialog_form").css('opacity')).toEqual('0')

    it "should add desktop object", ->
        expect($(@element).find("#desktop_icons")[0].childElementCount).toEqual(0)
        @gui.drawDesktopObject("test",'test', (=>), 100,100,'uuid')
        expect($(@element).find("#desktop_icons")[0].childElementCount).toEqual(1)

    #Todo test desktop object options

    it "move desktop object", ->
        @gui.drawDesktopObject("test",'test', (=>), 100,100,'uuid')
        ui = {}
        desktop_object = $(@element).find("#desktop_object_uuid")[0]
        ui['position'] = {}
        ui['position']['left'] = 10
        ui['position']['top'] = 50
        ui['helper'] = [desktop_object]
        spyOn(@gui, 'desktopObjectMoveSync')
        @gui.desktopObjectMove(0,ui)
        expect(@gui.desktopObjectMoveSync).toHaveBeenCalledWith('uuid',10,50)


    it "should remove desktop object", ->
        @gui.drawDesktopObject("test",'test', (=>), 100,100,'uuid')
        expect($(@element).find("#desktop_object_uuid")[0]).toBeDefined()
        @gui.removeDesktopObject('uuid')
        expect($(@element).find("#desktop_object_uuid")[0]).toBeUndefined()

