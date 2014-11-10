class Timecard.Models.Workload extends Backbone.Model
  defaults:
    id: null
    start_at: new Date()
    end_at: null

  parse: (response) ->
    response.issue = new Timecard.Models.Issue(response.issue, parse: true)
    response.user = new Timecard.Models.User(response.user, parse: true)
    response.start_time = Util.formatTime(response.start_at)
    response.end_time = Util.formatTime(response.end_at)
    response.formatted_duration = Util.formatWorkHours(Date.parse(response.start_at), Date.parse(response.end_at))
    response

  duration: () ->
    @stopped_at_or_now() - @started_at()

  formatted_duration: ->
    hour = Math.floor(@duration()/(60*60*1000))
    duration = @duration()-(hour*60*60*1000)
    min = Math.floor(duration/(60*1000))
    duration = duration-(min*60*1000)
    sec = Math.floor(duration/1000)
    hour = "0" + hour if hour < 10
    min = "0" + min if min < 10
    sec = "0" + sec if sec < 10
    "#{hour}:#{min}:#{sec}"

  started_at: ->
    Date.parse(@get('start_at'))

  stopped_at_or_now: ->
    if @get('end_at')?
      Date.parse(@get('end_at'))
    else
      new Date()

  isStopped: ->
    @get('end_at')?
