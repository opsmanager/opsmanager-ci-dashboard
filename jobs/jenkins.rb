def get_url(url, auth = nil)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  if uri.scheme == 'https'
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
  request = Net::HTTP::Get.new(uri.request_uri)

  if auth != nil then
    request.basic_auth *auth
  end

  response = http.request(request)
  return JSON.parse(response.body)
end

def get_jenkins_build_health(build_id)
  url = "http://opsci.opsmanager.com/job/opsmanager-fast/api/json?tree=builds[status,timestamp,id,result,duration,url,fullDisplayName]"
  auth = [ 'auth', 'pwd' ]

  build_info = get_url URI.encode(url), auth
  builds = build_info['builds']
  builds_with_status = builds.select { |build| !build['result'].nil? }
  successful_count = builds_with_status.count { |build| build['result'] == 'SUCCESS' }
  latest_build = builds_with_status.first
  return {
    name: latest_build['fullDisplayName'],
    status: latest_build['result'] == 'SUCCESS' ? SUCCESS : FAILED,
    duration: latest_build['duration'] / 1000,
    link: latest_build['url'],
    health: calculate_health(successful_count, builds_with_status.count),
    time: latest_build['timestamp']
  }
end

def calculate_health(successful_count, count)
  return (successful_count / count.to_f * 100).round
end

SCHEDULER.every '20s', first_in: 0 do
  send_event 'opsmanager-fast', get_jenkins_build_health('opsmanager-fast')
end
