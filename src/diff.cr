class Diff(A, B)
  VERSION = "1.0.0"

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

    @table = {} of {Int32, Int32} => Int32
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
      (-p..delta - 1).each { |k| fp[k + offset] = snake k, [fp[k - 1 + offset] + 1, fp[k + 1 + offset]].max }
      (delta + 1..delta + p).reverse_each { |k| fp[k + offset] = snake k, [fp[k - 1 + offset] + 1, fp[k + 1 + offset]].max }
      fp[delta + offset] = snake delta, [fp[delta - 1 + offset] + 1, fp[delta + 1 + offset]].max

      if fp[delta + offset] == @n
        return @edit_distance = delta + p * 2
      end
      p += 1
    end
  end

  private def snake(k, y)
    x = y - k

    i = 0
    while x < @m && y < @n && @a[x] == @b[y]
      x += 1
      y += 1
      i += 1
    end
    @table[{x, y}] = i
    y
  end

  def run
    edit_distance

    x, y = @m, @n
    chunk_list = [] of Chunk(self)
    loop do
      i = @table[{x, y}]
      if i != 0
        chunk_list.push chunk Type::NO_CHANGE, x - i...x, y - i...y
      end
      x, y = x - i, y - i

      i = 0
      flag = false
      while @table[{x, y - 1}]?
        y -= 1
        i += 1
      end
      if i != 0
        chunk_list.push chunk Type::APPEND, x...x, y...y + i
        flag = true
      end

      i = 0
      while @table[{x - 1, y}]?
        x -= 1
        i += 1
      end
      if i != 0
        chunk_list.push chunk Type::DELETE, x...x + i, y...y
        if flag && @reverse
          chunk_list[-1], chunk_list[-2] = chunk_list[-2], chunk_list[-1]
        end
      end

      if x == 0 && y == 0
        return chunk_list.reverse!
      end
    end
  end

  private def chunk(type, range_a, range_b)
    if @reverse
      Chunk.new self, type.reverse, range_b, range_a
    else
      Chunk.new self, type, range_a, range_b
    end
  end
end
