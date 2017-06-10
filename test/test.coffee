# build time tests for club plugin
# see http://mochajs.org/

club = require '../client/club'
expect = require 'expect.js'

describe 'club plugin', ->

  describe 'expand', ->

    it 'can make itallic', ->
      result = club.expand 'hello *world*'
      expect(result).to.be 'hello <i>world</i>'
