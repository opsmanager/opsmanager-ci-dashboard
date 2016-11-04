SUCCESS = 'Successful'
FAILED = 'Failed'

def get_jenkins_build_health(build)
  url = "#{build['url']}/api/json?tree=builds[status,timestamp,id,result,duration,url,fullDisplayName]"
  build_info = Jenkins.get_url URI.encode(url), Jenkins.get_auth
  builds = build_info['builds']
  builds_with_status = builds.select { |build| !build['result'].nil? }
  successful_count = builds_with_status.count { |build| build['result'] == 'SUCCESS' }
  latest_build = builds_with_status.first

  {
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
  Jenkins.get_jobs_list.each do |build|
    send_event build['name'], get_jenkins_build_health(build)
  end
end
