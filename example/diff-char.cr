require "colorize"
require "../src/diff"

Diff.diff("hello world", "hello good-bye").each do |chunk|
  print chunk.data.colorize(
    chunk.append? ? :green : chunk.delete? ? :red : :dark_gray)
end
puts
