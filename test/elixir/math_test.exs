Code.require_file "../test_helper", __FILE__

module MathTest
  mixin ExUnit::Case

  def constants_test
    3.141592653589793 = Math.pi
  end

  def exp_test
    1.0 = Math.exp(0)
    2.718281828459045 = Math.exp(1)
  end

  def sqrt_test
    3.0 = Math.sqrt(9)
    assert_error 'badarith, -> Math.sqrt(-1)
  end

  def pow
    9   = Math.pow(3, 2)
    0.1 = Math.pow(10, -1)
    10  = Math.pow(-1, 10)
  end

  def log_test
    2.0 = Math.log(10, 100)
    0.5 = Math.log(100, 10)

    assert_error 'badarith, -> Math.log(-1)
  end

  % this needs more tests
  def sin_cos_tan_test
    0.0 = Math.sin(0)
    1.0 = Math.cos(0)
    1.0 = Math.tan(0)
  end

end