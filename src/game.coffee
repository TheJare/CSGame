# CoffeeScript test
# (C) Copyright 2012 by Javier Arevalo

globalLayer = 0
minSize = 1

class Blob extends Go
	constructor: ->
		super
		@reset()
		return

	reset: ->
		@maxlife = RandomFloatRange 1, 8
		radius = minSize*RandomFloatRange 0.01, 0.10
		@color = RandomColor 0, 255, 100
		x = RandomIntRange 1, canvas.width-2
		y = RandomIntRange 1, canvas.height-2
		@rect = new Rect [x, y, x+radius*RandomFloatRange(0.1, 1), y+radius*RandomFloatRange(0.1, 1)]
		v = radius*RandomFloatRange(0.001, 0.1)
		a = RandomAngle()
		@vel = Vec2.FromAngLen a, v
		return

	tick: (t) ->
		super
		if @life >= @maxlife
			@kill()
		else
			@rect = @rect.translate @vel.x, @vel.y
			if (@vel.x > 0 and @rect.x1() >= canvas.width) or (@vel.x < 0 and @rect.x() <= 0)
				@vel.x = -@vel.x
			if (@vel.y > 0 and @rect.y1() >= canvas.height) or (@vel.y < 0 and @rect.y() <= 0)
				@vel.y = -@vel.y
		return

	born: ->
		@layer = globalLayer++
		super
		return

	die: ->
		super
		@container.creatego new Blob
		return

	render: (ctx) ->
		RenderRect ctx, @rect.x(), @rect.y(), @rect.w(), @rect.h(), @color
		return

canvas = ctx = null
blobs = null

tick = (elapsed, curTime) ->
	minSize = Math.min(canvas.width, canvas.height)
	blobs.tick elapsed

	RenderRect ctx, 0, 0, canvas.width, canvas.height, MakeColor 0,0,0,20
	blobs.render ctx
	return

window.addEventListener "load", () ->
	LOG "Starting up"
	[ctx, canvas] = SetupCanvas "uicontainer", "fullscreen", MakeColor 0,0,0 #255, 0, 255
	blobs = new GoContainer
	ui = new UIScreen
	ui.creatego new UITextButton "1", ctx, 100, 100, "Behind", "Times New Roman", [60, 80, 100], ["black", "red", "yellow"], (b) -> @text = "c #{b} #{ui.cursorx}, #{ui.cursory}"
	ui.creatego new UITextButton "2", ctx, 170, 130, "OnTop", "Arial", 60, ["black", "lightgreen", "white"], null, (b) -> @text = "h #{b} #{ui.cursorx}, #{ui.cursory}"
	blobs.creatego ui

	SetupUI canvas, ui

	tick()
	for i in [0...300]
		blobs.creatego new Blob
	Tick tick
	return
