module Math
  % Returns pi
  def pi
    Erlang.math.pi
  end

  % Computes e ** x
  %
  % ## Examples
  %
  %    Math.exp(0) % => 1
  %    Math.exp(2) % => 2.718281828459045
  %
  def exp(n)
    Erlang.math.exp(n)
  end

  % Raises the first number to the second
  %
  % ## Examples
  %
  %    Math.pow(3, 2)   % => 9
  %    Math.pow(10, -1) % => 0.1
  %
  def pow(a, b)
    Erlang.pow(a, b)
  end

  % Returns the natural logarithm of the given number
  % Raises badarith if the given number is negative
  def log(n)
    Erlang.math.log(n)
  end

  % Returns the natural logarithm of the given number in the given base
  % Raises badarith if the given number is negative
  %
  % ## Examples
  %
  %    Math.log(10, 100) % => 2.0
  %    Math.log(100, 10) % => 0.5
  %
  def log(base, n)
    log(n) / log(base)
  end

  % Returns the square root of the given number.
  % Raises 'badarith if the given number is negative.
  %
  % ## Examples
  %
  %    Math.sqrt(9) % => 3
  %
  def sqrt(n)
    Erlang.math.sqrt(n)
  end

  % Computes the sine of n in radians
  def sin(n)
    Erlang.math.sin(n)
  end

  % Computes the cosine of n in radians
  def cos(n)
    Erlang.math.cos(n)
  end

  % Computes the tangent of n in radians
  def tan(n)
    Erlang.math.cos(n)
  end
end