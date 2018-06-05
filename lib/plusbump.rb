require "plusbump/version"
require 'semver'
require 'rugged'

module PlusBump
	def self.bump(ref, latest)
		# Note: If you are reading the above usage in the source code and not using --help,
		# then ignore the double escapes in the usage examples.
		# On the command line you have to write --majorpattern='\+major'
		# The extra escape is to make it print that way in the usage message.
		  #puts input
	  debug = false

	  # Defaults
	  major = /\+major/
	  minor = /\+minor/
	  patch = /\+patch/
	  base = '0.0.0'
	  prefix = ''

	  # Init Repo from current directory
	  repository = Rugged::Repository.new(Dir.pwd)
	  tagcollection = Rugged::TagCollection.new(repository)


	  w = Rugged::Walker.new(repository)
	  # Initialise the walker to start at current HEAD
	  head = repository.lookup(repository.head.target.oid)
	  w.push(head)

	  if latest.nil?
	    tail = repository.rev_parse(ref)
	    w.hide(tail)
	  else
	    candidates = []
	    puts "Searching for at tag that matches the glob pattern: " + latest if debug

	    tagcollection.each(latest+'*') do |tag|
	      unless repository.merge_base(tag.target, head).nil?
	        puts "Found matching tag on correct branch: " + tag.name if debug
	        candidates << tag
	      end
	    end

	    if candidates.empty?
	      puts "No matching tag found for "+latest
	    else
	      candidates.sort! {|a,b| a.target.time <=> b.target.time }
	      latest_match = candidates.last
	      puts "Newest matching tag: #{latest_match.target.oid}" if debug
	      #set target of matching commit as the tail of our walker
	      w.hide(latest_match.target)
	    end
	  end

	  # Handle X.Y.Z-SPECIAL by saving SPECIAL part for later
	  split = base.split('-')
	  v_number = split[0].split('.')
	  special = ''

	  #TODO: Above could probably be re-written to use the semver gem for parsing.

	  major_bump = false
	  minor_bump = false
	  patch_bump = false

	  #walk through all commits looking for version bump requests
	  w.each do |commit|
	    puts "Commit: " + commit.oid if debug
	    if major =~ commit.message
	      puts "bumps major" if debug
	      major_bump = true
	    elsif minor =~ commit.message
	      puts "bump minor" if debug
	      minor_bump = true
	    else
	      patch_bump = true
	    end
	  end

	  result = SemVer.new(v_number[0].to_i, v_number[1].to_i, v_number[2].to_i, special)

	  if major_bump
	    result.major += 1
	    result.minor = 0
	    result.patch = 0
	  elsif minor_bump
	    result.minor += 1
	    result.patch = 0
	  elsif patch_bump
	    result.patch += 1
	  else
	    puts "No version increment"
	  end

	  final_res = prefix + (result.format "%M.%m.%p%s")

	  return final_res
	end
end
