#!/usr/bin/env ruby
#Takes CME output and groups based on hash for reuse identification
require 'pp'
require 'colorize'
require 'tty-prompt'

def read_cme_files
  sam_files = Dir.glob("/root/.cme/logs/*.sam")
end

def find_file_dates
  time_options = []
  read_cme_files.each do |file|
    unless time_options.include?(File.mtime(file).strftime("%d/%m/%Y"))
      time_options << File.mtime(file).strftime("%d/%m/%Y")
    end
  end
  time_options
end

def user_file_selection
  prompt  = TTY::Prompt.new
  @choices = prompt.multi_select("Which day's hashes shall we work with?", find_file_dates)
  @choices.uniq!
end

def remove_unwanted_dates
  @keepfiles = read_cme_files.keep_if { |file| @choices.any?(File.mtime(file).strftime("%d/%m/%Y"))}
end

def clean_hashes
  @hashes      = []
  @crackme     = []
  ipaddr_regex = /((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)/
  host_regex   = /(?:(?!_((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)).)*/
  @keepfiles.each do |file|
    ipaddr   = File.basename(file, ".*").match(ipaddr_regex).to_s
    hostname = File.basename(file, ".*").match(host_regex).to_s
    @hashes  << File.readlines(file).each {|line| line.prepend("#{ipaddr}:#{hostname}:")}
    @crackme << File.readlines(file).each {|line| line.prepend("#{ipaddr}_#{hostname}_")}
  end
  @hashes = @hashes.flatten.uniq
  @grouped_hashes = @hashes.group_by {|ele| ele.split(":")[5]}
end

def display_reuse
	group = 1
  puts "Reuse Identified For the Following Groups"
	@grouped_hashes.each do |k, v|
		if v.length > 1
		puts "GROUP: #{group}"
    puts "IP Address\tHostname\tUser"
	    v.each do |val|
	    	puts "#{val.split(":")[0]}\t#{val.split(":")[1]}\t#{val.split(":")[2]}"
	    end
	    group += 1
		end
	end
end

def write_hash_file
  filename = "hashes_#{Time.now.strftime("%d%b%Y_%H%M%S")}.txt"
  File.open(filename, 'w') { |f| f.puts(@crackme.join())}
  puts "Hashes written to #{filename}"
end

user_file_selection
remove_unwanted_dates
clean_hashes
display_reuse
write_hash_file