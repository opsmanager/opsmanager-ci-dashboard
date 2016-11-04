require 'base64'
require 'blanket'

freshdesk_token = ENV['FRESHDESK_TOKEN']

if freshdesk_token
  freshdesk_api = Blanket.wrap('https://opsmanager.freshdesk.com/api/v2', headers: {'Authorization' => "#{Base64.encode64(freshdesk_token+":X")}", 'Content-Type' => 'application/json' })
end

SCHEDULER.every '10m', first_in: 0 do
  if freshdesk_api
    begin
      tickets = freshdesk_api.tickets.get
      display_tickets = tickets.map do |ticket|
        { label: ticket.subject, value:  ticket.due_by }
      end

      send_event('freshdesk', { items: display_tickets })
    rescue e
      puts e.inspect
    end
  else
    puts 'Freshdesk api invalid'
  end
end
