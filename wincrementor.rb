#!/usr/bin/env ruby
#encoding: utf-8
require 'docopt'
require 'semver'
require 'rugged'

doc = <<DOCOPT
Usage:
  #{__FILE__} [--majorpattern=<major_pattern>] [--minorpattern=<minor_pattern>] [--tag-commit] (--latest=<tag-glob> | <ref>)  [<semver_version_string>] [--prefix=<prefix>]
  #{__FILE__} -h|--help

Options:
  -h --help
             
    Show this screen.
     
  --majorpattern=<major_pattern>
    
  --minorpattern=<minor_pattern>

  --tag-commit

    Tags HEAD with the version number computed.

  --prefix=<prefix>  

    Specify a prefix to add before the resulting version string

  --latest=<tag-glob>  

    Specify a glob pattern to search for last matching tag instead of
    providing a specific ref.
    Will attempt to use everything after <tag-glob> as the version string
    so be sure to provide _entire_ prefix. 
    E.g. use "R_" if your versions are "R_1.2.3"

DOCOPT

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

  # Defaults
  major = /\+major/
  minor = /\+minor/
  patch = /\+patch/

  debug = false
  # Base value 
  base = '0.0.0'
  prefix = ''

  if input['<semver_version_string>']
    base = input['<semver_version_string>']
  end

  unless input['--prefix'].nil?
    prefix = input['--prefix']
  end
  
  # Current directory
  repository = Rugged::Repository.new(Dir.pwd) 
  tagcollection = Rugged::TagCollection.new(repository)

  # Set up rugged to traverse our repoitory
  head = repository.lookup(repository.head.target.oid)

  w = Rugged::Walker.new(repository)
  # We need to walk 'backwards'
  w.push(head)

  if input['--latest'].nil?
    tail = repository.rev_parse(input['<ref>'])
    w.hide(tail)
  else
    candidates = []
    tail_glob = input['--latest']
    puts "globbing for " + tail_glob if debug

    tagcollection.each(tail_glob+'*') do |tag|
      puts "checking " + tag.name if debug
      candidates << tag unless repository.merge_base(tag.target, head).nil?
    end
    candidates.sort! {|a,b| a.target.time <=> b.target.time }
    latest_match = candidates.last
    puts "Match: #{latest_match.target.oid}"
    w.hide(latest_match.target)
    base = latest_match.name.sub(tail_glob,'')
  end
  # Set the intermediate result to the base
  # X.Y.Z-SPECIAL
  split = base.split('-')
  v_number = split[0].split('.')
  special = ''
  if (split[1])
    special = '-'+split[1]
  end

  major_bump = false
  minor_bump = false
  patch_bump = false
#  puts "Tail:"+tail.oid
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
    #If we find the commit. Abort
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
