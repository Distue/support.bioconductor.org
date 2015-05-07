
require 'sequel'

require_relative './get_list_of_packages.rb'

password = ENV['POSTGRESQL_PASSWORD']

DB = Sequel.connect("postgres://biostar:#{password}@habu:5432/biostar")

posts_post = DB[:posts_post]


today = Date.today
now = DateTime.new(today.year, today.month, today.day)
sixmonthsago = now
months = [now]

6.times do
  tmp = sixmonthsago.prev_month
  months << tmp
  sixmonthsago = tmp
end
months.reverse!
ranges = []
for i in 0..(months.length()-2)
  ranges.push months[i]..months[i+1]  
end
new_range = ranges.last.first..ranges.last.last.next_day
ranges.pop
ranges.push new_range


res = posts_post.where("lastedit_date > ?", sixmonthsago).select(:id, :tag_val).all

require 'pry';binding.pry

hsh = Hash.new { |h, k| h[k] = [] }

for item in res
  id = item[:id].to_i
  tags = item[:tag_val].split(',')
  for tag in tags
    tag.strip!
    tag.downcase!
    hsh[tag] << id
  end
end

hsh.each_pair {|k,v| hsh[k] = v.sort.uniq}


pkgs = []

[true, false].each do |state|
  pkgs += get_list_of_packages(state)
end

output = {}

#def get_posts_in_last_six_months(ids)


for pkg in pkgs
  output[pkg] = {}
  if hsh.has_key? pkg.downcase
    num = hsh[pkg.downcase].length

  else
    num = 0
  end
  output[pkg][posts] = num
end