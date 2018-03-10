YARD::Tags::Library.define_tag('Specification', :spec)

YARD::Parser::SourceParser.after_parse_list do
  YARD::Registry.all(:method).each do |meth|
    next unless meth.has_tag?(:spec)
    spec_tag = meth.tag(:spec)
    class_name = meth.to_s.gsub(/(\#.*)$/, '')
    file = "{include:file:specs/Router/##{meth.name}/requirements.md}"
    content = 'This is part of the specification for ' \
              "{#{class_name}}s.\n\n  #{file}"
    content = "#{spec_tag.text}\n\n  **Note:** #{content}" unless spec_tag.text.empty?
    meth.add_tag YARD::Tags::Tag.new(:note, content)
  end
end
