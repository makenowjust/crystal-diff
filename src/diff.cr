class Diff(A, B)
  VERSION = "1.1.0"

  struct Chunk(T)
    def initialize(@diff : T, @type : Type, @range_a : Range(Int32, Int32), @range_b : Range(Int32, Int32))
    end

    property diff, type, range_a, range_b

    def append?
      type == Type::APPEND
    end

    def delete?
      type == Type::DELETE
    end

    def no_change?
      type == Type::NO_CHANGE
    end

    def data
      case type
      when Type::NO_CHANGE
        diff.a[range_a]
      when Type::APPEND
        diff.b[range_b]
      when Type::DELETE
        diff.a[range_a]
      end
    end

    def ==(other : Chunk)
      type == other.type &&
        range_a == other.range_a &&
        range_b == other.range_b
    end

    def inspect(io)
      io << "Chunk(@type=#{@type}, @range_a=#{@range_a}, @range_b=#{@range_b})"
    end
  end

  enum Type
    NO_CHANGE
    APPEND
    DELETE

    def reverse
      case self
      when APPEND
        DELETE
      when DELETE
        APPEND
      else
        self
      end
    end
  end

  def self.diff(a, b)
    Diff.new(a, b).run
  end

  @m : Int32
  @n : Int32
  @reverse : Bool
  @edit_distance : Int32?

  def initialize(@a : A, @b : B)
    @m = a.size
    @n = b.size
    if @reverse = @n < @m
      @a, @b = @b, @a
      @m, @n = @n, @m
    end

    @path = Array(Int32).new @m + @n + 3, -1
    @points = [] of {Int32, Int32, Int32}
  end

  def a
    @reverse ? @b : @a
  end

  def b
    @reverse ? @a : @b
  end

  def edit_distance
    if ed = @edit_distance
      return ed
    end

    offset = @m + 1
    delta = @n - @m
    fp = Array.new @m + @n + 3, -1

    p = 0
    loop do
      (-p..delta - 1).each { |k| fp[k + offset] = snake k, fp[k - 1 + offset] + 1, fp[k + 1 + offset], offset }
      (delta + 1..delta + p).reverse_each { |k| fp[k + offset] = snake k, fp[k - 1 + offset] + 1, fp[k + 1 + offset], offset }
      fp[delta + offset] = snake delta, fp[delta - 1 + offset] + 1, fp[delta + 1 + offset], offset

      return @edit_distance = delta + p * 2 if fp[delta + offset] == @n
      p += 1
    end
  end

  private def snake(k, p, pp, offset)
    r = p > pp ? @path[k - 1 + offset] : @path[k + 1 + offset]

    y = {p, pp}.max
    x = y - k

    while x < @m && y < @n && @a[x] == @b[y]
      x += 1
      y += 1
    end

    @path[k + offset] = @points.size
    @points << {x, y, r}

    y
  end

  def run
    edit_distance

    offset = @m + 1
    delta = @n - @m

    ps = [] of {Int32, Int32}
    r = @path[delta + offset]
    until r == -1
      p = @points[r]
      ps << {p[0], p[1]}
      r = p[2]
    end

    chunk_list = [] of Chunk(self)

    x = y = x0 = y0 = 0
    ps.reverse_each do |p|
      px, py = p

      while x < px && py - px < y - x
        x += 1
      end
      deleted = x0 != x
      chunk chunk_list, Type::DELETE, x0...x, y0...y if deleted
      x0 = x

      while y < py && py - px > y - x
        y += 1
      end
      appended = y0 != y
      chunk chunk_list, Type::APPEND, x0...x, y0...y if appended
      y0 = y

      while x < px && y < py && py - px == y - x
        x += 1
        y += 1
      end
      chunk chunk_list, Type::NO_CHANGE, x0...x, y0...y unless x0 == x
      x0 = x
      y0 = y
    end

    chunk_list
  end

  private def chunk(chunk_list, type, range_a, range_b)
    if @reverse
      chunk = Chunk.new self, type.reverse, range_b, range_a
    else
      chunk = Chunk.new self, type, range_a, range_b
    end

    last = chunk_list.last?
    if last && chunk.type == last.type
      chunk_list[-1] = Chunk.new self, type, last.range_a.begin...chunk.range_a.end, last.range_b.begin...chunk.range_b.end
    else
      chunk_list << chunk
    end
  end
end
