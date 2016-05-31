#!/usr/bin/env ruby
#encoding: utf-8
require 'docopt'
require 'rugged'

doc = <<DOCOPT
Usage:
  #{__FILE__} [--majorpattern=<major_pattern>] [--minorpattern=<minor_pattern>] <ref>  [<semver_version_string>]
  #{__FILE__} -h|--help

Options:
  -h --help
             
    Show this screen.
     
  --majorpattern=<major_pattern>
  
    Pattern that specifies a x
    
  --majorpattern=<major_pattern>

    Format that describes how your release tags look. This is used together with -t LATEST. We always check agains HEAD/TIP.

  <ref>

    Some ref to the git commit where current version was released

  semver_version_string

    Optional version string that you want bumped


DOCOPT

begin

  # Defaults
  major = /\+major/
  minor = /\+minor/
  patch = /\+patch/

  # Base value 
  base = '0.0.0'

  #Increments the major version number based on current, returns new
  def increment_major(current)
    puts "Increment major"    
  end

  def increment_minor(current)    
    puts "Increment minor"
  end

  def increment_patch(current)
    puts "Increment patch"
  end

  input = Docopt::docopt(doc)

  # Current directory
  repository = Rugged::Repository.new(Dir.pwd) 

  head = repository.head.target
  tail = repository.rev_parse(input['<ref>'])

  walker = Rugged::Walker.new(repository)
  walker.sorting(Rugged::SORT_TOPO)
  waĺker.push(head.oid)

  result = base

  walker.each do |commit|
    #If we find the commit. Abort
    if commit.oid == tail      
      break
    end
    if major =~ commit.message
      result = increment_major(result)      
    elsif minor =~ commit.message
      result = increment_minor(result)
    else
      result = increment_patch(result)
    end
  end
  
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


rescue Docopt::Exit => e
  puts "versionbumpfinder"
  puts "#{version}\n"
  puts e.message
end
