rule 'MY000', 'A more strict version of MD013 to enforce line length limits excluding links' do
  tags :line_length
  aliases 'strict-line-length'
  docs "https://github.com/joshmeranda/MyJournal/#MY000"
  params :line_length => 120, :ignore_code_blocks => true, :ignore_tables => true, :ignore_links => true

  check do |doc|
    # Increment :line_length to accommodate for unix line endings
    params[:line_length] += 1

    # Every line in the document that is part of a code block.
    codeblock_lines = doc.find_type_elements(:codeblock).map do |e|
      (doc.element_linenumber(e)..
               doc.element_linenumber(e) + e.value.lines.count).to_a
    end.flatten

    # Every line in the document that is part of a table.
    locations = doc.elements
                   .map { |e| [e.options[:location], e] }
                   .reject { |l, _| l.nil? }
    table_lines = locations.map.with_index do |(l, e), i|
      if e.type == :table
        if i + 1 < locations.size
          (l..locations[i + 1].first - 1).to_a
        else
          (l..doc.lines.count).to_a
        end
      end
    end.flatten

    overlines = doc.matching_lines(/^.{#{@params[:line_length]}}.*$/)
    overlines -= table_lines unless !params[:ignore_tables]
    overlines -= codeblock_lines unless !params[:ignore_code_blocks]

    # We want to ignore files that exceed the line length limit, but end in a link.
    #  - [link text](some-url "Some Title")
    #  - <some-url>
    # todo: ideally we'd only search through overlines but this should be fine for now
    if params[:ignore_links]
      overlines -= doc.matching_lines(/^.*\[.*\]\(.*\)$/)
      overlines -= doc.matching_lines(/^.*<.*>$/)
    end

    overlines
  end
end