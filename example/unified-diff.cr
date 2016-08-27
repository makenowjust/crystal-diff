require "../src/unified_diff"

a = File.read("original.txt")
b = File.read("new.txt")

diff = Diff.unified_diff(a, b)
print diff

if Diff.apply(a, diff) != b
  raise "Mismatch after applying diff!"
end
