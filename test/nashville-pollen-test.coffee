Helper = require('hubot-test-helper')
chai = require 'chai'
nock = require 'nock'

expect = chai.expect

helper = new Helper('../src/nashville-pollen.coffee')

# Alter time as test runs
originalDateNow = Date.now
mockDateNow = () ->
  return Date.parse('Thu Mar 30 2017 15:00:00 GMT-0600 (CST)')

describe 'nashville-pollen', ->
  beforeEach ->
    @room = helper.createRoom()
    Date.now = mockDateNow
    do nock.disableNetConnect

    nock('https://jasontan.org')
      .get('/api/pollen')
      .replyWithFile(200, __dirname + '/fixtures/pollen.json')

  afterEach ->
    @room.destroy()
    Date.now = originalDateNow
    nock.cleanAll()

  it 'returns the current pollen count in Nashville', (done) ->

    selfRoom = @room
    selfRoom.user.say('alice', '@hubot pollen')
    setTimeout(() ->
      try
        expect(selfRoom.messages).to.eql [
          ['alice', '@hubot pollen']
          ['hubot', 'Nashville Pollen: 10.5 (High) - Juniper, Maple, Pine (a day ago)']
        ]
        done()
      catch err
        done err
      return
    , 1000)
