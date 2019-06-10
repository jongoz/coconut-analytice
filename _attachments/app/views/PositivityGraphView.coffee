_ = require 'underscore'
$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $

Graphs = require '../models/Graphs'
moment = require 'moment'
dc = require 'dc'
d3 = require 'd3'
crossfilter = require 'crossfilter'

class PositivityGraphView extends Backbone.View
  el: "#content"

  render: =>
    options = $.extend({},Coconut.router.reportViewOptions)
    title= "Number of Persons Tested and Number Positive"
    HTMLHelpers.ChangeTitle("Graphs: " + title)
    @$el.html "
       <div id='dateSelector'></div>
       <div class='chart-title'>#{title}</div>
       <div id='chart_container_1' class='chart_container'>
         <div class='mdl-grid'>
           <div class='mdl-cell mdl-cell--12-col mdl-cell--8-col-tablet mdl-cell--4-col-phone'>
             <div id='errMsg'></div>
             <div id='chart'></div>
           </div>
         </div>
       </div>
    "
    HTMLHelpers.resizeChartContainer()
    $('#analysis-spinner').show()
    options.adjustX = 10
    options.adjustY = 40
    startDate = options.startDate
    endDate = options.endDate
    Coconut.reportingDatabase.query "caseCounter",
      startkey: [startDate]
      endkey: [endDate]
      reduce: true
      group: true
      include_docs: false
    .then (result) =>
      dataForGraph = result.rows
      composite = dc.compositeChart("#chart")
      Graphs.positivityCases(dataForGraph, composite, 'chart_container_1', options)

      window.onresize = () ->
        HTMLHelpers.resizeChartContainer()
        Graphs.compositeResize(composite, 'chart_container', options)
                  
      $('#analysis-spinner').hide()
    .catch (error) ->
      console.error error
      $('#errMsg').html("Sorry. Unable to complete due to an error: </br>"+error)
      $('#analysis-spinner').hide()

       
module.exports = PositivityGraphView
