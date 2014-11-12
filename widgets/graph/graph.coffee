
class Dashing.Graph extends Dashing.Widget

  @accessor 'current_forks', ->
    return @get('displayedValue_forks') if @get('displayedValue_forks')
    forks = @get('forks')
    if forks
      forks[forks.length - 1].y


  @accessor 'current_pulls', ->
    return @get('displayedValue_pulls') if @get('displayedValue_pulls')
    pulls = @get('pulls')
    if pulls
      pulls[pulls.length - 1].y


  ready: ->
    container = $(@node).parent()
    # Gross hacks. Let's fix this.
    width = (Dashing.widget_base_dimensions[0] * container.data("sizex")) + Dashing.widget_margins[0] * 2 * (container.data("sizex") - 1)
    height = (Dashing.widget_base_dimensions[1] * container.data("sizey")) + Dashing.widget_margins[1] * 2 * (container.data("sizey") - 1)
    @graph = new Rickshaw.Graph(
      element: @node
      width: width
      height: height
      renderer: 'bar'
      stroke: true
      series: [
        {
        name: "rails-blog-sessions-ruby-006",
        color: "Lime",
        data: [ { x: 0, y: 100 }, { x: 1, y: 100 }]
        },
        {
        name: "intro-to-js-and-jasmine-ruby-006",
        color: "Red",
        data: [ { x: 0, y: 100}, { x: 1, y: 100 }]
        }
      ]
    )

    @graph.series[0].data = @get('forks') if @get('forks')
    @graph.series[1].data = @get('pulls') if @get('pulls')


    legend=new Rickshaw.Graph.Legend( {
        element: document.querySelector('.legend'),
        graph: @graph
      } )

    
    y_axis = new Rickshaw.Graph.Axis.Y(graph: @graph, tickFormat: Rickshaw.Fixtures.Number.formatKMBT)

 
    @graph.render()

  onData: (data) ->

    if @graph 
      @graph.series[0].data = data.forks
      @graph.series[1].data = data.pulls
      @graph.render()
