require "./spec_helper"

describe Diff do
  [
    {"abc", "abc", [no_change(0...3, 0...3)]},
    {"abc", "abcd", [no_change(0...3, 0...3), append(3...3, 3...4)]},
    {"abcd", "abc", [no_change(0...3, 0...3), delete(3...4, 3...3)]},
    {"abc", "acb", [no_change(0...1, 0...1), delete(1...2, 1...1), no_change(2...3, 1...2), append(3...3, 2...3)]},
    {"hello world", "hello good-bye", [no_change(0...6, 0...6), delete(6...7, 6...6), append(7...7, 6...7), no_change(7...8, 7...8), delete(8...10, 8...8), append(10...10, 8...9), no_change(10...11, 9...10), append(11...11, 10...14)]},
  ].each do |test_case|
    a, b, expect = test_case
    it "should calculate diff between #{a.inspect} and #{b.inspect}" do
      Diff.diff(a, b).should eq expect
    end
  end
end
