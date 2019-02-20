require 'plusbump/version'
require 'semver'
require 'rugged'

# PlusBump main module
module PlusBump
  # Module defaults
  BASE = '0.0.0'
  MAJOR = '+major'
  MINOR = '+minor'
  PATCH = '+patch'
  @repo = nil

  def self.repo
    @repo ||= Rugged::Repository.new(Dir.pwd)
    @repo
  end

  # Class Tag
  class Tag
    def self.create(tag_name)
      target = PlusBump.repo.head.target
      ref = PlusBump.repo.tags.create(tag_name, target)
      puts "Created tag #{tag_name}" if ref
    end

    def self.delete(tag_name)
      tag_to_delete = PlusBump.repo.tags[tag_name]
      PlusBump.repo.references.delete(tag_to_delete) if tag_to_delete
    end
  end

  def self.extract_number(partial)
    /\d+/.match(partial)[0] if /\d+/ =~ partial
  end

  def self.extract_prefix(partial)
    /\D+/.match(partial)[0] if /\D+/ =~ partial
  end

  def self.run(input)
    if input['tag']
      bump_by_tag(latest: input['<tag-glob>'], prefix: input['--prefix'], debug: input['--debug'])
    elsif input['ref']
      bump_by_ref(ref: input['<ref>'], semver: input['<semver>'], prefix: input['--prefix'], debug: input['--debug'])
    end
  end

  def self.create_walker(repository)
    w = Rugged::Walker.new(repository)
    # Initialise the walker to start at current HEAD
    head = repository.lookup(repository.head.target.oid)
    w.push(head)
    w
  end

  def self.bump_by_ref(args = {})
    semver_string = args[:semver] || PlusBump::BASE
    w = create_walker(PlusBump.repo)
    tail = PlusBump.repo.rev_parse(args[:ref])
    w.hide(tail)
    prefix = args[:prefix] || ''

    v_number = semver_string.split('.')
    v_special = semver_string.split('-').size > 1 ? semver_string.split('-')[-1] : ''

    if prefix.empty?
      prefix = extract_prefix(v_number[0]) || ''
    end

    # Current semver string
    result = SemVer.new(extract_number(v_number[0]).to_i, v_number[1].to_i, v_number[2].to_i, v_special) # TODO: Fix special

    # Logic bump
    bump_action(w, result)
    final_res = prefix + (result.format "%M.%m.%p%s")
  end

  def self.bump_by_tag(args = {})
    base = '0.0.0'
    # Init Repo from current directory
    tagcollection = Rugged::TagCollection.new(PlusBump.repo)
    w = create_walker(PlusBump.repo)
    head = PlusBump.repo.lookup(PlusBump.repo.head.target.oid)
    candidates = []
    tagcollection.each(args[:latest] + '*') do |tag|
        candidates << tag if !PlusBump.repo.merge_base(tag.target, head).nil?
    end

    if candidates.empty?
      puts 'No matching tag found for ' + args[:latest]
    else
      candidates.sort! { |a,b| a.target.time <=> b.target.time }
      latest_match = candidates.last
      # Set target of matching commit as the tail of our walker
      w.hide(latest_match.target)
      base = latest_match.name.sub(args[:latest],'')
      puts "Found matching tag #{latest_match.name}" if args[:debug]
    end
    
    v_number = base.split('.')
    # v_special = base.split('-')
    prefix = args[:prefix] || ''

    # Current semver string
    result = SemVer.new(extract_number(v_number[0]).to_i, v_number[1].to_i, v_number[2].to_i, '') # TODO: FIX SPECIAL
    # Logic bumps
    bump_action(w, result)
    prefix + (result.format "%M.%m.%p%s")
  end

  def self.bump_action(walker, semver)
    # Defaults
    major = /\+major/
    minor = /\+minor/
    patch = /\+patch/
    minor_bump = false

    walker.each do |commit|
      if major =~ commit.message
        semver.major += 1
        semver.minor = 0
        semver.patch = 0
        return :major
      end
      minor_bump = true if minor =~ commit.message
    end
    if minor_bump
      semver.minor += 1
      semver.patch = 0
      return :minor
    else
      semver.patch += 1
      return :patch
    end
  end
end
