require 'plusbump/version'
require 'plusbump/usage'
require 'plusbump/config'
require 'semver'
require 'rugged'

# PlusBump main module
module PlusBump

  @repo = nil

  def self.repo
    @repo ||= Rugged::Repository.new(Dir.pwd)
    @repo
  end

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

  def self.transform(input)
    Hash.new( input.map { |k,v|
      [k.replace('-','').to_s,v]
    })
  end

  def self.bump(input)
    if input['--from-tag']
      bump_by_tag(glob: input['--from-tag'],
                  base: input['--base-version'],
                  prefix: input['--new-prefix'] || '',
                  tag_replacement: input['--base-version-from-tag'],
                  major_pattern: input['--major-pattern'],
                  minor_pattern: input['--minor-pattern'],
                  patch_pattern: input['--patch-pattern'],
                  debug: input['--debug'])
    elsif input['--from-ref']
      bump_by_ref(ref: input['--from-ref'],
                  semver: input['--base-version'],
                  prefix: input['--new-prefix'] || '',
                  major_pattern: input['--major-pattern'],
                  minor_pattern: input['--minor-pattern'],
                  patch_pattern: input['--patch-pattern'],
                  debug: input['--debug'])
    end
  end

  def self.create_walker(repository)
    w = Rugged::Walker.new(repository)
    # Initialise the walker to start at current HEAD
    head = repository.lookup(repository.head.target.oid)
    w.push(head)
    w
  end

  # TODO: Need fixing!
  def self.current_semver()

  end

  def self.bump_by_ref(args = {})
    semver_string = args[:semver] || PlusBump::BASE
    w = create_walker(PlusBump.repo)
    tail = PlusBump.repo.rev_parse(args[:ref])
    w.hide(tail)

    v_number = semver_string.split('.')
    v_special = semver_string.split('-').size > 1 ? semver_string.split('-')[-1] : ''

    # Current semver string
    result = SemVer.new(extract_number(v_number[0]).to_i, v_number[1].to_i, v_number[2].to_i, v_special) # TODO: Fix special

    # Logic bump
    bump_action(w, result, major_p: args[:major_pattern], minor_p: args[:minor_pattern], patch_p: args[:patch_pattern])
    final_res = extract_prefix(v_number[0]) || '' + (result.format "%M.%m.%p%s")
  end

  # Should return a Rugged::Tag object
  def self.find_newest_matching_tag(candidates)
    candidates.sort! { |a,b| a.target.time <=> b.target.time }
    candidates.last
  end

  # The justification for this method is to split a semver tag into it's composite parts. Major.Minor.Patch[+-]....
  # We need these parts to construct the SemVer object
  def self.parse_semver_parts(base)
      main = base.split(/[\+\-]/) # Should split something like Release_1.2.3-beta1+001 into two parts.
      version_part = main[0].split('.')
      # Clean up the version part...extract all numbers excluding non-numerical characters
      version_part.map! { |elem| extract_number(elem) }
      special_part = main[1..-1] || ''
      return { :version_part => version_part, :special_part => special_part.join('') }
  end

  def self.bump_by_tag(args = {})
    base = '0.0.0'
    # Init Repo from current directory
    tagcollection = Rugged::TagCollection.new(PlusBump.repo)
    w = create_walker(PlusBump.repo)
    head = PlusBump.repo.lookup(PlusBump.repo.head.target.oid)
    candidates = []
    tagcollection.each(args[:glob] + '*') do |tag|
        candidates << tag if !PlusBump.repo.merge_base(tag.target, head).nil?
    end

    if candidates.empty?
      puts 'No matching tag found for ' + args[:glob]
    else
      latest_match = find_newest_matching_tag(candidates)
      # Set target of matching commit as the tail of our walker
      w.hide(latest_match.target)
      base = latest_match.name
      puts "Found matching tag #{latest_match.name}" if args[:debug]
    end

    # Current semver string
    unless args[:tag_replacement].nil?
      replacer = args[:tag_replacement] || ''
      parts = parse_semver_parts(base)
      result = SemVer.new(parts[:version_part][0].sub(replacer, '').to_i, parts[:version_part][1].to_i, parts[:version_part][2].to_i, parts[:special_part])
    else
      parts = parse_semver_parts(args[:base])
      result = SemVer.new(parts[:version_part][0].to_i, parts[:version_part][1].to_i, parts[:version_part][2].to_i, parts[:special_part]) # TODO: FIX SPECIAL
    end
    # Logic bumps
    bump_action(w, result, major_p: args[:major_pattern], minor_p: args[:minor_pattern], patch_p: args[:patch_pattern])
    args[:prefix] + (result.format "%M.%m.%p%s")
  end

  def self.bump_action(walker, semver, **args)
    # Defaults
    major = Regexp.new(Regexp.quote(args[:major_p] || PlusBump::MAJOR))
    minor = Regexp.new(Regexp.quote(args[:minor_p] || PlusBump::MINOR))
    patch = Regexp.new(Regexp.quote(args[:patch_p] || PlusBump::PATCH))
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
