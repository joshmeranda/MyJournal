rule 'MY000', 'A more strict version of MD013 to enforce line length limits excluding links and their trailing punctuation' do
  tags :line_length
#   docs 'https://github.com/joshmeranda/MyJournal/#MY000'
  aliases 'stricter-line-length'
  params :line_length => 120, :ignore_code_blocks => true, :ignore_tables => true, :ignore_links => true,
         :ignore_link_punctuation => true

  check do |doc|
    # Increment :line_length to accommodate for unix line endings
    params[:line_length] += 1

    overlines = doc.matching_lines(/^.{#{@params[:line_length]}}.*$/)

    # Every line in the document that is part of a code block.
    if params[:ignore_code_blocks]
      codeblock_lines = doc.find_type_elements(:codeblock).map do |e|
        (doc.element_linenumber(e)..
                 doc.element_linenumber(e) + e.value.lines.count).to_a
      end.flatten

      overlines -= codeblock_lines
    end

    if params[:ignore_tables]
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

      overlines -= table_lines
    end

    # We want to ignore files that exceed the line length limit, but end in a link.
    #  - [link text](some-url "Some Title")
    #  - <some-url>
    # todo: ideally we'd only search through overlines but this should be fine for now
    if params[:ignore_links] && params[:ignore_link_punctuation]
      overlines -= doc.matching_lines(/^.*\[.*\]\(.*\)[,.?;:!]*$/)
      overlines -= doc.matching_lines(/^.*<.*>[,.?;:!]*$/)
    elsif params[:ignore_links]
      overlines -= doc.matching_lines(/^.*\[.*\]\(.*\)$/)
      overlines -= doc.matching_lines(/^.*<.*>$/)
    end

    overlines
  end
end