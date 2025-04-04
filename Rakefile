# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

require 'standard/rake'

task default: %i[spec standard]

# !/usr/bin/env ruby

lib_dir = File.expand_path(File.join(__dir__, 'lib'))
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)

APP_ROOT = __dir__

### Test Tasks ###
require 'rake'
require 'rake/testtask'

namespace :test do
  desc 'Run all tests'
  Rake::TestTask.new(:all) do |t|
    t.libs << 'test'
    t.libs << 'lib'
    t.test_files = FileList['test/**/*_test.rb']
    t.warning = false
    t.verbose = true
  end

  desc 'Run Ohm model tests'
  Rake::TestTask.new(:ohm) do |t|
    t.libs << 'test'
    t.libs << 'lib'
    t.test_files = FileList['test/ohm/**/*_test.rb']
    t.warning = false
    t.verbose = true
  end

  desc 'Run parser tests'
  Rake::TestTask.new(:parsers) do |t|
    t.libs << 'test'
    t.libs << 'lib'
    t.test_files = FileList['test/parsers/**/*_test.rb']
    t.warning = false
    t.verbose = true
  end

  desc 'Run import tests'
  Rake::TestTask.new(:import) do |t|
    t.libs << 'test'
    t.libs << 'lib'
    t.pattern = 'test/import_test.rb'
    t.warning = false
    t.verbose = true
  end
end

# Make 'test' run all tests by default
desc 'Run all tests'
task test: 'test:all'

### Coverage Task ###
namespace :coverage do
  desc 'Generate test coverage report'
  task :report do
    ENV['COVERAGE'] = 'true'
    Rake::Task['test:all'].invoke
  end
end

### RDoc Tasks ###
require 'rdoc/task'

Rake::RDocTask.new do |rdoc|
  rdoc.title    = 'LLM Memory V2'
  rdoc.rdoc_dir = "#{APP_ROOT}/doc"
  rdoc.options += [
    '-w',
    '2',
    '-H',
    '-A',
    '-f',
    'darkfish',
    '-m',
    'README.md',
    '--visibility',
    'nodoc',
    '--markup',
    'markdown'
  ]
  rdoc.rdoc_files.include 'README.md'
  rdoc.rdoc_files.include Dir['lib/**/*.rb']
end

### Documentation Tasks ###
namespace :docs do
  desc 'Convert RDoc HTML to Markdown'
  task markdown: :rdoc do
    require 'nokogiri'
    require 'fileutils'

    doc_dir = File.join(APP_ROOT, 'doc')
    markdown_dir = File.join(doc_dir, 'markdown')
    FileUtils.mkdir_p(markdown_dir)

    puts 'Converting HTML documentation to Markdown...'

    def clean_code_block(code)
      lines = code.split("\n")
      min_indent = lines.reject(&:empty?).map { |l| l[/^\s*/].length }.min || 0
      lines.map { |line| line.empty? ? line : line[min_indent..-1] }.join("\n")
    end

    def process_html_file(file, output_dir)
      basename = File.basename(file, '.html')
      output_file = File.join(output_dir, "#{basename}.md")

      puts "Processing #{basename}..."

      doc = File.open(file) { |f| Nokogiri::HTML(f) }
      doc.css('.nav-section, #navigation').remove

      doc.css('pre code, .source_code').each do |code|
        lang = code['class']&.split&.find { |c| c.start_with?('language-') }&.sub('language-', '') || 'ruby'
        cleaned_code = clean_code_block(code.content)
        code.replace("```#{lang}\n#{cleaned_code}\n```")
      end

      IO.popen(['pandoc', '-f', 'html', '-t', 'gfm', '--wrap=none', '-s', '-o', output_file], 'w+') do |pipe|
        pipe.write(doc.at_css('body').inner_html)
        pipe.close_write
        pipe.read
      end

      puts "Markdown file generated at #{output_file}"
    end

    Dir[File.join(doc_dir, '**', '*.html')].sort.each do |file|
      next if %r{table_of_contents|index|js/}.match?(file)

      process_html_file(file, markdown_dir)
    end

    puts "Markdown files generated in #{markdown_dir}"
  end
end
