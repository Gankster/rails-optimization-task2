require 'ruby-prof'
require_relative 'task-2'

RubyProf.measure_mode = RubyProf::MEMORY
# RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  work(filename: 'files/data_1_000_000.txt', disable_gc: true)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("ruby_prof_reports/flat_#{Time.now.to_i}.txt", "w+"))

printer_2 = RubyProf::GraphHtmlPrinter.new(result)
printer_2.print(File.open("ruby_prof_reports/graph_#{Time.now.to_i}.html", "w+"))

printer_3 = RubyProf::CallTreePrinter.new(result)
printer_3.print(:path => "ruby_prof_reports", :profile => 'callgrind')

printer_4 = RubyProf::DotPrinter.new(result)
printer_4.print(File.open("ruby_prof_reports/graphviz_#{Time.now.to_i}.dot", 'w+'))

printer_5 = RubyProf::CallStackPrinter.new(result)
printer_5.print(File.open("ruby_prof_reports/callstack_#{Time.now.to_i}.html", 'w+'))