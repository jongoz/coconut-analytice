_ = require 'underscore'
$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $

DataTables = require( 'datatables.net' )()
Reports = require '../models/Reports'
moment = require 'moment'
Graphs = require '../models/Graphs'

class YearlyTrendsView extends Backbone.View
  el: "#content"

  render: =>
    options = $.extend({},Coconut.router.reportViewOptions)
    HTMLHelpers.ChangeTitle("Reports: Yearly Trends")
    @$el.html "
       <div id='dateSelector'></div>
       <div class='mdl-cell mdl-cell--6-col mdl-cell--8-col-tablet'>
         <div id='chart_container_2' class='chart_container'>
           <div id='y_axis_2' class='y_axis'></div>
           <div id='chart_2' class='chart'></div>
         </div>
       </div>
       <div class='mdl-cell mdl-cell--6-col mdl-cell--4-col-tablet'></div>
    "
    $('#analysis-spinner').show()
    options.container = 'chart_container_2'
    options.y_axis = 'y_axis_2'
    options.chart = 'chart_2'
    Graphs.YearlyTrends options, (err, response) ->
      if (err) then console.log(err)
      $('#analysis-spinner').hide()
       
module.exports = YearlyTrendsView
