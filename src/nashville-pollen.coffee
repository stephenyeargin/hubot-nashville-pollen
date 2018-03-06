# Description
#   Get the latest pollen forecast from @NashvillePollen.
#
# Dependencies:
#   "moment"
#
# Configuration:
#   None
#
# Commands:
#   hubot pollen - Gets pollen status for Nashville, Tennessee
#
# Notes:
#   Uses the pollen forecast that powers https://twitter.com/NashvillePollen
#
# Author:
#   stephenyeargin
#   jt2k

module.exports = (robot) ->
  apiUrl = 'https://jasontan.org/api/pollen'
  defaultTimeString = ' 05:00:00-06:00'

  moment = require 'moment'

  # Use enhanced formatting?
  isSlack = robot.adapterName == 'slack'

  robot.respond /pollen/i, (msg) ->
    msg.http(apiUrl)
      .get() (err,res,body) ->
        result = JSON.parse(body)

        try
          if result.error
            msg.send result.error
          else
            defaultMessage = "Nashville Pollen: " + result.count + " (" + result.level + ") - " + result.types + " (" + moment(result.date + defaultTimeString).fromNow() + ")"
            if isSlack
              switch result.level
                when "Low" then levelColor = '#1DA1F2' # Blue
                when "High" then levelColor = '#de4407' # Red
                else levelColor = '#088253' # Green

              payload = {
                attachments: [
                  {
                    fallback: defaultMessage,
                    title: 'Nashville Pollen Forecast',
                    title_link: 'https://twitter.com/NashvillePollen',
                    thumb_url: 'https://pbs.twimg.com/profile_images/142534479/pollen.jpg',
                    author_name: '@NashvillePollen',
                    author_link: 'https://twitter.com/NashvillePollen',
                    author_icon: 'https://a.slack-edge.com/6e067/img/services/twitter_pixel_snapped_32.png',
                    footer: result.source,
                    color: levelColor,
                    fields: [
                      {
                        title: 'Level'
                        value: result.level,
                        short: true
                      },
                      {
                        title: 'Count'
                        value: result.count,
                        short: true
                      },
                      {
                        title: 'Types',
                        value: result.types,
                        short: true
                      }
                    ],
                    ts: moment(result.date + defaultTimeString).unix()
                  },
                ]
              }
              robot.logger.debug JSON.stringify(payload)
              msg.send payload
            else
              msg.send defaultMessage

        catch error
          robot.logger.error error
          msg.send "Could not retrieve pollen data."
