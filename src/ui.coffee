# Simple UI widgets

class @UIWidget extends Go
    constructor: (@rect, @id) ->
        super
        @disabled = false
        @interactive = false
        @hovered = false
        @clicked = false
        @events = {}
        return

    hittest: (x,y) ->
        @rect.contains x, y

    hover: (b) ->
        @hovered = b
        @emit "hover", b
        return

    click: (b) ->
        @clicked = b
        @emit "click", b
        return

    on: (ev, cb) ->
        if ev not of @events
            @events[ev] = []
        @events[ev].push cb
        return

    off: (ev, cb) ->
        if not ev?
            @events = []
        else if ev of @events
            if cb?
                e = @events[ev]
                idx = 0
                while (idx = e.indexOf(cb, idx)) > 0
                    e.splice idx, 1
            else
                delete @events[ev]
        return

    emit: (ev) -> #, ..args...
        if ev of @events
            e = @events[ev]
            for cb in e
                cb.apply this, Array.prototype.slice.call(arguments, 1)
        return

class @UITextButton extends UIWidget
    constructor: (id, ctx, x, @y, @text, font, size, color) ->
        @color = color ? "white"
        @font = "#{ size }px " + font
        ctx.font = @font
        w = (ctx.measureText text).width
        h = size
        topy = y - size/1.2
        x -= w/2 # always centered
        super new Rect [x, topy, x+w, topy+h], id
        @interactive = true
        return

    render: (ctx) ->
        ctx.font = @font
        ctx.fillStyle = "#808"
        ctx.fillRect @rect.x(), @rect.y(), @rect.w(), @rect.h()
        if IsArray @color
            s = if @clicked then 2 else if @hovered then 1 else 0
            s = Clamp(s, 0, @color.length)
            ctx.fillStyle = @color[s]
        else
            ctx.fillStyle = @color
        ctx.fillText @text, @rect.x(), @y
        return

class @UIScreen extends GoContainer
    constructor: ->
        @cursorx = 0
        @cursory = 0
        @lasthover = null
        @lastclick = null
        super
        return

    findWidgetById: (id) ->
        for go in @gos
            if go.id == id
                return go
        for go in @newgos
            if go.id == id
                return go
        return null

    findWidgetAt: (x,y) ->
        # Call contained gos in descending order of layer they are in
        layers = (parseInt(k) for k,v of @layers)
        layers.sort()
        layers.reverse()
        for k in layers
            # Should optimize this to not traverse the entire @gos array
            for go in @gos
                if go.layer is k and go.interactive and not go.disabled
                    if go.hittest x, y
                        return go
        return null

    cursor: (x,y) ->
        prevWidget = @lasthover
        if x == false
            curWidget = null
        else
            @cursorx = x
            @cursory = y
            curWidget = @findWidgetAt x,y

        if prevWidget? and prevWidget != curWidget
            prevWidget.hover(false)
        if curWidget?
            curWidget.hover(true)
        @lasthover = curWidget
        return curWidget

    click: (x,y, b) ->
        prevWidget = @lastclick
        curWidget = @cursor x,y
        if prevWidget? and (not b or prevWidget != curWidget)
            prevWidget.click(false)
        if curWidget? and b
            curWidget.click(true)
        @lastclick = if b then curWidget else null
        return @lastclick


@SetupUI = (canvas, ui) ->
    cursorMoveFn = (x,y) ->
        [x,y] = ClientToCanvas canvas, x,y
        #but.text = "#{x}, #{y}"
        ui.cursor x,y
        return
    cursorClickFn = (x,y, b) ->
        [x,y] = ClientToCanvas canvas, x,y
        #but.text = "#{b}, #{x}, #{y}"
        ui.click x,y, b
        return

    if IsTouchDevice()
        canvas.addEventListener "touchmove", (e) -> cursorMoveFn e.changedTouches[0].pageX, e.changedTouches[0].pageY
        canvas.addEventListener "touchstart", (e) -> cursorClickFn e.changedTouches[0].pageX, e.changedTouches[0].pageY, true
        canvas.addEventListener "touchend", (e) ->
            cursorClickFn e.changedTouches[0].pageX, e.changedTouches[0].pageY, false
            ui.cursor false
    else
        canvas.addEventListener "mousemove", (e) -> cursorMoveFn e.clientX, e.clientY
        canvas.addEventListener "mousedown", (e) -> cursorClickFn e.clientX, e.clientY, true
        canvas.addEventListener "mouseup", (e) -> cursorClickFn e.clientX, e.clientY, false

