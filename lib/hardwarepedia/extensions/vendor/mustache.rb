
# Monkey patches to Mustache, mainly to support arguments on callable tags.

class Mustache
  class Parser
    # Override to allow arguments for helpers.
    #
    def scan_tags
      # Scan until we hit an opening delimiter.
      start_of_line = @scanner.beginning_of_line?
      pre_match_position = @scanner.pos
      last_index = @result.length

      return unless x = @scanner.scan(/([ \t]*)?#{Regexp.escape(otag)}/)
      padding = @scanner[1] || ''

      # Don't touch the preceding whitespace unless we're matching the start
      # of a new line.
      unless start_of_line
        @result << [:static, padding] unless padding.empty?
        pre_match_position += padding.length
        padding = ''
      end

      # Since {{= rewrites ctag, we store the ctag which should be used
      # when parsing this specific tag.
      current_ctag = self.ctag
      type = @scanner.scan(/#|\^|\/|=|!|<|>|&|\{/)
      @scanner.skip(/\s*/)

      # ANY_CONTENT tags allow any character inside of them, while
      # other tags (such as variables) are more strict.
      if ANY_CONTENT.include?(type)
        r = /\s*#{regexp(type)}?#{regexp(current_ctag)}/
        content = scan_until_exclusive(r)
      else
        content = @scanner.scan(ALLOWED_CONTENT)
      end

      # We found {{ but we can't figure out what's going on inside.
      error "Illegal content in tag" if content.empty?

      fetch = [:mustache, :fetch, content.split('.')]
      prev = @result

      # Based on the sigil, do what needs to be done.
      case type
      when '#'
        block = [:multi]
        @result << [:mustache, :section, fetch, block]
        @sections << [content, position, @result]
        @result = block
      when '^'
        block = [:multi]
        @result << [:mustache, :inverted_section, fetch, block]
        @sections << [content, position, @result]
        @result = block
      when '/'
        section, pos, result = @sections.pop
        raw = @scanner.pre_match[pos[3]...pre_match_position] + padding
        (@result = result).last << raw << [self.otag, self.ctag]

        if section.nil?
          error "Closing unopened #{content.inspect}"
        elsif section != content
          error "Unclosed section #{section.inspect}", pos
        end
      when '!'
        # ignore comments
      when '='
        self.otag, self.ctag = content.split(' ', 2)
      when '>', '<'
        @result << [:mustache, :partial, content, padding]
      when '{', '&'
        # The closing } in unescaped tags is just a hack for
        # aesthetics.
        type = "}" if type == "{"
      #--- START PATCH ---------------------------------------------------------
        token_type = :utag
      else
        token_type = :etag
      end

      # Skip whitespace after the content inside this tag.
      @scanner.skip(/\s+/)

      if token_type == :utag || token_type == :etag
        tag = [fetch]
        i = 0
        loop do
          if i > 30
            # this should never happen, but worth checking anyway
            error "Unclosed tag"
          end

          # Skip any balancing sigils after the content inside this tag.
          @scanner.skip(regexp(type)) if type

          # Try to find the closing tag.
          re = regexp(current_ctag)
          if close = @scanner.scan(re)
            # We're good, go on.
            # A unary call {{foo}} will be parsed as [:mustache, :etag, "foo"]
            # A call with args {{foo bar baz}} will be parsed as [:mustache, :etag, "foo", "bar", "baz"]
            result = ([:mustache, token_type] + tag)
            @result << result
            break
          end
          # Check for arguments.
          if @scanner.scan(/\s*(?:,?\s*)?(?:"([^"]+)"|'([^']+)')\s*/)
            tag << (@scanner[2] || @scanner[1])
          elsif @scanner.scan(/\s*(?:,?\s*)?([^ #{current_ctag}]+)\s*/)
            tag << @scanner[1]
          else
            error "Unclosed tag"
          end
          i += 1
        end
      else
        # Skip any balancing sigils after the content inside this tag.
        @scanner.skip(regexp(type)) if type
        # Try to find the closing tag.
        re = regexp(current_ctag)
        unless close = @scanner.scan(re)
          error "Unclosed tag"
        end
      end
      #--- END PATCH -----------------------------------------------------------

      # If this tag was the only non-whitespace content on this line, strip
      # the remaining whitespace.  If not, but we've been hanging on to padding
      # from the beginning of the line, re-insert the padding as static text.
      if start_of_line && !@scanner.eos?
        if @scanner.peek(2) =~ /\r?\n/ && SKIP_WHITESPACE.include?(type)
          @scanner.skip(/\r?\n/)
        else
          prev.insert(last_index, [:static, padding]) unless padding.empty?
        end
      end

      # Store off the current scanner position now that we've closed the tag
      # and consumed any irrelevant whitespace.
      @sections.last[1] << @scanner.pos unless @sections.empty?

      return unless @result == [:multi]
    end
  end

  class Generator
    # Override to call the helper method with arguments given to the tag.
    #
    # on_utag([:mustache, :fetch, "foo"]) => render(foo())
    # on_utag([:mustache, :fetch, "foo"], "bar", "baz quux") => render(foo("bar, "baz quux"))
    #
    def on_utag(name, *args)
      args_as_str = args.map(&:inspect).join(", ")
      ev(<<-compiled)
        v = #{compile!(name)}
        if v.is_a?(Proc)
          #--- START PATCH -----------------------------------------------------
          v = Mustache::Template.new(v.call(#{args_as_str}).to_s).render(ctx.dup)
          #--- END PATCH -------------------------------------------------------
        end
        v.to_s
      compiled
    end

    # Override to call the helper method with arguments given to the tag.
    #
    # on_etag([:mustache, :fetch, "foo"]) => render(foo())
    # on_etag([:mustache, :fetch, "foo"], "bar", "baz quux") => render(foo("bar, "baz quux"))
    #
    def on_etag(name, *args)
      args_as_str = args.map(&:inspect).join(", ")
      ev(<<-compiled)
        v = #{compile!(name)}
        if v.is_a?(Proc)
          #--- START PATCH -----------------------------------------------------
          v = Mustache::Template.new(v.call(#{args_as_str}).to_s).render(ctx.dup)
          #--- END PATCH -------------------------------------------------------
        end
        ctx.escapeHTML(v.to_s)
      compiled
    end
  end

  class Context
    # Override so that if the tag refers to a method or proc on the context,
    # call it with the args given to the tag.
    #
    def find(obj, key, default = nil)
      hash = obj.respond_to?(:has_key?)

      if hash && obj.has_key?(key)
        obj[key]
      elsif hash && obj.has_key?(key.to_s)
        obj[key.to_s]
      elsif !hash && obj.respond_to?(key)
        meth = obj.method(key) rescue proc { obj.send(key) }
      #--- START PATCH ---------------------------------------------------------
        if meth.arity == 0
          meth[]
        else
          meth.to_proc
        end
      #--- END PATCH -----------------------------------------------------------
      else
        default
      end
    end
  end
end
