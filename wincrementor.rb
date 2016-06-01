#!/usr/bin/env ruby
#encoding: utf-8
require 'docopt'
require 'semver'
require 'rugged'


doc = <<DOCOPT
Usage:
  #{__FILE__} [-t] [-p <prefix>] [-a <maj_p>] [-i <min_p>] <ref> [<semver_version_string>] 
  #{__FILE__} [-t] [-p <prefix>] [-a <maj_p>] [-i <min_p>] --latest=<tag-glob> [<semver_version_string>] 
  #{__FILE__} -h|--help

Options:
  -h --help        Show this screen.
  -t --tag-commit  Actually tag HEAD with the version number computed.
     
  -l --latest=<tag-glob>  

    Specify a glob pattern to search for last matching tag instead of
    providing a specific ref.
    Will attempt to use everything after <tag-glob> as the version string
    so be sure to provide _entire_ prefix. 
    E.g. use "R_" if your versions are "R_1.2.3"

  -p --prefix=<prefix>  

    Specify a prefix to add before the resulting version string

  -a --majorpattern=<major_pattern>

    Specify an alternative (regex) pattern that indicates a major version bump.
    E.g. --majorpattern='\\+major'
    
  -i --minorpattern=<minor_pattern>

    Specify an alternative (regex) pattern that indicates a minor version bump.
    E.g. --minorpattern='\\+minor'

DOCOPT

# Note: If you are reading the above usage in the source code and not using --help, 
# then ignore the double escapes in the usage examples. 
# On the command line you have to write --majorpattern='\+major'
# The extra escape is to make it print that way in the usage message.

begin

  # look at all commits between <ref> and HEAD. 
  # Look for commit-message mentions 
  # of +major or +minor (unless different patterns where specified ).
  # +patch is implicit as the default if none of the others where specified.
  
  # If a version string was speciefied
  # Bump the provided semver string correctly 
  # i.e. increase the highest bumped level, and reset those below to 0.
  # I am thinking that the bump should probably leave any part of semver
  # after '-'' intact (e.g. 1.3.14-alpha3+as34df32), 
  # but I reserve the right to change my mind on this :-D
  
  # If no version string was specified
  # bump the version 0.0.0, i.e. return either 1.0.0, 0.1.0 or 0.0.1
  # The last should probably be equivalent to just defaulting version_string 
  # to "0.0.0" if none was provided.

  input = Docopt::docopt(doc)

  #puts input 
  debug = false

  # Defaults
  major = /\+major/
  minor = /\+minor/
  patch = /\+patch/
  base = '0.0.0'
  prefix = ''

  if input['<semver_version_string>']
    base = input['<semver_version_string>']
  end

  unless input['--prefix'].nil?
    prefix = input['--prefix']
  end

  unless input['--majorpattern'].nil?
    majorpatternstring = input['--majorpattern']
    major = Regexp.new(majorpatternstring)
  end

  unless input['--minorpattern'].nil?
    majorpatternstring = input['--minorpattern']
    major = Regexp.new(majorpatternstring)
  end
  
  # Init Repo from current directory
  repository = Rugged::Repository.new(Dir.pwd) 
  tagcollection = Rugged::TagCollection.new(repository)


  w = Rugged::Walker.new(repository)
  # Initialise the walker to start at current HEAD
  head = repository.lookup(repository.head.target.oid)
  w.push(head)

  if input['--latest'].nil?
    tail = repository.rev_parse(input['<ref>'])
    w.hide(tail)
  else
    candidates = []
    tail_glob = input['--latest']
    
    puts "Searching for at tag that matches the glob pattern: " + tail_glob if debug

    tagcollection.each(tail_glob+'*') do |tag|
      unless repository.merge_base(tag.target, head).nil?
        puts "Found matching tag on correct branch: " + tag.name if debug
        candidates << tag
      end
    end
    candidates.sort! {|a,b| a.target.time <=> b.target.time }
    latest_match = candidates.last
    puts "Newest matching tag: #{latest_match.target.oid}" if debug
    #set target of matching commit as the tail of our walker
    w.hide(latest_match.target)

    #Use remainder of tag as the current semver version string
    base = latest_match.name.sub(tail_glob,'')
  end

  # Handle X.Y.Z-SPECIAL by saving SPECIAL part for later
  split = base.split('-')
  v_number = split[0].split('.')
  special = ''
  if (split[1])
    special = '-'+split[1]
  end

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

  if (input['--tag-commit'])
    repository.tags.create(final_res, 'HEAD', true)
    puts "created tag with name #{final_res}" if debug
  end

  puts final_res

rescue Docopt::Exit => e
  puts "Wincrementor 1.2"
  puts ""
  puts e.message
end
