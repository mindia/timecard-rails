class Timecard.Views.IssuesList extends Backbone.View

  template: JST['issues/list']

  el: '#issues'

  initialize: ->

  render: ->
    if @collection.length is 0
      @$el.append("<div class='media'><p>You don't have assigned issue.</p></div>")
    else
      @collection.each (issue) ->
        @addIssueView(issue)
      , @
    @
  
  addIssueView: (issue) ->
    @$el.append(new Timecard.Views.IssuesItem(model: issue).render().el)
