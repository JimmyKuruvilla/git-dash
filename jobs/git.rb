require 'octokit'
require 'yaml'
## require 'pry'
# # #SAWYER::RESOURCE to YAML and back doesn't work
# # ##remember to check the header and see if the data has changed since last time!
# # #problems:
# # #2 Concurrent requests will speed it up, Cached requests will minimize requests
# # #3. omniauth
# # # 4. DEPOLY TO HEROKU!!
###5. not using pull request user name or the commit title!

# # Octokit.auto_paginate = true
Octokit.configure do |c|
  c.login = 'jimmyjk@gmail.com'
  c.password = 't)b!ed0G'
end

  pulls_hash ||=Hash.new { |h, k| h[k] = { } }
  forks_hash ||=Hash.new { |h, k| h[k] = { } }

  old_pulls_hash={}
  old_forks_hash={}
  run_count=0
  graph_hash={}

SCHEDULER.every '5s' do
  run_count+=1
  graph_counter=0

  pulls_count=0
  forks_data=[]
  pulls_data=[]
  pulls_msg_data=[]


  if run_count!=1#create a baseline first, then start comparing. 
    old_pulls_hash=YAML.load(File.read("/home/j/dev/dash/pulls_hash"))
    old_forks_hash = YAML.load(File.read("/home/j/dev/dash/forks_hash"))
  end

  pulls_changes_hash=Hash.new { |h, k| h[k] = { } }#clears changes every loop
  forks_changes_hash=Hash.new { |h, k| h[k] = { } }
  # repositories=[Octokit.repo("flatiron-school-ironboard/project-euler-sum-square-difference-ruby-006")]
  repositories=[Octokit.repo("flatiron-school-ironboard/rails-blog-sessions-ruby-006")]
  # repositories ||=Octokit.org_repos("flatiron-school-ironboard")

  repositories.each do |repo|
      forks_hash[repo.full_name][:forks_count]=repo[:forks_count]
      forks_hash[repo.full_name][:html_url]=repo[:html_url]
      # {"flatiron-school-ironboard/rails-blog-sessions-ruby-006"=>{:forks_count=>23}}

      Octokit.pulls(repo.full_name).each do |pull|
        pulls_count+=1
        pulls_hash[pull.html_url][:name]=pull[:user][:login]
        pulls_hash[pull.html_url][:created_at]=pull[:created_at]
        pulls_hash[pull.html_url][:title]=pull[:title]
        pulls_hash[pull.html_url][:html_url]=pull[:html_url].match(/(.*)\/pull/)[1]##to drop the /pull/18 bit
     ##testing only
      pulls_msg_data<<{label: pull[:user][:login], value: pull[:title]}
      end
    # {"https://github.com/flatiron-school-ironboard/rails-blog-sessions-ruby-006/pull/14"=>{:name=>"samvantran", :created_at=>2014-11-08 20:14:28 UTC, :title=>"all systems go"}
    end

    ##compare and retrieve changes
  pulls_hash.keys.each do |new_pull_request_url|
    if !old_pulls_hash.has_key?(new_pull_request_url)
      pulls_changes_hash[new_pull_request_url]=pulls_hash[new_pull_request_url]
    end
  end

  old_forks_hash.each do |repo_full_name, old_value_hash|
    if old_value_hash[:forks_count]!=forks_hash[repo_full_name][:forks_count]
      forks_changes_hash[repo_full_name]=forks_hash[repo_full_name]
    end
  end
  # {"flatiron-school-ironboard/rails-blog-sessions-ruby-006"=>{:forks_count=>25}}

  #persist data betwen loops. Wierd errors with using variables, probaby due data referencing API instead of being stored locally. 
  File.open("/home/j/dev/dash/pulls_hash", 'w') {|f| f.write(YAML.dump(pulls_hash)) }
  File.open("/home/j/dev/dash/forks_hash", 'w') {|f| f.write(YAML.dump(forks_hash)) }#absolute path only? permissions erros?

#test this part better
  forks_changes_hash.each do |key, value_hash|
    if graph_hash.has_key?(key)
      forks_data<< {x: graph_hash[key].to_i, y: value_hash[:forks_count] }
    else#not forked yet
      forks_data<< {x: graph_counter, y: value_hash[:forks_count] }
      graph_hash[key]=graph_counter
      graph_counter+=1
    end
  end

  pulls_changes_hash.each do |key, value_hash|
    formatted_key=key.match(/https:\/\/github.com\/(.*)\/pull/)[1]
    if graph_hash.has_key?(formatted_key)#match the fork key from the pull key
      pulls_data<< {x: graph_hash[formatted_key].to_i , y: pulls_count }
      pulls_msg_data<<{label: value_hash[:name], value: value_hash[:title]}
    else#this should not happen normally, only for testing
      pulls_data<< {x: graph_counter , y: pulls_count }
      graph_hash[formatted_key]=graph_counter
      graph_counter+=1
    end
  end
 


  # pulls_msg_data<<{label: "Jimmy", value: "FINISHED the LAB!"}
  

  send_event('pullrequests', { items: pulls_msg_data })
# forks_data<<{x: 0 ,y: rand(10) }
# forks_data<<{x: 1 ,y: rand(10) }
# pulls_data<<{x: 0 ,y: rand(10) }
# pulls_data<<{x: 1 ,y: rand(10) }
  send_event('labs', forks: forks_data, pulls: pulls_data)


p forks_data
p pulls_data
  p graph_hash
    p "run_count #{run_count}"
    p Octokit.rate_limit.remaining
end#scheduler end



# # p Octokit.last_response.headers[:etag] # p Octokit.last_response #p Octokit.ratelimit_remaining   
# #https://github.com/bratsche/octokit
# #at 60 requests per minute, we will be under 5k/hr. If needed implement this :since business
# # gem 'octokit', :github => 'bratche/octokit'
# #https://coderwall.com/p/hu2n4g/how-to-make-conditional-requests-to-github-s-api-using-octokit
# # p Octokit.notifications({all: true, since: '2012-10-09T23:39:01Z'}) #Time.now.httpdate

