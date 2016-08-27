require "../src/unified_diff"

a = File.read("original.txt")
b = File.read("new.txt")

print Diff.unified_diff(a, b)
