require 'http'
require 'json'
require 'eventmachine'
require 'faye/websocket'

# rc = HTTP.post('https://slack.com/api/api.test')

# rc = HTTP.post('https://slack.com/api/auth.test',
#   params: {
#     token: ENV['SLACK_API_TOKEN']
#   })

# rc = HTTP.post('https://slack.com/api/chat.postMessage',
#   params: {
#     token: ENV['SLACK_API_TOKEN'],
#     channel: '#general',
#     text: 'Hello world.',
#     as_user: true
#   })

# puts JSON.pretty_generate(JSON.parse(rc.body))


rc = HTTP.post('https://slack.com/api/rtm.start',
  params: {
    token: ENV['SLACK_API_TOKEN']
  }
)

rc = JSON.parse(rc.body)

puts rc['url']

EM.run do
  ws = Faye::WebSocket::Client.new(rc['url'])

  ws.on :open do
    p [:open]
  end

  ws.on :message do |event|
    data = JSON.parse(event.data)
    p [:message, data]
    if data['text'] == 'hi'
      ws.send(
        {
          type: 'message',
          text: "hi <@#{data['user']}>",
          channel: data['channel']
        }.to_json
      )
    end
    p [:message, JSON.parse(event.data)]
  end

  ws.on :close do |event|
    p [:close, event.code]
    ws = nil
    EM.stop
  end
end
