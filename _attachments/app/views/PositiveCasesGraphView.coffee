_ = require 'underscore'
$ = require 'jquery'
Backbone = require 'backbone'
Backbone.$  = $

DataTables = require( 'datatables.net' )()
Reports = require '../models/Reports'
moment = require 'moment'
Graphs = require '../models/Graphs'

class PositiveCasesGraphView extends Backbone.View
  el: "#content"

  render: =>
    options = $.extend({},Coconut.router.reportViewOptions)
    @$el.html "
       <div id='dateSelector'></div>
       <div class='mdl-grid'>
         <div class='mdl-cell mdl-cell--12-col mdl-cell--8-col-tablet'>
           <div class='chart-title'>Number of Positive Malaria Cases</div>
           <div id='legend' class='f-right'></div>
           <div id='chart_container_1' class='chart_container'>
             <div id='y_axis_1' class='y_axis'></div>
             <div id='chart_1' class='chart'></div>
             
           </div>
         </div>
       </div>
    "

    $('#analysis-spinner').show()
    options.container = 'chart_container_1'
    options.y_axis = 'y_axis_1'
    options.chart = 'chart_1'
    options.couch_view = "positiveCases"
    options.name = 'Positive Cases'
    options.renderer = 'area'
    options.chart_width = 0.8 * $('.chart_container').width()
    Graphs.PositiveCasesGraph options, (err, response) ->
      if (err) then console.log(err)
      $('#analysis-spinner').hide()
       
module.exports = PositiveCasesGraphView
