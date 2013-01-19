#= require pusher_chat


describe "Pusher_chat", ->
	describe "Pusher Chat app", ->
		it "should have name", ->
			expect(pusher_chat.PusherChatApp.fullname).toBeDefined()
			expect(pusher_chat.PusherChatApp.fullname).not.toEqual("")

		it "should have description", ->
			expect(pusher_chat.PusherChatApp.description).toBeDefined()
			expect(pusher_chat.PusherChatApp.description).not.toEqual("")


	it "UseCase can be created", ->
		usecase = new pusher_chat.UseCase()
		expect(usecase).toBeDefined()
	describe "UseCase", ->
		beforeEach ->
			stubMethod = (obj, method) =>
				voidFn = ((args...) =>)
				obj[method] = voidFn
				spyOn(obj, method)

			@fakeBackend = @fakeGui = {}
			stubMethod(@fakeBackend, 'post_data')
			stubMethod(@fakeGui, 'set_chat_window_content')
			stubMethod(@fakeGui, 'append_msg')

			@usecase = new pusher_chat.UseCase(@fakeGui, @fakeBackend)

		it "start_chat sets windows content", ->
			@usecase.start_chat("testUser")
			expect(@fakeGui.set_chat_window_content).toHaveBeenCalled()

		it "send_msg sends message", ->
			@usecase.start_chat("testUser")
			@usecase.send_msg("ohai")
			expect(@fakeBackend.post_data).toHaveBeenCalledWith({nick: 'testUser', msg: 'ohai'})

		it "new message is appended", ->
			@usecase.start_chat("testUser")
			@usecase.new_msg_received({nick: 'foo', msg: "hello", date: '123'})
			expect(@fakeGui.append_msg).toHaveBeenCalledWith('foo', 'hello', '123')

	describe "Gui", ->
		beforeEach ->
			@templates = new pusher_chat.Templates()
			@gui = new pusher_chat.Gui(@templates)
			@gui.create_window('test', 'main')
			@window_element = $("##{@gui.div_id}")

		afterEach ->
			$("##{@gui.div_id}").remove()

		it 'creates main window', ->
			expect(@window_element).toBeVisible()

		it 'Should setbindings', ->
			form = @window_element.find("form")
			expect(form).toHandle("submit")

		it 'should change window content' , ->
			window_content = @window_element.find(".window-content")
			@gui.set_chat_window_content()
			expect(@window_element.find("#chat_window")).toExist()

		it 'chat_window should have bindings' , ->
			window_content = @window_element.find(".window-content")
			@gui.set_chat_window_content()
			form = window_content.find("#msg_input")
			expect(form).toHandle("submit")



			