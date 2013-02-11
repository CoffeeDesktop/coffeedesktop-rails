#= require sa


describe "Sample Application", ->
	describe "Sample Application app", ->
		it "should have name", ->
			expect(sa.SampleApp.fullname).toBeDefined()
			expect(sa.SampleApp.fullname).not.toEqual("")

		it "should have description", ->
			expect(sa.SampleApp.description).toBeDefined()
			expect(sa.SampleApp.description).not.toEqual("")


		it "UseCase can be created", ->
			usecase = new sa.UseCase()
			expect(usecase).toBeDefined()
	describe "UseCase", ->
		beforeEach ->
			stubMethod = (obj, method) =>
				voidFn = ((args...) =>)
				obj[method] = voidFn
				spyOn(obj, method)

			@fakeGui = {}
			window.CoffeeDesktop = {}
			window.CoffeeDesktop.notes = {}
			stubMethod(@fakeGui, 'updateChild')
			stubMethod(@fakeGui, 'createWindow')
			stubMethod(CoffeeDesktop.notes , 'addNote')
			@usecase = new sa.UseCase(@fakeGui)
			@fakeGui['closeWindow'] = (window)=>
			      if (@usecase.windows.indexOf(window)) > -1
			        @usecase.windows.splice(@usecase.windows.indexOf(window), 1)

		it "Usecase should have empty windows array", ->
			expect(@usecase.windows.length).toEqual(0)

		it "registerWindow should append new window to windows array", ->
			expect(@usecase.windows.length).toEqual(0)
			@usecase.registerWindow("test-id")
			expect(@usecase.windows.length).toEqual(1)


		it "removeWindow should remove window from windows array", ->
			expect(@usecase.windows.length).toEqual(0)
			@usecase.registerWindow("test-id")
			@usecase.registerWindow("it_should_be_deleted")
			@usecase.registerWindow("test-izxcd")
			expect(@usecase.windows.length).toEqual(3)
			@usecase.removeWindow("it_should_be_deleted")
			expect(@usecase.windows.length).toEqual(2)
			expect(@usecase.windows).not.toMatch("it_should_be_deleted")

		it "updateFirstChildWindow should update first child", ->
			@usecase.registerWindow("test")
			@usecase.registerWindow("test_asd")
			@usecase.updateFirstChildWindow()
			expect(@fakeGui.updateChild).toHaveBeenCalledWith("test")

		it "closeAllChildWindows should tell gui to close all windows", ->
			@usecase.registerWindow("testa")
			@usecase.registerWindow("testb")
			@usecase.registerWindow("testc")
			@usecase.registerWindow("testd")
			@usecase.closeAllChildWindows() 

		it "start should have other contents with args", ->
			@usecase.start()
			expect(@fakeGui.createWindow).toHaveBeenCalledWith("Sample Application","main")
			@usecase.start('link')
			expect(@fakeGui.createWindow).toHaveBeenCalledWith("Sample Application link","link")
			@usecase.start('secret')
			expect(@fakeGui.createWindow).toHaveBeenCalledWith("Sample Application (secret)","secret")
			options = {
            title: 'Secret undiscovered',
            text: 'Someone here discover secret! :D<br>
            He or She must love adventures!',
            image: 'http://img-cache.cdn.gaiaonline.com/cfc29eb51f1f53134577339fb5af37e9/http://i1063.photobucket.com/albums/t501/TedBenic/Icons/Avatars/CAR_ATM_FINN2.jpg'
            }
			expect(CoffeeDesktop.notes.addNote).toHaveBeenCalledWith(options)


	describe "Gui", ->
		beforeEach ->
			@templates = new sa.Templates()
			@gui = new sa.Gui(@templates)
			@gui.createWindow('test', 'main')
			@window_element = $("##{@gui.div_id}")
			spyOn(@gui, "registerWindow")

		afterEach ->
			$("##{@gui.div_id}").remove()

				

		it 'creates main window', ->
			expect(@window_element).toBeVisible()

		it 'Should setbindings', ->
			expect(@window_element.find(".notify_try_button")).toHandle("click")
			expect(@window_element.find(".notify_error_try_button")).toHandle("click")
			expect(@window_element.find(".child_try_button")).toHandle("click")
			expect(@window_element.find(".close_all_childs_try_button")).toHandle("click")
			expect(@window_element.find(".update_first_child_try_button")).toHandle("click")


		it 'created child should have content' , ->
			@gui.openChildWindow()
			div_id = @gui.registerWindow.argsForCall
			window_element = $("##{div_id}")
			window_content = window_element.find(".window-content")
			expect(window_content[0].innerHTML).toContain("This is childwindow")
			$("##{div_id}").remove()

		it 'updateChild should change content and have bindings' , ->
			@gui.openChildWindow()
			div_id = @gui.registerWindow.argsForCall
			window_element = $("##{div_id}")
			window_content = window_element.find(".window-content")
			expect(window_content[0].innerHTML).toContain("This is childwindow")
			@gui.updateChild(div_id)
			expect(window_content[0].innerHTML).toContain("I WAS UPDATED!")
			expect(window_element.find(".updated_child_try_button")).toHandle("click")
			$("##{div_id}").remove()

		it 'closeWindow should close window and call callback' , ->
			runs ->
				spyOn(@gui, "removeWindow")
				@gui.openChildWindow()
				@div_id = @gui.registerWindow.argsForCall
				window_element = $("##{@div_id}")
				@gui.closeWindow(@div_id)
				expect(@gui.removeWindow).toHaveBeenCalledWith(@div_id)

			waitsFor (-> 
				$("##{@div_id}").length == 0
			),"The element won't ever be hidden", 10000

			runs ->
				expect($("##{@div_id}").length).toEqual(0)
			



			