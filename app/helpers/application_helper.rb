module ApplicationHelper
  def flash_notice
    notice = ''
    if flash[:now]
      notice = flash[:now]
      flash[:now] = nil
    end
    if flash[:notice]
      notice += ' ' + flash[:notice]
    end
    unless notice.empty?
      content_tag('div', h(notice), {id: "flash_notice"})
    end
  end

  def body_id
    request.host.gsub!('.','-')
  end

  def body_class
    controller_name == 'pages' && action_name == 'show' ? @page.slug : ''
  end

  def truncate(string, length)
    if string.length > length * 1.1
      string[0,length].rstrip + '...'
    else
      string
    end
  end

  def clear
    content_tag('p', '&nbsp;'.html_safe, {class: 'clear'})
  end
  
  def a_tick
    '<span class="tick">✔</span>'.html_safe
  end
  
  def a_cross
    '<span class="cross">✘</span>'.html_safe
  end
  
  def tick_cross yes, show_cross=true
    if yes
      a_tick
    elsif show_cross
      a_cross
    end
  end
  
  def tick yes
    tick_cross yes, false
  end

  def nav_link_to page, options = {}, html_options = nil, class_name = ''
    name = page.is_a?(String) ? page : page.name
    class_name = 'n_' + name.downcase.gsub(' ', '_').gsub('&amp;', 'and') if class_name.empty?
    if current_page? options
      class_name += ' n_current'
      content_tag(:li, h(name) + sub_nav(page), class: class_name)
    else
      content_tag(:li, link_to(name, options, html_options) + sub_nav(page), class: class_name)
    end
  end

  def sub_nav page
    sn = ''.html_safe
    if(page.is_a?(Page) && page.children.count > 0)
      page.children.each {|c| sn += content_tag(:li, link_to(c.name, c.path))}
      sn = content_tag(:ul, sn)
    end
    sn
  end

  def format_date d
    if (Time.now - d) < 2.minutes
      'Just a moment ago'
    elsif (Time.now - d) < 1.hours
      ((Time.now - d)/60).ceil.to_s + ' minutes ago'
    elsif d.today?
      'Today at ' + d.strftime("%l:%M%p").downcase
    elsif (d+1.day).today?
      'Yesterday at ' + d.strftime("%l:%M%p").downcase
    elsif (Time.now - d) < 1.week
      d.strftime('%A at ') + d.strftime("%l:%M%p").downcase
    elsif d.year == Time.now.year
      d.strftime("%e %b at ") + d.strftime("%l:%M%p").downcase
    else
      d.strftime("%e %b %Y at ") + d.strftime("%l:%M%p").downcase
    end
  end

  def template(name, args = {})
    lt = LiquidTemplate.find_by(name: name, website_id: @w.id)
    if lt
      raw Liquid::Template.parse(lt.markup).render(args.stringify_keys!)
    else
      begin
        render partial: "default_templates/#{name}", locals: args
      rescue ActionView::MissingTemplate
        raw LiquidTemplate.new_called(name, @w.id).markup
      end
    end
  end

  # Returns <tt>true</tt> if the current page is the home page.
  def home_page?
    '/' == request.path
  end

  # Creates a robots meta tag.
  #
  # ==== Options
  # * <tt>:index</tt> - Robots should index this page.
  # * <tt>:follow</tt> - Robots should follow links from this page.
  def robots_meta_tag(options = {})
    options.reverse_merge! index: true, follow: true
    values = []
    values << (options[:index]  ? 'index'  : 'noindex')
    values << (options[:follow] ? 'follow' : 'nofollow')
    tag(:meta, {name: 'robots', content: values.join(', ')})
  end
end
