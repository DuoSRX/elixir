Code.require_file "../test_helper", __FILE__

% We break tests in different test cases so they can run in parallel.
module CodeTest
  mixin ExUnit::Case

  def require_test
    assert_error { 'enoent, File.expand_path("code_sample.exs") }, do
      Code.require_file "code_sample"
    end

    Code.require_file "../fixtures/code_sample", __FILE__
    assert_included File.expand_path("test/elixir/fixtures/code_sample.exs"), Code.loaded_files
  end

  def empty_files_require_test
    Code.require_file "../fixtures/comments", __FILE__
  end

  module Code1Test
    mixin ExUnit::Case

    def code_init_test
      "3\n"       = OS.cmd("bin/elixir -e \"IO.puts 1 + 2\"")
      "5\n3\n"    = OS.cmd("bin/elixir -f \"IO.puts 1 + 2\" -e \"IO.puts 3 + 2\"")
      "5\n3\n1\n" = OS.cmd("bin/elixir -f \"IO.puts 1\" -e \"IO.puts 3 + 2\" test/elixir/fixtures/init_sample.exs")

      expected = "#{["-o", "1", "2", "3"].inspect}\n3\n"
      ~expected = OS.cmd("bin/elixir -e \"IO.puts Code.argv\" test/elixir/fixtures/init_sample.exs -o 1 2 3")
    end
  end

  module Code2Test
    mixin ExUnit::Case

    def code_error_test
      example = OS.cmd("bin/elixir -e \"self.throw 1\"")
      assert_included "** throw 1", example
      assert_included "Module::Behavior#throw/1", example

      assert_included "** error 1", OS.cmd("bin/elixir -e \"self.error 1\"")
      assert_included "** exit {1}", OS.cmd("bin/elixir -e \"self.exit {1}\"")

      % It does not catch exits with integers nor strings...
      "" = OS.cmd("bin/elixir -e \"self.exit 1\"")
    end
  end

  module Code3Test
    mixin ExUnit::Case

    def syntax_code_error_test
      assert_included "nofile:1: syntax error before:  []", OS.cmd("bin/elixir -e \"[1,2\"")
      assert_included "nofile:1: syntax error before:  'end'", OS.cmd("bin/elixir -e \"-> 2 end()\"")
    end
  end

  module CompileTest
    mixin ExUnit::Case

    def compile_code_test
      "Compiling test/elixir/fixtures/bookshelf.exs\n" =
        OS.cmd("bin/elixirc test/elixir/fixtures/bookshelf.exs -o test/tmp/")
      true = File.regular?("test/tmp/exBookshelf.beam")
    after
      Erlang.file.del_dir("test/tmp/")
    end

    def compile_spec_test
      "Compiling test/elixir/fixtures/bookshelf.exs\n" =
        OS.cmd("bin/elixirc -s test/elixir/fixtures/elixirc.spec -o test/tmp/")
      true = File.regular?("test/tmp/exBookshelf.beam")
    after
      Erlang.file.del_dir("test/tmp/")
    end

    def compile_paths_test
      assert_included "13", OS.cmd("bin/elixir -pa foo -pz bar -e \"IO.puts 13\"")
    end
  end
end