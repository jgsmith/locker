xml.instruct!
xml.feed :xmlns => 'http://www.w3.org/2005/Atom' do |feed|
  feed.title("#{@filter.size} Most Recent Uploads in #{@filter.name}")
  feed.link "rel" => "self", "href" => upload_filter_url(@filter) + '.atom'
  feed.id upload_filter_url(@filter)+'.atom'
  feed.updated(@files.first.created_at.strftime("%Y-%m-%dT%H:%M:%SZ"))

  @files.each do |file|
    feed.entry do |entry|
      entry.title(file.display_name)
      entry.link(upload_url(file))
      entry.id(upload_url(file))
      entry.content(markdown(file.description), :type => 'html')
      entry.updated(file.created_at.strftime("%Y-%m-%dT%H:%M:%SZ"))
      entry.author do |author|
        author.name(file.user.login)
      end
    end
  end
end
