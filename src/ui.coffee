# Simple UI widgets

class @UIWidget extends Go
    constructor: (@id, @rect, clickfn, hoverfn) ->
        super
        @disabled = false
        @interactive = false
        @hovered = false
        @clicked = false
        @events = {}
        if clickfn?
            @on "click", clickfn
        if hoverfn?
            @on "hover", hoverfn
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
                eventcbs = @events[ev]
                idx = 0
                while (idx = eventcbs.indexOf(cb, idx)) > 0
                    eventcbs.splice idx, 1
            else
                delete @events[ev]
        return

    emit: (ev) -> #, ..args...
        if ev of @events
            eventcbs = @events[ev]
            for cb in eventcbs
                cb.apply this, Array.prototype.slice.call(arguments, 1)
        return

class @UITextButton extends UIWidget
    constructor: (id, ctx, @x, @y, @text, font, size, color, clickfn, hoverfn) ->
        @color = color ? "white"
        @font = if IsArray size then ("#{ s }px " + font for s in size) else ["#{ size }px " + font]
        maxSize = if IsArray size then size[size.length-1] else size
        ctx.font = @font[@font.length-1]
        w = (ctx.measureText text).width
        h = maxSize
        topy = y - maxSize/1.2
        leftx = x - w/2 # always centered
        super id, (new Rect [leftx, topy, leftx+w, topy+h]), clickfn, hoverfn
        @interactive = true
        return

    render: (ctx) ->
        ctx.fillStyle = "#808"
        ctx.fillRect @rect.x(), @rect.y(), @rect.w(), @rect.h()
        state = if @clicked then 2 else if @hovered then 1 else 0
        ctx.font = @font[Clamp(state, 0, @font.length)]
        ctx.fillStyle = if IsArray @color then @color[Clamp(state, 0, @color.length)] else @color
        ctx.textAlign = "center"
        ctx.fillText @text, @x, @y
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
        # Check layers from top to bottom
        layers.reverse()
        for k in layers
            # Should optimize this to not traverse the entire @gos array
            # Iterate array in reverse draw order
            i = @gos.length
            while go = @gos[--i]
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

