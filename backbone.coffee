# Backbone.coffee 0.9.2

  root = @

  previousBackbone = root.Backbone

  # Create a local reference to slice/splice.
  slice = Array.prototype.slice
  splice = Array.prototype.splice

  # The top-level namespace. All public Backbone classes and modules will
  # be attached to this. Exported for both CommonJS and the browser.
  Backbone = if exports? then exports else root.Backbone = {}

  # Require Underscore, if we're on the server, and it's not already present.
  _ = if (!_ and require?) then require 'underscore' else root._

  # For Backbone's purposes, jQuery, Zepto, or Ender owns the `$` variable.
  $ = root.jQuery or root.Zepto or root.ender

  # Current version of the library. Keep in sync with `package.json`.
  Backbone.VERSION = '0.9.2'

  Backbone.setDomLibrary = (lib) -> $ = lib; return

  Backbone.noConflict =  () -> root.Backbone = previousBackbone; @

  ### Turn on `emulateHTTP` to support legacy HTTP servers. Setting this option
      will fake `"PUT"` and `"DELETE"` requests via the `_method` parameter and
      set a `X-Http-Method-Override` header.
  ###
  Backbone.emulateHTTP = false;

  ### Turn on `emulateJSON` to support legacy servers that can't deal with direct
     `application/json` requests ... will encode the body as
     `application/x-www-form-urlencoded` instead and will send the model in a
     form param named `model`.
  ###
  Backbone.emulateJSON = false;

  eventSplitter = /\s+/
  Events = Backbone.events =
    on: (events, callback, context) ->
        return @ if !callback
        events = events.split eventSplitter
        calls = if @._callbacks? then @._callbacks else @._callbacks = {}
        while event = events.shift()
          list = calls[event]
          node = if list then list.tail else {}
          node.next = tail = {}
          node.$prop = $prop for $prop in [context, callback]
          calls[event] =
            tail: tail
            next: if list then list.next else nod
        this

    off: (events, callback, context) ->
      return @ if !(calls = @._callbacks)
      unless events or callback or context
        delete @._callbacks
        @

      events = if events? then events.split eventSplitter else _.keys(calls)

      while event = events.shift()
        unless (list = calls[event] and (callback or context))
          delete calls[event]
          continue

      for i in [list.length - 2...0] by -2
        list.splice i, 2 unless (callback and list[i] isnt callback or 
                                   context and list[i + 1] isnt context)

      @

    trigger: (events) ->
      @ unless (calls = @._callbacks)

      rest = []
      events = events.split eventSplitter
      
  return
