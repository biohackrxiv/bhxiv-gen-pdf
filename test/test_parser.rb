#
# Run with
#
#   ruby -I lib test/test_parser.rb
#
require 'minitest'
require 'minitest/autorun'
require 'bhxiv/markdown'

class TestParser < MiniTest::Test
  def test_yaml_valid
    yml = md_parser('test/data/yaml1.md')
    assert yml['title'] == "Logic Programming for the Biomedical Sciences"
  end

  def test_yaml_complete
    md_checker('test/data/yaml1.md')
  end

  def test_yaml_other_empty
    header = md_parser('test/data/incomplete.md')
    assert_raises MarkdownError do
      meta = meta_expand(header)
    end
    # md_meta_checker(meta)
  end

  def test_yaml_other
    header = md_parser('test/data/other.md')
    meta = meta_expand(header)
    # p meta
    md_meta_checker(meta)
    assert meta['biohackathon_name'] == "My biohackathon"
  end

  def test_bib_keys_without_colon
    assert bib_key_checker('test/data/keys-clean.bib')
  end

  def test_bib_keys_with_colon_are_rejected
    err = assert_raises MarkdownError do
      bib_key_checker('test/data/keys-colon.bib')
    end
    assert_includes err.message, 'Smith:2020'
    assert_includes err.message, 'Smith2020'
    refute_includes err.message, 'Jones2021'
  end

  def test_bib_keys_missing_file_is_not_an_error
    assert bib_key_checker('test/data/does-not-exist.bib')
  end
end
