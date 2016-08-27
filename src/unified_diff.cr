require "./diff"

class Diff(A, B)
  def self.unified_diff(a, b, n = 3, newline = "\n")
    diff = Diff.new(a, b)
    chunks = diff.run

    result = [] of String
    group = [] of String
    start_a = start_b = 0

    chunks.each_with_index do |cur, i|
      next if cur.no_change?
      prv = i > 0 ? chunks.at(i-1) : Chunk.new(diff, Type::NO_CHANGE, 0...0, 0...0)
      nxt = chunks.at(i+1) { Chunk.new(diff, Type::NO_CHANGE, a.size...a.size, b.size...b.size) }

      if group.empty? && prv.no_change?
        start_a = {prv.range_a.end - n, 0}.max
        start_b = {prv.range_b.end - n, 0}.max
        add_with_prefix ' ', prv.data.last(n), group
      end

      prefix = cur.append? ? '+' : '-'
      add_with_prefix prefix, cur.data, group

      if !group.last.ends_with?(newline)
        if cur.delete? ? cur.range_a.end == a.size : cur.range_b.end == b.size
          group[-1] += newline
          group.push "\\ No newline at end of file" + newline
        end
      end

      if nxt.no_change?
        if nxt.data.size > n*2 || i >= chunks.size - 2
          add_with_prefix ' ', nxt.data.first(n), group

          size_a = {nxt.range_a.begin + n, a.size}.min - start_a
          size_b = {nxt.range_b.begin + n, b.size}.min - start_b
          start_a += 1 unless size_a == 0
          start_b += 1 unless size_b == 0

          result.push String.build {|io|
            io << "@@ -" << start_a
            io << "," << size_a unless size_a == 1
            io << " +" << start_b
            io << "," << size_b unless size_b == 1
            io << " @@" << newline
          }
          result += group
          group.clear
        else
          add_with_prefix ' ', nxt.data, group
        end
      end
    end

    result
  end

  private def self.add_with_prefix(prefix, lines, to array)
    lines.each do |line|
      array.push prefix + line
    end
  end

  def self.unified_diff(a : String, b : String, n = 3, newline = "\n")
    unified_diff(a.lines, b.lines, n, newline).join
  end
end
