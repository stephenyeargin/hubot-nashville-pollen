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
  api_url = 'https://jasontan.org/api/pollen'

  moment = require 'moment'

  # Use enhanced formatting?
  isSlack = robot.adapterName == 'slack'

  robot.respond /pollen/i, (msg) ->
    msg.http(api_url)
      .get() (err,res,body) ->
        result = JSON.parse(body)

        try
          if result.error
            msg.send result.error
          else
            default_message = "Nashville Pollen: " + result.count + " (" + result.level + ") - " + result.types
            if isSlack
              switch result.level
                when "Low" then level_color = '#1DA1F2' # Blue
                when "High" then level_color = '#de4407' # Red
                else level_color = '#088253' # Green

              payload = {
                attachments: [
                  {
                    fallback: default_message,
                    title: 'Nashville Pollen Forecast',
                    title_link: 'https://twitter.com/NashvillePollen',
                    thumb_url: 'https://pbs.twimg.com/profile_images/142534479/pollen.jpg',
                    author_name: '@NashvillePollen',
                    author_link: 'https://twitter.com/NashvillePollen',
                    author_icon: 'https://a.slack-edge.com/6e067/img/services/twitter_pixel_snapped_32.png',
                    footer: result.source,
                    color: level_color,
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
                    ts: moment(result.date).unix()
                  },
                ]
              }
              robot.logger.debug JSON.stringify(payload)
              msg.send payload
            else
              msg.send default_message

        catch error

          msg.send "Could not retrieve pollen data."
