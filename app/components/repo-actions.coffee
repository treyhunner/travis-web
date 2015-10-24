`import Ember from 'ember'`

RepoActionsComponent = Ember.Component.extend(
  displayCodeClimate: (->
    @get('repo.githubLanguage') == 'Ruby'
  ).property('repo.githubLanguage')

  displayCodecov: (->
    @get('repo.githubLanguage') in ['Ruby', 'Python', 'Go', 'Java', 'PHP', 'Node.js', 'Scala', 'D', 'C']
  ).property('repo.githubLanguage')

  actions:
    codeClimatePopup: ->
      $('.popup').removeClass('display')
      $('#code-climate').addClass('display')
      return false

    codecovPopup: ->
      $('.popup').removeClass('display')
      language = @get('repo.githubLanguage')
      $codecov = $('#codecov')
      $codecov.addClass('display').find('.languages').hide()
      if language in ['Python', 'Go', 'Java', 'PHP', 'Node.js', 'Scala', 'D', 'C']
        link = 'https://github.com/codecov/example-' + language.toLowerCase()
        $codecov.find('#codecov-bash').show()
        $('#codecov-bash-link').attr('href', link).text(link)
      else
        $codecov.find('#codecov-'+language.toLowerCase()).show()
      return false
)

`export default RepoActionsComponent`
