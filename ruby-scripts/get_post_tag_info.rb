
require 'sequel'

require_relative './get_list_of_packages.rb'

password = ENV['POSTGRESQL_PASSWORD']

DB = Sequel.connect("postgres://biostar:#{password}@localhost:6432/biostar")

posts_post = DB[:posts_post]
res = posts_post.select(:id, :tag_val).all

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

for pkg in pkgs
  if hsh.has_key? pkg.downcase
    num = hsh[pkg.downcase].length
  else
    num = 0
  end
  puts "#{pkg} has #{num} posts"
end