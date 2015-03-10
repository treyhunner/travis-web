`import Ember from 'ember'`
`import config from 'travis/config/environment'`

Controller = Ember.Controller.extend
  queryParams: ['org']
  filter: null
  org: null

  filteredRepositories: (->
    filter = @get('filter')
    model = @get('model')
    org = @get('org')

    if org
      model = model.filter (item, index) ->
        item.get('owner.login') == org

    if !Ember.isBlank(filter)
      model =model.filter (item, index) ->
        item.slug.match(new RegExp(filter))

    model
  ).property('filter', 'model', 'org')

  activeRepositories: Ember.computed.filterBy('filteredRepositories', 'active', true)
  inactiveRepositories: Ember.computed.filterBy('filteredRepositories', 'active', false)

  updateFilter: () ->
    value = @get('_lastFilterValue')
    @transitionToRoute queryParams: { filter: value }
    @set('filter', value)

  selectedOrg: (->
    @get('orgs').findBy('login', @get('org'))
  ).property('org', 'orgs.[]')

  orgs: (->
    orgs = Ember.ArrayProxy.create(
      content: []
      isLoading: true
    )

    apiEndpoint = config.apiEndpoint
    $.ajax(apiEndpoint + '/v3/orgs', {
      headers: {
        Authorization: 'token ' + @auth.token()
      }
    }).then (response) ->
      array = response.organizations.map( (org) ->
        Ember.Object.create(org)
      )
      orgs.set('content', array)
      orgs.set('isLoading', false)

    orgs
  ).property()

  actions:
    updateFilter: (value) ->
      @set('_lastFilterValue', value)
      Ember.run.throttle this, @updateFilter, [], 200, false

    selectOrg: (org) ->
      login = if org then org.get('login') else null
      @set('org', login)

`export default Controller`
