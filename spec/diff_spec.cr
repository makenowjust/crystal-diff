require "./spec_helper"

describe Diff do
  [
    {"abc", "abc", [no_change(0...3, 0...3)]},
    {"abc", "abcd", [no_change(0...3, 0...3), append(3...3, 3...4)]},
    {"abcd", "abc", [no_change(0...3, 0...3), delete(3...4, 3...3)]},
    {"abc", "acb", [no_change(0...1, 0...1), append(1...1, 1...2), no_change(1...2, 2...3), delete(2...3, 3...3)]},
    {"hello world", "hello good-bye", [no_change(0...6, 0...6), append(6...6, 6...7), delete(6...7, 7...7), no_change(7...8, 7...8), append(8...8, 8...9), delete(8...10, 9...9), no_change(10...11, 9...10), append(11...11, 10...14)]},
  ].each do |test_case|
    a, b, expect = test_case
    it "should calculate diff between #{a.inspect} and #{b.inspect}" do
      Diff.diff(a, b).should eq expect
    end
  end
end
