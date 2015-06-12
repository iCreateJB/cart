module Filter
  def javascript
    parse('//script/@src')
  end

  def stylesheets
    parse('//link/@href')
      .reject(&method(:style))
  end

  def page
    # Filter social media
    # Filter subdomains
    # Expand relative URLs
    parse('//a/@href')
      .reject(&method(:social))
      .reject(&method(:subdomain))
  end

private
  def parse(elem)
    source.xpath(elem)
      .map(&:text)
      .reject(&:empty?)
  end

  def style(x)
    !x.match('(css|sass|less)')
  end

  def source(x)
    !x.match('(js|coffee)')
  end

  def social(x)
    URI.parse(x).host.match('(facebook|instagram|twitter)') unless URI.parse(x).host.nil?
  end

  def relative(x)
    URI.parse(x).host.nil?
  end

  def subdomain(x)
    if !URI.parse(x).host.nil?
      URI.parse(x).host.sub(/www./,'').scan('.').count > 1
    end
  end
end
