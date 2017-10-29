#!/usr/bin/ruby

require 'date'

if ARGV.length != 1
  puts "Missing filename (try --help)"
  exit 0
end

@date = Date.today.strftime("%Y%m%d")

@state = 'NONE'
@poemcount = 1;

@firstline = nil
@title = nil
@subtitle = nil
@body = []
@keywords = nil;

def printPoem()
  puts "<poem id=\"POETID#{@date}#{'%02d' % @poemcount}\">"
  puts "<head>"
  puts "    <title>#{@title}</title>"
  if @subtitle
    puts "    <subtitle>#{@subtitle}</subtitle>"
  end
  puts "    <firstline>#{@firstline}</firstline>"
  if @keywords
    puts "    <keywords>#{@keywords}</keywords>"
  end
  puts "</head>"
  puts "<body>"
  puts @body.join("\n").strip
  puts "</body>"
  puts "</poem>"
  puts ""
  @firstline = nil
  @title = nil
  @subtitle = nil
  @body = []
  @keywords = nil;
  @poemcount += 1
end

File.readlines(ARGV[0]).each do |line|
  if @state == 'NONE' and line =~ /^T:/
    @state = 'INHEAD'
  end
  if @state == 'INBODY' and line.start_with?("T:")
    printPoem()
    @state = 'INHEAD'
  end
  if @state == 'INHEAD'
    if line.start_with?("T:")
      @title = line[2..-1].strip
    elsif line.start_with?("F:")
      @firstline = line[2..-1].strip
    elsif line.start_with?("U:")
      @subtitle = line[2..-1].strip
    elsif line.start_with?("N:")
      @keywords = line[2..-1].strip
    elsif line =~ /^.:/
      throw "Unknown header-line: #{line}"
    else
      @state = 'INBODY'
    end
  end
  if @state == 'INBODY'
    @body.push(line.rstrip)
  end
end

printPoem()
