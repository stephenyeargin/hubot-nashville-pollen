Helper = require('hubot-test-helper')
chai = require 'chai'
nock = require 'nock'

expect = chai.expect

helper = new Helper('../src/nashville-pollen.coffee')

describe 'nashville-pollen', ->
  beforeEach ->
    @room = helper.createRoom()
    do nock.disableNetConnect

  afterEach ->
    @room.destroy()
    nock.cleanAll()

  it 'responds to pollen', (done) ->
    nock('https://jasontan.org')
      .get('/api/pollen')
      .replyWithFile(200, __dirname + '/fixtures/pollen.json')

    selfRoom = @room
    testPromise = new Promise (resolve, reject) ->
      selfRoom.user.say('alice', '@hubot pollen')
      setTimeout(() ->
        resolve()
      , 200)

    testPromise.then ((result) ->
      try
        expect(selfRoom.messages).to.eql [
          ['alice', '@hubot pollen']
          ['hubot',  'Nashville pollen level: 10.5 (High) - Juniper, Maple, Pine']
        ]
        done()
      catch err
        done err
      return
    ), done
