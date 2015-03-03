`import Ember from 'ember'`
`import config from 'travis/config/environment'`

Controller = Ember.Controller.extend
  queryParams: ['org']
  filter: null
  org: null

  filteredRepositories: (->
    filter = @get('filter')
    # repos = @get('model')
    org = @get('org')

    repos = Ember.ArrayProxy.create(
      active: []
      inactive: []
      isLoading: true
    )

    apiEndpoint = config.apiEndpoint
    $.ajax(apiEndpoint + '/v3/repos', {
      headers: {
        Authorization: 'token ' + @auth.token()
      }
    }).then (response) ->
      array = response.repositories.map( (repo) ->
        Ember.Object.create(repo)
      )

      if org
        array = array.filter (item, index) ->
          item.get('owner.login') == org

      if Ember.isBlank(filter)
        array
      else
        array.filter (item, index) ->
          item.slug.match(new RegExp(filter))

      repos.set('active', array.filter (item, index) ->
        item.active == true && item.last_build != null
      )
      repos.set('inactive', array.filter (item, index) ->
        item.active == false || item.last_build == null
      )
      repos.set('isLoading', false)

    repos

  ).property('filter', 'model', 'org')

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
