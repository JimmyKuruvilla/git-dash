require 'rss'

blogs = []
sampled_blog=[]

url_array=["http://catarak.github.io/atom.xml", "http://thinhthinh.github.io/atom.xml" ]
run_count=0


SCHEDULER.every '2s' do
  if url_array[run_count]==nil
  else
    url=url_array[run_count]
    if blogs.length>5
    blogs=[]
  end

  name=url.match(/.+\/\/(.+).github.io\//)[1]

  rss = RSS::Parser.parse((url), false)

  rss.entries.each do |entry|
    blogs<< {label:"#{name}: #{entry.title.content}", value:""}
  end

  sampled_blog=blogs.sample
  # blogs  = [{:label=>"Count", :value=>10}, { :label=>"Sort", :value=>30}]
  send_event('rss', { items: blogs})
  end

  
  run_count+=1
end

