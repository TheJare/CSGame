# Misc utils

@LOG = (a) -> console.log(if typeof a is "object" then JSON.stringify a else a); return
@MakeColor = (r,g,b,a) -> "rgba("+Math.floor(Clamp r, 0, 255) + "," + Math.floor(Clamp g, 0, 255)+","+Math.floor(Clamp b, 0, 255)+","+(if a? then a else "255") + ")"

@Pow2 = (v) -> v*v
@Lerp = (a,b,t) -> a+(b-a)*t
@Clamp = (v,a,b) -> if v<a then a else if v>b then b else v
@Wrap = (v,a,b) -> if v<a then (v+(b-a)) else if v>b then (v-(b-a)) else v
@RandomInt = (v) -> Math.floor Math.random()*v
@RandomIntRange = (a,b) -> Math.floor Math.random()*(b-a)+a
@RandomFloat = (v) -> Math.random()*v
@RandomFloatRange = (a,b) -> Math.random()*(b-a)+a
@RandomColor = (min, max, a) -> min ||= 0; max ||= 255; MakeColor RandomIntRange(min, max), RandomIntRange(min, max), RandomIntRange(min, max), a

@requestAnimationFrame ||= 
    window.webkitRequestAnimationFrame ||
    window.mozRequestAnimationFrame ||
    window.oRequestAnimationFrame ||
    window.msRequestAnimationFrame ||
    (callback, element) ->
        window.setTimeout callback, 1000 / 60

@SetupCanvas = (container, canvasclass, bgcolor) ->
	uicontainer = $ container
	uicontainer.css("background", bgcolor) if bgcolor
	canvas = document.createElement "canvas"
	$(canvas).addClass if canvasclass then canvasclass else "fullscreen"
	uicontainer.append(canvas)
	ctx = canvas.getContext "2d"

	rebuildCanvas = () ->
		canvas.width = uicontainer.width() #window.document.body.clientWidth
		canvas.height = uicontainer.height() #window.document.body.clientHeight
		return

	$(window.document).bind "touchmove", (e) -> e.preventDefault()
	$(window).resize rebuildCanvas
	$(window.document).bind "orientationChanged", (e) -> rebuildCanvas()
	rebuildCanvas()
	return [ctx, canvas]

curTime = lastTime = 0
@Tick = (tickf) ->
	timeNow = Date.now()
	elapsed = (timeNow - lastTime)*0.001
	if elapsed > 0
		curTime += elapsed
		if lastTime != 0
			# Cap max elapsed time to 1 second to avoid death spiral
			if elapsed > 1 then elapsed = 1
			tickf elapsed, curTime
		lastTime = timeNow

	requestAnimationFrame () -> Tick tickf
	return

@RenderCircle = (ctx, x, y, r, color) ->
	ctx.beginPath()
	ctx.arc x, y, r, 0, Math.PI*2, true
	ctx.fillStyle = color
	ctx.fill()
