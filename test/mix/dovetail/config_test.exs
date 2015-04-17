defmodule Dovetail.ConfigTest do
  use ExUnit.Case
  alias Mix.Tasks.Dovetail.Config

  test "template/{0,1}" do
    {template, options} = Config.template()
    assert is_binary(template)
    assert is_list(options)

    for {_, value} <- options do
      assert String.contains?(template, value)
    end

    tester = "test"
    {_template, options} = Config.template(default_user: tester)
    assert options[:default_user] == tester
  end

  test "write" do
    test_dir = Application.app_dir(:dovetail, "test/")
    path = Path.join(test_dir, "dovetail.conf")

    {template, options} = Config.template()
    ^options = Config.write!({template, options}, path)
    assert File.read!(path) == template

    File.rm!(path)
  end

end
