_ = require 'underscore'
$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $

moment = require 'moment'
global.Graphs = require '../models/Graphs'
DateSelectorView = require './DateSelectorView'
AdministrativeAreaSelectorView = require './AdministrativeAreaSelectorView'

camelize = require "underscore.string/camelize"


class DashboardView extends Backbone.View
  el: "#content"

  events:
    "click .moreInfo": "toggle"

  toggle: (event) =>
    @$(event.target).closest("div").next().toggle()

  render: =>

    # Always have at least 4 weeks of data, and start at beginning of week so it's comparable data
    if moment(@endDate).diff(@startDate, 'weeks') < 4
      @startDate = moment(@endDate).subtract(4, 'weeks').startOf("isoWeek").format("YYYY-MM-DD")
      @$("#dateDescription").html "
        Start date shifted to #{@startDate} (week #{moment(@startDate).isoWeek()}) to improve context.
      "
    else
      @$("#dateDescription").html()

    Coconut.router.navigate "dashboard/startDate/#{@startDate}/endDate/#{@endDate}/administrativeLevel/#{@administrativeLevel}/administrativeName/#{@administrativeName}"



    Coconut.statistics = Coconut.statistics || {}
    # $('#analysis-spinner').show()
    HTMLHelpers.ChangeTitle("muonekano-dashibodi")
    @$el.html "
        <style>
          .page-content {margin: 0}
          .chart {left: 0; padding: 5px}
          .chart_container {width: 100%}

        </style>
        <div id='dateSelector' style='display:inline-block'></div>
        <div id='dateDescription' style='display:inline-block;vertical-align:top;margin-top:10px'></div>
        <div id='administrativeAreaSelector'>
        </div>

        <dialog id='dialog'>
          <div id='dialogContent'> </div>
        </dialog>
        <div>
          <div class='moreInfo'>
            <i class='mdi mdi-play mdi-24px'></i>
            Indicators
          </div>
          <div style='display:none'>
            Alerts and Alarms show the epidemic thresholds, which are automatically checked every night.<br/>
          </div>
        </div>
        <div id='dashboard-summary'>
          <div class='sub-header-color relative clear'>
            #{
                (for chipData,index in [
                  class: "alertStat"
                  title: "alati"
                  icon: "mdi-bell-ring-outline"
                ,
                  class: "alarmStat"
                  title: "hatar"
                  icon: "mdi-bell-ring"
                ,
                  class: "notFollowedUp"
                  title: "hazijafuatiliwa"
                  icon: "mdi-account-location"
                ]
                  "
                    <div class='stat_summary'>
                      <a class='chip summary#{index+1}'>
                        <div class='summary_icon'>
                          <div><i class='mdi #{chipData.icon} mdi-24px white'></i></div>
                          <div class='stats' id='#{chipData.class}'></div>
                        </div>
                        <div class='stats-title'>#{chipData.title}</div>
                      </a>
                    </div>
                  "
                ).join("")
            }
          </div>
        </div>
        <div class='page-content'>
          <div class='mdl-grid'>
          #{
            (for title, graph of Graphs.definitions
              "
                <div class='chart mdl-cell mdl-cell--6-col mdl-cell--4-col-tablet mdl-cell--2-col-phone'>
                  <div id='container_#{index+1}' class='chart_container f-left'>
                    <div class='moreInfo'>
                      <i class='mdi mdi-play mdi-24px'></i>
                      #{title}
                    </div>
                    <div style='display:none'>
                      #{graph.description} 
                    <a href='#graph/type/#{camelize(title)}/startDate/#{@startDate}/endDate/#{@endDate}/administrativeLevel/#{@administrativeLevel}/administrativeName/#{@administrativeName}'>
                     Large version with more details
                    </a>
                      
                    </a>
                    </div>
                    <a href='#graph/type/#{camelize(title)}/startDate/#{@startDate}/endDate/#{@endDate}/administrativeLevel/#{@administrativeLevel}/administrativeName/#{@administrativeName}'>
                      <div>
                        <canvas id='#{camelize(title)}'></canvas>
                      </div>
                    </a>
                  </div>
                </div>
                #{
                  if index+1%2 is 0 # 2 graphs per row
                    "</div><div class='mdl-grid'>"
                  else
                    ""
                }
              "
            ).join("")
          }
        </div>
    "
    adjustButtonSize()

    @dateSelectorView or= new DateSelectorView()
    @dateSelectorView.setElement "#dateSelector"
    @dateSelectorView.startDate = @startDate
    @dateSelectorView.endDate = @endDate
    @dateSelectorView.onChange = (startDate, endDate) =>
      @startDate = startDate.format("YYYY-MM-DD")
      @endDate = endDate.format("YYYY-MM-DD")
      @render()
    @dateSelectorView.render()

    @administrativeAreaSelectorView or= new AdministrativeAreaSelectorView()
    @administrativeAreaSelectorView.setElement "#administrativeAreaSelector"
    @administrativeAreaSelectorView.administrativeLevel = @administrativeLevel
    @administrativeAreaSelectorView.administrativeName = @administrativeName
    @administrativeAreaSelectorView.onChange = (@administrativeName, @administrativeLevel) => @render()
    @administrativeAreaSelectorView.render()

    Coconut.administrativeAreaSelectorView or= new AdministrativeAreaSelectorView()

    @showGraphs()

  showGraphs: =>

    momentStartDate = moment(@startDate)
    momentEndDate = moment(@endDate)

    data = await Graphs.definitions["Positive Individuals by Year"].dataQuery
      startDate: momentStartDate
      endDate: momentEndDate
      administrativeLevel: @administrativeLevel
      administrativeName: @administrativeName

    Graphs.render("Positive Individuals by Year", data)


    @showOpdGraphs(momentStartDate, momentEndDate)
    @showCaseCounterGraphsAndIndicators(momentStartDate, momentEndDate)
    @renderAlertAlarmIndicators(momentStartDate, momentEndDate)

  showOpdGraphs: (momentStartDate, momentEndDate)=>
    # Get data 4 weeks before start date
    opdData = await Graphs.weeklyDataCounter
      startDate: momentStartDate
      endDate: momentEndDate
      administrativeLevel: @administrativeLevel
      administrativeName: @administrativeName

    Graphs.render("OPD Visits By Age", opdData)
    Graphs.render("OPD Testing and Positivity Rate", opdData)

  showCaseCounterGraphsAndIndicators: (momentStartDate, momentEndDate) =>

    data = await Graphs.caseCounter
      startDate: momentStartDate
      endDate: momentEndDate
      administrativeLevel: @administrativeLevel
      administrativeName: @administrativeName


    for graph in [
      "kulinganisha miaka"
      "Positive Individual Classifications"
      "Hours from Positive Test at Facility to Notification"
      "Hours From Positive Test To Complete Follow-up"
      "Household Testing and Positivity Rate"
    ]
      if data.length is 0
        canvas = document.getElementById("#{camelize(graph)}");
        ctx = canvas.getContext("2d");
        ctx.font = "20px Arial";
        ctx.fillText("No cases/data for area/dates", 10, 50);
      else
        Graphs.render(graph, data)

    @renderNotFollowedUpIndicator(data)

  renderNotFollowedUpIndicator: (dataByDate) =>
    notFollowedUp = 0
    hasNotification = 0
    for data in dataByDate
      if data.key[1] is "Complete Household Visit"
        notFollowedUp -= data.value
      if data.key[1] is "Has Notification"
        notFollowedUp += data.value
        hasNotification += data.value

    percentNotFollowedUp = Math.round(notFollowedUp/hasNotification*100)
    @$('#notFollowedUp').html "#{notFollowedUp} <small>(#{percentNotFollowedUp}%)</small>"

  renderAlertAlarmIndicators: (startDate, endDate) =>
    alerts = 0
    alarms = 0
    Coconut.database.query "alertAlarmCounter",
      startkey: [startDate,{}]
      endkey: [endDate,{}]
      reduce: true
      group: true
    .then (result) =>
      for result in result.rows
        alerts += result.value if result.key[1] is "Alert"
        alarms += result.value if result.key[1] is "Alarm"

      @$('#alertStat').html(alerts)
      @$('#alarmStat').html(alarms)


  adjustButtonSize = () ->
    noButtons = 8
    summaryWidth = $('#dashboard-summary').width()
    buttonWidth = (summaryWidth - 14)/noButtons
    $('.chip').width(buttonWidth-2)

module.exports = DashboardView
