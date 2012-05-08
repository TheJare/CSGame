# Iced CoffeeScript test
# (C) Copyright 2012 by Javier Arevalo

globalLayer = 0
minSize = 1

class Blob extends Go
	constructor: ->
		super
		@reset()

	reset: ->
		@maxlife = RandomFloatRange 0.1, 0.8
		@radius = minSize*RandomFloatRange 0.01, 0.10
		@color = RandomColor 0, 255, 0.2
		@pos = new Vec2 RandomInt(canvas.width), RandomInt(canvas.height)

	tick: (t) ->
		super
		@radius++
		if @life >= @maxlife
			@kill()

	born: ->
		@layer = globalLayer++
		super

	die: ->
		super
		@container.creatego new Blob

	render: (ctx) ->
		RenderCircle ctx, @pos.x, @pos.y, @radius, @color

canvas = ctx = null
blobs = new GoContainer

tick = (elapsed, curTime) ->
	minSize = Math.min(canvas.width, canvas.height)
	blobs.tick elapsed
	blobs.xform = (new Mat2).translate(canvas.width/2, canvas.height/2).scale(0.5, 0.5).rotate curTime*0.8
	blobs.render ctx

$ () ->
	LOG "Starting up"
	[ctx, canvas] = SetupCanvas "#uicontainer", "fullscreen", MakeColor 0,0,0 #255, 0, 255
	for i in [0...20]
		blobs.creatego new Blob
	Tick tick
	return
