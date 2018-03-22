#!/usr/bin/env ruby
#Takes CME output and groups based on hash for reuse identification
require 'pp'

cme_output   = File.readlines(ARGV[0])
cme_output   = cme_output.keep_if { |line| line.include?(":::") }
cme_output   = cme_output.delete_if { |line| line.include?("Guest")}
clean_hashes = []

cme_output.each { |line| clean_hashes << line.split(/[ ]{2,}/)[1..100]} #cant split like this, it breaks usernames with spaces
grouped_hashes = clean_hashes.group_by {|ele| ele[3].split(":")[3]}


count = 1
grouped_hashes.each do |k, v|
  if v.length > 1
    puts "GROUP: #{count}"
    puts "IP Address\tHostname\tUser"
    v.each do |val|
      user = val[3].split(":")[0]
      puts "#{val[0]}\t#{val[2]}\t#{user}"
    end
    puts "\r\n"
    count += 1
  end
end

puts "Hashes in clean format for cracking...."
clean_hashes.each {|hash| puts "#{hash[0]}_#{hash[1]}_#{hash[3]}"}
