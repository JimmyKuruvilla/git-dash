# ## require 'pry'
##concurrency
##caching
##check if changed, header 304
##new widget to coorindate with IOS app
require 'octokit'
require 'yaml'

# # # Octokit.auto_paginate = true
  client = Octokit::Client.new(:access_token=>"e71797d2467099d04491afd5458d0deaa1a9af7c")
  user=client.user
  user.login

  pulls_hash ||=Hash.new { |h, k| h[k] = { } }
  forks_hash ||=Hash.new { |h, k| h[k] = { } }

  old_pulls_hash={}
  old_forks_hash={}
  run_count=0
  graph_hash={}
  # old_forks_data=[{x: 0, y:20}, {x:1, y: 60}]
  # old_pulls_data=[{x:0, y: (-20+16)}, {x:1, y: (-60+30)}]#-forks y+pulls y
  old_forks_data=[{x: 0, y: 0}, {x: 1, y: 0}]
  old_pulls_data=[{x: 0, y: 0}, {x: 1, y: 0}]
  pulls_msg_data=[]
  yf0,yf1, tnum1, tnum2=0,0,0,0
  yp0, yp1=-42,-42


SCHEDULER.every '3s' do
  demo=false
  run_count+=1
  if !demo
    graph_counter=0

    pulls_count=0
    forks_data=[]
    pulls_data=[]
    
    if run_count>1#create a baseline first, then start comparing. 
      old_pulls_hash=YAML.load(File.read("/home/j/dev/git-dash/pulls_hash"))
      old_forks_hash = YAML.load(File.read("/home/j/dev/git-dash/forks_hash"))
    end

    pulls_changes_hash=Hash.new { |h, k| h[k] = { } }#clears changes every loop
    forks_changes_hash=Hash.new { |h, k| h[k] = { } }
    repositories=[client.repo("flatiron-school-ironboard/rails-blog-sessions-ruby-006")]
    repositories<<client.repo("flatiron-school-ironboard/intro-to-js-and-jasmine-ruby-006")
    # repositories ||=client.org_repos("flatiron-school-ironboard")

    repositories.each do |repo|
        forks_hash[repo.full_name][:forks_count]=repo[:forks_count]
        forks_hash[repo.full_name][:html_url]=repo[:html_url]
        # {"flatiron-school-ironboard/rails-blog-sessions-ruby-006"=>{:forks_count=>23}}

        client.pulls(repo.full_name).each do |pull|
          pulls_hash[pull.html_url][:name]=pull[:user][:login]
          pulls_hash[pull.html_url][:created_at]=pull[:created_at]
          pulls_hash[pull.html_url][:title]=pull[:title]
          pulls_hash[pull.html_url][:html_url]=pull[:html_url].match(/(.*)\/pull/)[1]##to drop the /pull/18 bit
        end
      # {"https://github.com/flatiron-school-ironboard/rails-blog-sessions-ruby-006/pull/14"=>{:name=>"samvantran", :created_at=>2014-11-08 20:14:28 UTC, :title=>"all systems go"}
      end

      ##compare and retrieve changes
      if run_count>1
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
      end

    # {"flatiron-school-ironboard/rails-blog-sessions-ruby-006"=>{:forks_count=>25}}

    #persist data betwen loops. Wierd errors with using variables, probaby due data referencing API instead of being stored locally. 
    File.open("/home/j/dev/git-dash/pulls_hash", 'w') {|f| f.write(YAML.dump(pulls_hash)) }
    File.open("/home/j/dev/git-dash/forks_hash", 'w') {|f| f.write(YAML.dump(forks_hash)) }

  #check for changes, and add to graph data and graph lookup hash if present
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
      graph_key=key.match(/https.*ironboard\/(.*)\/pull\//)[1]
      pulls_count=key.match(/.+\/(.+)/)[1].to_i
      if graph_hash.has_key?(formatted_key)#match the fork key from the pull key
        pulls_data<< {x: graph_hash[formatted_key].to_i , y: pulls_count }
        pulls_msg_data<<{label: value_hash[:name]+" finished: ", value: graph_key +" and said: "+ value_hash[:title]}
      else#this should not happen normally, only for testing
        pulls_data<< {x: graph_counter , y: pulls_count }
        pulls_msg_data<<{label: value_hash[:name]+" finished: ", value: graph_key +" and said: "+ value_hash[:title]}
        graph_hash[formatted_key]=graph_counter
        graph_counter+=1
      end
    end

  else#demo code
    max=42
    tnum1+=5
    tnum2+=5

    yf0+=5
    if yf0>=42
      yf0=42
    end

    if yf0==42
      yp0+=5
      if yp0>=0
        yp0=0
      end
    end

    if yp0>-30
      yf1+=5
      if yf1>=42
        yf1=42
      end
    end

    if yf1==42
      yp1+=5
      if yp1>=0
        yp1=0
      end
    end

    
    forks_data=[{x: 0, y: yf0}, {x:1, y: yf1}]
    pulls_data=[{x:0, y: yp0}, {x:1, y: yp1}]

    names=["fkenji", "thinhthinh", "molgin", "strohy1210", "amshane", "jmoses89", "karimbutt", "daniellecs", "Sailorflares", "samvantran", "changamanda"]
    repos=["rails-blog-sessions-ruby-006","intro-to-js-and-jasmine-ruby-006"]
    said=["dominated", "rails rails rails", "finally done!", "DONE", "completed testing", "made tests pass", "st paddy's day parade"]
    if run_count%4==0
      pulls_msg_data<<{label: (names.sample + " finished: "), value: (repos.sample + " and said: "+ said.sample)}
    end
    
  end#end if block for demos
 
 #sort forks and pulls by x ORDER to avoid halts
    forks_data=forks_data.sort_by {|h| h[:x]}
    pulls_data=pulls_data.sort_by {|h| h[:x]}

#checks to see if pulls/forks has changed, correctly associates it in the graph data, and adjusts the bar chart from stacking to overlapping
  if forks_data!=[]
    forks_data.each do |item|
      old_forks_data[item[:x]]=item
    end
  end

  if pulls_data!=[]
    pulls_data.each do |item|
      old_pulls_data[item[:x]]={:x=>item[:x], :y=>(-1*old_forks_data[item[:x]][:y])+item[:y]}
    end
  end

  send_event('pullrequests', { items: pulls_msg_data })
  send_event('photo', { items: pulls_msg_data })
# always display old data if there is no new data
  if forks_data==[] && pulls_data==[]
    send_event('labs', forks: old_forks_data, pulls: old_pulls_data)
     # p "C1 forks_data #{forks_data}"
     # p "C1 old-forks_data #{old_forks_data}"
  elsif forks_data==[]
    send_event('labs', forks: old_forks_data, pulls: pulls_data)
     # p "C2 forks_data #{forks_data}"
  elsif pulls_data==[]
    send_event('labs', forks: forks_data, pulls: old_pulls_data)
     # p "C3 forks_data #{forks_data}"
  else
    send_event('labs', forks: forks_data, pulls: pulls_data)
     # p "C4 forks_data #{forks_data}"
  end

  p "forks_data #{forks_data}"
  p "forks_changes #{forks_changes_hash}"
  p "pulls_data #{pulls_data}"
  p "pulls_changes #{pulls_changes_hash}"
  p "pulls_msg_data #{pulls_msg_data}"
  p "old_forks_data #{old_forks_data}"
  p "old_pulls_data #{old_pulls_data}"
  p "graph_hash #{graph_hash}"
##caching
##check if changed, he
  p "run_count #{run_count}"
  p client.rate_limit.remaining
end#scheduler end
