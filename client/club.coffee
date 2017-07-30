includes = {}

escape = (text) ->
  text
    .replace /&/g, '&amp;'
    .replace /</g, '&lt;'
    .replace />/g, '&gt;'


load_sites = (uri) ->
  tuples = uri.split ' '
  while tuples.length
    site = tuples.shift()
    wiki.neighborhoodObject.registerNeighbor site

parse = ($item, item) ->
  roster = {all: []}
  category = null
  lineup = []
  marks = {}
  lines = []

  if $item?
    $item.addClass 'roster-source'
    $item.get(0).getRoster = -> roster

  more = item.text.split /\r?\n/

  flag = (site) ->
    roster.all.push site
    lineup.push site
    br = if lineup.length >= 18
      newline()
    else
      ''
    "<img class=\"remote\" src=\"//#{site}/favicon.png\" title=\"#{site}\" data-site=\"#{site}\" data-slug=\"welcome-visitors\">#{br}"

  newline = ->
    if lineup.length
      [sites, lineup] = [lineup, []]
      if category?
        roster[category] ||= []
        roster[category].push site for site in sites
      """ <a class='loadsites' href= "/#" data-sites="#{sites.join ' '}" title="add these #{sites.length} sites\nto neighborhood">»</a><br> """
    else
      "<br>"

  cat = (name) ->
    category = name

  includeRoster = (line, siteslug) ->
    if marks[siteslug]?
      return "<span>trouble looping #{siteslug}</span>"
    else
      marks[siteslug] = true
    if includes[siteslug]?
      [].unshift.apply more, includes[siteslug]
      ''
    else
      $.getJSON "http://#{siteslug}.json", (page) ->
        includes[siteslug] = ["<span>trouble loading #{siteslug}</span>"]
        for i in page.story
          if i.type is 'roster'
            includes[siteslug] = i.text.split /\r?\n/
            break
        $item.empty()
        emit $item, item
        bind $item, item
      "<span>loading #{siteslug}</span>"

  includeReferences = (line, siteslug) ->
    if includes[siteslug]?
      [].unshift.apply more, includes[siteslug]
      ''
    else
      $.getJSON "http://#{siteslug}.json", (page) ->
        includes[siteslug] = []
        for i in page.story
          if i.type is 'reference'
            includes[siteslug].push i.site if includes[siteslug].indexOf(i.site) < 0
        $item.empty()
        emit $item, item
        bind $item, item
      "<span>loading #{siteslug}</span>"

  includeJoin = (line) ->
    "<button>Join</button>"

  expand = (text) ->
    text
      .replace /^$/, newline
      .replace /^([a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+)(:\d+)?$/, flag
      .replace /^localhost(:\d+)?$/, flag
      .replace /^ROSTER ([A-Za-z0-9.-:]+\/[a-z0-9-]+)$/, includeRoster
      .replace /^REFERENCES ([A-Za-z0-9.-:]+\/[a-z0-9-]+)$/, includeReferences
      .replace /^JOIN\b.*$/, includeJoin
      .replace /^([^<].*)$/, cat

  while more.length
    lines.push expand more.shift()
  lines.push newline()
  lines.join ' '

emit = ($item, item) ->
  $item.append """
    <p style="background-color:#eee;padding:15px;">
      #{parse $item, item}
    </p>
  """

bind = ($item, item) ->
  $item.dblclick (e) ->
    if e.shiftKey
      wiki.dialog "Roster Categories", "<pre>#{JSON.stringify $item.get(0).getRoster(), null, 2}</pre>"
    else
      wiki.textEditor $item, item
  $item.find('.loadsites').click (e) ->
    e.preventDefault()
    e.stopPropagation()
    console.log 'roster sites', $(e.target).data('sites').split(' ')

window.plugins.club = {emit, bind} if window?
module.exports = {parse, includes} if module?

