TABLE_FOR_ESCAPE_HTML__ = {
  '&' => '&amp;',
  '"' => '&quot;',
  '<' => '&lt;',
  '>' => '&gt;',
}

# Escape special characters in HTML, namely &\"<>
#   CGI::escapeHTML('Usage: foo "bar" <baz>')
#      # => "Usage: foo &quot;bar&quot; &lt;baz&gt;"
def escapeHTML(string)
  string.gsub(/[&\"<>]/, TABLE_FOR_ESCAPE_HTML__)
end

@comment_start = '<!--'
@comment_end = '-->'
@esc_amp = '&amp;'
@esc_quot = '&quot;'
@esc_lt = '&lt;'
@esc_gt = '&gt;'
@esc_amp_eql = '&'
@esc_quot_eql = '"'
@esc_lt_eql = '<'
@esc_gt_eql = '>'
@esc_patern = /[&\"<>]/

def escape(string)
  string.
      gsub(@esc_amp_eql, @esc_amp).
      gsub(@esc_quot_eql, @esc_quot).
      gsub(@esc_lt_eql, @esc_lt).
      gsub(@esc_gt_eql, @esc_gt)
end
def escape2(string)
  string.
      gsub(@esc_amp_eql, @esc_amp).
      gsub!(@esc_quot_eql, @esc_quot).
      gsub!(@esc_lt_eql, @esc_lt).
      gsub!(@esc_gt_eql, @esc_gt)
end
def escape3(string)
  string.chars.map do |ch|
    case ch
    when @esc_amp_eql then @esc_amp
    when @esc_quot_eql then @esc_quot
    when @esc_lt_eql then @esc_lt
    when @esc_gt_eql then @esc_gt
    else ch
    end
  end.join
end

require 'benchmark'

count = 100000

Benchmark.bmbm(15) do |b|
  str = ('asd& sd  " <>' *2 + 'asd asd '*4)*3
  b.report('escapeHTML') do
    count.times do
      escapeHTML(str)
    end
    p escapeHTML(str)
  end

  b.report('escape') do
    count.times do
      escape(str)
    end
    p escape(str)
  end
  b.report('escape2') do
    count.times do
      escape2(str)
    end
    p escape2(str)
  end
  b.report('escape2') do
    count.times do
      escape3(str)
    end
    p escape3(str)
  end
end

