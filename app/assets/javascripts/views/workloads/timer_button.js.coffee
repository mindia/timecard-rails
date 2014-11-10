class Timecard.Views.WorkloadsTimerButton extends Backbone.View

  template: JST['workloads/timer_button']

  el: '.timer-button__container'

  events:
    'click .timer-button--start': 'start'
    'click .timer-button--stop': 'stop'

  initialize: (@options) ->
    @issue = @options.issue

  render: ->
    @$el.html(@template(issue: @issue))
    @

  start: (e) ->
    e.preventDefault()
    model = @collection.findWhere(end_at: null)
    if model?
      model.set('end_at', new Date())
      issue = @issue.collection.get(model.get('issue').id)
      if issue?
        issue.set('is_running', false)
      Timecard.timer.stop()
    @collection.create {start_at: new Date()},
      url: '/issues/'+@issue.id+'/workloads'
      success: (model) =>
        @viewTimerContainer = new Timecard.Views.TimerContainer(model: model, issues: @issue.collection)
        @viewTimerContainer.render()
        @issue.set('is_running', true)
        $('.timer').removeClass('timer--off')
        $('.timer').addClass('timer--on')

  stop: (e) ->
    e.preventDefault()
    if @issue.get('is_crowdworks') is true
      password = sessionStorage.getItem('crowdworks_password')
      if password?
        attrs = {end_at: new Date(), password: password}
        @update(attrs)
      else
        $('.crowdworks-form__modal').modal('show')
    else
      attrs = {end_at: new Date()}
      @update(attrs)

  update: (attrs) ->
    @collection.current_user = true
    @collection.fetch
      success: (collection) =>
        collection.current_user = false
        model = collection.findWhere(end_at: null)
        model.save attrs,
          patch: true
          success: (model) =>
            Timecard.timer.stop()
            @issue.set('is_running', false)
            $('.timer').removeClass('timer--on')
            $('.timer').addClass('timer--off')
