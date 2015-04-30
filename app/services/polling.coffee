`import Ember from 'ember'`

service = Ember.Object.extend
  init: ->
    @_super.apply(this, arguments)

    @set('watchedModels', [])
    @set('sources', [])

    interval = setInterval =>
      @poll()
    , 30000

    @set('interval', interval)

  willDestroy: ->
    @_super.apply(this, arguments)

    clearInterval(@get('interval'))

  startPollingHook: (source) ->
    sources = @get('sources')
    unless sources.contains(source)
      sources.pushObject(source)

  stopPollingHook: (source) ->
    sources = @get('sources')
    sources.removeObject(source)

  startPolling: (model) ->
    watchedModels = @get('watchedModels')
    unless watchedModels.contains(model)
      watchedModels.pushObject(model)

  stopPolling: (model) ->
    watchedModels = @get('watchedModels')
    watchedModels.removeObject(model)

  poll: ->
    @get('watchedModels').forEach (model) ->
      model.reload()

    @get('sources').forEach (source) =>
      if source.get('destroyed')
        @get('sources').removeObject(source)
      else
        source.pollHook()

`export default service`