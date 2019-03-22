module PlusBump
  # Module defaults
  BASE = '0.0.0'
  MAJOR = ENV['plusbump_major'] || '+major'
  MINOR = ENV['plusbump_minor'] || '+minor'
  PATCH = ENV['plusbump_patch'] || '+patch'
end
