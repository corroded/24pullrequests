class PullRequestDownloader
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def pull_requests
    @pull_requests ||= download_pull_requests
  end

  private
  def github_client
    @github_client ||= Octokit::Client.new(:login => user.nickname, :oauth_token => user.token, :auto_traversal => true)
  end

  def download_pull_requests
    begin
      events = github_client.user_events(user.nickname)
      events.select do |e| 
        event_date = DateTime.parse(e['created_at'])
        e.type == 'PullRequestEvent' && 
        e.payload.action == 'opened' &&
        event_date >= PullRequest::EARLIEST_PULL_DATE && 
        event_date <= PullRequest::LATEST_PULL_DATE
      end
    rescue
      puts 'likely a Github api error occured'
      []
    end
  end
end
