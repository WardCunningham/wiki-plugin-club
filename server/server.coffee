# club plugin, server-side component
# These handlers are launched with the wiki server. 

startServer = (params) ->
  app = params.app
  argv = params.argv

  cors = (req, res, next) ->
    res.header("Access-Control-Allow-Origin", "*")
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept")
    next()

  app.post '/plugin/club/:slug/:id', cors, (req, res) ->
    console.log 'handle post'
    slug = req.params.slug
    id = req.params.id
    res.json {slug,id}

module.exports = {startServer}
