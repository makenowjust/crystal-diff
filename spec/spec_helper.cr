require "spec"
require "../src/diff"

def no_change(ra, rb)
  Diff::Chunk.new nil, Diff::Type::NO_CHANGE, ra, rb
end

def append(ra, rb)
  Diff::Chunk.new nil, Diff::Type::APPEND, ra, rb
end

def delete(ra, rb)
  Diff::Chunk.new nil, Diff::Type::DELETE, ra, rb
end
