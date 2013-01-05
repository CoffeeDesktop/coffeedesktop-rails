# use require to load any .js file available to the asset pipeline


#= require desktopjs
$ ->
	  $("body").append("<div id='desktopjs_sandbox'></div>");
describe "Desktopjs", ->

  #Testing if jasmine is ok ... don't look at me
  it "Has to be absolute truth! ... NO EXCEPTIONS!!!11!", ->
  	expect(true).toEqual(true);


  window.Desktopjs_element = "#desktopjs_sandbox";

  it "Has to start", ->
  	@Desktopjs = new $.desktopjs();

  #It's uncool that Desktopjs done a lot of stuff on start and i can't test for example downloading apps
  #Meh ... i will fix it later
  #Todo ... make desktopjs not to load all stuff automagically at start





