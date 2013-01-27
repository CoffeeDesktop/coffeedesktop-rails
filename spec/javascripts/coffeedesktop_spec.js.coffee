# use require to load any .js file available to the asset pipeline


#= require coffeedesktop
$ ->
	  $("body").append("<div id='coffeedesktop_sandbox'></div>");
describe "CoffeeDesktop", ->

  #Testing if jasmine is ok ... don't look at me
  it "Has to be absolute truth! ... NO EXCEPTIONS!!!11!", ->
  	expect(true).toEqual(true);


  window.CoffeeDesktop_element = "#coffeedesktop_sandbox";

  it "Has to start", ->
  	@CoffeeDesktop = new $.coffeedesktop();

  #It's uncool that CoffeeDesktop done a lot of stuff on start and i can't test for example downloading apps
  #Meh ... i will fix it later
  #Todo ... make CoffeeDesktop not to load all stuff automagically at start





